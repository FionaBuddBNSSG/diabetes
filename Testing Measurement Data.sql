select * from [MODELLING_SQL_AREA].[dbo].[swd_measurement] where measurement_name = 'hba1c'

SET NOCOUNT ON

----------------------------- Join procedures table to the primary care activity tables, finding activity within 365 days of procedure ---------------------------

DROP TABLE IF EXISTS #pcconts
Select AIMTC_Pseudo_NHS, 
	AIMTC_ProviderSpell_Start_Date, 
	Age_Band_5YR,
	Agegroup2,
	[Amputation/Footprocedure],
	sum(case when (specific_POD = 'primary_care_contact_GP' OR specific_POD = 'primary_care_contact_other') 
		AND arr_date BETWEEN (AIMTC_ProviderSpell_Start_Date - 365) AND AIMTC_ProviderSpell_Start_Date THEN 1 ELSE 0 END)  AS 'total_pc_conts_prev_12m'
INTO #pcconts
from [modelling_sql_area].[dbo].[SWD_PHM_Diabetes_Procedures]	a
left join [MODELLING_SQL_AREA].[dbo].[swd_activity_kept_analystview] b on a.AIMTC_Pseudo_NHS = b.nhs_number


group by AIMTC_Pseudo_NHS, 
	AIMTC_ProviderSpell_Start_Date,
	Age_Band_5Yr,
	[Amputation/Footprocedure],
	agegroup2




----------------------------- Take temp table and add attribute data and measurement data ---------------------------
select AIMTC_Pseudo_NHS,
c.diabetes_1,
c.diabetes_2,
CASE WHEN total_pc_conts_prev_12m = 0 THEN 'NoPC' ELSE 'PC' END AS 'group1_pc_contacts',
FirstDay_CalendarMonth,
c.Sex,
c.smoking,
Age_Band_5YR,
[Amputation/Footprocedure],
Case when d.[main group] IS NULL then ' Unknown'
	when d.[main group] = 'NA' then ' Unknown' 
	when d.[main group] = 'Unknown' then ' Unknown'
	when d.[main group] = 'Not stated' then ' Unknown' 
	when d.[main group] = ' Not stated' then ' Unknown'
	when d.[Ethnicity_description] = 'British or mixed British - ethnic category 2001 census' then ' White'
	else concat(' ', d.[main group]) end as 'Main_ethnic_group',
[Analyst_SQL_Area].[dbo].[fn_BNSSG_imd_quintile] (e.[Index of Multiple Deprivation (IMD) Decile])  AS 'IMD_Quintile',
CASE when agegroup2 = '0-17' THEN 'child' 
WHEN c.[bmi] < 18.5 THEN 'Underweight'
WHEN c.[bmi] between 18.5 and 24.9 THEN 'Healthy Weight'
WHEN c.[bmi] between 25 and 29.9 THEN 'Overweight'
WHEN c.[bmi] >29.9 THEN 'Obese' 
ELSE 'Unknown' END AS 'BMI',
c.lsoa,
f.Locality_Name,
c.is_carer,
g.segment,
CASE WHEN cast((a.AIMTC_ProviderSPell_Start_Date - h.measurement_date) as int) IS NULL THEN 0 
	ELSE cast((a.AIMTC_ProviderSPell_Start_Date - h.measurement_date) as int) END AS 'days (proc less measure)',
h.measurement_group,
h.measurement_date
INTO #pcmeasures
from #pcconts a
LEFT JOIN [ABI].[Lard].[tbl_DateTime_Lookup] b on a.AIMTC_ProviderSpell_Start_Date = b.Date
LEFT JOIN [MODELLING_SQL_AREA].[dbo].[primary_care_attributes] c on a.AIMTC_Pseudo_NHS = c.nhs_number and b.FirstDay_CalendarMonth = c.attribute_period
left join [MODELLING_SQL_AREA].[dbo].[swd_ethnicity_groupings] d on c.[ethnicity] = d.[Ethnicity_description]
LEFT JOIN [Analyst_SQL_Area].[dbo].[Lkup_England_IMD_by_LSOA] e on c.lsoa = e.[LSOA code (2011)]
LEFT JOIN [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Lookups_GP] f on c.practice_code = f.practice_code
LEFT JOIN [MODELLING_SQL_AREA].[dbo].[new_Cambridge_Score] g on a.AIMTC_Pseudo_NHS = g.nhs_number and b.FirstDay_CalendarMonth = g.attribute_period
LEFT JOIN [MODELLING_SQL_AREA].dbo.[swd_measurement] h on a.AIMTC_Pseudo_NHS = h.nhs_number and h.measurement_name = 'hba1c'

where c.nhs_number IS NOT NULL and c.practice_code not in ('L81055', 'L81067') -- removes those practices who opted out

order by FirstDay_CalendarMonth

select * from #pcmeasures where [group1_pc_contacts] = 'nopc'

