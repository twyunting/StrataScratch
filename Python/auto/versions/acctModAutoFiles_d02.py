"""
Author: Yunting Chiu
Date: 11/30/3022
"""

import sys
import os
import re
"""
"""
# folder paths
source_path = r'U:\WORKS\Acc_Tools\PJAC06 - Files_Automation\JEM_test_files\JEM2022\source'
destination_path = r'U:\WORKS\Acc_Tools\PJAC06 - Files_Automation\JEM_test_files\JEM2022\destination'

# list to store file names
names = []
versions = []

def genFolderNames(source_path, destination_path):
    # save folder names to arrays
    for path in os.listdir(source_path):
        # check if current path is a folder
        if os.path.isdir(os.path.join(source_path, path)):
            versions.append(path)
            names.append(path.split("_", 1)[0])
    # generate folders
    for name in names:
        if not os.path.exists(os.path.join(destination_path, name)):
            dir = os.path.join(destination_path, name)
            os.mkdir(dir)
    return versions, names

def oldNewNamesDict(versions):
    """
    # convert two arrays into a dictionary
    keys: from T:\RSG Chicago\CAT Modeling\PAPI Reports\Xceedance\JEM\Compact Edition\Report
    values: from T:\CAT Modeling\CAT\JEM\Account Modeling\2022
    """
    res = {versions[i]: names[i] for i in range(len(versions))}
    #print("Resultant dictionary is : " + str(res))
    return res

versions, names = genFolderNames(source_path, destination_path)
res = oldNewNamesDict(versions)

# list to store subfolder names
subFolders = ["Final", "Source", "Working"]
for key, value in res.items():
    # find the digit after _R 
    digit = -1
    digitList = re.findall("_R[0-9]+_", key)   
    if len(digitList) > 0:
        tempStr = digitList[0]
        digit = int(re.findall(r'\d+', tempStr)[0])
    if digit != -1 and len(digitList) > 0 and len(re.findall("_R[0-9]+_", key)) == 1 and not os.path.exists(os.path.join(destination_path, value,"Revised_" + str(digit))):
        Rs_folder = os.path.join(destination_path, value,"Revised_" + str(digit))
        os.mkdir(Rs_folder)
        if os.path.exists(Rs_folder):
            for i in range(len(subFolders)):
                subFolder = os.path.join(Rs_folder, subFolders[i])
                os.mkdir(subFolder)
    elif key.count("_") == 1 and not os.path.exists(os.path.join(destination_path, value, "Orginal")):
        Org_folder = os.path.join(destination_path, value, "Orginal")
        os.mkdir(Org_folder)
        if os.path.exists(Org_folder):
            for i in range(len(subFolders)):
                    subFolder = os.path.join(Org_folder, subFolders[i])
                    os.mkdir(subFolder)
    elif key.count("_OP") == 1 and len(re.findall("_R[0-9]+_", key)) == 0 and not os.path.exists(os.path.join(destination_path, value, "Orginal")):
        Org_folder = os.path.join(destination_path, value, "Orginal")
        os.mkdir(Org_folder)
        if os.path.exists(Org_folder):
            for i in range(len(subFolders)):
                    subFolder = os.path.join(Org_folder, subFolders[i])
                    os.mkdir(subFolder)



print("ENDEND!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
"""
References
1. https://www.stackvidhya.com/python-list-files-in-directory/
2. https://bobbyhadz.com/blog/python-remove-everything-after-character
3. https://www.geeksforgeeks.org/how-to-create-directory-if-it-does-not-exist-using-python/
4. https://realpython.com/iterate-through-dictionary-python/
5. https://www.geeksforgeeks.org/python-os-path-join-method/
6. https://www.geeksforgeeks.org/python-os-mkdir-method/
7. https://www.geeksforgeeks.org/python-string-find/
8. https://pythonexamples.org/python-regex-extract-find-all-the-numbers-in-string/
9. https://thispointer.com/extract-numbers-from-string-in-python/
"""