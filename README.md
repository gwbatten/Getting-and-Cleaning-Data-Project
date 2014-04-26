##Getting-and-Cleaning-Data-Project
Peer reviewed project for Getting and Cleaning Data class (Coursera) Spring 2014.

I started this program with a script that downloads the zip file of the data, unzips it and places 
it in a directory.  

```{r}
dirURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles
                %2FUCI%20HAR%20Dataset.zip"
        temp <- tempfile()
        download.file(dirURL, temp)
        unzip(temp)  
        unlink(temp) 
```
If you already have the data directory, you can comment these lines out (place
'#' in front of them), before you run the program.

I heavily commented my program to make it (hopefully) easy to follow, so I will not
go through every step in this READ ME document.  Here are the steps I took:

1. Load the training data and training activity data and column bind them together
2. Read the feature names and use to label the columns of the training data/activity df.
3. Repeat process for the test data.
4. Combine the train and test df's together.
5. Create a logical vector by searching the features df for mean and std.  Use this vector
to subset the train/test df.
6. Label "activity" column with descriptive names ("walking", "laying", etc.).
7. Add a column for subjects.  Order df by subjects and activity.
8. Use plyr to create table of means.
9. Write csv of resulting table.

When using plyr, I ran ddply once organized by "subject" and "activity" and taking the mean
of the first column of data.  This produced a 3 column data frame with "subject" and "activity"
being the first 2 columns.  Next I used ddply (in a loop) on all of the remaining columns, each
time column binding the third column to the first ddply df. 

```{r}
#create table with 3 columns: subject, activity, and mean of first data column
        tidy <- ddply(allData, c("subject","activity"), function(df)mean(df[,2]))

#add means of the remaining columns
        for (i in 3:87){
                temp <- ddply(allData, c("subject","activity"), 
                              function(df)mean(df[,i]))
                tidy <- cbind(tidy, temp[,3])
        }

        detach(allData)
```
Plyr does not retain the column names so I added those to the final df.
