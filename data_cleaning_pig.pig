#To load csv and make ETL:
	
#load csv loader and load file

DEFINE CsvLoader org.apache.pig.piggybank.storage.CSVLoader();
athlete_data = LOAD '/home/Documents/athlete_events.csv' USING CsvLoader() AS (ID:chararray, Name:chararray, Sex:chararray, Age:int, Height:double, Weight:double, Team:chararray, NOC:chararray, Games:chararray, Year:int, Season:chararray, City:chararray, Sport:chararray, Event:chararray, Medal:chararray);


#CLEAN TEAM column

athlete_data_cleaned = FOREACH athlete_data GENERATE ID, Name, Sex, Age, Height, Weight, REGEX_EXTRACT(Team, '^[^-,"/#]*', 0) AS Team, NOC, Games, Year, Season, City, Sport, Event, Medal;

athlete_data_cleaned_1 = FOREACH athlete_data_cleaned GENERATE ID, Name, Sex, Age, Height, Weight, REPLACE(Team, '(I|IV|VII|XII|II|VIII|III|V|X|XI|VI|IX|XIII)$', '') AS Team, NOC, Games, Year, Season, City, Sport, Event, Medal;		


#replace null values with not specified value as string
athlete_data_replaced = FOREACH athlete_data_cleaned_1 GENERATE ID, Name, Sex, (Age is null ? 'Not Specified' : (chararray)Age) as Age,(Height is null ? 'Not Specified' : (chararray)Height) as Height, (Weight is null ? 'Not Specified' : (chararray)Weight) as Weight, Team, NOC, Games, Year, Season, City, Sport, Event, (Medal is null ? 'Not Specified' : Medal) as Medal;

# clean NA from medals 
athlete_data_cleaned_2 = FOREACH athlete_data_replaced GENERATE ID, Name, Sex, Age, Height, Weight, Team, NOC, Games, Year, Season, City, Sport, Event, REPLACE(Medal, 'NA', 'Not Specified') AS Medal;	

# clean EVENTS column
athlete_data_cleaned_3 = FOREACH athlete_data_cleaned_2 GENERATE ID, Name, Sex, Age, Height, Weight, Team, NOC, Games, Year, Season, City, Sport, REPLACE(Event, ',', '.') AS Event, Medal;

# remove duplicated values
athlete_data_distinct = DISTINCT athlete_data_cleaned_3;

# store the data 
STORE athlete_data_distinct INTO '/home/sofia/Documents/athlete_clean_dataset' USING PigStorage(',');
