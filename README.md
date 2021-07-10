# RIG-HeatMap

The code respository to go alongside the research paper:  
"How does temperature of a night during a heatwave differ with nearby land use?  
Using night of 26th to 27th of June as reference during the 2019 Swiss Summer Heat Wave".

## Overview
Done by Dominik Ummel, Michèle Grindat, Brian Schweigler for the lecture Research in Geography, at the university of Bern.

## Setup
To work with this project, we recommend R Studio and QGIS 3.16.X or higher.

## Repository Structure
- Daten für GIS: Contains files used in QGIS.
- Formatted: Further work on the outputted files from R (that were placed in output_reworked)
- Presentations: A backup of presentations held for this project (TODO Update and remove this comment).
- Temperaturverlauf: Output folder of temperature gradients over time for different loggers.
- output_reworked: Output files for data formatted with r.
- r_scripts: Collection of completely custom r scripts used.
- **R scripts on root level:**
  - The following files should be executed in order: Files 0_pre_proccessing.R, 1b_Processing_transect_means_orig.R, 2a_Spatial_and_temporal_Analysis.R, 4_diurnal_cycle_reduction_for GIS_orig.R
    - You can also just use the data from "output_reworked", instead of going through the R scripts again. 
  - Bicycle_2019.R: Reworks some of the raw data for easier use by combining GPS data with the measurements.
  - Logger_Vergleich.R: Compares 2-3 loggers.

## Data Sources
The data from the bicycle transects are from the field course in 2019 about the micrometeorlogical climata in Bern.
CWS data are available upon request.
Low-cost device (LOD) data is available upon request at the [institute of climatology at the giub](https://www.geography.unibe.ch/research/climatology_group/index_eng.html).

### More information is found in our research paper.

##### **Fahrradmessungen**
- Transekt1:     26.06.2019    18:01 bis 20:11
- Transekt2_3:   26.06.2019    20:16 bis 23:26
- Transekt4:     27.06.2019    02:10 bis 03:54
- Transekt5:     27.06.2019    04:09 bis 06:15
- Transekt6:     27.06.2019    06:44 bis 09:08
- Transekt7:     27.06.2019    11:24 bis 13:17
! Alle Zeiten sind GMT (CH im Sommer ist CEST, also GMT+2)

##### **Low Cost Logger**
- 15.05.2019 12:00 bis 15.09.2019 23:50:00. Zeitliche Auflösung 10min.
- Ca. 80 Stationen
! Zeiten sind wohl in CEST (???)

##### **Netatmo Citizen Weather Stations**
- 01.06.2019 01:00 bis 31.08.2019 23:00. Zeitliche Auflösung 1h.
- Ca. 900 Stationen (in Messperiode und innerhalb Stadt Bern wohl halb so viele).
 ! Zeiten Sind UTC (CH im Sommer ist CEST, also UTC+2)
- *time* ist die von der Qualitätskontrolle der nächsten Stunde (also 14:31 = 15:00; 14:29 = 14:00) zugeordnete Zeit
- *time_orig* ist der tatsächliche Messzeitpunkt
- ta_int: Lufttemperatur interpoliert durch Qualitätskontrolle Stufe o1 (Napoly et al. 2018)
- 'altitude'-Werte kommen von Netatmo und die 'z'-Höhenangaben sind aus dem SRTM abgeleitet.

#### **4_diurnal_cycle_reduction_for GIS_orig.R**
Script welches aus den Fahrradmessungen Nachtmittel (nächtlichen Temperaturverlauf (=nächtliche Abkühlung)) der low cost logger im Umkreis von 200m zu den gemessenen Fahrradtemperaturen hinzufügt. Für Fahrradmessungen im Umkreis von 500m von low cost loggern wurde die Temperaturanpassung der 200m Messungen interpoliert.

#### **Optional: 2a_Spatial_and_temporal_Analysis.R**
Berechnet mithilfe der im Script **0_pre_processing.R** in einem loop die invers-distanz-gewichtete mittlere Temperatur von CWS oder LOG im bestimmten Radien (=spatial distance) und zeitlicher distanz um jede Fahrradmessung. So kann jede Fahrradmessung mit CWS/LOG temperaturen in der Nähe verglichen werden. Dies ist für die Hitzekarte nicht relevant, aber falls ihr Interessiert seid, wie gut die Messungen übereinstimmen wäre das spannend. 
