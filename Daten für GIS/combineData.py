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

concattedData22 = [["Typ", "ID", "Time", "Temp", "lon", "lat", "altitude"]]
concattedData23 = [["Typ", "ID", "Time", "Temp", "lon", "lat", "altitude"]]
concattedData00 = [["Typ", "ID", "Time", "Temp", "lon", "lat", "altitude"]]
concattedData01 = [["Typ", "ID", "Time", "Temp", "lon", "lat", "altitude"]]
concattedData02 = [["Typ", "ID", "Time", "Temp", "lon", "lat", "altitude"]]
concattedData03 = [["Typ", "ID", "Time", "Temp", "lon", "lat", "altitude"]]
concattedData04 = [["Typ", "ID", "Time", "Temp", "lon", "lat", "altitude"]]
concattedData05 = [["Typ", "ID", "Time", "Temp", "lon", "lat", "altitude"]]

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
while allnight[index][16][-8:-6] == "22":
    concattedData22.append(["Bicycle", 1, allnight[index][16], allnight[index][5], allnight[index][13], allnight[index][14], allnight[index][15]])
    index += 1

for i in range(2,len(log[0])):
    logno = log[0][i][4:]
    logM = findLogMeta(logno)

    temp = 0
    for j in range(13,19):
        temp += float(log[j][i])
    
    temp = round(temp/6,3)
    concattedData22.append(["Logger", 3, log[13][0], temp, logM[0], logM[1], logM[2]])

index = 2
while index < len(cws[0]):
    cwsno = cws[0][index][:4]
    cwsM = findCwsMeta(cwsno)
    concattedData22.append(["CWS", cws[3][index-1], cws[3][index], cwsM[0], cwsM[1], cwsM[2]])
    index += 2

with open("Data/concattedData22.csv", 'w', newline="") as output:
    writer = csv.writer(output, delimiter=",")
    writer.writerows(concattedData22)

#23
index = 232
while allnight[index][16][-8:-6] == "23":
    concattedData23.append(["Bicycle", 1, allnight[index][16], allnight[index][5], allnight[index][13], allnight[index][14], allnight[index][15]])
    index += 1

for i in range(2,len(log[0])):
    logno = log[0][i][4:]
    logM = findLogMeta(logno)

    temp = 0
    for j in range(19,25):
        temp += float(log[j][i])
    
    temp = round(temp/6,3)
    concattedData23.append(["Logger", 3, log[19][0], temp, logM[0], logM[1], logM[2]])

index = 2
while index < len(cws[0]):
    cwsno = cws[0][index][:4]
    cwsM = findCwsMeta(cwsno)
    concattedData23.append(["CWS", 2, cws[4][index-1], cws[4][index], cwsM[0], cwsM[1], cwsM[2]])
    index += 2

with open("Data/concattedData23.csv", 'w', newline="") as output:
    writer = csv.writer(output, delimiter=",")
    writer.writerows(concattedData23)

#00
index = 591
while allnight[index][16][-8:-6] == "00":
    concattedData00.append(["Bicycle", 1, allnight[index][16], allnight[index][5], allnight[index][13], allnight[index][14], allnight[index][15]])
    index += 1

for i in range(2,len(log[0])):
    logno = log[0][i][4:]
    logM = findLogMeta(logno)

    temp = 0
    for j in range(25,31):
        temp += float(log[j][i])
    
    temp = round(temp/6,3)
    concattedData00.append(["Logger", 3, log[25][0], temp, logM[0], logM[1], logM[2]])

index = 2
while index < len(cws[0]):
    cwsno = cws[0][index][:4]
    cwsM = findCwsMeta(cwsno)
    concattedData00.append(["CWS", 2, cws[5][index-1], cws[5][index], cwsM[0], cwsM[1], cwsM[2]])
    index += 2

with open("Data/concattedData00.csv", 'w', newline="") as output:
    writer = csv.writer(output, delimiter=",")
    writer.writerows(concattedData00)

#01
index = 943
while allnight[index][16][-8:-6] == "01":
    concattedData01.append(["Bicycle", 1, allnight[index][16], allnight[index][5], allnight[index][13], allnight[index][14], allnight[index][15]])
    index += 1

for i in range(2,len(log[0])):
    logno = log[0][i][4:]
    logM = findLogMeta(logno)

    temp = 0
    for j in range(31,37):
        temp += float(log[j][i])
    
    temp = round(temp/6,3)
    concattedData01.append(["Logger", 3, log[31][0], temp, logM[0], logM[1], logM[2]])

index = 2
while index < len(cws[0]):
    cwsno = cws[0][index][:4]
    cwsM = findCwsMeta(cwsno)
    concattedData01.append(["CWS", 2, cws[6][index-1], cws[6][index], cwsM[0], cwsM[1], cwsM[2]])
    index += 2

with open("Data/concattedData01.csv", 'w', newline="") as output:
    writer = csv.writer(output, delimiter=",")
    writer.writerows(concattedData01)

#02

for i in range(2,len(log[0])):
    logno = log[0][i][4:]
    logM = findLogMeta(logno)

    temp = 0
    for j in range(37,43):
        temp += float(log[j][i])
    
    temp = round(temp/6,3)
    concattedData02.append(["Logger", 3, log[37][0], temp, logM[0], logM[1], logM[2]])

index = 2
while index < len(cws[0]):
    cwsno = cws[0][index][:4]
    cwsM = findCwsMeta(cwsno)
    concattedData02.append(["CWS", 2, cws[7][index-1], cws[7][index], cwsM[0], cwsM[1], cwsM[2]])
    index += 2

with open("Data/concattedData02.csv", 'w', newline="") as output:
    writer = csv.writer(output, delimiter=",")
    writer.writerows(concattedData02)

#03

for i in range(2,len(log[0])):
    logno = log[0][i][4:]
    logM = findLogMeta(logno)

    temp = 0
    for j in range(43,49):
        temp += float(log[j][i])
    
    temp = round(temp/6,3)
    concattedData03.append(["Logger", 3, log[43][0], temp, logM[0], logM[1], logM[2]])

index = 2
while index < len(cws[0]):
    cwsno = cws[0][index][:4]
    cwsM = findCwsMeta(cwsno)
    concattedData03.append(["CWS", 2, cws[8][index-1], cws[8][index], cwsM[0], cwsM[1], cwsM[2]])
    index += 2

with open("Data/concattedData03.csv", 'w', newline="") as output:
    writer = csv.writer(output, delimiter=",")
    writer.writerows(concattedData03)

#04
index = 1099
while allnight[index][16][-8:-6] == "04":
    concattedData04.append(["Bicycle", 1, allnight[index][16], allnight[index][5], allnight[index][13], allnight[index][14], allnight[index][15]])
    index += 1

for i in range(2,len(log[0])):
    logno = log[0][i][4:]
    logM = findLogMeta(logno)
    
    temp = 0
    for j in range(49,55):
        temp += float(log[j][i])
    
    temp = round(temp/6,3)
    concattedData04.append(["Logger", 3, log[49][0], temp, logM[0], logM[1], logM[2]])

index = 2
while index < len(cws[0]):
    cwsno = cws[0][index][:4]
    cwsM = findCwsMeta(cwsno)
    concattedData04.append(["CWS", 2, cws[9][index-1], cws[9][index], cwsM[0], cwsM[1], cwsM[2]])
    index += 2

with open("Data/concattedData04.csv", 'w', newline="") as output:
    writer = csv.writer(output, delimiter=",")
    writer.writerows(concattedData04)

#05
index = 1288
while allnight[index][16][-8:-6] == "05":
    concattedData05.append(["Bicycle", 1, allnight[index][16], allnight[index][5], allnight[index][13], allnight[index][14], allnight[index][15]])
    if index == len(allnight)-1:
        break
    index += 1

for i in range(2,len(log[0])):
    logno = log[0][i][4:]
    logM = findLogMeta(logno)

    temp = 0
    for j in range(55,61):
        temp += float(log[j][i])
    
    temp = round(temp/6,3)
    concattedData05.append(["Logger", 3, log[55][0], temp, logM[0], logM[1], logM[2]])

index = 2
while index < len(cws[0]):
    cwsno = cws[0][index][:4]
    cwsM = findCwsMeta(cwsno)
    concattedData05.append(["CWS", 2, cws[10][index-1], cws[10][index], cwsM[0], cwsM[1], cwsM[2]])
    index += 2

with open("Data/concattedData05.csv", 'w', newline="") as output:
    writer = csv.writer(output, delimiter=",")
    writer.writerows(concattedData05)

#All
allData= concattedData22 + concattedData23[1:] + concattedData00[1:] + concattedData01[1:] + concattedData02[1:] + concattedData03[1:] + concattedData04[1:] + concattedData05[1:]
with open("Data/concattedDataAll.csv", 'w', newline="") as output:
    writer = csv.writer(output, delimiter=",")
    writer.writerows(allData)