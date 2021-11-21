# craw_plotathon_2021
My entry for the 2021 DataTas plot-a-thon!

The final figure is "himalayas.gif". This is an animation progressing through time, and showing first ascents of each Himalayan peak in the "death zone" (peaks above 8000m). Top left, a map of all peak locations. Peaks turn green when they have been climbed. Top right, a plot of total death zone peaks which have been climbed, over time. Bottom, a stylised "cross-section" with a triangle for each peak. When the peak has been climbed, a flag appears to signify which nationality the climbers were.

Also included here is everything needed to recreate the plot (I hope!):
- himalayas.m, plotting script written for MATLAB R2018b Update 7 (9.5.0.1298439), with the mapping toolbox installed
- death_zone_peaks.txt, a list of death zone peaks and their lat and long which I pulled from the Himalayan Index at alpine-club.co.uk
- ./flags/, a directory containing .png images of country flags. I got these from https://github.com/lipis/flag-icons
- hiker-overnight.png, a symbol from the IAN open-source symbol library https://ian.umces.edu/media-library
