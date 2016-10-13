# paprbag
**Pa**thogenicity **pr**ediction for **ba**cterial **g**enomes is a random forest based method for the assessment of the pathogenic potential of a set of reads belonging to a single genome.
Its strength lies in the prediction of novel, unknown bacterial pathogens.

***

## Install
```r
# install.packages("devtools")
devtools::install_github("crarlus/paprbag")

```

Note that due to changes in base::capabilities() for R >= 3.2, installing the package via devtools (version 1.12.0) and R (version <= 3.1) might throw an error
```
Installing paprbag
Error in if (capabilities("libcurl")) { : argument is of length zero
```
This issue has been addressed in [https://github.com/hadley/devtools/issues/1244]. Until it is fixed, either use an older version of devtools (<= 1.10) or install the package manually from source.


_(Installation might require some time due to the package's dependencies)_

***

## Label data
The resource of the inferred pathogenicity labels can be found in [labels](https://github.com/crarlus/paprbag/tree/master/labels)

The label data together with the strain's Bioproject accession can be accessed by `data("Labels")`

***

## More data
Large classifiers trained on the present data are provided in the R package [data4paprbag](https://github.com/crarlus/data4paprbag).


***

## Basic usage


### Make prediction from read set

```R
library(paprbag)
library(ranger) # load ranger package explicitly


data("ReadData")
# Or read in sequence data via Biostrings::readDNAStringSet()

Prediction <- Predict.ReadSet (ForestObject = forest, ReadObject = ReadData, Feature.Configuration = NULL, verbose = T)
```

#### Quick analysis
```R
# Histogram of pathogenic potential
hist(Prediction$predictions[,"TRUE"])

# Mean pathogenic potential
mean(Prediction$predictions[,"TRUE"])
```

#### Operate prediction via file paths
``` R
Predict.ReadSet.fromFiles (Path2Forest = Path2Forest, Path2ReadFiles = Path2ReadFiles, saveLocation = saveLocation, OutputFilename = OutputFilename, Return.Predictions = F, Save.AsTSV = F, verbose = T, num.threads = 1)

```

___

### Feature extraction
Extract features from a set of reads
```R
data("ReadData")
# Or read in sequence data via Biostrings::readDNAStringSet()

Features <- CreateFeaturesFromReads(Reads=ReadData, NT_kmax = 4, Do.NTMotifs = T)
```

___

### Create features for all fasta files in a given directory
```R
  data("Standard.configuration") # load standard configuration
  Standard.configuration$Path2ReadFiles <- Path2ReadFiles # add path to Read files
  Standard.configuration$savePath <- "Features" # add save path

  do.call(UpdateFeatures,Standard.configuration)


  # or
  UpdateFeatures (Path2ReadFiles = Path2ReadFiles,savePath = file.path(Path2ReadFiles,"Features") ,Cores = 5, verbose = T)
```

___
### Create training set
Join all feature files in a directory and create read labels for every data row by matching to bioproject accessions.
```R
 #Labels: A vector containing either 'TRUE' or 'FALSE' together with the name attributes pointing to the Organism identifier (Bioproject ID)
  data("Labels")
  
 Create.TrainingDataSet (Path2Files = "Features", pattern="Features",OSlabels = Labels, savePath = "TrainingData")

  # patterns: Regex-Pattern that identifies the feature files

```
___
### Training

Train a pathogenicity classifier from a set of feature data together with read label information


```R
# Please specify paths:
# Path2FeatureFile:  path to combined label and feature file (in rds format)
# savePath: path where trained classifier is saved

# example path
Tempdir <- tempdir()
data("trainingData")
saveRDS(trainingData,file.path(Tempdir,"trainingData.rds"))
Path2FeatureFile <- file.path(Tempdir,"trainingData.rds")
savePath <- file.path(Tempdir,"classifier")

# Run with path information
Run.Training (Path2FeatureFile = Path2FeatureFile, savePath = savePath)

```

#### More options
```R
# Specify
# Path2FeatureFile: Path to feature data only
# Path2LabelFile: Path to label file with labels for every data row in 'Path2FeatureFile'

forest <- Run.Training (Path2FeatureFile = Path2FeatureFile, Path2LabelFile = Path2LabelFile, SelectedFeatures = NULL, savePath = NULL, ReturnForest = T, verbose = T, min.node.size = 1, num.trees = 100)

```

#### Training a classifier with other types of label data
As mentioned in the original publication, PaPrBaG is not restricted for classification of pathogens only. 

> It is rather a general workflow for the classification of labeled genomes, potential further applications range from
bacterial host and habitat prediction, taxonomic classification to human and microbial read separation

Basically the same workflows as described here can be applied and also the features need not be re-calculated. It suffices to 
- either provide a new path to a label file _Path2NewLabelFile_ with labels for every data row in _Path2FeatureFile_
```R
Run.Training (Path2FeatureFile = Path2FeatureFile, Path2LabelFile = Path2NewLabelFile, savePath = NewsavePath)
```
- or manipulate the column "Labels" in the data.frame "Path2FeatureFile". E.g.
```
trainingData$Labels <- as.factor(c(rep("NewLabel_A",floor(nrow(trainingData)/2)),rep("NewLabel_B",ceiling(floor(nrow(trainingData)/2)) )) )
saveRDS(trainingData, NewPath2FeatureFile) # save 
Run.Training (Path2FeatureFile = NewPath2FeatureFile, savePath = NewsavePath)
```

In case that read labels are not yet available, a new training set based on the new labels can be obtained via the command
```R
Create.TrainingDataSet (Path2Files = "Features", pattern="Features",OSlabels = NewLabels, savePath = "TrainingData")
```
A proper vector _NewLabels_ containing two (or more) labels (e.g. 'TRUE' or 'FALSE') together with the name attributes pointing to the Organism identifier (Bioproject ID) is required.
It outputs a file "ReadLabel_OS.rds" in the _savePath_ which can be used for running the function _Run.Training_ subsequently.

Predictions obtained from the newly trained classifier provide classification according to the new label.

