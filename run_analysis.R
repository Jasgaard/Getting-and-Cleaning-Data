# The Purpose of this script is taken from the Course Porject Assignment and is listed directly below:
#
# Create one R script called run_analysis.R that does the following:
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive activity names.
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#
# Requirements that has to be met in order top be able to run the R script:
# 1.Package "data.table" needs to be installed
# 2.Package "reshape2" needs to be installed
# 3.The data for the project needs to be downloaded and unzipped in the working directory

# Whenever possible or meaningful variable names in the script has been named after data source names

# Read "activity labels" from data set
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Read "features" from data set
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
extract_mean_standard_deviation <- grepl("mean|std", features)

# Read X_train, y_train and subject_train data.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(X_train) = features

# Extract mean and standard deviation from x_train data.
X_train = X_train[,extract_mean_standard_deviation]

# Load activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Bind data from x_train and y_train into train_data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Load and process X_test & y_test data.
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
names(X_test) = features

# Extract mean and standard deviation from x_test data.
X_test = X_test[,extract_mean_standard_deviation]

# Load "activity labels" from y_test
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Bind data from x_test and y_test into test_data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Merge test_data and train_data
data = rbind(test_data, train_data)
id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to "data" using dcast function. Create a new variable tidy_data.txt.
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)
write.table(tidy_data, file = "./tidy_data.txt", row.names = FALSE)