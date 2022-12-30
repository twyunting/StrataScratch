####################################################################################################
## Name: {Read data and Execution of Account Modeling File Automations}
## Description: {Save CAT account modeling reports and data files to T:/CAT drive automatically}
####################################################################################################
## Department: {CU - Modeling/0017030054}
####################################################################################################
## Author: {Yunting Chiu}
## Copyright: Copyright {2023}, {Ryan Specialty, LLC}
## License: {license}
## Version: {1}.{0}.{0}
## Maintainer: {Yunting Chiu}
## Email: {yunting.chiu@ryansg.com}
## Status: {production}
####################################################################################################
## Version Control

####################################################################################################

# install libs and main.py functions
import pandas as pd
from datetime import date
from main import *

# read and tidy data
df = pd.read_csv("data_2022.csv")
df = df.applymap(lambda x: x.strip() if isinstance(x, str) else x)

# find the current year
todays_date = date.today()
todays_year = todays_date.year

# iterate all business units
for i in range(len(df)):
    if str(todays_year) == str(df.iloc[i, 0]):
        autoAllFiles(df.iloc[i, 0], df.iloc[i, 1], df.iloc[i, 2], df.iloc[i, 3])
    else:
        print("Please update data and save it as data_{}.csv".format(todays_year))
        break

