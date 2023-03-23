DROP TABLE IF EXISTS [modelling_sql_area].[dbo].[SWD_PHM_Diabetes_Procedures]			

/* limit period to exclude dates with no data from Mendip Vale */
DECLARE @STARTDATE AS Datetime
SET @STARTDATE =  '20201001'
DECLARE @ENDDATE AS Datetime
SET @ENDDATE =  '20210930'

SELECT 
	a.[AIMTC_Pseudo_NHS],
		CASE WHEN left(a.AdmissionMethod_HospitalProviderSpell,1) in ('2','3','8') THEN 'NEL' WHEN left(a.AdmissionMethod_HospitalProviderSpell,1) = '1' THEN 'EL'  ELSE 'Other' END AS Admission_Method , 
	a.AdmissionMethod_HospitalProviderSpell,
	a.AIMTC_ProviderSpell_Start_Date,
	DATEADD(month, DATEDIFF(month, 0, a.AIMTC_ProviderSpell_End_Date), 0) AS StartOfMonth,
	a.AIMTC_ProviderSpell_End_Date,
	a.DischargeDate_FromHospitalProviderSpell,	
--Month--
	CASE WHEN datepart(month,a.AIMTC_ProviderSpell_End_Date) >= 4 THEN '0'+ cast (datepart(month,a.AIMTC_ProviderSpell_End_Date)-3 AS VARCHAR(2)) ELSE cast (datepart(month,a.AIMTC_ProviderSpell_End_Date)+9 AS VARCHAR(2))
		END  + '_' + left(datename(month,a.AIMTC_ProviderSpell_End_Date),3) AS 'FinEndMonth',
  -- Financial Year
	CASE WHEN DATEPART(quarter,a.AIMTC_ProviderSpell_End_Date)=1 THEN datename(yy,dateadd(yy,-1,a.AIMTC_ProviderSpell_End_Date))+'-'+datename(yy,a.AIMTC_ProviderSpell_End_Date)
		ELSE datename(yy,a.AIMTC_ProviderSpell_End_Date)+'-'+datename(yy,dateadd(yy,1,a.AIMTC_ProviderSpell_End_Date)) END AS 'FinYear',
	left(a.OrganisationCode_CodeOfProvider,3) AS 'OrganisationCode_CodeOfProvider',
left(a.OrganisationCode_CodeOfCommissioner,3) as 'OrganisationCode_CodeOfCommissioner',													
a.AIMTC_PracticeCodeOfRegisteredGP,		
	CASE WHEN left (a.OrganisationCode_CodeofProvider,3) In ('RVJ') THEN a.OrganisationCode_CodeofProvider ELSE 'Other' END AS TrustGroup,		
	CASE WHEN left (a.OrganisationCode_CodeofProvider,3) = 'RVJ' THEN 'NBT' WHEN left (a.OrganisationCode_CodeofProvider,3) = 'RA3' THEN 'Weston' WHEN left (a.OrganisationCode_CodeofProvider,3) = 'RA7' THEN 'UHB'
		ELSE 'Other' END AS TrustGroupLocal,	
	CASE WHEN a.AIMTC_AGE between 0 and 15 THEN '0 to 15' WHEN a.AIMTC_AGE between 16 and 64 THEN '16 to 64' WHEN a.AIMTC_AGE between 65 and 74 THEN '65 to 74' WHEN a.AIMTC_AGE between 75 and 84 THEN '75 to 84'												
		WHEN a.AIMTC_AGE >84 THEN '85+' ELSE 'UNKNOWN' END AS Agegroup,	
	CASE WHEN a.AIMTC_AGE between 0 and 17 THEN '0-17' WHEN a.AIMTC_AGE >18 THEN '18+' ELSE 'UNKNOWN' END AS Agegroup2,	
	[Analyst_SQL_Area].[dbo].[fn_BNSSG_Age_5yr] (a.AIMTC_AGE) AS Age_Band_5YR,											
	CASE WHEN left (a.PrimaryProcedure_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major' WHEN left(a.Procedure2nd_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major'												
		WHEN left(a.Procedure3rd_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major' WHEN left(a.Procedure4th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major'												
		WHEN left(a.Procedure5th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major' WHEN left(a.Procedure6th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major'												
		WHEN left(a.Procedure7th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major' WHEN left(a.Procedure8th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major'												
		WHEN left(a.Procedure9th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major' WHEN left(a.Procedure10th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major'	
		WHEN left(a.Procedure11th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major' WHEN left(a.Procedure12th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major'	
		WHEN left(a.Procedure13th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major' WHEN left(a.Procedure14th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major'	
		WHEN left(a.Procedure15th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major' WHEN left(a.Procedure16th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major'	
		WHEN left(a.Procedure17th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major' WHEN left(a.Procedure18th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major'	
		WHEN left(a.Procedure19th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major' WHEN left(a.Procedure20th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major'		
		WHEN left(a.Procedure21st_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major' WHEN left(a.Procedure22nd_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major'		
		WHEN left(a.Procedure23rd_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation_major' 
		
		WHEN left (a.PrimaryProcedure_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure2nd_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure3rd_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor'
		WHEN left(a.Procedure4th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure5th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure6th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor'												
		WHEN left(a.Procedure7th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure8th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure9th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor'	
		WHEN left(a.Procedure10th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure11th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure12th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor'	
		WHEN left(a.Procedure13th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure14th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure15th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor'	
		WHEN left(a.Procedure16th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure17th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure18th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor'	
		WHEN left(a.Procedure19th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure20th_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure21st_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor'	
		WHEN left(a.Procedure22nd_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' WHEN left(a.Procedure23rd_OPCS,3) IN ('X10','X11') THEN 'Amputation_minor' 
		
		WHEN left (a.PrimaryProcedure_OPCS,3) = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure2nd_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure3rd_OPCS,3)  = 'X12' THEN 'Operations on amputation stump'												
		WHEN left(a.Procedure4th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure5th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure6th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump'												
		WHEN left(a.Procedure7th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure8th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump'	WHEN left(a.Procedure9th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump'	
		WHEN left(a.Procedure10th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure11th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure12th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump'	
		WHEN left(a.Procedure13th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure14th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure15th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump'	
		WHEN left(a.Procedure16th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure17th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure18th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump'	
		WHEN left(a.Procedure19th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure20th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure21st_OPCS,3)  = 'X12' THEN 'Operations on amputation stump'	
		WHEN left(a.Procedure22nd_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure23rd_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' ELSE 'Not_Amputation' END AS Amputation_Class,													
---------------------
	CASE WHEN left (a.PrimaryProcedure_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation' WHEN left(a.Procedure2nd_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation'												
		WHEN left(a.Procedure3rd_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation' WHEN left(a.Procedure4th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation'												
		WHEN left(a.Procedure5th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation' WHEN left(a.Procedure6th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation'												
		WHEN left(a.Procedure7th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation' WHEN left(a.Procedure8th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation'												
		WHEN left(a.Procedure9th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation' WHEN left(a.Procedure10th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation'	
		WHEN left(a.Procedure11th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation' WHEN left(a.Procedure12th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation'	
		WHEN left(a.Procedure13th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation' WHEN left(a.Procedure14th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation'	
		WHEN left(a.Procedure15th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation' WHEN left(a.Procedure16th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation'	
		WHEN left(a.Procedure17th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation' WHEN left(a.Procedure18th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation'	
		WHEN left(a.Procedure19th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation' WHEN left(a.Procedure20th_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation'		
		WHEN left(a.Procedure21st_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation' WHEN left(a.Procedure22nd_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation'		
		WHEN left(a.Procedure23rd_OPCS,4) IN ('X091','X092','X093', 'X094','X095','X098','X099') THEN 'Amputation' 
		
		WHEN left (a.PrimaryProcedure_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure2nd_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure3rd_OPCS,3) IN ('X10','X11') THEN 'Amputation'
		WHEN left(a.Procedure4th_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure5th_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure6th_OPCS,3) IN ('X10','X11') THEN 'Amputation'												
		WHEN left(a.Procedure7th_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure8th_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure9th_OPCS,3) IN ('X10','X11') THEN 'Amputation'	
		WHEN left(a.Procedure10th_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure11th_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure12th_OPCS,3) IN ('X10','X11') THEN 'Amputation'	
		WHEN left(a.Procedure13th_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure14th_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure15th_OPCS,3) IN ('X10','X11') THEN 'Amputation'	
		WHEN left(a.Procedure16th_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure17th_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure18th_OPCS,3) IN ('X10','X11') THEN 'Amputation'	
		WHEN left(a.Procedure19th_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure20th_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure21st_OPCS,3) IN ('X10','X11') THEN 'Amputation'	
		WHEN left(a.Procedure22nd_OPCS,3) IN ('X10','X11') THEN 'Amputation' WHEN left(a.Procedure23rd_OPCS,3) IN ('X10','X11') THEN 'Amputation' 
		
		WHEN left (a.PrimaryProcedure_OPCS,3) = 'X12' THEN 'Amputation' WHEN left(a.Procedure2nd_OPCS,3)  = 'X12' THEN 'Amputation' WHEN left(a.Procedure3rd_OPCS,3)  = 'X12' THEN 'Amputation'												
		WHEN left(a.Procedure4th_OPCS,3)  = 'X12' THEN 'Amputation' WHEN left(a.Procedure5th_OPCS,3)  = 'X12' THEN 'Amputation' WHEN left(a.Procedure6th_OPCS,3)  = 'X12' THEN 'Amputation'												
		WHEN left(a.Procedure7th_OPCS,3)  = 'X12' THEN 'Amputation' WHEN left(a.Procedure8th_OPCS,3)  = 'X12' THEN 'Amputation'	WHEN left(a.Procedure9th_OPCS,3)  = 'X12' THEN 'Amputation'	
		WHEN left(a.Procedure10th_OPCS,3)  = 'X12' THEN 'Amputation' WHEN left(a.Procedure11th_OPCS,3)  = 'X12' THEN 'Amputation' WHEN left(a.Procedure12th_OPCS,3)  = 'X12' THEN 'Amputation'	
		WHEN left(a.Procedure13th_OPCS,3)  = 'X12' THEN 'Amputation' WHEN left(a.Procedure14th_OPCS,3)  = 'X12' THEN 'Amputation' WHEN left(a.Procedure15th_OPCS,3)  = 'X12' THEN 'Amputation'	
		WHEN left(a.Procedure16th_OPCS,3)  = 'X12' THEN 'Amputation' WHEN left(a.Procedure17th_OPCS,3)  = 'X12' THEN 'Amputation' WHEN left(a.Procedure18th_OPCS,3)  = 'X12' THEN 'Amputation'	
		WHEN left(a.Procedure19th_OPCS,3)  = 'X12' THEN 'Amputation' WHEN left(a.Procedure20th_OPCS,3)  = 'X12' THEN 'Amputation' WHEN left(a.Procedure21st_OPCS,3)  = 'X12' THEN 'Amputation'	
		WHEN left(a.Procedure22nd_OPCS,3)  = 'X12' THEN 'Amputation' WHEN left(a.Procedure23rd_OPCS,3)  = 'X12' THEN 'Amputation' ELSE 'Foot Procedure' END AS 'Amputation/Footprocedure',									
---------------------																						
	CASE WHEN left (a.PrimaryProcedure_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg' WHEN left(a.Procedure2nd_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg' WHEN left(a.Procedure3rd_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg'				
		WHEN left(a.Procedure4th_OPCS,3)  in ('X093','X094','X095') THEN 'Amputation of lower leg' WHEN left(a.Procedure5th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg' WHEN left(a.Procedure6th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg'														
		WHEN left(a.Procedure7th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg' WHEN left(a.Procedure8th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg' WHEN left(a.Procedure9th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg'			
		WHEN left(a.Procedure10th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg' WHEN left(a.Procedure11th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg' WHEN left(a.Procedure12th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg'			
		WHEN left(a.Procedure13th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg' WHEN left(a.Procedure14th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg' WHEN left(a.Procedure15th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg'			
		WHEN left(a.Procedure16th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg' WHEN left(a.Procedure17th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg' WHEN left(a.Procedure18th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg'			
		WHEN left(a.Procedure19th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg' WHEN left(a.Procedure20th_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg' WHEN left(a.Procedure21st_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg'			
		WHEN left(a.Procedure22nd_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg'			
		WHEN left(a.Procedure23rd_OPCS,4) in ('X093','X094','X095') THEN 'Amputation of lower leg'		
	
		WHEN left (a.PrimaryProcedure_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure2nd_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure3rd_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure4th_OPCS,3) = 'X09' THEN 'Amputation of leg'												
		WHEN left(a.Procedure5th_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure6th_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure7th_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure8th_OPCS,3) = 'X09' THEN 'Amputation of leg'												
		WHEN left(a.Procedure9th_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure10th_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure11th_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure12th_OPCS,3) = 'X09' THEN 'Amputation of leg'	
		WHEN left(a.Procedure13th_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure14th_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure15th_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure16th_OPCS,3) = 'X09' THEN 'Amputation of leg'	
		WHEN left(a.Procedure17th_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure18th_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure19th_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure20th_OPCS,3) = 'X09' THEN 'Amputation of leg'	
		WHEN left(a.Procedure21st_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure22nd_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left(a.Procedure23rd_OPCS,3) = 'X09' THEN 'Amputation of leg' WHEN left (a.PrimaryProcedure_OPCS,3) = 'X10' THEN 'Amputation of foot'												
		WHEN left(a.Procedure2nd_OPCS,3) = 'X10' THEN 'Amputation of foot' WHEN left(a.Procedure3rd_OPCS,3) = 'X10' THEN 'Amputation of foot' WHEN left(a.Procedure4th_OPCS,3) = 'X10' THEN 'Amputation of foot' WHEN left(a.Procedure5th_OPCS,3) = 'X10' THEN 'Amputation of foot'												
		WHEN left(a.Procedure6th_OPCS,3) = 'X10' THEN 'Amputation of foot' WHEN left(a.Procedure7th_OPCS,3) = 'X10' THEN 'Amputation of foot' WHEN left(a.Procedure8th_OPCS,3) = 'X10' THEN 'Amputation of foot' WHEN left(a.Procedure9th_OPCS,3) = 'X10' THEN 'Amputation of foot'	
		WHEN left(a.Procedure10th_OPCS,3) = 'X10' THEN 'Amputation of foot' WHEN left(a.Procedure11th_OPCS,3) = 'X10' THEN 'Amputation of foot' WHEN left(a.Procedure12th_OPCS,3) = 'X10' THEN 'Amputation of foot' WHEN left(a.Procedure13th_OPCS,3) = 'X10' THEN 'Amputation of foot'	
		WHEN left(a.Procedure14th_OPCS,3) = 'X10' THEN 'Amputation of foot' WHEN left(a.Procedure15th_OPCS,3) = 'X10' THEN 'Amputation of foot' WHEN left(a.Procedure16th_OPCS,3) = 'X10' THEN 'Amputation of foot' WHEN left(a.Procedure17th_OPCS,3) = 'X10' THEN 'Amputation of foot'	
		WHEN left(a.Procedure18th_OPCS,3) = 'X10' THEN 'Amputation of foot'	WHEN left(a.Procedure19th_OPCS,3) = 'X10' THEN 'Amputation of foot'	WHEN left(a.Procedure20th_OPCS,3) = 'X10' THEN 'Amputation of foot'	WHEN left(a.Procedure21st_OPCS,3) = 'X10' THEN 'Amputation of foot'	
		WHEN left(a.Procedure22nd_OPCS,3) = 'X10' THEN 'Amputation of foot'	WHEN left(a.Procedure23rd_OPCS,3) = 'X10' THEN 'Amputation of foot'	
													
		WHEN left (a.PrimaryProcedure_OPCS,3) = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure2nd_OPCS,3) = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure3rd_OPCS,3) = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure4th_OPCS,3) = 'X11' THEN 'Amputation of toe'												
		WHEN left(a.Procedure5th_OPCS,3) = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure6th_OPCS,3) = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure7th_OPCS,3) = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure8th_OPCS,3) = 'X11' THEN 'Amputation of toe'												
		WHEN left(a.Procedure9th_OPCS,3) = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure10th_OPCS,3)  = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure11th_OPCS,3)  = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure12th_OPCS,3)  = 'X11' THEN 'Amputation of toe'
		WHEN left(a.Procedure13th_OPCS,3)  = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure14th_OPCS,3)  = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure15th_OPCS,3)  = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure16th_OPCS,3)  = 'X11' THEN 'Amputation of toe'
		WHEN left(a.Procedure17th_OPCS,3)  = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure18th_OPCS,3)  = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure19th_OPCS,3)  = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure20th_OPCS,3)  = 'X11' THEN 'Amputation of toe'
		WHEN left(a.Procedure21st_OPCS,3)  = 'X11' THEN 'Amputation of toe' WHEN left(a.Procedure22nd_OPCS,3)  = 'X11' THEN 'Amputation of toe'
		WHEN left(a.Procedure23rd_OPCS,3) = 'X11' THEN 'Amputation of toe'		
												
		WHEN left (a.PrimaryProcedure_OPCS,3) = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure2nd_OPCS,3) = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure3rd_OPCS,3) = 'X12' THEN 'Operations on amputation stump'												
		WHEN left(a.Procedure4th_OPCS,3) = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure5th_OPCS,3) = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure6th_OPCS,3) = 'X12' THEN 'Operations on amputation stump'												
		WHEN left(a.Procedure7th_OPCS,3) = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure8th_OPCS,3) = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure9th_OPCS,3) = 'X12' THEN 'Operations on amputation stump'		
		WHEN left(a.Procedure10th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure11th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure12th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump'	
		WHEN left(a.Procedure13th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure14th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure15th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump'	
		WHEN left(a.Procedure16th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure17th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure18th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump'	
		WHEN left(a.Procedure19th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure20th_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure21st_OPCS,3)  = 'X12' THEN 'Operations on amputation stump'	
		WHEN left(a.Procedure22nd_OPCS,3)  = 'X12' THEN 'Operations on amputation stump' WHEN left(a.Procedure23rd_OPCS,3) =  'X12' THEN 'Operations on amputation stump'	
	ELSE 'Other' End as Amputation_Location,	

------------Other foot procedures------------------------------------------------------------------------------------------
	CASE WHEN left (a.PrimaryProcedure_OPCS,4) = 'S571' 
			AND (Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') 
				OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') 
				OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')) THEN 'Debridement'												
		WHEN left(a.Procedure2nd_OPCS,4) = 'S571' 
			AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')) THEN 'Debridement'												
		WHEN left(a.Procedure3rd_OPCS,4) = 'S571' 
			AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')) THEN 'Debridement'												
		WHEN left(a.Procedure4th_OPCS,4) = 'S571' 
			AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')) THEN 'Debridement'												
		WHEN left(a.Procedure5th_OPCS,4) = 'S571' 
			AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')) THEN 'Debridement'												
		WHEN left(a.Procedure6th_OPCS,4) = 'S571' 
			AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')) THEN 'Debridement'												
		WHEN left(a.Procedure7th_OPCS,4) = 'S571' 
			AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')) THEN 'Debridement'												
		WHEN left(a.Procedure8th_OPCS,4) = 'S571' 
			AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')) THEN 'Debridement'												
		WHEN left(a.Procedure9th_OPCS,4) = 'S571' 
			AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
				OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')) THEN 'Debridement'												
	ELSE 'none' END AS Debridement,												
	CASE WHEN left(a.DiagnosisPrimary_ICD,4) IN ('E105', 'E115', 'E125', 'E135', 'E145') THEN 'Peripheral' ELSE 'none' END AS PeripheralCirculation,													
	CASE WHEN left(a.DiagnosisPrimary_ICD,3) IN ('L97') THEN 'UlcerLL' ELSE 'none' END AS UlcerLowerLimb,													
	CASE WHEN left(a.DiagnosisPrimary_ICD,3) IN ('L89') THEN 'UlcerDC' ELSE 'none' END AS UlcerDecubitus,													
	CASE WHEN left(a.DiagnosisPrimary_ICD,4) IN ('L030', 'L031') THEN 'Cellulitis' ELSE 'none' END AS Cellulitis,													
	CASE WHEN left (a.DiagnosisPrimary_ICD,4) IN ('M860', 'M861','M862', 'M863','M864', 'M865','M866', 'M868','M869')													
			AND (Left(a.Diagnosis1stSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis2ndSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis3rdSecondary_ICD,3) IN ('L97','L89','L03','R02')
				OR Left(a.Diagnosis4thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis5thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis6thSecondary_ICD,3) IN ('L97','L89','L03','R02')
				OR Left(a.Diagnosis7thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis8thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis9thSecondary_ICD,3) IN ('L97','L89','L03','R02')
				OR Left(a.Diagnosis10thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis11thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis12thSecondary_ICD,3) IN ('L97','L89','L03','R02')
				OR Left(a.Diagnosis13thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis14thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis15thSecondary_ICD,3) IN ('L97','L89','L03','R02')
				OR Left(a.Diagnosis16thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis17thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis18thSecondary_ICD,3) IN ('L97','L89','L03','R02')
				OR Left(a.Diagnosis19thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis20thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis21stSecondary_ICD,3) IN ('L97','L89','L03','R02')
				OR Left(a.Diagnosis22ndSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis23rdSecondary_ICD,3) IN ('L97','L89','L03','R02')) THEN 'Osteomyelitis' ELSE 'none' END AS Osteomyelitis,													
	CASE WHEN left(a.DiagnosisPrimary_ICD,3) IN ('R02') THEN 'Gangrene' ELSE 'none' END AS Gangrene,													
	CASE WHEN left (a.DiagnosisPrimary_ICD,4) IN ('I702')													
			AND (Left(a.Diagnosis1stSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis2ndSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis3rdSecondary_ICD,3) IN ('L97','L89','L03','R02')
				OR Left(a.Diagnosis4thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis5thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis6thSecondary_ICD,3) IN ('L97','L89','L03','R02')
				OR Left(a.Diagnosis7thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis8thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis9thSecondary_ICD,3) IN ('L97','L89','L03','R02')
				OR Left(a.Diagnosis10thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis11thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis12thSecondary_ICD,3) IN ('L97','L89','L03','R02')
				OR Left(a.Diagnosis13thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis14thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis15thSecondary_ICD,3) IN ('L97','L89','L03','R02')
				OR Left(a.Diagnosis16thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis17thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis18thSecondary_ICD,3) IN ('L97','L89','L03','R02')
				OR Left(a.Diagnosis19thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis20thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis21stSecondary_ICD,3) IN ('L97','L89','L03','R02')
				OR Left(a.Diagnosis22ndSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis23rdSecondary_ICD,3) IN ('L97','L89','L03','R02')) THEN 'Atherosclerosis' ELSE 'none' END AS Atherosclerosis,													
	CASE WHEN left (a.DiagnosisPrimary_ICD,4) IN ('A400', 'A401','A402', 'A403','A408', 'A409','A410', 'A411','A412', 'A413','A414', 'A415','A418', 'A419','A499')		
			AND (Left(a.Diagnosis1stSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis2ndSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis3rdSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis4thSecondary_ICD,3) IN ('L97')
				OR Left(a.Diagnosis5thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis6thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis7thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis8thSecondary_ICD,3) IN ('L97')
				OR Left(a.Diagnosis9thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis10thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis11thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis12thSecondary_ICD,3) IN ('L97')
				OR Left(a.Diagnosis13thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis14thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis15thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis16thSecondary_ICD,3) IN ('L97')
				OR Left(a.Diagnosis17thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis18thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis19thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis20thSecondary_ICD,3) IN ('L97')
				OR Left(a.Diagnosis21stSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis22ndSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis23rdSecondary_ICD,3) IN ('L97')) THEN 'Sepsis' ELSE 'none' END AS Sepsis													

INTO [modelling_sql_area].[dbo].[SWD_PHM_Diabetes_Procedures]												
FROM abi.dbo.vw_APC_SEM_001 a	


WHERE a.AIMTC_ProviderSpell_End_Date between @STARTDATE AND @ENDDATE
		AND a.[AIMTC_OrganisationCode_Codeofcommissioner] in ('5A3','12A','5QJ','11H','5M8','11T','15C','14f','q65')
		AND left(a.OrganisationCode_CodeOfProvider, 3) in ('RA7','RVJ','RA3')
AND (left(a.DiagnosisPrimary_ICD,3) BETWEEN 'E10' AND 'E14' OR left(a.Diagnosis1stSecondary_ICD,3) BETWEEN 'E10' AND 'E14'													
		OR left(a.Diagnosis2ndSecondary_ICD,3) BETWEEN 'E10' AND 'E14' OR left(a.Diagnosis3rdSecondary_ICD,3) BETWEEN 'E10' AND 'E14'													
		OR left(a.Diagnosis4thSecondary_ICD,3) BETWEEN 'E10' AND 'E14' OR left(a.Diagnosis5thSecondary_ICD,3) BETWEEN 'E10' AND 'E14'													
		OR left(a.Diagnosis6thSecondary_ICD,3) BETWEEN 'E10' AND 'E14' OR left(a.Diagnosis7thSecondary_ICD,3) BETWEEN 'E10' AND 'E14'													
		OR left(a.Diagnosis8thSecondary_ICD,3) BETWEEN 'E10' AND 'E14' OR left(a.Diagnosis9thSecondary_ICD,3) BETWEEN 'E10' AND 'E14'													
		OR left(a.Diagnosis10thSecondary_ICD,3) BETWEEN 'E10' AND 'E14' OR left(a.Diagnosis11thSecondary_ICD,3) BETWEEN 'E10' AND 'E14'													
		OR left(a.Diagnosis12thSecondary_ICD,3) BETWEEN 'E10' AND 'E14' OR left(a.Diagnosis13thSecondary_ICD,3) BETWEEN 'E10' AND 'E14'													
		OR left(a.Diagnosis14thSecondary_ICD,3) BETWEEN 'E10' AND 'E14' OR left(a.Diagnosis15thSecondary_ICD,3) BETWEEN 'E10' AND 'E14'													
		OR left(a.Diagnosis16thSecondary_ICD,3) BETWEEN 'E10' AND 'E14' OR left(a.Diagnosis17thSecondary_ICD,3) BETWEEN 'E10' AND 'E14'													
		OR left(a.Diagnosis18thSecondary_ICD,3) BETWEEN 'E10' AND 'E14' OR left(a.Diagnosis19thSecondary_ICD,3) BETWEEN 'E10' AND 'E14'													
		OR left(a.Diagnosis20thSecondary_ICD,3) BETWEEN 'E10' AND 'E14' OR left(a.Diagnosis21stSecondary_ICD,3) BETWEEN 'E10' AND 'E14'													
		OR left(a.Diagnosis22ndSecondary_ICD,3) BETWEEN 'E10' AND 'E14' OR left(a.Diagnosis23rdSecondary_ICD,3) BETWEEN 'E10' AND 'E14')													
												
AND ((left(a.PrimaryProcedure_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure2nd_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure3rd_OPCS,3) in ('X09','X10','X11','X12') 											
		OR left(a.Procedure4th_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure5th_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure6th_OPCS,3) in ('X09','X10','X11','X12') 												
		OR left(a.Procedure7th_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure8th_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure9th_OPCS,3) in ('X09','X10','X11','X12') 	
		OR left(a.Procedure10th_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure11th_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure12th_OPCS,3) in ('X09','X10','X11','X12') 	
		OR left(a.Procedure13th_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure14th_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure15th_OPCS,3) in ('X09','X10','X11','X12') 	
		OR left(a.Procedure16th_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure17th_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure18th_OPCS,3) in ('X09','X10','X11','X12') 
		OR left(a.Procedure19th_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure20th_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure21st_OPCS,3) in ('X09','X10','X11','X12') 	
		OR left(a.Procedure22nd_OPCS,3) in ('X09','X10','X11','X12') OR left(a.Procedure23rd_OPCS,3) in ('X09','X10','X11','X12'))

OR left(a.PrimaryProcedure_OPCS,4) = 'S571' 
		AND (Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507'))
OR left(a.Procedure2nd_OPCS,4) = 'S571' 
		AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507'))
OR left(a.Procedure3rd_OPCS,4) = 'S571'
		AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507'))
OR left(a.Procedure4th_OPCS,4) = 'S571'
		AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507'))
OR left(a.Procedure5th_OPCS,4) = 'S571' 
		AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507'))
OR left(a.Procedure6th_OPCS,4) = 'S571' 
		AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507'))
OR left(a.Procedure7th_OPCS,4) = 'S571' 
		AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507'))
OR left(a.Procedure8th_OPCS,4) = 'S571' 
		AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure9th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507'))
OR left(a.Procedure9th_OPCS,4) = 'S571' 
		AND (Left(a.PrimaryProcedure_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure2nd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure3rd_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507')
			OR Left(a.Procedure4th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure5th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure6th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') 
			OR Left(a.Procedure7th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507') OR Left(a.Procedure8th_OPCS,4) IN ('Z504', 'Z505', 'Z506', 'Z507'))
OR left(a.DiagnosisPrimary_ICD,4) IN ('E105', 'E115', 'E125', 'E135', 'E145') 												
OR left(a.DiagnosisPrimary_ICD,3) IN ('L97') 												
OR left(a.DiagnosisPrimary_ICD,3) IN ('L89')										
OR left(a.DiagnosisPrimary_ICD,4) IN ('L030', 'L031') 												
OR left (a.DiagnosisPrimary_ICD,4) IN ('M860', 'M861','M862', 'M863','M864', 'M865','M866', 'M868','M869')													
		AND (Left(a.Diagnosis1stSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis2ndSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis3rdSecondary_ICD,3) IN ('L97','L89','L03','R02')
			OR Left(a.Diagnosis4thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis5thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis6thSecondary_ICD,3) IN ('L97','L89','L03','R02')
			OR Left(a.Diagnosis7thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis8thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis9thSecondary_ICD,3) IN ('L97','L89','L03','R02')
			OR Left(a.Diagnosis10thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis11thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis12thSecondary_ICD,3) IN ('L97','L89','L03','R02')
			OR Left(a.Diagnosis13thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis14thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis15thSecondary_ICD,3) IN ('L97','L89','L03','R02')
			OR Left(a.Diagnosis16thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis17thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis18thSecondary_ICD,3) IN ('L97','L89','L03','R02')
			OR Left(a.Diagnosis19thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis20thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis21stSecondary_ICD,3) IN ('L97','L89','L03','R02')
			OR Left(a.Diagnosis22ndSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis23rdSecondary_ICD,3) IN ('L97','L89','L03','R02'))
OR left(a.DiagnosisPrimary_ICD,3) IN ('R02')													
OR left (a.DiagnosisPrimary_ICD,4) IN ('I702')													
		AND (Left(a.Diagnosis1stSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis2ndSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis3rdSecondary_ICD,3) IN ('L97','L89','L03','R02')
			OR Left(a.Diagnosis4thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis5thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis6thSecondary_ICD,3) IN ('L97','L89','L03','R02')
			OR Left(a.Diagnosis7thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis8thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis9thSecondary_ICD,3) IN ('L97','L89','L03','R02')
			OR Left(a.Diagnosis10thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis11thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis12thSecondary_ICD,3) IN ('L97','L89','L03','R02')
			OR Left(a.Diagnosis13thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis14thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis15thSecondary_ICD,3) IN ('L97','L89','L03','R02')
			OR Left(a.Diagnosis16thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis17thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis18thSecondary_ICD,3) IN ('L97','L89','L03','R02')
			OR Left(a.Diagnosis19thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis20thSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis21stSecondary_ICD,3) IN ('L97','L89','L03','R02')
			OR Left(a.Diagnosis22ndSecondary_ICD,3) IN ('L97','L89','L03','R02') OR Left(a.Diagnosis23rdSecondary_ICD,3) IN ('L97','L89','L03','R02'))
OR left (a.DiagnosisPrimary_ICD,4) IN ('A400', 'A401','A402', 'A403','A408', 'A409','A410', 'A411','A412', 'A413','A414', 'A415','A418', 'A419','A499')		
		AND (Left(a.Diagnosis1stSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis2ndSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis3rdSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis4thSecondary_ICD,3) IN ('L97')
			OR Left(a.Diagnosis5thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis6thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis7thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis8thSecondary_ICD,3) IN ('L97')
			OR Left(a.Diagnosis9thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis10thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis11thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis12thSecondary_ICD,3) IN ('L97')
			OR Left(a.Diagnosis13thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis14thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis15thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis16thSecondary_ICD,3) IN ('L97')
			OR Left(a.Diagnosis17thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis18thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis19thSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis20thSecondary_ICD,3) IN ('L97')
			OR Left(a.Diagnosis21stSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis22ndSecondary_ICD,3) IN ('L97') OR Left(a.Diagnosis23rdSecondary_ICD,3) IN ('L97')))
AND a.AIMTC_PracticeCodeOfRegisteredGP NOT IN ('L81055', 'L81067')
		