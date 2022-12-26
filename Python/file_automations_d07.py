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
sourceXC_path = r'U:\WORKS\Acc_Tools\PJAC06 - Files_Automation\JEM_test_files\JEM2022\souceXC_01'
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
    subFolders = ["final", "source", "working"]
    for key, value in res.items():
        # find the digit after _R 
        digit = -1
        digitList = re.findall("_R[0-9]+", key)   
        if len(digitList) > 0:
            tempStr = digitList[0]
            digit = int(re.findall(r'\d+', tempStr)[0])
        if digit != -1 and len(digitList) > 0 and len(re.findall("_R[0-9]+", key)) == 1 and not os.path.exists(os.path.join(destination_path, value, "rev_" + str(digit))):
            Rs_folder = os.path.join(destination_path, value, "rev_" + str(digit))
            os.mkdir(Rs_folder)
            if os.path.exists(Rs_folder):
                for i in range(len(subFolders)):
                    subFolder = os.path.join(Rs_folder, subFolders[i])
                    os.mkdir(subFolder)
        elif key.count("_") == 1 and not os.path.exists(os.path.join(destination_path, value, "ori")):
            ori_folder = os.path.join(destination_path, value, "ori")
            os.mkdir(ori_folder)
            if os.path.exists(ori_folder):
                for i in range(len(subFolders)):
                    subFolder = os.path.join(ori_folder, subFolders[i])
                    os.mkdir(subFolder)
        elif key.lower().count("_op") == 1 and len(re.findall("_R[0-9]+", key)) == 0 and not os.path.exists(os.path.join(destination_path, value, "ori")):
            ori_folder = os.path.join(destination_path, value, "ori")
            os.mkdir(ori_folder)
            if os.path.exists(ori_folder):
                for i in range(len(subFolders)):
                    subFolder = os.path.join(ori_folder, subFolders[i])
                    os.mkdir(subFolder)

def oriRevisionAbbr(string):
    pattern = r'rev_(\d+)|ori'
    matches = re.findall(pattern, string)
    extracted_strings = []
    for match in matches:
        if match:
            extracted_strings.append("R" + match)
        else:
            extracted_strings.append("ORI")
    extracted_strings = extracted_strings.pop()
    return extracted_strings


versions, names = genFolderNames(source_path, destination_path)
res = oldNewNamesDict(versions)
genFolders(res)


#xcFoldersList = []
for key, value in res.items():
    for file in glob.glob(os.path.join(source_path, key, '*.xlsx')):
        # find a file name
        excelFileName = str(os.path.split(file)[1])
        # cur_file should be a list: len(list) >= 1
        curFolder = glob.glob(os.path.join(destination_path, value, '*/final'))
        for i in curFolder:
            # find an account version: ori, rev_12345
            accVersion = i.split(os.sep)[-2]
            # find an accout version abbreviation 
            #accVersionAbbr = accVersion[::len(accVersion)-1] #limitation: rev_9 is a maximum
            accVersionAbbr = oriRevisionAbbr(accVersion)
            # a file path
            copiedFileName = os.path.join(i, excelFileName)
            # ensure each src_version = dest_version and a reoprt isn't existing
            if not os.path.exists(copiedFileName) and len(re.findall("ori", accVersion)) == 1 and len(re.findall("R[0-9]+", excelFileName)) < 1:
                shutil.copy(file, copiedFileName)
            elif not os.path.exists(copiedFileName) and len(re.findall(accVersionAbbr, excelFileName)) == 1:
                shutil.copy(file, copiedFileName)
    for data in glob.glob(os.path.join(source_path, key, '*.txt')):
        textDataName = str(os.path.split(data)[1])
        # cur_file should be a list: len(list) >= 1
        curFolder = glob.glob(os.path.join(destination_path, value, '*/working'))
        for j in curFolder:
            # find an account version: ori, rev_12345
            accVersion = j.split(os.sep)[-2]
            # find an accout version abbreviation 
            #accVersionAbbr = accVersion[::len(accVersion)-1] #limitation: rev_9 is a maximum
            accVersionAbbr = oriRevisionAbbr(accVersion)
            # a file path
            copiedFileName = os.path.join(j, textDataName)
            # ensure each src_version = dest_version and a reoprt isn't existing
            if not os.path.exists(copiedFileName) and len(re.findall("ori", accVersion)) == 1 and len(re.findall("R[0-9]+", textDataName)) < 1 and textDataName != "PAPILog.txt" and textDataName != "RMSLog.txt":
                shutil.copy(data, copiedFileName)
            elif not os.path.exists(copiedFileName) and len(re.findall(accVersionAbbr, textDataName)) == 1 and textDataName != "PAPILog.txt" and textDataName != "RMSLog.txt":
                shutil.copy(data, copiedFileName)

    for xc in os.listdir(sourceXC_path):
        if os.path.isdir(os.path.join(sourceXC_path, xc.strip())):
            xcPaths = os.path.join(sourceXC_path, xc.strip())
            if str(os.path.split(xcPaths)[1].lower()) == value.lower():
                xcFolderVersions = glob.glob(os.path.join(xcPaths, '*'))
                catFolderVersions = glob.glob(os.path.join(destination_path, value, '*'))
                for xcFolderVersion in xcFolderVersions:
                    for catFolderVersion in catFolderVersions:
                        xcFolVerLower = [i.lower() for i in xcFolderVersion.split(os.sep)[-2:]]
                        catFolVerLower = [i.lower() for i in catFolderVersion.split(os.sep)[-2:]]
                        if xcFolVerLower == xcFolVerLower and len(xcFolderVersions) >= 1 and len(catFolderVersions) >= 1:
                            # ? match exactly one character - "Source" (old version) & "source" (new version) can be applied
                            # the lengh of "source" path is only 1 so there is no need to conduct a for-loop
                            xcFolderPath = glob.glob(os.path.join(xcFolderVersion, '?ource'))
                            catFolderPath = glob.glob(os.path.join(catFolderVersion, '?ource'))
                            xcFolPathLower = [i.lower() for i in xcFolderPath[0].split(os.sep)[-3:]]
                            catFolPathLower = [i.lower() for i in catFolderPath[0].split(os.sep)[-3:]]
                            if xcFolPathLower == catFolPathLower:
                                xcFilePaths = glob.glob(os.path.join(xcFolderPath[0], '*'))
                                #catFilePaths = glob.glob(os.path.join(catFolderPath[0], '*'))
                                for xcFilePath in xcFilePaths:
                                    fileName = str(os.path.split(xcFilePath)[1])
                                    if not os.path.exists(os.path.join(catFolderPath[0], fileName)) and os.path.isfile(xcFilePath):
                                        shutil.copy(xcFilePath, catFolderPath[0])
                                        print("Copied")



print("ENDEND!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

"""
References
1. https://www.stackvidhya.com/python-list-files-in-directory/
2. https://bobbyhadz.com/blog/python-remove-everything-after-character
3. https://www.geeksforieeks.ori/how-to-create-directory-if-it-does-not-exist-using-python/
4. https://realpython.com/iterate-through-dictionary-python/
5. https://www.geeksforieeks.ori/python-os-path-join-method/
6. https://www.geeksforieeks.ori/python-os-mkdir-method/
7. https://www.geeksforieeks.ori/python-string-find/
8. https://pythonexamples.ori/python-regex-extract-find-all-the-numbers-in-string/
9. https://thispointer.com/extract-numbers-from-string-in-python/
10. https://www.geeksforieeks.ori/python-os-path-split-method/
11. https://www.earthdatascience.ori/courses/intro-to-earth-data-science/python-code-fundamentals/work-with-files-directories-paths-in-python/os-glob-manipulate-file-paths/
12. https://www.geeksforieeks.ori/python-program-to-convert-a-list-to-string/
13. https://www.w3schools.com/python/python_regex.asp
14. https://stackoverflow.com/questions/72474704/how-to-count-the-uppercase-and-lowercase-letters-in-string-writing-lesser-code
"""