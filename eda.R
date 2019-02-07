df <- read.csv('Desktop/misc/Data_Analysis_Exercise/Data Analysis Exercise/trainingData.csv')
View(df)

nrow(df) # number of columns 
ncol(df) # number of rows 

length(unique(df$city)) # checking number of unique cities 
df$Id <- NULL # deleting Id columns from data
df$city <- NULL # deleting city column from data 

# There were some blank spaces in city which are converetd to NA values. 
df[df==""] <- NA
str(df) # qualitative details about each column
colMeans(is.na(df)) * 100 # percent of missing values in each column. 

# Fortunately not a lot of data is missing!  

sapply(df, class)
library(corrplot)

M <- cor(df[sapply(df, function(x) !is.factor(x))], use = "complete.obs")
corrplot(M)
# No multicollinearity as such. 

summary(na.omit(df[sapply(df, function(x) !is.factor(x))])) # summary of numeric columns 
boxplot( na.omit(df[sapply(df, function(x) !is.factor(x))]))
# There are many outliers in variables like monthly_expenses, annual_income and others which is understandable. 

# Let's look at each column separately 

##### Age #####
summary(df$age)
boxplot(df$age)

# Age has an outlier that does not make any sense 
df[df$age > 100,] # age of 766105 does not make sense! 
df$age[df$age > 100] = median(df$age[df$age < 100]) # imputing that value to the mean of age. 
plot(df$age) # there is someone two years old
# the upper end seems fixed but highly unlikely that a two year old took a loan!
df$age[df$age < 10] <- median(df$age[df$age >10])
plot(df$age)
boxplot(df$age)
hist(df$age, xlab = "Age", main = "")
###### ###### 

##### Annual Income ##### 
summary(df$annual_income)
boxplot(df$annual_income)
df[df$annual_income < 50,] # a lot of places where annual income is zero
hist(df$annual_income, breaks = 20)
df$annual_income[df$annual_income < 50] <- mean(df$annual_income[df$annual_income > 50])
##### ###### 

##### Monthly expenses ##### 
summary(df$monthly_expenses)
# Monthly expenses have a minimum of 2! Let's investigate 
# First we impute the missing values to the mean of expenses. 
df$monthly_expenses[is.na(df$monthly_expenses)] <- mean(df$monthly_expenses, na.rm = TRUE)
# We make the assumption that the monthly expense cannot go below 100. Though it is still low value but we take a threshold fot the time being. 
df[df$monthly_expenses < 100,] 
df$monthly_expenses[df$monthly_expenses < 100] <- mean(df$monthly_expenses[df$monthly_expenses > 100])
summary(df$monthly_expenses)
hist(df$monthly_expenses)
##### ##### 

par(mfrow=c(1,2))
barplot(table(df$old_dependents), main = "Old Dependents")
barplot(table(df$young_dependents), main = "Young Dependents")
par(mfrow=c(1,1))

##### Occupant Count #####
summary(df$occupants_count) 
nrow(df[df$occupants_count > 20,])
df$occupants_count[df$occupants_count > 20] = median(df$occupants_count[df$occupants_count < 20])
plot(df$occupants_count)
# Also a lot of places where occupant count is zero 
df$occupants_count[df$occupants_count < 1] <- median(df$occupants_count[df$occupants_count > 1])
hist(df$occupants_count, xlab = "Occupants count", main="")
##### ##### 

##### House Area ##### 
summary(df$house_area)
df[df$house_area ==5,]
plot(df$house_area[df$house_area <10])
# A huge chunk of data is missing in between. Area of 1 appears at two places. we will impute both this values. 
# What is the unit of house area 
df$house_area[df$house_area == 0] <- mean(df$house_area[df$house_area > 1])
df$house_area[df$house_area == 0] <- mean(df$house_area[df$house_area > 1])
df$house_area[df$house_area == 1] <- mean(df$house_area[df$house_area > 1])
(df[df$house_area > 10000,])
##### #####

summary(df$loan_tenure)
barplot(table(df$loan_tenure))

##### Loan Installments ##### 
plot(df$loan_installments)
summary(df$loan_installments)
df[df$loan_installments ==0,]
df$loan_installments[df$loan_installments==0] <- median(df$loan_installments[df$loan_installments > 0])
##### ##### 

summary(df$loan_amount)
# Looking at summary to double check the findings. 
summary(na.omit(df[sapply(df, function(x) !is.factor(x))]))

##### Sex #####
barplot(table(df$sex))
boxplot(loan_amount ~ sex, data = df, outline=F)
##### ##### 

##### Primary Business ##### 
length(unique(df$primary_business))
sort(table(df$primary_business), decreasing = T)
pm <- sort(table(df$primary_business), decreasing = T)
sum(pm[1:40])
pm[40]
min.freq <- 1000
# keeping only top 80% primary businesses 
require(data.table)
df <- as.data.table(df)
class(df)
# Levels that don't meet minumum frequency (using data.table)
fail.min.f <- df[, .N, primary_business][N < min.freq, primary_business]

# Call all these level "Other"
levels(df$primary_business)[fail.min.f] <- "Other"
df$primary_business <- factor(df$primary_business)
##### ##### 

##### Secondary Business #####
sort(table(df$secondary_business), decreasing = T)
df$secondary_business <- gsub("NULL", "none", df$secondary_business)
df$secondary_business <- as.factor(df$secondary_business)
##### #####

##### Home Ownership ##### 
sort(table(df$home_ownership))
df$home_ownership[df$home_ownership=="NULL"] <- 0
df$home_ownership <- factor(df$home_ownership)
barplot(table(df$home_ownership))
boxplot(loan_amount ~ home_ownership, data = df, outline=F)
##### ##### 

##### Type of house ##### 
table(df$type_of_house)
df$type_of_house <- gsub("NULL", "T2", df$type_of_house)
df$type_of_house <- factor(df$type_of_house)
boxplot(loan_amount ~ type_of_house, data = df, outline=F)

###### ###### 

##### Sanitary Availability ##### 
table(df$sanitary_availability)
df$sanitary_availability[df$sanitary_availability=="NULL"] <- 0
df$sanitary_availability[df$sanitary_availability==-1] <- 1
df$sanitary_availability <- factor(df$sanitary_availability)
boxplot(loan_amount ~ sanitary_availability, data = df, outline=F)
##### ##### 

##### Water availability ##### 
table(df$water_availabity)
df$water_availabity[df$water_availabity==-1] <- 1
df$water_availabity[df$water_availabity==0.5] <- 0
df$water_availabity[df$water_availabity=="NULL"] <- 0
df$water_availabity <- factor(df$water_availabity)
boxplot(loan_amount ~ water_availabity, data=df, outline=F)
##### #####

#### Loan Purpose ##### 
sort(table(df$loan_purpose), decreasing = T)
df$loan_purpose[df$loan_purpose=="#N/A"] <- "Others"
min.freq <- 100
require(data.table)
df <- as.data.table(df)
class(df)
# Levels that don't meet minumum frequency (using data.table)
fail.min.f <- df[, .N, loan_purpose][N < min.freq, loan_purpose]

# Call all these level "Other"
levels(df$loan_purpose)[fail.min.f] <- "Others"
df$loan_purpose <- factor(df$loan_purpose)
table(df$loan_purpose)
##### ##### 

##### Social Class ##### 
sort(table(df$social_class), decreasing = T)
length(unique(df$social_class))
df$social_class <- toupper(df$social_class)
df$social_class <- gsub("[.]","",df$social_class) # replace . by "" 
df$social_class <- gsub(".*MUS.*","MUSLIM", df$social_class) # Replace any word with MUS as MUSLIM 
df$social_class <- gsub(".*GEN.*","GENERAL", df$social_class) # Replace any word with GEN as GENERAL 
df$social_class <- gsub(".*CAST.*","SC", df$social_class) # Replace any word wih CAST as SC 
df$social_class <- gsub(".*GC.*","GENERAL", df$social_class) # GC is probably general 
df$social_class <- gsub("BC","OBC", df$social_class)
df$social_class <- gsub("O B C","OBC", df$social_class)
min.freq <- 1000
require(data.table)
df <- as.data.table(df)
df$social_class <- factor(df$social_class)
class(df)
# Levels that don't meet minumum frequency (using data.table)
fail.min.f <- df[, .N, social_class][N < min.freq, social_class]

# Call all these level "Other"
levels(df$social_class)[fail.min.f] <- "Other"
df$social_class <- factor(df$social_class)
boxplot(loan_amount ~ social_class, data=df,outline=F)
##### #####

df <- as.data.frame(df)
str(df)

dffit_1 <- lm(log(loan_amount) ~ ., data = df)
summary(fit_1)
plot(fit_1$residuals)
trydf <- df
trydf$annual_income <- log(trydf$annual_income)
trydf$monthly_expenses <- log(trydf$monthly_expenses)
trydf$loan_amount <- log(trydf$loan_amount)
trydf$house_area <- log(trydf$house_area)
t_fit <- lm(loan_amount ~ ., data=trydf)
summary(t_fit)

plot(t_fit$residuals)

write.csv(df,"data_eda.csv") # Saving transformed data as a csv 

