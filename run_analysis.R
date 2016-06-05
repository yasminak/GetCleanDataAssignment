# download and unzip file
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/projectfiles.zip", method = "curl")
unzip("./data/projectfiles.zip", exdir = "./data/")

# get training and tests data
trainSet <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
trainLabels <- read.table("./data/UCI HAR Dataset/train/y_train.txt", col.names = "ActivityNum")
testSet <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
testLabels <- read.table("./data/UCI HAR Dataset/test/y_test.txt", col.names = "ActivityNum")
trainSubject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", col.names = "SubjectNum")
testSubject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", col.names = "SubjectNum")

# get all features 
allFeatures <- read.table("./data/UCI HAR Dataset/features.txt")

# get activites
activities <- read.table("./data/UCI HAR Dataset/activity_labels.txt", col.names = c("ActivityNum", "Activity"))

# Merge the training and the test sets to create one data set
subjects <- rbind(trainSubject,testSubject)
sets <- rbind(trainSet, testSet)
names(sets) <- allFeatures$V2

# Use descriptive activity names to name the activities in the data set
labels <- merge(rbind(trainLabels, testLabels), activities, by = "ActivityNum")

# combine all data
dat <- cbind(subjects, labels, sets)

# Extract only the measurements on the mean and standard deviation for each measurement
features <- as.vector(allFeatures[grepl("\\<mean\\>|std", allFeatures$V2),]$V2)
datExtract <- subset(dat, select = c("SubjectNum","Activity",features))

# Appropriately label the data set with descriptive variable names
datExtract$Activity <- tolower(datExtract$Activity)
datExtract$Activity <- gsub("_", "", datExtract$Activity)
names(datExtract) <- sub("()", "", names(datExtract), fixed = TRUE)
names(datExtract) <- sub("^t", "time", names(datExtract))
names(datExtract) <- sub("^f", "frequency", names(datExtract))
names(datExtract) <- sub("Acc", "Accelerometer", names(datExtract))
names(datExtract) <- sub("Mag", "Magnitude", names(datExtract))
names(datExtract) <- sub("Gyro", "Gyroscope", names(datExtract))

# create a second, independent tidy data set with the average of each variable for each activity and each subject
library(data.table)
dat2nd <- data.table(datExtract)
finaldat <- dat2nd[, lapply(.SD,mean), by = c("SubjectNum","Activity")]
write.table(finaldat, "./data/tidydata.txt")

# create code book
library(memisc)
Write(codebook(finaldat), file = "./data/CodeBook.md")