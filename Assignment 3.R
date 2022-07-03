
install.packages("tidyverse")
library(tidyverse)
#Obtain and read stormevent details dataset.
stormevent_details <- read.csv("C:\\Users\\rache\\OneDrive\\Desktop\\ANA515\\StormEvents_details-ftp_v1.0_d1996_c20220425.csv.gz")
stormevent_details

#Create a subset of the dataframe with the following columns.
myvars <- c("BEGIN_DAY","BEGIN_TIME","END_DAY","END_TIME","BEGIN_DATE_TIME",
            "END_DATE_TIME","EPISODE_ID","EVENT_ID","EVENT_TYPE","STATE",
            "STATE_FIPS","CZ_NAME","CZ_TYPE","CZ_FIPS","SOURCE","BEGIN_LAT",
            "BEGIN_LON","END_LAT","END_LON")
substormevent_details <- stormevent_details[myvars]
head(substormevent_details,5)

#Arrange the data by state name.
substormevent_detailsbySTATE <- arrange(substormevent_details,STATE)
substormevent_detailsbySTATE

#Change state and county names to title
str_to_title(substormevent_detailsbySTATE$STATE,substormevent_detailsbySTATE$CZ_NAME)

#Limited the events to county tyoe (c) then removed CZ_TYPE column.
substormevent_detailsbySTATE %>%
  filter(CZ_TYPE=="C") %>% select(-CZ_TYPE)

#Pad state and county fips  then united the two columns
substormevent_detailsbySTATE %>% mutate_at(vars(STATE_FIPS, CZ_FIPS), str_pad, width = 3, pad = '0') %>%
  unite("fips",STATE_FIPS,CZ_FIPS,sep="")

#changed all columns to lowercase
rename_all(substormevent_detailsbySTATE,tolower)

#Call "state" data and create a dataframe
data("state")
us.state.info <- data.frame(state=state.name,region=state.region,area=state.area)

#create dataframe with the number of events per state
table(substormevent_detailsbySTATE$STATE)
state_stormevent <- data.frame(table(substormevent_detailsbySTATE$STATE))

#rename Var1 column to state then changed the column values of  state to upper case
state_stormevent <- rename(state_stormevent,c("state"="Var1"))
us.state.info<- mutate_all(us.state.info,toupper)

#merge state_stormevent dataframe with us.state.info dataframe
state_storms <- merge(x=state_stormevent,y=us.state.info,by.x = "state",by.y = "state")

#create a graph showing the no. of storm events per land square miles
library(ggplot2)
storm_plot <- ggplot(state_storms, aes(x = area, y = Freq)) +
  geom_point(aes(color = region)) +
  labs(x = "Land area (square miles)",
       y = "# of storm events in 2017")
storm_plot
       


