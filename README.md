# RIG-HeatMap

Csv --> GPS Einträg
DAT file --> tatsächliche Messwerte



GPS Messung auf DAT ''drauflegen'
Sollte ein schönes CSV rausspucken



### **Datenbeschreibung**

##### ***Fahrradmessungen\***

- Transekt1:     26.06.2019    18:01 bis 20:11
- Transekt2_3:   26.06.2019    20:16 bis 23:26
- Transekt4:     27.06.2019    02:10 bis 03:54
- Transekt5:     27.06.2019    04:09 bis 06:15
- Transekt6:     27.06.2019    06:44 bis 09:08
- Transekt7:     27.06.2019    11:24 bis 13:17

! Alle Zeiten sind GMT (CH im Sommer ist CEST, also GMT+2)

 

Eine Nacht während einer Hitzewelle im Juni 2019. Zeitliche Auflösung 10s.

 

##### ***Low Cost Logger\***

- 15.05.2019 12:00 bis 15.09.2019 23:50:00. Zeitliche Auflösung 10min.
- Ca. 80 Stationen

! Zeiten sind wohl in CEST (kläre ich noch ab)



##### ***Netatmo Citizen Weather Stations\***

- 01.06.2019 01:00 bis 31.08.2019 23:00. Zeitliche Auflösung 1h.

- Ca. 900 Stationen (in Messperiode und innerhalb Stadt Bern wohl halb so viele).

 ! Zeiten Sind UTC (CH im Sommer ist CEST, also UTC+2)

 

- *time* ist die von der Qualitätskontrolle der nächsten Stunde (also 14:31 = 15:00; 14:29 = 14:00) zugeordnete Zeit
- *time_orig* ist der tatsächliche Messzeitpunkt
- ta_int: Lufttemperatur interpoliert durch Qualitätskontrolle Stufe o1 (Napoly et al. 2018)
- 'altitude'-Werte kommen von Netatmo und die 'z'-Höhenangaben sind aus dem SRTM abgeleitet.

 

### **Beschreibung Scripts Hitzekarten**

#### **Bicycle_2019.R**

Script für die Fahrradmessungen 2019 zum Kombinieren der .csv (enthalten GPS Daten) und .dat (enthalten Messwerte) files. Hiermit könnt ihr die Fahrraddaten einlesen, kombinieren und dann in euerem gewünschten Format ausgeben. Dieses script sollte mit euren Daten funktionieren.

#### **0_pre_processing.R**

Auslesen, aussortieren, umformatieren, etc. der relevanten Daten. Erstellen von Matrizen mit der Distanz (rämlich = spatial; zeitlich = temporal) zwischen den Fahrradmessungen und den Netatmo Stationen (CWS) und low cost loggern (LOG). Die meisten weiteren Scripts verwenden als Input die output Daten von diesem. Hier habe ich ein wenig angepasst.

 

Zusatz 30.03:

- TODO: Check that time is correct, line 36/37
-  43-47 only if a file with all bicycle routes
- 112 delete unnneded files
- TODO Check line 147-ish for alternatives
- TODO Check for no Dach-Stationen (linie 163-ish)
- TODO Check Index offset
- TODO Maybe filter data or lat/long values -> Maybe check for speed via lat/long difference (too slow, remove)

#### **1b_Processing_transect_means_orig.R**

Berechnet die Mittelwerte für CWS oder LOG während bestimmten Zeiträumen (z.B. über die ganze Nacht oder für einen Transekt). Nicht angepasst.



Zusatz 30.3:

#### **2a_Spatial_and_temporal_Analysis.R**

Berechnet mithilfe der im Script ***0_pre_processing.R\*** in einem loop die invers-distanz-gewichtete mittlere Temperatur von CWS oder LOG im bestimmten Radien (=spatial distance) und zeitlicher distanz um jede Fahrradmessung. So kann jede Fahrradmessung mit CWS/LOG temperaturen in der Nähe verglichen werden. Dies ist für die Hitzekarte nicht relevant, aber falls ihr Interessiert seid, wie gut die Messungen übereinstimmen wäre das spannend. Das Loop unbedingt Zeile für Zeile testen, bevor man es laufen lässt. Nicht angepasst.

Zusatz 30.3

- Only compare measurements if in a distance of 200m (500m would be too much!)
- Todo same length and width as bicycle measurements - then it can calculate the distances

#### **4_diurnal_cycle_reduction_for GIS_orig.R**

Script welches aus den Fahrradmessungen Nachtmittel berechnet indem es den nächtlichen Temperaturverlauf (=nächtliche Abkühlung) der low cost logger im Umkreis von 200m zu den gemessenen Fahrradtemperaturen hinzufügt. Für Fahrradmessungen im Umkreis von 500m von low cost loggern wurde die Temperaturanpassung der 200m Messungen interpoliert. Nicht angepasst.

 

 

 

 

 

 