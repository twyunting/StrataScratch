import glob
import os 
import re
import difflib
#import Levenshtein
"""
Org_folder = os.path.join(destination_path, value, "Orginal")
os.mkdir(Org_folder)
Final_subFolder = os.path.join(Org_folder, "Final")
os.mkdir(Final_subFolder)
Source_subFolder = os.path.join(Org_folder, "Source")
os.mkdir(Source_subFolder)
Working_subFolder = os.path.join(Org_folder, "Working")
os.mkdir(Working_subFolder)
"""

##########################################################
"""
subFolders = ["Final", "Source", "Working"]

for i in range(len(subFolders)):
    #subFolder = os.path.join(Org_folder, subFolders[i])
    #os.mkdir(subFolder)
    subFolder = subFolders[i]
    print(subFolder)
    print(type(subFolder))


# Path
path = '/home/User/documents'
 
 
# Above specified path
# will be splitted into
# (head, tail) pair as
# ('/home/User', 'Documents')
 
# Get the base name 
# of the specified path
basename = os.path.basename(path)
 
# Print the base name 
print(basename)
"""
"""
source_path = r'U:\WORKS\Acc_Tools\PJAC06 - Files_Automation\JEM_test_files\JEM2022\source'
arr1 = []
arr2 = []
for file in glob.glob(os.path.join(source_path, "*/*.xlsx")):
    print(os.path.basename(file))
    arr1.append(os.path.basename(file))

for file in glob.glob(os.path.join(source_path, "**/*.xlsx")):
    print(os.path.basename(file))
    arr2.append(os.path.basename(file))

print(arr1 == arr2)
"""


"""
def originalRevisedAbbr(string):
    pattern = r'Revised_(\d+)|Original'
    matches = re.findall(pattern, string)
    extracted_strings = []
    for match in matches:
        if match:
            extracted_strings.append("R" + match)
        else:
            extracted_strings.append("Ol")
    extracted_strings = extracted_strings.pop()
    return extracted_strings

print(originalRevisedAbbr("Revised_2"))
print(originalRevisedAbbr("Revised_100"))
print(originalRevisedAbbr("Revised_69"))
print(originalRevisedAbbr("Original"))

str1="HEY tHeRE Whats UP"
str2 = str1.lower()
print(str2)

"""


string1 = "Revision 1"
string2 = " Revised_1"

matcher = difflib.SequenceMatcher(None, string1, string2)
similarity = matcher.ratio()
#print(similarity)  


# Python code to demonstrate
# return the sum of values of a dictionary
# with same keys in the list of dictionary

"""
from itertools import cycle

# Initialising list of dictionary
ini_lis1 = ['a', 'b', 'c', 'd', 'e']
ini_lis2 = [1, 2, 3]

# zipping in cyclic if shorter length
result = dict(zip(ini_lis1, cycle(ini_lis2)))

# printing resultant dictionary
print("resultant dictionary : ", str(result))
sourceXC_path = r'T:\Xceedance\JEM\2022'
# save folder names to arrays
for xcFile in glob.glob(os.path.join(sourceXC_path, '*', '*', 'Source', '*')):
    if os.path.isfile(xcFile):
        print(xcFile)

import string

def normalize(s):
    # Remove all non-alphabetic characters from the string
    s = s.translate(string.punctuation)
    # Convert the string to lowercase
    s = s.lower()
    return s

# Test the normalize function
print(normalize("Revised_01")) 
print(normalize("Revision 1"))

b = "  Revision_ 2"
print(b.strip().lower().translate(string.punctuation))


#for xcFolder in glob.glob(os.path.join(sourceXC_path, '**', '*/Source')):
for xc in os.listdir(sourceXC_path):
        if os.path.isdir(os.path.join(sourceXC_path, xc.strip())):
            xcPath = os.path.join(sourceXC_path, xc.strip())
            #print(xcPath)
            xcFullPath = glob.glob(os.path.join(xcPath, '*', '*/Source'))
            for k in xcFullPath:
                print(k)
"""

"""
sourceXC_path = r'U:\WORKS\Acc_Tools\PJAC06 - Files_Automation\JEM_test_files\JEM2022\souceXC_01'

for xc in os.listdir(sourceXC_path):
    if os.path.isdir(os.path.join(sourceXC_path, xc.strip())):
        xcPaths = os.path.join(sourceXC_path, xc.strip())
        print(xcPaths)
        xcFolderVersions = glob.glob(os.path.join(xcPaths, '*'))
        for xcFolderVersion in xcFolderVersions:
            #print("xcFolderVersion:", xcFolderVersion)
            # ? match exactly one character - Source (old version) & source (new version) can be applied
            xcFolderPaths = glob.glob(os.path.join(xcFolderVersion, '?ource'))
            for xcFolderPath in xcFolderPaths:
                #print("xcFolderPath:", xcFolderPath)
                xcFilePaths = glob.glob(os.path.join(xcFolderPath, '*'))
                for xcFilePath in xcFilePaths:
                    print("xcFilePath:", xcFilePath)
"""


"""
Source Note


for xcFolderPath in xcFolderPaths:
for catFolderPath in catFolderPaths:
xcFolPathLower = [i.lower() for i in xcFolderPath.split(os.sep)[-3:]]
catFolPathLower = [i.lower() for i in catFolderPath.split(os.sep)[-3:]]
if xcFolPathLower == catFolPathLower and len(xcFolPathLower) >= 1 and len(catFolPathLower) >= 1:
xcFilePaths = glob.glob(os.path.join(xcFolderPath, '*'))
catFilePaths = glob.glob(os.path.join(catFolderPath, '*'))
print(len(xcFilePaths))
print(len(catFilePaths))

#for xcFilePath in xcFilePaths:
#for catFilePath in catFilePaths:
    # print(xcFilePath)
    #print(catFilePath)
#if not os.path.exists(catFilePath) and os.path.isfile(catFilePath):

#if not os.path.exists(catFilePath) and os.path.isfile(catFilePath):
    #shutil.copy(catFilePath, xcFilePath)

"""

"""
import datetime

now = datetime.datetime.now()
local_now = now.astimezone()
local_tz = local_now.tzinfo
local_tzname = local_tz.tzname(local_now)
print(local_tz)
"""
"""
import re

year = 2023
year = "_" + str(year)
#print(type(year))
#print(year)
name = "17 FLL Holdings_2023-09-03--05-53-34"
print(len(re.findall(year, name)))
"""
"""
xc_path = r'T:\Xceedance\JEM\2022\20th Street Church of Christ Inc\Original'
xc_list1 = [i.lower() for i in xc_path.split(os.sep)[-2:]]
xc_list2 = [i.lower() for i in xc_path.split(os.sep) if len(xc_path.split(os.sep)) >= 2]
tmp = []
for i in xc_path.split(os.sep):
    if len(xc_path.split(os.sep)) >= 2:
        i = i.lower()
        tmp.append(i)
xc_list3 = tmp[-2:]

test_str = r"T:\RSG Chicago\CAT Modeling\PAPI Reports\Xceedance\JEM\Compact Edition\Report\Beacon Hospital _op1_2022-05-27--09-11-33"
#print(xc_list1)
#print(xc_list3)
#print(len(xc_path.split(os.sep)))
test_str2 = test_str.replace(" ", "")
print(test_str)
print(test_str2)
print(test_str.split("_", 1)[0])
"""
"""
string = "Beacon Hospital _op1_2022-05-27--09-11-33"
a = string.split("_", 1)[0]
b = string.split("_", 1)[0].strip()
print(len(a))
print(len(b))
"""

"""
source_JEM = r'T:\RSG Chicago\CAT Modeling\PAPI Reports\Xceedance\JEM\Compact Edition\Report'
source_JEMs = glob.glob(os.path.join('T:\RSG Chicago\CAT Modeling\PAPI Reports\*\JEM\*\Report'))

#for i in source_JEMs:
    #print(i)

#print(source_JEM)

source_BU = "JEM"
source_PAPIs = glob.glob(os.path.join('T:\RSG Chicago\CAT Modeling\PAPI Reports\*', source_BU.strip(), '*\Report'))

for i in source_PAPIs:
    print(i)
"""
from datetime import date
todays_date = date.today()
#print(type(todays_date.year))
today_year = 2022
print("Please update data and save it as data_{}.csv".format(today_year))
