---No. of distinct patients per year with Type 2 Diabetes, i.e. distinct in each year--------------------------------------------------

--FB NOTE: The below finds distinct practices with PCN

SELECT DISTINCT (c.[practice_code]) AS 'Practice Code',LOWER(d.[PCN]) AS PCN
INTO #PCNLookup
FROM [MODELLING_SQL_AREA].[dbo].[swd_attribute] c
		LEFT JOIN [Analyst_SQL_Area].[dbo].[vw_BNSSG_Lookups_GP_Prescribing] d ON c.[practice_code] = d.[Merged_Practice_Code]
INSERT INTO #PCNLookup ([Practice Code],[PCN]) 
				VALUES	('l81043','pier health'),('l81622','affinity'),('l81648','bristol inner city');

--SELECT * FROM #PCNLookup
--DROP TABLE #PCNLookup

--FB NOTE: Add the unique PCN details from above to SWD for the 

SELECT a.[nhs_number] AS 'NHS Number',a.[Practice_Code],b.PCN,a.[attribute_period] AS 'Date',
		CASE WHEN DATEPART(quarter,a.[attribute_period])=1 THEN datename(yy,dateadd(yy,-1,a.[attribute_period]))+'-'+datename(yy,a.[attribute_period])
			ELSE datename(yy,a.[attribute_period])+'-'+datename(yy,dateadd(yy,1,a.[attribute_period])) END AS Year 
INTO #ALLPatients
FROM [MODELLING_SQL_AREA].[dbo].[primary_care_attributes] a -- Historic Data to get all Patients
		LEFT JOIN #PCNLookup b on a.[practice_code] = b.[Practice Code]
--FB NOTE diabetes_2 used to identify individuals: 
WHERE [diabetes_2]=1 AND a.[nhs_number] IS NOT NULL
GROUP BY a.[nhs_number],a.[Practice_Code],b.PCN,a.[attribute_period] 

--SELECT * FROM #ALLPatients
--DROP TABLE #ALLPatients

--REMOVE WHERE PEOPLE HAVE MORE THAN 1 PCN--
SELECT *
INTO #LatestPCN
FROM (
		SELECT t.[NHS Number],t.[PCN], row_number() over(partition by [NHS Number] order by date desc) rn
		FROM #ALLPatients t
		) t
WHERE rn=1 
order by [NHS Number]

--SELECT * FROM #LatestPCN
--DROP TABLE #LatestPCN

--FB NOTE: Create a count of patients by PCN and year
SELECT count(distinct(z.[NHS Number])) AS 'No. of Distinct Patients',z.[PCN],g.[Year] 
FROM #LatestPCN z 
		RIGHT JOIN #ALLPatients g ON z.[NHS Number] = g.[NHS number] 
GROUP BY z.[PCN],g.[Year] 

--------------Distinct Type 2 Diabetes Patients showing who has and has not been tested--------------------------------------------------------------------------------------------
--FB MOTE: Creates a distinct list of patients by year
SELECT distinct(z.[NHS Number]),z.[PCN],g.[Year] 
INTO #TESTS
FROM #LatestPCN z 
		RIGHT JOIN #ALLPatients g ON z.[NHS Number] = g.[NHS number] 

--SELECT * FROM #TESTS
--DROP TABLE #TESTS

--FB NOTE: uses the distinct list of patients by PCN & Year to 
SELECT distinct(g.[NHS Number]),g.[PCN],g.[Year], h.[Measurement Year], CASE WHEN h.[Measurement Year] IS NULL THEN 'Not had Check' ELSE 'Has had a Check' END AS 'Has had a HbA1c Check' 
FROM #TESTS g
--FB NOTE: NOT SURE THIS SCRIPT HAS CREATED #ThoseTested BY THIS POINT?
		LEFT JOIN #ThoseTested h 
			ON g.[NHS Number] = h.[NHS number] 
				AND g.[Year] = h.[Measurement Year] 


--------------No of HbA1c Tests that have been done on Type 2 patients------------------------------------------------------------------------------------------------------------
SELECT distinct(z.[NHS Number]), z.PCN, f.[measurement_name] AS 'Measure Name', f.[measurement_value] AS 'Measure Value', f.[measurement_date] AS 'Measure Date',
					CASE WHEN DATEPART(quarter,f.[measurement_date])=1 THEN datename(yy,dateadd(yy,-1,f.[measurement_date]))+'-'+datename(yy,f.[measurement_date])
						ELSE datename(yy,f.[measurement_date])+'-'+datename(yy,dateadd(yy,1,f.[measurement_date])) END AS 'Measurement Year'
INTO #ThoseTested	
FROM #LatestPCN z
		LEFT JOIN [MODELLING_SQL_AREA].[dbo].[swd_measurement] f on z.[NHS Number] = f.[nhs_number]
WHERE f.[measurement_name] = 'hba1c' 
 

---Nos of those who and who have not had a HbA1c Check-----------------------------------------------------------------------------------------------------------

--SELECT distinct(g.[NHS Number]),g.[Year], CASE WHEN h.[Measurement Year] IS NULL THEN 'Not had Check' ELSE 'Has had a Check' END AS 'Has had a HbA1c Check' 
--INTO #Nos	
--FROM #TESTS g
--		LEFT JOIN #ThoseTested h 
--			ON g.[NHS Number] = h.[NHS number] 
--				AND g.[Year] = h.[Measurement Year] 


-- SELECT [Year], Count([NHS Number]) AS 'Number of People', [Has had a HbA1c Check] 
-- FROM #Nos	
-- GROUP BY [Year],[Has had a HbA1c Check] 
-- ORDER BY [Year]
-- --DROP TABLE #Nos 