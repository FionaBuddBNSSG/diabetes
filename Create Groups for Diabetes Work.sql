------------------------Activity Start Date = '20201001' ----------------------------------------
------------------------Variable set for latest attribute period in SWD -------------------------

---------------------------------------------------------------------------CREATE GROUP 1 ---------------------------------------------------------------------------
/*Group 1. Adults with Type 1 or 2 diabetes who had a foot procedure 
(with clarification of which of these are a full foot amputation) */

DROP TABLE IF EXISTS [modelling_sql_area].[dbo].[FB_diab_procedures]	

/* limit period to exclude dates with no data from Mendip Vale
	Uses CMS Segment from START of the procedure*/

DECLARE @PERIOD AS Datetime
SET @PERIOD =  (select max(attribute_period) from modelling_sql_area.dbo.primary_care_attributes)
DECLARE @STARTDATE AS Datetime
SET @STARTDATE =  DATEADD(year, -1, @PERIOD)
DECLARE @ENDDATE AS Datetime
SET @ENDDATE =  @PERIOD - 1 
;



WITH cte_proc AS 
(
SELECT 
	a.[AIMTC_Pseudo_NHS] as nhs_number,
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

											
FROM abi.dbo.vw_APC_SEM_001 a	
LEFT JOIN [MODELLING_SQL_AREA].[dbo].[new_cambridge_score] c on a.[AIMTC_Pseudo_NHS] = c.nhs_number and AIMTC_ProviderSpell_start_Date >= c.attribute_period and AIMTC_ProviderSpell_Start_Date <= EOMONTH(c.attribute_period,0)


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
	AND a.AIMTC_PracticeCodeOfRegisteredGP not in ('L81669', --Monks Park, no data from Dec 2022
								'L81036', --Coniston, no data before Jun 2022
								'L81086' -- Mendip Vale, no data from Dec 2022
								)
AND a.AIMTC_AGE >= 17
)

--Create a temp table with distinct rows

SELECT distinct *
INTO #tempproc from cte_proc 	

--Add row numbers and place into the final table
Select *, ROW_NUMBER() OVER(PARTITION BY nhs_number ORDER BY AIMTC_ProviderSpell_Start_Date)  AS 'RN_1'
INTO [modelling_sql_area].[dbo].[FB_diab_procedures]
from #tempproc	


DROP TABLE IF EXISTS #tempproc

---------------------------------------------------------------------------CREATE GROUP 2 ---------------------------------------------------------------------------
/* Group 2. Adults with Type 2 diabetes who had at least two hospital admissions 
within a 12 month period AND/OR three or more A&E visits over the same 12 month period.
Uses CMS Segment & Attributes from START of the spell*/

DROP TABLE IF EXISTS [modelling_sql_area].[dbo].[FB_diab_admissions];

WITH cte_admissions_ip AS (
	SELECT 
		a.NHS_number, -- this is the pseudo_nhs for the event
		a.dep_date, --this is the arrival date of the event
		'ip' as 'Specific_POD type',
		a.specific_POD,
		a.Main_POD,
		b.diabetes_2,
		c.segment,
		LAG(a.nhs_number,1) OVER (
			PARTITION BY a.NHS_Number
			ORDER BY a.dep_date
		) previous_nhs_number,  -- drop the nhs number down (not really needed in this example)
		LAG (a.dep_date, 1) OVER (
		PARTITION BY a.NHS_Number
			ORDER BY a.dep_date
		) previous_dep_date -- drops the last arrival date down, only where the NHS number matches
	FROM 
		[MODELLING_SQL_AREA].[dbo].[swd_activity_kept_analystview] a 
		LEFT JOIN MODELLING_SQL_AREA.dbo.primary_care_attributes b on a.nhs_number = b.nhs_number and dep_date >= b.attribute_period and dep_date <= EOMONTH(b.attribute_period,0)
		LEFT JOIN [MODELLING_SQL_AREA].[dbo].[new_cambridge_score] c on a.nhs_number = c.nhs_number and dep_date >= c.attribute_period and dep_date <= EOMONTH(c.attribute_period,0)
	WHERE (b.diabetes_2 = 1) 
	AND b.practice_code not in ('L81055', 'L81067')
	AND b.practice_code not in ('L81669', --Monks Park, no data from Dec 2022
								'L81036', --Coniston, no data before Jun 2022
								'L81086' -- Mendip Vale, no data from Dec 2022
								)
	AND a.Main_POD = 'secondary'  
	AND a.specific_POD in ('ip elective', 'ip non_elective') 
	AND b.age >= 17
		
) ,

-- Create CTE which extracts only discharge dates in our target period, then allocates whether they are a multi admission or not

cte_multiadd_ip AS (
SELECT 
	*,
	CASE WHEN (dep_date - previous_dep_date) <365 THEN 1 ELSE 0 END AS 'multi_admissions', --looks for admissions less than 365 days apart
	ROW_NUMBER() OVER(PARTITION BY NHS_number ORDER BY dep_date)  AS 'RN_1',
	count (distinct(nhs_number)) AS 'occurances'
FROM
	cte_admissions_ip
where dep_date BETWEEN @STARTDATE and @ENDDATE
	group by
	nhs_number,
	dep_date,
	specific_POD,
	[Specific_POD type],
	Main_POD,
	diabetes_2,
	segment,
	Previous_nhs_number,
	Previous_dep_date,
	CASE WHEN (dep_date - previous_dep_date) <365 THEN 1 ELSE 0 END

),


cte_admissions_ae AS (
	SELECT 
		a.NHS_number, -- this is the pseudo_nhs for the event
		a.dep_date, --this is the arrival date of the event
		'ae' as 'Specific_POD type',
		a.specific_POD,
		a.Main_POD,
		b.diabetes_2,
		c.segment,
		LAG(a.nhs_number,1) OVER (
			PARTITION BY a.NHS_Number
			ORDER BY a.dep_date
		) previous_nhs_number,  -- drop the nhs number down (not really needed in this example)
		LAG (a.dep_date, 1) OVER (
		PARTITION BY a.NHS_Number
			ORDER BY a.dep_date
		) previous_dep_date -- drops the last arrival date down, only where the NHS number matches
	FROM 
		[MODELLING_SQL_AREA].[dbo].[swd_activity_kept_analystview] a 
		LEFT JOIN MODELLING_SQL_AREA.dbo.primary_care_attributes b on a.nhs_number = b.nhs_number and dep_date >= b.attribute_period and dep_date <= EOMONTH(b.attribute_period,0)
		LEFT JOIN [MODELLING_SQL_AREA].[dbo].[new_cambridge_score] c on a.nhs_number = c.nhs_number and dep_date >= c.attribute_period and dep_date <= EOMONTH(c.attribute_period,0)
	WHERE (b.diabetes_2 = 1 ) 
	AND b.practice_code not in ('L81055', 'L81067')
	AND b.practice_code not in ('L81669', --Monks Park, no data from Dec 2022
								'L81036', --Coniston, no data before Jun 2022
								'L81086' -- Mendip Vale, no data from Dec 2022
								)
	AND a.Main_POD = 'secondary'  
	AND a.specific_POD in ('ae') 
	AND b.age >= 17
		
) ,

-- Create CTE which extracts only discharge dates in our target period, then allocates whether they are a multi admission or not

cte_multiadd_ae AS (
SELECT 
	*,
	CASE WHEN (dep_date - previous_dep_date) <365 THEN 1 ELSE 0 END AS 'multi_admissions', --looks for admissions less than 365 days apart
	ROW_NUMBER() OVER(PARTITION BY NHS_number  ORDER BY dep_date)  AS 'RN_1',
	count (distinct(nhs_number)) AS 'occurances'
FROM
	cte_admissions_ae
where dep_date BETWEEN @STARTDATE and @ENDDATE
group by
	nhs_number,
	dep_date,
	Specific_POD,
	[Specific_POD type],
	Main_POD,
	diabetes_2,
	segment,
	Previous_nhs_number,
	Previous_dep_date,
	CASE WHEN (dep_date - previous_dep_date) <365 THEN 1 ELSE 0 END
)

-- NOTE: the lag will include data which is excluded from the cte_multiadd dataset
SELECT * into [modelling_sql_area].[dbo].[FB_diab_admissions] 
FROM cte_multiadd_ip WHERE nhs_number in (SELECT nhs_number FROM cte_multiadd_ip WHERE rn_1 >1)
UNION ALL
SELECT * 
FROM cte_multiadd_ae  WHERE nhs_number in (SELECT nhs_number FROM cte_multiadd_ae WHERE rn_1 >2)
; 
-------------------------------------------------------------

---------------------------------------------------------------------------CREATE GROUP 4 ---------------------------------------------------------------------------
/* Group 4. Everyone else (at this point - everyone with a diabetes diagnosis over the 12 month period!)*/

DROP TABLE IF EXISTS [modelling_sql_area].[dbo].[FB_diab_basepop] 

Select * 
INTO [modelling_sql_area].[dbo].[FB_diab_basepop] 
FROM (SELECT a.nhs_number, segment, a.diabetes_2, 
		a.age, a.smoking, a.bmi, a.sex, a.lsoa, a.is_carer, a.practice_code,
			a.attribute_period, CASE WHEN c.[main group] IS NULL THEN ' Unknown'
			 WHEN c.[main group] = 'NA' THEN ' Unknown' 
			 WHEN c.[main group] = 'Unknown' THEN ' Unknown'
			 WHEN c.[main group] = 'Not stated' THEN ' Unknown' 
			 WHEN c.[main group] = ' Not stated' THEN ' Unknown'
			 WHEN c.[Ethnicity_description] = 'British or mixed British - ethnic category 2001 census' THEN ' White'
			 ELSE concat(' ', c.[main group]) END AS 'Main_ethnic_group',
				ROW_NUMBER() OVER(PARTITION BY a.NHS_number ORDER BY a.attribute_period DESC)  AS 'RN_1' --this means the final entry = 1
		From (Select * from [MODELLING_SQL_AREA].dbo.[primary_care_attributes] where diabetes_2 = 1
																				AND age >17 
																					AND attribute_period between @STARTDATE and @ENDDATE
																						AND practice_code not in ('L81055', 'L81067')
																						AND practice_code not in ('L81669', --Monks Park, no data from Dec 2022
																													'L81036', --Coniston, no data before Jun 2022
																													'L81086' -- Mendip Vale, no data from Dec 2022
																													)
				)  a
		LEFT JOIN [MODELLING_SQL_AREA].[dbo].[new_cambridge_score] b  on a.nhs_number = b.nhs_number AND a.attribute_period = b. attribute_period
		LEFT JOIN [MODELLING_SQL_AREA].[dbo].[swd_ethnicity_groupings] c on a.[ethnicity] = c.[Ethnicity_description] ) a
		WHERE RN_1 = 1

---------------------------------------------------------------------------Create the MPI Table ---------------------------------------------------------------------------
/* Uses the latest CMS data for everyone*/


DROP TABLE IF EXISTS [modelling_sql_area].[dbo].[FB_diab]	

select a.nhs_number, a.diabetes_2,
CASE WHEN b.nhs_number IS NOT NULL AND c.nhs_number IS NULL THEN 1
	WHEN b.nhs_number IS NULL AND c.nhs_number IS NOT NULL THEN 2
	WHEN b.nhs_number IS NOT NULL AND c.nhs_number IS NOT NULL  THEN 3
	WHEN b.nhs_number IS NULL AND c.nhs_number IS NULL THEN 4  ELSE 5 END AS 'group',
d.Locality_Name,
d.PrimaryCareNetwork,
[Analyst_SQL_Area].[dbo].[fn_BNSSG_Age_5yr] (a.[Age]) AS Age_Band_5YR,
[Analyst_SQL_Area].[dbo].[fn_BNSSG_imd_quintile] (e.[Index of Multiple Deprivation (IMD) Decile]) AS 'IMD_Quintile',
a.smoking,
CASE WHEN a.[bmi] < 18.5 THEN 'Underweight'
WHEN a.[bmi] between 18.5 and 24.9 THEN 'Healthy Weight'
WHEN a.[bmi] between 25 and 29.9 THEN 'Overweight'
WHEN a.[bmi] >29.9 THEN 'Obese' 
ELSE 'Unknown' END AS 'BMI',
a.sex,
a.is_carer,
a.segment,
a.practice_code,
a.attribute_period,
a.Main_ethnic_group,
a.AGE
INTO [modelling_sql_area].[dbo].[FB_diab]	
-- DECLARE @PERIOD AS Datetime
--SET @PERIOD =  '20210901'
--select count (*)	
from [modelling_sql_area].[dbo].[FB_diab_basepop] a
LEFT JOIN (select * from [modelling_sql_area].[dbo].[FB_diab_procedures] where RN_1 = 1) b on a.nhs_number = b.nhs_number
LEFT JOIN (select distinct(NHS_number) from [modelling_sql_area].[dbo].[FB_diab_admissions] where multi_admissions = 1 AND RN_1 = 1) c on a.nhs_number = c.nhs_number
LEFT JOIN analyst_sql_area.dbo.tbl_BNSSG_Lookups_GP d on a.practice_code = d.Practice_Code
LEFT JOIN [Analyst_SQL_Area].[dbo].[Lkup_England_IMD_by_LSOA] e on a.lsoa = e.[LSOA code (2011)]
LEFT JOIN modelling_sql_area.dbo.new_cambridge_score f on a.nhs_number = f.nhs_number and a.attribute_period = f.attribute_period



