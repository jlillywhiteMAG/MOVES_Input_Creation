#####################################################################################
########   Load tdm2moves_mysql_2050 database  WEEKDAY: UT County   ####
#####################################################################################

###update cdm base files moves3_cdm_basefiles_31 to moves3.1_cdm_basefiles_33
# delete FROM rtp24_2050_pm25_m4_in.auditlog;
# to update change the PATH in the following strings
# rtp24_2050_pm25_m4_in
#
# change yearid if modeling different year
# update yearid = 2050 yearID <> 2050
# delete dayID = 2 for weekday database
# hourDayID not in (15,25,35,45,55,65,75,85,95,105,115,125,135,145,155,165,175,185,195,205,215,225,235,245)

##############   Utah COUNTY _2050_  Weekday ID: 49049 #################################################################
#################################################################################################################################
## Load UT Vehicle Activity Data: (Age from DAQ), (Population from DAQ), VMT by Vehicle, Hour Fraction, Road Distribution, Speed Profile ##############
#################################################################################################################################

# I don't understand what this does#
#FLUSH TABLES;#
#use rtp24_2050_pm25_m4_in#;

#truncate sourcetypeagedistribution;
truncate hourVMTfraction;
truncate avgspeeddistribution;
truncate HPMSvtypeday;
truncate roadtypedistribution;
#truncate sourcetypeyear;

### Using DAQ SourceTypeYear aka Population xxUse WFRC age profile from DMV 2020 data for Vehicles 11, 21, 31, 32xx #########
#insert into  sourcetypeagedistribution
#SELECT sourcetypeid, yearID, ageID, ageFraction
#FROM wfrc_parameters.vehicle_age_dmv_2020_ld
#where countyID = 49003
#and yearid = 2050;

### Use MOVES4 Default Age for HD vehicle types 41,42,43,51,52,53,54,61,62 ###
#insert into  sourcetypeagedistribution
#SELECT * FROM movesdb20240104.sourcetypeagedistribution
#where sourcetypeid in (41,42,43,51,52,53,54,61,62)
#and yearid = 2050
#order by sourcetypeid, ageid;

insert into  hourvmtfraction
SELECT sourcetypeid, roadTypeID, dayID, hourID, hourVMTFraction
FROM tdm2moves_parameters.hourvmtfraction_mag2024
where dayID = 5;

insert into roadtypedistribution
SELECT 	sourcetypeid, roadtypeID2345 AS roadTypeID, 
		round(sum(Jan_roadVMTFraction),4) AS roadTypeVMTFraction 
FROM tdm2moves_mysql_2050.1mv_road_dist_county
where County_FIPS = 49
GROUP BY sourceTypeID, roadtypeID2345
;

insert into  hpmsvtypeday
SELECT yearID, monthID, dayID, HPMSVtypeID, HPMS_VMT_w as VMT
FROM tdm2moves_mysql_2050.2mv_vmtbyveh_dist_county
where County_FIPS = 49
;

UPDATE hpmsvtypeday
SET monthID = 1
;

insert into  hpmsvtypeday
SELECT yearID, monthID, dayID, HPMSVtypeID, HPMS_VMT_s as VMT
FROM tdm2moves_mysql_2050.2mv_vmtbyveh_dist_county
where County_FIPS = 49
;

#insert into  sourcetypeyear
#SELECT yearID, sourceTypeID, salesGrowthFactor, sourceTypePopulation, migrationrate
#FROM tdm2moves_mysql_2050.3mv_vehpop_dist_county
#where County_FIPS = 49;

insert into  avgspeeddistribution
SELECT sourcetypeid, roadTypeID2345 as roadTypeID, hourDayID, avgSpeedBinID, avgSpeedFraction_w as avgSpeedFraction
FROM tdm2moves_mysql_2050.4mv_speed_dist_county
where County_FIPS = 49;