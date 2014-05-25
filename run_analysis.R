run_analysis<-function(){
  ##Install packages and add to library
  ##install.packages("plyr")
  library(plyr)
  
  ##Set working directory
  setwd("/Users/danliebermann/Documents/Coursera/G&C Data/Course Project")
  
  ## Read in all files
  xTest<-read.table("UCI HAR Dataset-2/test/X_test.txt")
  yTest<-read.table("UCI HAR Dataset-2/test/y_test.txt")
  subjectTest<-read.table("UCI HAR Dataset-2/test/subject_test.txt")
  xTrain<-read.table("UCI HAR Dataset-2/train/X_train.txt")
  yTrain<-read.table("UCI HAR Dataset-2/train/y_train.txt")
  subjectTrain<-read.table("UCI HAR Dataset-2/train/subject_train.txt")
  activityLabels<-read.table("UCI HAR Dataset-2/activity_labels.txt")
  features<-read.table("UCI HAR Dataset-2/features.txt")
  
  ###############COMBINE TABLES AND ADD ACTIVITY NAMES###############
  ##Transpose features table, add columns for additional rows, and combine
  tFeatures<-t(features)
  m<-matrix(c(562, "Subject", 563, "Activity"), ncol=2, nrow=2)
  finalFeatures<-cbind(tFeatures,m)
  finalFeatures<-as.data.frame(finalFeatures)
  ##Extract a character vector of names
  finalFeatures<-as.vector(sapply(finalFeatures[2,],FUN=as.character))
  
  ##Add activity data labels
  colnames(activityLabels)<-c("Activity", "Activity Description")
  
  ##Combine files
  fullTrain<-cbind(xTrain,subjectTrain,yTrain)
  fullTest<-cbind(xTest,subjectTest,yTest)
  fullData<-rbind(fullTrain, fullTest)
  ##Add column names
  colnames(fullData)<-finalFeatures
  ##Label activities
  fullData<-join(fullData, activityLabels, by ="Activity")
  
  #########EXTRACT MEAN AND STD COLUMNS################
  
  ##Return column names for means and standard deviations
  meanCols<-grep("mean", colnames(fullData))
  stdCols<-grep("std", colnames(fullData))
  ##Create a vector for mean and std-related columns as well as the subject and activity columns
  interestedColumns<-c(meanCols,stdCols, 562:564)
  ##Create a new data frame with only mean, std, subject, and activity data
  interestedData<-subset(fullData,select = interestedColumns)
  
  #########CREATE TIDY DATASET################
  ##For each column calculate the average for each activity/subject combination and save to a new data frame
  
  ##Create a variable "k" to iterate through columns
  k<-1
  ##Create the Subject and Activity columns of the tidy dataframe, and the first column of means
  while(k==1){
    tidyStart<-ddply(interestedData, .(Subject, Activity), summarize, newCol = mean(interestedData[,k]))
    tidyData<-tidyStart
    k<-k+1
  }
  ##Create subsequent columns of means and bind them to the existing data frame
  while(k>1 & k<=79){
    tidyCol<-ddply(interestedData, .(Subject, Activity), summarize, newCol = mean(interestedData[,k]))
    tidyData<-cbind(tidyData,tidyCol[,3])
    k<-k+1  
  }
  ##Add column names to the dataframe
  names(tidyData)<-c("Subject", "Activity", names(interestedData[1:79]))
  ##Re-label activities
  tidyData<-join(tidyData, activityLabels, by ="Activity")
  ##Change variable and activity names to be more readable and fit tidy principles
  names(tidyData)<-tolower(names(tidyData))
  names(tidyData)<-gsub(" ","",names(tidyData))
  names(tidyData)<-gsub("\\()","",names(tidyData))
  tidyData[,82]<-tolower(tidyData[,82])
  ##Write data to file 
  write.csv(tidyData, "Tidy Data")
  ##########TIDY DATASET COMPLETE###########
}