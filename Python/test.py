import glob
import os 

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