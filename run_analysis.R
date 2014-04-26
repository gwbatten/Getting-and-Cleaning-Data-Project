setwd("C:\\Users\\George\\R\\GetCleanData\\Getting-and-Cleaning-Data-Project")

#download zip file of data and unzip
        dirURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles
                %2FUCI%20HAR%20Dataset.zip"
        temp <- tempfile()
        download.file(dirURL, temp)
        unzip(temp)  #places the unzipped directory in the working directory
        unlink(temp) #deletes the zip file

###############################################################
### 1. Merge training and test sets to create one data set. ###
###############################################################

#load train_X and train_y and column bind 
        trainX <- read.table("./UCI HAR Dataset/train/X_train.txt")
        trainY <- read.table("./UCI HAR Dataset/train/y_train.txt")
        train <- cbind(trainX,trainY)

#download feature file, extract names, add "activity", apply to train data.frame
        features <- read.table("./UCI HAR Dataset/features.txt")
        columnames <- as.vector(features[,2])
        columnames[562] <- "activity" 
        colnames(train) <- columnames

#load test_X and test_y and column bind 
        testX <- read.table("./UCI HAR Dataset/test/X_test.txt")
        testY <- read.table("./UCI HAR Dataset/test/y_test.txt")
        test <- cbind(testX,testY)

#label columns of test data.frame 
        colnames(test) <- columnames

#join train and test data.frames 
        allData <- rbind(train,test)

####################################################################
### 2.Extract measurements on mean and std for each measurement. ###
####################################################################

        columns <- grepl("[Mm]ean|std", as.character(features[,2]))
        allData <- allData[,columns]

##################################################################
### 3 and 4. Use descriptive activity names and label data set ###
##################################################################

        allData[allData$activity == 1, 87] <- "walking"
        allData[allData$activity == 2, 87] <- "walking_upstairs"
        allData[allData$activity == 3, 87] <- "walking_downstairs"
        allData[allData$activity == 4, 87] <- "sitting"
        allData[allData$activity == 5, 87] <- "standing"
        allData[allData$activity == 6, 87] <- "laying"

#add subject column to dataset and name column
        subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
        subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
        subjectAll <- rbind(subjectTrain,subjectTest)
        allData <- cbind(subjectAll,allData)
        colnames(allData)[1] = "subject"

######################################################################
### 5. Create a second, independent tidy data set with the average ###
###    of each variable for each activity and each subject.        ###
######################################################################

#sort dataset into subjects and activity
        allData <- allData[order(allData$subject, allData$activity),]

#use package plyr to create table of means
        library(plyr)
        attach(allData)

#create table with 3 columns: subject, activity, and mean of first data column
        tidy <- ddply(allData, c("subject","activity"), function(df)mean(df[,2]))

#add means of the remaining columns
        for (i in 3:87){
                temp <- ddply(allData, c("subject","activity"), 
                              function(df)mean(df[,i]))
                tidy <- cbind(tidy, temp[,3])
        }

        detach(allData)

#add names to columns of means (first 2 columns named by plyr ("subject" and "activity"))
        columnames <- names(allData)[2:87]
        colnames(tidy)[3:88] <- columnames

        write.csv(tidy, "./tidy.csv")




