require(plyr)

#Get data
datadir<-file.path(getwd(),"UCI HAR Dataset")

datadirtest<-file.path(datadir, "test")
datadirtrain<-file.path(datadir, "train")
  
xtest<-read.table(file.path(datadirtest,"X_test.txt"))
ytest<-read.table(file.path(datadirtest,"Y_test.txt"))
subjecttest<-read.table(file.path(datadirtest,"subject_test.txt"))

xtrain<-read.table(file.path(datadirtrain,"X_train.txt"))
ytrain<-read.table(file.path(datadirtrain,"Y_train.txt"))
subjecttrain<-read.table(file.path(datadirtrain,"subject_train.txt"))

#Get activity labels 
activitylabels<-read.table(file.path(datadir,
                              			"activity_labels.txt"),
                            col.names = c("Id", "Activity")
                            )

#Get features labels
featurelabels<-read.table(file.path(datadir,
                            		"features.txt"),
                            colClasses = c("character")
                           	)

#1.Merges the training and the test sets to create one data set.
traindata<-cbind(cbind(xtrain, subjecttrain), ytrain)
testdata<-cbind(cbind(xtest, subjecttest), ytest)
sensordata<-rbind(traindata, testdata)

sensorlabels<-rbind(rbind(featurelabels, c(562, "Subject")), c(563, "Id"))[,2]
names(sensordata)<-sensorlabels

#2. Extracts only the measurements on the mean and standard deviation for each measurement.
means <- sensordata[,grepl("mean\\(\\)|std\\(\\)|Subject|Id", names(sensordata))]

#3. Uses descriptive activity names to name the activities in the data set
means <- join(means, activitylabels, by = "Id", match = "first")
means <- means[,-1]

#4. Appropriately labels the data set with descriptive names.
names(means) <- gsub("([()])","",names(means))
#norm names
names(means) <- make.names(names(means))

#5. From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject 
output_data<-ddply(means, c("Subject","Activity"), numcolwise(mean))
#improve column names
headers<-names(output_data)
names(output_data)<-headers

write.table(output_data, file = "data_avgs.txt", row.name=FALSE)
