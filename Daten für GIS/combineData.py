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

concattedData22 = [["Typ", "Time", "Temp", "lon", "lat", "altitude"]]
concattedData23 = [["Typ", "Time", "Temp", "lon", "lat", "altitude"]]
concattedData00 = [["Typ", "Time", "Temp", "lon", "lat", "altitude"]]
concattedData01 = [["Typ", "Time", "Temp", "lon", "lat", "altitude"]]
concattedData02 = [["Typ", "Time", "Temp", "lon", "lat", "altitude"]]
concattedData03 = [["Typ", "Time", "Temp", "lon", "lat", "altitude"]]
concattedData04 = [["Typ", "Time", "Temp", "lon", "lat", "altitude"]]
concattedData05 = [["Typ", "Time", "Temp", "lon", "lat", "altitude"]]

for i in range(0, len(files)):
    if files[i] == "all_night_means_22_06.csv":
        allnight = readCSV(files[i])
    elif files[i] == "cws_be_2019.csv":
        cws = readCSV(files[i])
    elif files[i] == "cws_be_2019_meta.csv":
        cwsMeta = readCSV(files[i])
    elif files[i] == "log.csv":
        log = readCSV(files[i])
    elif files[i] == "log_meta.csv":
        logMeta = readCSV(files[i])

def findLogMeta(logno):
    for i in range(1,len(logMeta)):
        if logno == logMeta[i][1]:
            return [logMeta[i][4], logMeta[i][3], logMeta[i][5]]
    
    return ["NA", "NA", "NA"]

def findCwsMeta(cwsno):
    for i in range(1,len(cwsMeta)):
        if cwsno == cwsMeta[i][2]:
            return [cwsMeta[i][3], cwsMeta[i][4], cwsMeta[i][5]]
    
    return ["NA", "NA", "NA"]

#22
index = 1
while allnight[index][3][:-2] == "22":
    concattedData22.append(["Bicycle", "26.06.2019 " + allnight[index][3][:2] + ":" + allnight[index][3][-2:], allnight[index][5], allnight[index][13], allnight[index][14], allnight[index][15]])
    index += 1

for i in range(2,len(log[0])):
    logno = log[0][i][4:]
    logM = findLogMeta(logno)

    for j in range(13,19):

        concattedData22.append(["Logger", log[j][0], log[j][i], logM[0], logM[1], logM[2]])

index = 2
while index < len(cws[0]):
    cwsno = cws[0][index][:4]
    cwsM = findCwsMeta(cwsno)
    concattedData22.append(["CWS", "26.06.2019 22:00", cws[3][i], cwsM[0], cwsM[1], cwsM[2]])
    index += 2

with open("Data/concattedData22.csv", 'w', newline="") as output:
    writer = csv.writer(output, delimiter=",")
    writer.writerows(concattedData22)

