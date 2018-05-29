# paprbag
**Pa**thogenicity **pr**ediction for **ba**cterial **g**enomes is a random forest based method for the assessment of the pathogenic potential of a set of reads belonging to a single genome.
Its strength lies in the prediction of novel, unknown bacterial pathogens.

The related paper is available at https://www.nature.com/articles/srep39194

*** News

* New forestes were trained with a new version of ranger and are available in the [release](https://github.com/crarlus/paprbag/releases/tag/2.0)
* The new section [Predicting real data](#Predicting-real-data)


***

## Install
```r
# install.packages("devtools")
devtools::install_github("crarlus/paprbag")

```
_(Installation might require some time due to the package's dependencies)_

Due to changes of the dependencies, some problems occurred when installing paprbag and using the original data. In particular, different ranger versions are not compatible. Since the original data were trained with ranger 0.3 they can only be used when the same ranger version is installed on your system.

The original version of paprbag is still available under the [legacy](https://github.com/crarlus/paprbag/tree/legacy) branch.

The data made available in this branch, as well as the release data, should work with recent ranger versions. 


For full reproducibility, the packages used for building the data sets are provided as a packrat bundle. The bundle can be downloaded from the [release](https://github.com/crarlus/paprbag/releases/tag/2.0)

They can be installed via
```R
# Download the bundle
path2bundle <- "/path/to/bundle/" 
packrat::unbundle(bundle=path2bundle, where="/path/to/my/project")
```
See [here](https://rstudio.github.io/packrat/) and [here](https://www.r-bloggers.com/creating-reproducible-software-environments-with-packrat/) for more details about packrat.

The packages versions are also listed [here](https://github.com/crarlus/paprbag/releases/download/2.0/packrat.lock). They were installed under R version 3.4.4.

***

## Label data
The resource of the inferred pathogenicity labels can be found in [labels](https://github.com/crarlus/paprbag/tree/master/labels)

The label data together with the strain's Bioproject accession can be accessed by `data("Labels")`

***

## Original data
The large classifiers used in the publication are provided in the R package [data4paprbag](https://github.com/crarlus/data4paprbag). They were trained with ranger version 0.3. 
Current data is available in the (release tab)[link]


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

## Predicting real data
In this section, we describe how paprbag can be applied to real data based on the pre-trained forests located in the release.

### Available data

The following forests are available in the release tab:
* [classifier_all.rds](https://github.com/crarlus/paprbag/releases/download/2.0/classifier_all.rds): Classifier that was trained on all data described in paprbag; only nucleotide features (faster)
* [classifier_all_includingPeptideFeatures.rds](https://github.com/crarlus/paprbag/releases/download/2.0/classifier_all_includingPeptideFeatures.rds): Classifier that was trained on all data described in paprbag; including peptide features (slower)

Furthermore, the forests related to the 5-fold cross validation in (paprbag)[link] can be found here:
* [classifier_fold1.rds](https://github.com/crarlus/paprbag/releases/download/2.0/classifier_fold1.rds): Classifier based on training fold 1
* [classifier_fold2.rds](https://github.com/crarlus/paprbag/releases/download/2.0/classifier_fold2.rds): Classifier based on training fold 2
* [classifier_fold3.rds](https://github.com/crarlus/paprbag/releases/download/2.0/classifier_fold3.rds): Classifier based on training fold 3
* [classifier_fold4.rds](https://github.com/crarlus/paprbag/releases/download/2.0/classifier_fold4.rds): Classifier based on training fold 4
* [classifier_fold5.rds](https://github.com/crarlus/paprbag/releases/download/2.0/classifier_fold5.rds): Classifier based on training fold 5

``` R
library(paprbag)
library(ranger)

# download forest from release
# use wget 
# OR
# use R

# define forest
Path2Forest <- file.path(forestDir_nuc,"all","randomForest.rds")
Path2Forest <- path/to/forest # define your path

# define prediction data
Path2ReadFiles <- path/to/independent_test_data_in_fasta_format

# define output
OutputFilename <- "prediction_paprbag"
saveLocation <- "Predictions/example"

Predictions_paprbag <- Predict.ReadSet.fromFiles (Path2Forest = Path2Forest, Path2ReadFiles = Path2ReadFiles, saveLocation = saveLocation, OutputFilename = OutputFilename, Return.Predictions = T, Save.AsTSV = F, num.threads = 20, verbose = T)
```
### alternative: loading forest and read data into R
* Use case: Avoids re-loading of large forests when predicting many fasta files

``` R

library(paprbag)
library(ranger)

# download forest from release

# load forest
forest_large <- readRDS(file.path(forest_nuc))

# read file
Readfile <- Readfiles[1]
ReadData_real <- Biostrings::readDNAStringSet(Readfile)

# predict
Prediction_forest_nuc_realdata <- Predict.ReadSet (ForestObject = forest_large <- , ReadObject = ReadData_real, Feature.Configuration = NULL, verbose = T, num.threads = 20)
```
* note: the prediction function can be called with a number of threads via the num.threads option, however it still predicts read per read in a linear fashion. If a number of cores is available, the prediction process can be sped up by diving the reads in read chunks and joining the prediction results. Aka _Embarrassingly parallel problem_.


### Quick evaluation

``` R
hist(Prediction_forest_nuc_realdata$predictions[,2])
mean(Prediction_forest_nuc_realdata$predictions[,2])

ifelse(mean(Prediction_forest_nuc_realdata$predictions[,2])> 0.5, "Pathogenic", "Non-Pathogenic")

```



### Feature configuration


You can pass a value of `Feature.Configuration` in function `Predict.ReadSet`. Choose between:

```R
# load standard configuration; used in toy forest and classifier_all.rds, classifier_fold1.rds, etc.
data("Standard.configuration") 
# load standard configuration including peptide features; used in forest classifier_all_includingPeptideFeatures.rds
data("Standard.configuration_peptides") 
# infer feature configuration directly from forest
my.configuration <- paprbag:::IdentifyFeatures.FromForest(ForestObject = forest_new)
```
And set e.g. `Feature.Configuration = Standard.configuration`






___
## Advanced usage 

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

