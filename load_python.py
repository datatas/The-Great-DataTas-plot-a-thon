#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov  9 15:50:04 2021
For DataTas Plot-A-Thon!
@author: Nic Pittman
"""
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


# Load and Data cleanup roughly copied from the R version.
peaks=pd.read_csv('data/peaks.csv')
expeds=pd.read_csv('data/expeditions.csv')
members=pd.read_csv('data/members.csv')


# Data is already processed
peaks['climbing_status']=peaks.climbing_status.astype('category')
peaks['climbing_status_encode']=peaks.climbing_status.cat.codes
peak_names=peaks[['peak_id','peak_name']]


print('Variables\n---------')
print('')
print(list(expeds))
print(list(members))
print(list(peaks))


# %% Possibly useful groupby functions.
#expeds['agency_short']=expeds.agency
agency=expeds.groupby('trekking_agency')
agency=agency.sum()
print(agency)


# Example plot %%

number_of_climbs=expeds.groupby('peak_id').sum()#.rename('Number of recorded climbs')
peaks_climbed=peaks.join(number_of_climbs,on='peak_id')

total_climbs_per_height=peaks_climbed.groupby('height_metres').sum()

plt.scatter(total_climbs_per_height.members,total_climbs_per_height.index,c=total_climbs_per_height.member_deaths)
plt.xlabel('Total Number of Climbs')
plt.ylabel('Mountain Height')
#plt.scale('log',basey=10) 
#plt.xlim([0,20000])
plt.ylim([6500,9000])
cb=plt.colorbar()
cb.set_label('Number of deaths')
plt.title('Everest is Dangerous ... But is it?')
print('I know this plot is a lie.... ')