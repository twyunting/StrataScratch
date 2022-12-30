import pandas as pd
from datetime import date

class dataObj:
    def __init__(self, _year, _srcPapiBU, _srcXcPath, _dstCatPath):
        self.year = _year
        self.srcPapiBU = _srcPapiBU
        self.srcXcPath = _srcXcPath
        self.dstCatPath = _dstCatPath

objArr = []
df = pd.read_csv('data.csv', header = None)
#print(df.iloc[0, 0])#row, column
#print(len(df))

"""
for i in range(len(df)):
    todays_date = date.today()
    _year = todays_date.year
    _srcPapiBU = df.iloc[0, 0]
    _srcXcPath = df.iloc[1, 0]
    _dstCatPath = df.iloc[2, 0]
    newObj = dataObj(_year, _srcPapiBU, _srcXcPath, _dstCatPath)
    objArr.append(newObj)
print(len(objArr))
"""

todays_date = date.today()
_year = todays_date.year
_srcPapiBU = df.iloc[0, 0]
_srcXcPath = df.iloc[1, 0]
_dstCatPath = df.iloc[2, 0]
newObj = dataObj(_year, _srcPapiBU, _srcXcPath, _dstCatPath)
objArr.append(newObj)
#print(objArr)




