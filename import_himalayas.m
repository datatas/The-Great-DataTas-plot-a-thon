%% Download data from the tidytuesday repository {{{
% this will store the files in your current directory. 
urlwrite('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/members.csv', 'members.csv');
urlwrite('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/expeditions.csv', 'expeditions.csv');
urlwrite('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/peaks.csv', 'peaks.csv');
%}}}

%% Import the data from .csv files into the workspace {{{
% Data will be imported as three tables, with the header info used as column labels.
% you will need to be in the directory where the files are stored, or edit the filepaths to specify their location. 
members = readtable('members.csv', 'ReadVariableNames', 1);
expeditions = readtable('expeditions.csv', 'ReadVariableNames', 1);
peaks = readtable('peaks.csv', 'ReadVariableNames', 1);
%%}}}

%% An example of a simple plot (uncomment to run) {{{
%% I want to plot the number of expedition over time. 
%% First I'll convert the string for the date of reaching the base camp to a datetime 
%basecamp_date = datetime(expeditions.basecamp_date, 'InputFormat', 'yyyy-MM-dd');

%%then I'll plot these dates as a frequency histogram.
%histogram(basecamp_date);
%title('Number of expeditions leaving base camp')
%xlabel('year')
%ylabel('number of expeditions')

%%easy! 

%}}}
