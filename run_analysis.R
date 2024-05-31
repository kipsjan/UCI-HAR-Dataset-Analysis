# The run_analysis.R script is in partial fulfillment of the Course Project 
# for the Coursera "Getting and Cleaning Data" course.
#
# The script downloads the Human Activity Recognition dataset, tidies 
# it up, and performs various required data manipulations and summaries.



# 0. Preparatory steps
# -------------------------
# install.packages("dplyr")
# Create dir
if (!file.exists("./Data")) 
{
    message("Creating data directory")
    dir.create("./Data")
}

# Download dataset
if (!file.exists("./Data/UCI_HAR_Dataset.zip")) 
{
    message("Downloading dataset")
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
                  destfile = "./Data/UCI_HAR_Dataset.zip", 
                  method = "auto",
                  mode = "wb")
}

# unzip dataset
if (!file.exists("./Data/UCI HAR Dataset")) 
{
    message("Extracting dataset")
    unzip("./Data/UCI_HAR_Dataset.zip", 
          overwrite = FALSE, 
          exdir = "./Data")
}

# 1. Merge the training and the test sets to create one data set
# -------------------------------------------------------------
# load TRAIN data
# structure of the TRAIN dataset will be subject_train | y_train | x_train
# load subject_train data
subject_train <- tibble::as_tibble(read.table("./Data/UCI HAR Dataset/train/subject_train.txt",col.names = c("Subject ID")))
# load x_train data
x_train <- tibble::as_tibble(read.table("./Data/UCI HAR Dataset/train/X_train.txt"))
features <- tibble::as_tibble(read.table("./Data/UCI HAR Dataset/features.txt",col.names = c("Id", "Feature")))
#give x_train columns meaningful names
colnames(x_train)<-features$Feature
#load y_train data
y_train <- tibble::as_tibble(read.table("./Data/UCI HAR Dataset/train/y_train.txt",col.names="Activity"))
#coerce train data
train<-cbind(subject_train,y_train,x_train)

# load TEST data
# structure of the TEST dataset will be subject_test | y_test | x_test
# load subject_test data
subject_test <- tibble::as_tibble(read.table("./Data/UCI HAR Dataset/test/subject_test.txt",col.names = c("Subject ID")))
# load x_test data
x_test <- tibble::as_tibble(read.table("./Data/UCI HAR Dataset/test/X_test.txt"))
#give x_test columns meaningful names
colnames(x_test)<-features$Feature
#load y_test data
y_test <- tibble::as_tibble(read.table("./Data/UCI HAR Dataset/test/y_test.txt",col.names="Activity"))
#coerce test data
test<-cbind(subject_test,y_test,x_test)

# combine TRAIN and TEST datasets into combined dataset COMBO
# first add a 'Type' to each dataset (TRAIN/TEST)
# mutate(train,Type2='TRAIN')
data <-rbind(train,test)

# 2. Extract only the measurements on the mean and standard deviation for each measurement                                 
#----------------------------------------------------------------------------------------

mean_std_data<-select(data,contains("Subject")|contains("Activity")|contains("mean()")|contains("std()"))

# 3. Use descriptive activity names to name the activities in the data set                                 
#----------------------------------------------------------------------------------------

readable_names <- colnames(mean_std_data)
readable_names<-gsub("^t","Total",readable_names)
readable_names<-gsub("Acc","Acceleration",readable_names)
readable_names<-gsub("Freq","Frequency",readable_names)
readable_names<-gsub("^f","Frequency",readable_names)
readable_names<-gsub("BodyBody","Body",readable_names)  
# readable_names<-gsub("mean\\(\\)","mean",readable_names) 
# readable_names<-gsub("std\\(\\)","std",readable_names)
# readable_names<-gsub("max\\(\\)","max",readable_names)  
#  t<-select(xtrain,filter(features2, IsMean == TRUE))


# 4. Appropriately label the data set with descriptive variable names. 
#---------------------------------------------------------------
colnames(mean_std_data)<-readable_names



#5. create a second, independent tidy data set with the average of each variable for each activity and each subject
#-------------------------------------------------------------------
tidy_data<-summarise_each(group_by(mean_std_data,Subject.ID, Activity), funs(mean))
write.table(tidy_data, file="tidy_data.txt", row.name=FALSE)
