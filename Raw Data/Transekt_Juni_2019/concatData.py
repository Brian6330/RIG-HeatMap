## Script to concat the Transekt csv 

import os
import re
import csv

def readCSV(filename):
    readFile = open(filename, errors="ignore")
    reader = csv.reader((line.replace('\0','') for line in readFile), delimiter=",")
    dataArray = []
    for row in reader:
        dataArray.append(row)

    readFile.close()
    return dataArray

files = os.listdir()

pattern = re.compile("\d.*\.CSV")

concattedData = [["INDEX", "TAG", "DATE", "TIME", "LATITUDE N/S", "LONGITUDE E/W", "HEIGHT", "SPEED", "HEADING", "FIX MODE", "VALID", "PDOP", "HDOP", "VDOP", "VOX"]]

for i in range(0, len(files)):
    if pattern.match(files[i]):
        print(files[i])
        concattedData += readCSV(files[i])[1:]

for i in range(1, len(concattedData)):
    concattedData[i][0] = i

with open("Transsekt_Juni_2019.csv", 'w', newline="") as output:
    writer = csv.writer(output, delimiter=",")
    writer.writerows(concattedData)

