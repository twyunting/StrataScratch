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

# list to store files
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

#print(names[:5])
#print(versions[:5])

# convert two arrays into a dictionary
res = {versions[i]: names[i] for i in range(len(versions))}
#print("Resultant dictionary is : " + str(res))

for key, value in res.items():
    if key.count("_") == 1 and not os.path.exists(os.path.join(destination_path, value, "Orginal")):
        Org_folder = os.path.join(destination_path, value, "Orginal")
        os.mkdir(Org_folder)
    elif key.count("_OP") == 1 and len(re.findall("_R[0-9]+_", key)) == 0 and not os.path.exists(os.path.join(destination_path, value, "Orginal")):
    #elif key.count("_OP") == 1 and key.find("_R") == -1 and not os.path.exists(os.path.join(destination_path, value, "Orginal")):
        Org_folder = os.path.join(destination_path, value, "Orginal")
        os.mkdir(Org_folder)
    elif len(re.findall("_R[0-9]+_", key)) == 1 and not os.path.exists(os.path.join(destination_path, value, "Revised_TEST")):
        temp1 = re.findall("_R[0-9]+_", key)
        temp1 = ".".join([str(temp1) for x in temp1])
        #print(type(temp1))
        #print(temp1)
        temp2 = re.findall("[0-9]+", temp1)
        #print(temp2)
        temp2 = ".".join([str(temp2) for y in temp2])
        Rs_folder = os.path.join(destination_path, value, "Revised_" + temp2)
        os.mkdir(Rs_folder)



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
