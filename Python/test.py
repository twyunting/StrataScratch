import glob
import os 
import re
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

"""

str1="HEY tHeRE Whats UP"
str2 = str1.lower()
print(str2)