% Script for plotting himalayas data for the DataTas Plot-a-thon!

%% IMPORT DATA as tables {{{
members = readtable('members.csv', 'ReadVariableNames', 1);
expeditions = readtable('expeditions.csv', 'ReadVariableNames', 1);
peaks = readtable('peaks.csv', 'ReadVariableNames', 1);
% To get latitude and longitude data, I sourced a list of the death zone peaks from the Himalayan Index at alpine-club.co.uk. 
% I used vim to quickly edit the file and change the second and minute signifiers to 's' and 'm', to avoid headaches with MATLAB syntax
death_zone = readtable('death_zone_peaks.txt', 'ReadVariableNames', 1);
%}}}

%% DATA WRANGLING {{{

% convert co-ordinates to decimal degrees, and match up data from the peaks.csv file 
%the function ConvertDegrees is defined at the bottom of this file. It only works for the specific format used here
latitude = [];
for i = 1:length(death_zone.Latitude)
	latitude(i,1) = ConvertDegrees(death_zone.Latitude(i));
end
death_zone.Latitude = latitude;
clear latitude

longitude = [];
for i = 1:length(death_zone.Longitude)
	longitude(i,1) = ConvertDegrees(death_zone.Longitude(i));
end
death_zone.Longitude = longitude;
clear longitude

% select only peaks from the death zone list with unique names (there are a few double-ups)
[group, name] = findgroups(death_zone.PreferredName);
mean_lat = splitapply(@mean, death_zone.Latitude, group);
mean_long = splitapply(@mean, death_zone.Longitude, group);
unique_deathzone = table(name, mean_lat, mean_long);

% select only death zone peaks from the peaks list
peaks_tall = (peaks(peaks.height_metres>=8000, :));

% now go through our peaks list and find the same named peak from the death zone list, to get the latitude and longitude for each one.
peak_list = {'peak_id', 'peak_name', 'peak_alternative_name', 'height_metres', 'climbing_status', 'first_ascent_year', 'first_ascent_country', 'first_ascent_expedition_id', 'latitude', 'longitude'};
peak_height = [];
for j = 1:length(peaks_tall.peak_name)
	name_peaklist = string(peaks_tall.peak_name(j));
   for k = 1:length(unique_deathzone.name)
		%replace abbreviations to match the original list
		% this definitely would have been easier to do manually, but I've come this far 
		name_deathzonelist = char(unique_deathzone.name(k));
		name_deathzonelist = strrep(name_deathzonelist, "M ", "Middle ");
		name_deathzonelist = strrep(name_deathzonelist, "C ", "Central ");
		name_deathzonelist = strrep(name_deathzonelist, "E ", "East ");
		name_deathzonelist = strrep(name_deathzonelist, "W ", "West ");
		name_deathzonelist = strrep(name_deathzonelist, "Annapurna ", "Annapurna I ");
		name_deathzonelist = strrep(name_deathzonelist, "Dhaulagiri ", "Dhaulagiri I ");
		name_deathzonelist = strrep(name_deathzonelist, " Pk  ", " ");
		name_deathzonelist = char(name_deathzonelist);
		%remove floating space at the end
		name_deathzonelist = name_deathzonelist(1:end-1);
		if strcmp(name_peaklist, name_deathzonelist) ==1;
			new_entry = {string(peaks_tall.peak_id(j)), string(peaks_tall.peak_name(j)), string(peaks_tall.peak_alternative_name(j)), peaks_tall.height_metres(j), string(peaks_tall.climbing_status(j)), peaks_tall.first_ascent_year(j), string(peaks_tall.first_ascent_country(j)), string(peaks_tall.first_ascent_expedition_id(j)), unique_deathzone.mean_lat(k), unique_deathzone.mean_long(k)};
			peak_list = [peak_list; new_entry];
		end
	end
end

%store all data together as a table sorted in order of latitude, but extract some arrays that we'll need 
varnames = peak_list(1,:);
peak_list = array2table(peak_list(2:end,:), 'VariableNames', varnames);
peak_list = sortrows(peak_list,10);
latitude = cell2mat(peak_list.latitude);
longitude = cell2mat(peak_list.longitude);
height = cell2mat(peak_list.height_metres);
names = string(table2cell(peak_list(:,2)));
year_climbed = reshape([peak_list.first_ascent_year{:}],size(peak_list.first_ascent_year,1),size(peak_list.first_ascent_year{1},2));
first_country = reshape([peak_list.first_ascent_country{:}],size(peak_list.first_ascent_country,1),size(peak_list.first_ascent_country{1},2));

%figure out how many countries were in the first successful expedition for each mountain
num_countries = count(first_country, ',') + 1;

%}}}

%% IMPORT SOME STUFF {{{
% symbol for climber dude (sadly there is no woman climber symbol)
[climber, ~, ImageAlpha] = imread('hiker-overnight.png');
% country flags
[swiss_flag, swiss_colormap] = imread('./flags/ch.png');
[german_flag, german_colormap] = imread('./flags/de.png');
[austrian_flag, austrian_colormap] = imread('./flags/at.png');
[french_flag, french_colormap] = imread('./flags/fr.png');
[uk_flag, uk_colormap] = imread('./flags/gb.png');
[indian_flag, indian_colormap] = imread('./flags/in.png');
[japanese_flag, japanese_colormap] = imread('./flags/jp.png');
[nz_flag, nz_colormap] = imread('./flags/nz.png');
[polish_flag, polish_colormap] = imread('./flags/pl.png');
[russian_flag, russian_colormap] = imread('./flags/ru.png');
[nepalese_flag, nepalese_colormap] = imread('./flags/np.png');

%store flags in a structure with their colormaps
flags.name = ["Switzerland", "W Germany", "Austria", "France", "UK", "India", "Japan", "New Zealand", "Poland", "Russia", "Nepal"]';
flags.flag = {swiss_flag, german_flag, austrian_flag, french_flag, uk_flag, indian_flag, japanese_flag, nz_flag, polish_flag, russian_flag, nepalese_flag};
flags.colormaps = {swiss_colormap, german_colormap, austrian_colormap, french_colormap, uk_colormap, indian_colormap, japanese_colormap, nz_colormap, polish_colormap, russian_colormap, nepalese_colormap};

%}}}

%% PLOTTING {{{
f1 = figure('Position', [100 100 1500 1000]);
afs = 14; %axis font size
filename = 'himalayas.gif'; % file name for output gif
hold on

%caption
caption = '\textbf{First ascents of death zone ($>8000\,\mathrm{m}$) peaks in the Himalayas over time}';
annotation('textbox', [0.22 0.014 0.8 0.05], 'String', caption, 'Interpreter', 'latex', 'FontSize', 20, 'EdgeColor', 'none');

%plot map of mountain locations
map = subplot(2,2,1);
geoscatter(latitude, longitude, 100, [0.4 0.4 0.4], '^', 'filled')
geolimits([25.5 30], [82 90])
%xlabel('longitude', 'Interpreter', 'latex', 'FontSize', afs);
%ylabel('latitude', 'Interpreter', 'latex', 'FontSize', afs);
hold on

% label peaks. Need to offset the labels to avoid overlaps
long_offset = [0.1 0.1 0.1 0.1 0.1 0.1 0.3 0.1 0.1 0.15 0.1 0.1 0.1]';
lat_offset = [0.4 0.3 -0.3 0.2 0.4 -0.55 -0.2 0.4 0.1 -0.35 0 -0.3 0.3]';
text(latitude+lat_offset, longitude+long_offset, string(table2cell(peak_list(:,2))))

% lines to connect labels with peaks
for i = 1:length(latitude)
	geoplot([(latitude(i)+lat_offset(i));latitude(i)], [(longitude(i)+long_offset(i));longitude(i)], 'LineWidth', 0.5, 'color', [0.5 0.5 0.5])
end

%make axes for line graph
line_graph = subplot(2,2,2)
axis([1949 2002 0 15]);
xlabel('year', 'Interpreter', 'latex', 'FontSize', afs);
ylabel('number of DZ peaks climbed', 'Interpreter', 'latex', 'FontSize', afs);
elevation_line = [];

% make axes for cross-section
xsection = subplot(2,2,[3,4]);
axis tight manual

%find points either side of peaks to turn them into triangles
half_width = 0.4;
plot_long = [];
plot_height = [];
for i = 1:length(height)
	behind = longitude(i)-(height(i)./8000)*0.2;
	front = longitude(i)+(height(i)./8000)*0.2;
	plot_long(end+1) = behind;
	plot_long(end+1) = longitude(i);
	plot_long(end+1) = front;
	plot_height(end+1) = 0;
	plot_height(end+1) = height(i);
	plot_height(end+1) = 0;
end

% plot "cross-section" of the mountain range
plot(plot_long, plot_height, 'color', [0.3 0.3 0.3], 'LineWidth', 2);
axis([83.2 88.4 3000 28000]);
yticks([2000 4000 6000 8000 10000]);
xsection.YRuler.Exponent = 0;
hold on
set(xsection, 'color', 'none');
set(xsection, 'XAxisLocation', 'top');
xlabel('longitude', 'Interpreter', 'latex', 'FontSize', afs);
ylabel('height, m', 'Interpreter', 'latex', 'FontSize', afs);
%fill each mountain in grey
i=1;
while i < length(plot_long)
	fill(plot_long(i:i+2), plot_height(i:i+2), [0.6 0.6 0.6])
	i = i+3;
end
% label peaks
name_offset = [0 -0.02 0.02 0 0 -0.08 -0.03 0.01 0.07 0.1 -0.05 -0.02 0.08];
for i = 1:length(names)
	arrow = annotation('textarrow');
	arrow.Parent = gca;
	arrow.Position = [longitude(i)-0.06+name_offset(i) 27500 longitude(i)+1+name_offset(i) 24500];
	arrow.String = strcat('\textbf{', names(i), '}');
	arrow.HeadStyle = 'none';
	arrow.LineStyle = 'none';
	arrow.TextRotation = 90;
	arrow.Interpreter = 'latex';
	arrow.FontSize = 12;
end
% line to mark death zone
yline(8000, '--', 'LineWidth', 2);
text(85.5, 0.95e4, '\textbf{death zone}', 'FontSize', 14);
text(85.2, 0.6e4, '\textbf{slightly-less-deathy zone}', 'FontSize', 14);
%fill in non-death zone
fill([83.2 88.4 88.4 83.2], [0 0 8000 8000], [0.95 0.95 0.99], 'EdgeColor', 'none', 'FaceAlpha', 0.7);

%make a list of all years that we will be covering
years_in_question = [1949:1:2002];

% loop through each of the years and mark and count peaks climbed. Add each frame to a gif
climbed = 0;
climbed_list = [0 1949];
for year = 1:length(years_in_question)
	hold on
	%label the year
	annotation('textbox', [.46 .34 .1 .08], 'String', string(years_in_question(year)), 'FitBoxToText', 'off', 'BackgroundColor', 'white', 'FontSize', 50, 'Interpreter', 'latex');
	%remove climbing dude if he exists
	if year>1
		axes(climber_axes)
		cla
	end
	%find and mark all peaks climbed in that year
	for mountain = 1:length(year_climbed)
		if strcmp(string(years_in_question(year)), string(year_climbed(mountain))) ==1;
			climbed = climbed+1;
			% plot the flags of involved countries on the mountains which have been climbed 
			% this uses the PlotFlag function defined at the bottom of the script
			% if more than one country was involved in the expedition, all flags are plotted
			if num_countries(mountain) == 1
				axes(xsection)
				PlotFlag(longitude, height, xsection, flags, mountain, first_country(mountain), 0.22, 4300, 1500, -0.003, +0.02)

			elseif num_countries(mountain) == 2
				country_1 = extractBefore(first_country(mountain), ", ");
				axes(xsection)
				PlotFlag(longitude, height, xsection, flags, mountain, country_1, 0.22, 4300, 1500, -0.003, +0.02)

				country_2 = extractAfter(first_country(mountain), ", ");
				axes(xsection)
				PlotFlag(longitude, height, xsection, flags, mountain, country_2, 0.22, 7100, 4300, -0.003, +0.058)

			elseif num_countries(mountain) == 4; 
				country_1 = extractBefore(first_country(mountain), ", ");
				axes(xsection)
				PlotFlag(longitude, height, xsection, flags, mountain, country_1, 0.22, 4300, 1500, -0.003, +0.02)
				
				country_2 = extractBetween(first_country(mountain), strcat(country_1, ", "), ", ");
				axes(xsection)
				PlotFlag(longitude, height, xsection, flags, mountain, country_2, 0.22, 7100, 4300, -0.003, +0.058)
				
				country_3 = extractBetween(first_country(mountain), strcat(country_2, ", "), ", ");
				axes(xsection)
				PlotFlag(longitude, height, xsection, flags, mountain, country_3, -0.22, 7100, 4300, -0.036, +0.02)
				
				country_4 = extractAfter(first_country(mountain), strcat(country_3, ", "));
				axes(xsection)
				PlotFlag(longitude, height, xsection, flags, mountain, country_4, -0.22, 4300, 1500, -0.036, +0.058)
			end
			%plot number of climbed mountains on line graph
%			climbed_list(end+1,1:2) = [climbed str2double(cell2mat(year_climbed(mountain)))]
			axes(line_graph)
			hold on
%			plot(years_in_question(year), climbed, '^', 'MarkerSize', 10, 'color', [0 0.6 0.2], 'markerFaceColor', [0 0.6 0.2]);
			plot(years_in_question(year), climbed, '.', 'MarkerSize', 20, 'color', [0 0 0]);
			% turn the climbed peaks green on the map
			map = subplot(2,2,1);
			geoaxes(map)
			hold on
			geoscatter(latitude(mountain), longitude(mountain), 100, [0 0.6 0.2], '^', 'filled')
		end
	end
	%plot our little hiker dude
	axes(line_graph)
	hold on
	axis_position = get(line_graph, 'position');
	[climber, ~, ImageAlpha] = imread('hiker-overnight.png');
	%units are normalised, so need to convert from the data units
	climber_x = (((years_in_question(year)-1949)/(2002-1949))*(axis_position(3))+axis_position(1));
	climber_y = (climbed/15)*(axis_position(4))+axis_position(2);
	climber_axes = axes('Position', [climber_x-0.02, climber_y-0.02 0.07 0.07], 'color', 'none', 'XColor', [1 1 1], 'YColor', [1 1 1]);
	climber_image = imshow(climber);
	%make background transparent
	set(climber_image, 'AlphaData', ImageAlpha);

	
	%grab frame for gif (this part is shamelessly stolen from StackExchange)
	frame = getframe(f1);
	im = frame2im(frame);
	[imind, cm] = rgb2ind(im,256);
	if  year == 1
		imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
	else
		imwrite(imind,cm,filename,'gif','WriteMode','append');
	end
end

% FUNCTIONS {{{

%function to convert the lat and long from the death_zone list to decimal degrees
function decimal_degrees = ConvertDegrees(oldschool_degrees)
	degrees = (extractBefore(oldschool_degrees, 'o'));
	minutes = cell2mat(extractBetween(oldschool_degrees, 'o', 'm'));
seconds = cell2mat(extractBetween(oldschool_degrees, 'm', 's'));
	decimal_degrees = str2double(degrees)+(str2double(minutes)/60)+(str2double(seconds)/3600); 
end
				
% function to plot a country's flag on top of the climbed mountain. Arguments:
% longitude, height, xsection, flags, mountain: these are already in the workspace
%country_name: name of country as a string
%longdiff: height of the flagpole in data units
%height1: distance from top of mountain to top of flag in data units
%height2: distance from to of mountain to bottom of flag in data units
%axdiff: distance from top of mountain to edge of flag, in normalised units
%aydiff: distance from top of mountain to bottom of flag, in normalised units
function PlotFlag(longitude, height, xsection, flags, mountain, country_name, longdiff, height1, height2, axdiff, aydiff)
	axes(xsection);
	hold on
	% find the flag to match the name of the country which first climbed it 
	ind = find(flags.name == country_name);
	% get the flag image
	country_flag = cell2mat(flags.flag(ind));
	country_colormap = cell2mat(flags.colormaps(ind));
	%set figure background to transparent (otherwise it overwrites the flags)
	set(gca, 'color', 'none');
	%find position of flag in normalised units, and create invisible axes
	axis_position = get(xsection, 'Position');
	flag_x = (((longitude(mountain)-83.2)/(88.4-83.2))*(axis_position(3))+axis_position(1));
	flag_y = (((height(mountain)-3000)/(28000-3000))*(axis_position(4))+axis_position(2));
	ax(mountain) = axes('Position', [flag_x+axdiff, flag_y+aydiff, 0.04 0.04], 'color', [0 0 0], 'XColor', [0 0 0], 'YColor', [0 0 0]);
	hold on
	box on
	%plot flag on those axes
	flag_image = imshow(country_flag, country_colormap);
	hold on
	%plot flag outline
	axes(xsection);
	plot([longitude(mountain) longitude(mountain) longitude(mountain)+longdiff longitude(mountain)+longdiff longitude(mountain)], [height(mountain), height(mountain)+height1 height(mountain)+height1 height(mountain)+height2 height(mountain)+height2], 'k-', 'LineWidth', 2);
end

%}}}
