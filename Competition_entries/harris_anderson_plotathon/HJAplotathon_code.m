

%% Download data from the tidytuesday repository {{{
% this will store the files in your current directory. 
% urlwrite('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/members.csv', 'members.csv');
% urlwrite('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/expeditions.csv', 'expeditions.csv');
% urlwrite('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/peaks.csv', 'peaks.csv');
% %}}}

%% Import the data from .csv files into the workspace {{{
% Data will be imported as three tables, with the header info used as column labels.
% you will need to be in the directory where the files are stored, or edit the filepaths to specify their location. 
members = readtable('members.csv', 'ReadVariableNames', 1);
expeditions = readtable('expeditions.csv', 'ReadVariableNames', 1);
peaks = readtable('peaks.csv', 'ReadVariableNames', 1);
%%}}}

%% Computes data for graphing

%create a new variable for total deaths
expeditions.alldeath = expeditions.hired_staff_deaths+expeditions.member_deaths;

% finds numbers of deaths per year and creates array containing the year
% and total deaths per year

alld = [expeditions.year expeditions.alldeath];
[Ua,~,idx] = unique(alld(:,1)); 
DpY = [accumarray(idx,alld(:,2),[],@sum)];
death = [Ua DpY];

% Finds trekking agencies most likely to cause death

% First create a new version of table
exp2 = expeditions;

% remove years with no death and NA values for agency
exp2(ismember(exp2.alldeath,0),:)=[];
exp2(ismember(exp2.trekking_agency,'NA'),:)=[];

% find most common agencies leading an expedition in which there is a death
b = exp2.trekking_agency;
[s,~,j] = unique(b);
m1 = s{mode(j)}
b(ismember(b,m1),:)=[];
[s,~,j] = unique(b);
m2 = s{mode(j)}
b(ismember(b,m2),:)=[];
[s,~,j] = unique(b);
m3 = s{mode(j)}
b(ismember(b,m3),:)=[];
[s,~,j] = unique(b);
m4 = s{mode(j)}
b(ismember(b,m4),:)=[];
[s,~,j] = unique(b);
m5 = s{mode(j)}

names = strcat(m1,", ",m2,", ",m3,", ",m4,", ",m5);


% finds how may deaths each company is responsible for
alldeath = expeditions.alldeath;
nm1 = contains(expeditions.trekking_agency,m1); 
DpT1 = sum(alldeath(nm1));
nm2 = contains(expeditions.trekking_agency,m2); 
DpT2 = sum(alldeath(nm2));
nm3 = contains(expeditions.trekking_agency,m3); 
DpT3 = sum(alldeath(nm3));
nm4 = contains(expeditions.trekking_agency,m4); 
DpT4 = sum(alldeath(nm4));
nm5 = contains(expeditions.trekking_agency,m5); 
DpT5 = sum(alldeath(nm5));

% finds year each company is responsible for most death

AT = [expeditions.year(nm1)  alldeath(nm1)];
SST = [expeditions.year(nm2)  alldeath(nm2)];
TT = [expeditions.year(nm3)  alldeath(nm3)];
HG = [expeditions.year(nm4)  alldeath(nm4)];
CT = [expeditions.year(nm5)  alldeath(nm5)];

% now we find the max number of deaths a company was responsible for in a single year
% and find which year

[atUa,~,idx] = unique(AT(:,1)); 
atd = [accumarray(idx,AT(:,2),[],@sum)];
atm = [atUa atd];
[mat,iat] = max(atd)

[sstUa,~,idx] = unique(SST(:,1)); 
sstd = [accumarray(idx,SST(:,2),[],@sum)];
sstm = [sstUa sstd];
[msst,isst] = max(sstd)

[ttUa,~,idx] = unique(TT(:,1)); 
ttd = [accumarray(idx,TT(:,2),[],@sum)];
ttm = [ttUa ttd];
[mtt,itt] = max(ttd)

[hgUa,~,idx] = unique(HG(:,1)); 
hgd = [accumarray(idx,HG(:,2),[],@sum)];
hgm = [hgUa hgd];
[mhg,ihg] = max(hgd)

[ctUa,~,idx] = unique(CT(:,1)); 
ctd = [accumarray(idx,CT(:,2),[],@sum)];
ctm = [ctUa ctd];
[mct,ict] = max(ctd)

incidents.years = vertcat(atUa(iat),sstUa(isst),ttUa(itt),hgUa(ihg),ctUa(ict));
incidents.max = vertcat(mat,msst,mtt,mhg,mct);


%% reads image

[skull, ~, ImageAlpha] = imread('Skull.png');

%% plotting
addpath /Users/harrisa5/Documents/MATLAB/chadagreene-CDT-dbc2a90/cdt/


figure('Renderer', 'painters', 'Position', [10 10 800 1600])
ax1 = axes('Position',[0.1300 0.1100 0.7 0.7]);
set(gcf,'Color',[0.1 0.1 0.1 0.1]);
bar(death(:,1),death(:,2),0.8,'FaceColor',[1,1,1],'FaceAlpha',0.7);
hold on
plot(death(:,1),scatstat1(death(:,1),death(:,2),3),'LineWidth',2,'Color',[1,1,1])
set(gca,'Color',[1 1 1 0.2],'FontSize',14,'TickDir','out','YColor',[1,1,1],'XColor',[1 1 1],'LineWidth',1.5);
ylabel('Deaths per Year');
hold on
yyaxis right
% plots the cumularive deaths and deals with labelling
plot(death(:,1),cumsum(death(:,2)),'LineWidth',2,'Color',[1 0 0]);
set(gca,'YColor',[1 0 0])
ylabel('Cumulative Deaths (D/yr)');
xlabel('Year');
title('Death in the Himalaya','Color',[1 1 1],'FontSize',20);
subtitle(['and the top companies that kill: ',names],'Color',[1 1 1],'FontSize',14);
xlim([1904 2019.5])

%this following section creates minuature cartesian that are used to plot
%skull images
ax_pos = get(ax1,'Position');
skull_x1 = (((incidents.years(1)-1905)/(2019-1905)))*(ax_pos(3)+ax_pos(1));
skull_y1 = (incidents.max(1)-0)/(35)*(ax_pos(4))+ax_pos(2);
skull_x2 = (((incidents.years(2)-1905)/(2019-1905)))*(ax_pos(3)+ax_pos(1));
skull_y2 = (incidents.max(2)-0)/(35)*(ax_pos(4))+ax_pos(2);
skull_x3 = (((incidents.years(3)-1905)/(2019-1905)))*(ax_pos(3)+ax_pos(1));
skull_y3 = (incidents.max(3)-0)/(35)*(ax_pos(4))+ax_pos(2);
skull_x4 = (((incidents.years(4)-1905)/(2019-1905)))*(ax_pos(3)+ax_pos(1));
skull_y4 = (incidents.max(4)-0)/(35)*(ax_pos(4))+ax_pos(2);
skull_x5 = (((incidents.years(5)-1905)/(2019-1905)))*(ax_pos(3)+ax_pos(1));
skull_y5 = (incidents.max(5)-0)/(35)*(ax_pos(4))+ax_pos(2);

hold on
skull_ax1 = axes('Position', [skull_x1-0.02 skull_y1-0.02 0.09 0.09], 'color', 'none', 'XColor', [1 1 1 0], 'YColor', [1 1 1 0])
skull_image = imshow(skull);
set(skull_image, 'AlphaData', ImageAlpha);

skull_ax2 = axes('Position', [skull_x2-0.02 skull_y2-0.02 0.09 0.09], 'color', 'none', 'XColor', [1 1 1 0], 'YColor', [1 1 1 0])
skull_image = imshow(skull);
set(skull_image, 'AlphaData', ImageAlpha);

skull_ax3 = axes('Position', [skull_x3-0.02 skull_y3-0.02 0.09 0.09], 'color', 'none', 'XColor', [1 1 1 0], 'YColor', [1 1 1 0])
skull_image = imshow(skull);
set(skull_image, 'AlphaData', ImageAlpha);

skull_ax4 = axes('Position', [skull_x4-0.02 skull_y4-0.02 0.09 0.09], 'color', 'none', 'XColor', [1 1 1 0], 'YColor', [1 1 1 0])
skull_image = imshow(skull);
set(skull_image, 'AlphaData', ImageAlpha);

skull_ax5 = axes('Position', [skull_x5-0.02 skull_y5-0.02 0.09 0.09], 'color', 'none', 'XColor', [1 1 1 0], 'YColor', [1 1 1 0])
skull_image = imshow(skull);
set(skull_image, 'AlphaData', ImageAlpha);

print(gcf, '-dtiff', 'plotathon.tiff');

