####################################################################################################
## Name: {Main Functions of Account Modeling File Automations}
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

# install libs
import os
import re
import shutil
import glob
from datetime import datetime

# define functions
def genFolderNames(year: int, srcPapiPath: str, dstCatPath: str) -> list[str]:
    # list to store file names
    names = []
    versions = []
    year = "_" + str(year)
    # save folder names to arrays
    for path in os.listdir(srcPapiPath):
        # check if current path is a folder
        if os.path.isdir(os.path.join(srcPapiPath, path)) and len(re.findall(year, os.path.join(srcPapiPath, path))) == 1:
            # remove spaces at the beginning and at the end of the string
            versions.append(path.strip())
            names.append(path.split("_", 1)[0].strip())
    # generate folders
    for name in names:
        if not os.path.exists(os.path.join(dstCatPath, name)):
            dir = os.path.join(dstCatPath, name)
            os.mkdir(dir)
    return versions, names

def oldNewNamesDict(versions: list[str], names: list[str]) -> dict[str, str]:
    """
    # convert two arrays into a dictionary
    keys: from T:\RSG Chicago\CAT Modeling\PAPI Reports\Xceedance\JEM\Compact Edition\Report
    values: from T:\CAT Modeling\CAT\JEM\Account Modeling\2022
    """
    res = {versions[i]: names[i] for i in range(len(versions))}
    #print("Resultant dictionary is : " + str(res))
    return res

def genFolders(res: dict[str, str], dstCatPath: str):
    # list to store subfolder names
    subFolders = ["final", "source", "working"]
    for key, value in res.items():
        # find the digit after _R 
        digit = -1
        digitList = re.findall("_R[0-9]+", key)   
        if len(digitList) > 0:
            tempStr = digitList[0]
            digit = int(re.findall(r'\d+', tempStr)[0])
        if digit != -1 and len(digitList) > 0 and len(re.findall("_R[0-9]+", key)) == 1 and not os.path.exists(os.path.join(dstCatPath, value, "rev_" + str(digit))):
            Rs_folder = os.path.join(dstCatPath, value, "rev_" + str(digit))
            os.mkdir(Rs_folder)
            if os.path.exists(Rs_folder):
                for i in range(len(subFolders)):
                    subFolder = os.path.join(Rs_folder, subFolders[i])
                    os.mkdir(subFolder)
        elif key.count("_") == 1 and not os.path.exists(os.path.join(dstCatPath, value, "ori")):
            ori_folder = os.path.join(dstCatPath, value, "ori")
            os.mkdir(ori_folder)
            if os.path.exists(ori_folder):
                for i in range(len(subFolders)):
                    subFolder = os.path.join(ori_folder, subFolders[i])
                    os.mkdir(subFolder)
        elif key.lower().count("_op") == 1 and len(re.findall("_R[0-9]+", key)) == 0 and not os.path.exists(os.path.join(dstCatPath, value, "ori")):
            ori_folder = os.path.join(dstCatPath, value, "ori")
            os.mkdir(ori_folder)
            if os.path.exists(ori_folder):
                for i in range(len(subFolders)):
                    subFolder = os.path.join(ori_folder, subFolders[i])
                    os.mkdir(subFolder)

def oriRevAbbr(string: str) -> str:
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

def copyFiles(res: dict[str, str], srcPapiPath: str, srcXcPath: str, dstCatPath: str):
    for key, value in res.items():
        # final
        for file in glob.glob(os.path.join(srcPapiPath, key, '*.xlsx')):
            # find a file name
            excelFileName = str(os.path.split(file)[1])
            # cur_file should be a list: len(list) >= 1
            curFolder = glob.glob(os.path.join(dstCatPath, value, '*/final'))
            for i in curFolder:
                # find an account version: ori, rev_12345
                accVersion = i.split(os.sep)[-2]
                # find an accout version abbreviation 
                #accVersionAbbr = accVersion[::len(accVersion)-1] #limitation: rev_9 is a maximum
                accVersionAbbr = oriRevAbbr(accVersion)
                # a file path
                copiedFileName = os.path.join(i, excelFileName)
                # ensure each src_version = dest_version and a reoprt isn't existing
                if not os.path.exists(copiedFileName) and len(re.findall("ori", accVersion)) == 1 and len(re.findall("R[0-9]+", excelFileName)) < 1:
                    shutil.copy(file, copiedFileName)
                elif not os.path.exists(copiedFileName) and len(re.findall(accVersionAbbr, excelFileName)) == 1:
                    shutil.copy(file, copiedFileName)
        # working
        for data in glob.glob(os.path.join(srcPapiPath, key, '*.txt')):
            textDataName = str(os.path.split(data)[1])
            # cur_file should be a list: len(list) >= 1
            curFolder = glob.glob(os.path.join(dstCatPath, value, '*/working'))
            for j in curFolder:
                # find an account version: ori, rev_12345
                accVersion = j.split(os.sep)[-2]
                # find an accout version abbreviation 
                #accVersionAbbr = accVersion[::len(accVersion)-1] #limitation: rev_9 is a maximum
                accVersionAbbr = oriRevAbbr(accVersion)
                # a file path
                copiedFileName = os.path.join(j, textDataName)
                # ensure each src_version = dest_version and a reoprt isn't existing
                if not os.path.exists(copiedFileName) and len(re.findall("ori", accVersion)) == 1 and len(re.findall("R[0-9]+", textDataName)) < 1 and textDataName != "PAPILog.txt" and textDataName != "RMSLog.txt":
                    shutil.copy(data, copiedFileName)
                elif not os.path.exists(copiedFileName) and len(re.findall(accVersionAbbr, textDataName)) == 1 and textDataName != "PAPILog.txt" and textDataName != "RMSLog.txt":
                    shutil.copy(data, copiedFileName)
        # source
        for xc in os.listdir(srcXcPath):
            if os.path.isdir(os.path.join(srcXcPath, xc.strip())):
                xcPaths = os.path.join(srcXcPath, xc.strip())
                if str(os.path.split(xcPaths)[1].lower()) == value.lower():
                    xcFolderVersions = glob.glob(os.path.join(xcPaths, '*'))
                    catFolderVersions = glob.glob(os.path.join(dstCatPath, value, '*'))
                    for xcFolderVersion in xcFolderVersions:
                        for catFolderVersion in catFolderVersions:
                            xcFolVerLower = [i.lower() for i in xcFolderVersion.split(os.sep) if len(xcFolderVersion.split(os.sep)) >= 2]
                            xcFolVerLower = xcFolVerLower[-2:]
                            catFolVerLower = [i.lower() for i in catFolderVersion.split(os.sep) if len(catFolderVersion.split(os.sep)) >= 2]
                            catFolVerLower = catFolVerLower[-2:]
                            if xcFolVerLower == catFolVerLower and len(xcFolderVersions) >= 1 and len(catFolderVersions) >= 1:
                                # ? match exactly one character - "Source" (old version) & "source" (new version) can be applied
                                # the lengh of "source" path is only 1 so there is no need to conduct a for-loop
                                xcFolderPath = glob.glob(os.path.join(xcFolderVersion, '?ource'))
                                catFolderPath = glob.glob(os.path.join(catFolderVersion, '?ource'))
                                xcFolPathLower = [i.lower() for i in xcFolderPath[0].split(os.sep) if len(xcFolderPath[0].split(os.sep)) >= 3]
                                catFolPathLower = [i.lower() for i in catFolderPath[0].split(os.sep) if len(catFolderPath[0].split(os.sep)) >= 3]
                                xcFolPathLower = xcFolPathLower[-3:]
                                catFolPathLower = catFolPathLower[-3:]
                                if xcFolPathLower == catFolPathLower:
                                    xcFilePaths = glob.glob(os.path.join(xcFolderPath[0], '*'))
                                    #catFilePaths = glob.glob(os.path.join(catFolderPath[0], '*'))
                                    cnt = 0
                                    for xcFilePath in xcFilePaths:
                                        fileName = str(os.path.split(xcFilePath)[1])
                                        if not os.path.exists(os.path.join(catFolderPath[0], fileName)) and os.path.isfile(xcFilePath):
                                            shutil.copy(xcFilePath, os.path.join(catFolderPath[0], fileName))
                                            #print("Copied")
                                            cnt += 1
                                    #print("ADD", cnt, "files")
                                    if cnt > 0:
                                        now = datetime.now()
                                        local_now = now.astimezone()
                                        local_tz = local_now.tzinfo
                                        with open(os.path.join(catFolderPath[0], 'path.txt'), 'w') as note:
                                            note.write('- The source file(s) is/are copied from "{}"\n- Latest Update: {} {}'.format(xcFolderPath[0], now, local_tz))

def autoAllFiles(year: int, srcPapiBU: str, srcXcPath: str, dstCatPath: str):
    srcPapiPaths = glob.glob(os.path.join('T:\RSG Chicago\CAT Modeling\PAPI Reports\*', srcPapiBU.strip(), '*\Report'))
    # iterate four paths: CAT/Compact Edition, CAT/Full Edition, Xceedance/Compact Edition, Xceedance/Full Edition
    for srcPapiPath in srcPapiPaths:
        versions, names = genFolderNames(year, srcPapiPath, dstCatPath)
        res = oldNewNamesDict(versions, names)
        genFolders(res, dstCatPath)
        copyFiles(res, srcPapiPath, srcXcPath, dstCatPath)
        #print("Completed:", srcPapiPath)

# An example of inputs 
#year = 2022
#srcPapiBU = "RT Tampa and Jupiter - Hume"
#srcXcPath = r'T:\Xceedance\RT\RT Tampa (and Jupiter) - Hume\2022'
#dstCatPath = r'U:\WORKS\Acc_Tools\PJAC06 - Files_Automation\JEM_test_files\JEM2022\destination1'

# execute
#autoAllFiles(year, srcPapiBU, srcXcPath, dstCatPath)
#print("ENDEND!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
