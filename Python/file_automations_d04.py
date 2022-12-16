"""
Author: Yunting Chiu
Email: <yunting.chiu@ryansg.com>
Date: 11/30/3022
Description: Save CAT account modeling reports and data files to T:/CAT drive automatically
"""
# install required packages
import sys
import os
import re
import shutil
import glob

# folder paths
source_path = r'U:\WORKS\Acc_Tools\PJAC06 - Files_Automation\JEM_test_files\JEM2022\source'
destination_path = r'U:\WORKS\Acc_Tools\PJAC06 - Files_Automation\JEM_test_files\JEM2022\destination'

def genFolderNames(source_path, destination_path):
    # list to store file names
    names = []
    versions = []
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

def genFolders(res):
    # list to store subfolder names
    subFolders = ["Final", "Source", "Working"]
    for key, value in res.items():
        # find the digit after _R 
        digit = -1
        digitList = re.findall("_R[0-9]+", key)   
        if len(digitList) > 0:
            tempStr = digitList[0]
            digit = int(re.findall(r'\d+', tempStr)[0])
        if digit != -1 and len(digitList) > 0 and len(re.findall("_R[0-9]+", key)) == 1 and not os.path.exists(os.path.join(destination_path, value,"Revised_" + str(digit))):
            Rs_folder = os.path.join(destination_path, value, "Revised_" + str(digit))
            os.mkdir(Rs_folder)
            if os.path.exists(Rs_folder):
                for i in range(len(subFolders)):
                    subFolder = os.path.join(Rs_folder, subFolders[i])
                    os.mkdir(subFolder)
        elif key.count("_") == 1 and not os.path.exists(os.path.join(destination_path, value, "Original")):
            Org_folder = os.path.join(destination_path, value, "Original")
            os.mkdir(Org_folder)
            if os.path.exists(Org_folder):
                for i in range(len(subFolders)):
                    subFolder = os.path.join(Org_folder, subFolders[i])
                    os.mkdir(subFolder)
        elif key.lower().count("_op") == 1 and len(re.findall("_R[0-9]+_", key)) == 0 and not os.path.exists(os.path.join(destination_path, value, "Original")):
            Org_folder = os.path.join(destination_path, value, "Original")
            os.mkdir(Org_folder)
            if os.path.exists(Org_folder):
                for i in range(len(subFolders)):
                    subFolder = os.path.join(Org_folder, subFolders[i])
                    os.mkdir(subFolder)

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


versions, names = genFolderNames(source_path, destination_path)
res = oldNewNamesDict(versions)
genFolders(res)


for key, value in res.items():
    for file in glob.glob(os.path.join(source_path, key, '*.xlsx')):
        excelFileName = str(os.path.split(file)[1])
        #print(" OUTER Key version:" , re.findall("R[0-9]+", key))
        #print("OUTER excelFileName version: ", re.findall("R[0-9]+", excelFileName))
        #print(excelFileName)
        # cur_file should be a list: len(list) >= 1
        curFolder = glob.glob(os.path.join(destination_path, value, '*/Final'))
        #if value == "FAIR PRICE PROPERTIES":
            #print(curFolder)
        #print(type(curFolder.pop()))
        for i in curFolder:
            # find an account version
            accVersion = i.split(os.sep)[-2]
            #print(accVersion)
            # find an accout version abbreviation 
            #accVersionAbbr = accVersion[::len(accVersion)-1] #limitation: Revised_9 is a maximum
            accVersionAbbr = originalRevisedAbbr(accVersion)
            #print(accVersionAbbr)
            copiedFileName = os.path.join(i, excelFileName)
            #print(copiedFileName)
            # ensure the src_version = dest_version and the reoprt isn't existing
            if not os.path.exists(copiedFileName) and len(re.findall("Original", accVersion)) == 1 and len(re.findall("R[0-9]+", excelFileName)) < 1:
                shutil.copy(file, copiedFileName)
            elif not os.path.exists(copiedFileName) and len(re.findall(accVersionAbbr, excelFileName)) == 1:
                shutil.copy(file, copiedFileName)













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
10. https://www.geeksforgeeks.org/python-os-path-split-method/
11. https://www.earthdatascience.org/courses/intro-to-earth-data-science/python-code-fundamentals/work-with-files-directories-paths-in-python/os-glob-manipulate-file-paths/
12. https://www.geeksforgeeks.org/python-program-to-convert-a-list-to-string/
13. https://www.w3schools.com/python/python_regex.asp
"""