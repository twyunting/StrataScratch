USE [Z_PAPI_PROD]
GO
/****** Object:  StoredProcedure [dbo].[spGetPortfolioImpactMasterTable]    Script Date: 11/18/2022 9:18:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[spGetPortfolioImpactMasterTable] 
	@EDM varchar(60) = '',				-- JEM_MGU_EDM
	@REPORTING varchar(60) = '',		-- JEM_MGU_REPORTING
	@PAPI_JobId int = 0,				-- ??
	@DLM_JobId int = 0,					-- 145
	@AccountID varchar (max) = '',		-- 86
	@AnalysisIDList varchar (max) = ''	-- 209, 210, 211
AS
-----------------------------------------------------------------------------------------------------------------
-- Created by Ming Tsai 2020-05-14
-- 
-- Description:
--
-- History:
--	2020-05-14	Ming Tsai	Added
--	2020-08-17	Ming Tsai	Script revised in template
--	2020-09-24	Ming Tsai	##DB_NAME## used to map to current DB
--  2022-11-08  Yunting Chiu  Revise REPLACE term to ensure [EdmDataSource] can be excatly matched
--  2022-11-17  Yunting Chiu  Add EQ conditions to [AnalysisName] term
--
-----------------------------------------------------------------------------------------------------------------
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert/Updatemode
	IF @EDM <> ''
	BEGIN

		IF @REPORTING = ''
		BEGIN
			RAISERROR(N'@REPORTING is blank', 10, 1);
			return;
		END

		DECLARE @dynaSQL nvarchar(max)
																																																																																																																																																																																																																																																																																																																																																																																																			
		SET @dynaSQL = N'
IF OBJECT_ID("tempdb..#port_master") IS NOT NULL
DROP TABLE  #port_master;

select 
job.JobId,
job.EdmDataSource,
portImp.*,
job.WebServerName
INTO #port_master
from
(select 
r.[AccountId], 
a.[AnalysisId], 
a.[AnalysisName],
case when a.[AnalysisName] like "%Earthquake%" then "US EQ Portfolio Impact Report"
when a.[AnalysisName] like "%EQ%" then "US EQ Portfolio Impact Report"
when a.[AnalysisName] like "%Severe Convective Storm%" then "US SCS Portfolio Impact Report" 
when a.[AnalysisName] like "%Windstorm%" then "US WS Portfolio Impact Report" else "other" end PortImpRept,
case when a.[AnalysisName] like "%Earthquake%" then "EQ"
when a.[AnalysisName] like "%EQ%" then "EQ"
when a.[AnalysisName] like "%Severe Convective Storm%" then "SCS" 
when a.[AnalysisName] like "%Windstorm%" then "WS" else "other" end Peril,
e.ReportId,
e.ExposureId,
e.ExposureType,
e.ExposureName,
e.ExposureNumber,
REPLACE(e.EDMName, "_", " ") EDMName,
e.EDMSqlServer,
--case when e.EDMSqlServer = "DC02RSGRLDB01" then "DC02RSGRLAS01" else "other" end EDMSqlServer,
p.FPCode,
p.MethodType,
p.OutputType,
p.Comment,
p.ReturnPeriod,
p.Amount,
p.[Percent],
p.[Status]
from
[##REPORTING##].dbo.[ExposureInfo] e
inner join
[##REPORTING##].dbo.[PortfolioImpactReport] p
on
e.ReportID = p.ReportID
and e.[ExposureId] = p.[ExposureId]
and e.[ExposureType] = p.[ExposureType]
inner join
[##REPORTING##].dbo.[Report] r
on r.ID = e.ReportID
inner join
[##REPORTING##].dbo.[AnalysisInfo] a
on a.ReportID = e.ReportID
and p.Comment = case when a.[AnalysisName] like "%Earthquake%" then "US EQ Portfolio Impact Report"
when a.[AnalysisName] like "%EQ%" then "US EQ Portfolio Impact Report"
when a.[AnalysisName] like "%Severe Convective Storm%" then "US SCS Portfolio Impact Report"
when a.[AnalysisName] like "%Windstorm%" then "US WS Portfolio Impact Report" else "other" end
) portImp
left join
(select
j.[JobId],
jr.[ServiceId],
jr.[ReportId],
jd.[AccountId],
j.[WebServerName],
jd.[EdmDataSource],
jr.[Settings],
jr.[Status],
jr.[Message]
from
[rms_web_jobs].[dbo].[Jobs] j
left join
[rms_web_jobs].[dbo].[JobReport] jr
on j.JobId = jr.JobId
left join
[rms_web_jobs].[dbo].[JobDetails] jd
on jr.JobId = jd.JobId) job
on portImp.[AccountId] = job.[AccountId]
and portImp.ReportId = job.ReportId
and portImp.EDMName = REPLACE(job.[EdmDataSource], "_", " ")
--and portImp.EDMSqlServer = job.[WebServerName]
where
portImp.[AccountId] = ##ACCGRPID##
and portImp.[AnalysisId] in (##ANALYSISIDLIST##)
and job.JobId = ##DLM_JOBID##
and REPLACE(job.EdmDataSource, " ", "_") = REPLACE("##EDM##" , " ", "_")
order by JobId, EdmDataSource, AccountId, AnalysisId;

DELETE [##DB_NAME##].[dbo].[PortfolioImpact_Master] WHERE [JobId]="##DLM_JOBID##";

INSERT INTO [##DB_NAME##].[dbo].[PortfolioImpact_Master]
select ##PAPI_JOBID##, getdate(), * from #port_master;

-- select ##PAPI_JOBID##, * from #port_master;

'

		SET @dynaSQL = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@dynaSQL,'##DB_NAME##', DB_NAME()), '##EDM##', @EDM), '##REPORTING##', @REPORTING), '##ACCGRPID##', @AccountID), '##ANALYSISIDLIST##', @AnalysisIDList), '##DLM_JOBID##', @DLM_JobId), '##PAPI_JOBID##', @PAPI_JobId),'"', '''');
		-- print @dynaSQL

		EXEC sp_executesql @dynaSQL
	END

	-- Query mode
	IF @DLM_JobId <> 0
	BEGIN
		SELECT 
				[JobId],[EdmDataSource],[AccountId],[AnalysisId],[AnalysisName],[PortImpRept],
				[Peril],[ReportId],[ExposureId],[ExposureType],[ExposureName],[ExposureNumber],
				[EDMName],[EDMSqlServer],[FPCode],[MethodType],[OutputType],[Comment],
				[ReturnPeriod],[Amount],[Percent],[Status],[WebServerName],
				[PAPI_JobId],[Timestamp]
			FROM [dbo].[PortfolioImpact_Master] 
			WHERE [JobId] = @DLM_JobId
			ORDER BY JobId, EdmDataSource, AccountId, AnalysisId;
	END
	ELSE IF @PAPI_JobId <> 0
	BEGIN
		SELECT 
				[JobId],[EdmDataSource],[AccountId],[AnalysisId],[AnalysisName],[PortImpRept],
				[Peril],[ReportId],[ExposureId],[ExposureType],[ExposureName],[ExposureNumber],
				[EDMName],[EDMSqlServer],[FPCode],[MethodType],[OutputType],[Comment],
				[ReturnPeriod],[Amount],[Percent],[Status],[WebServerName],
				[PAPI_JobId],[Timestamp]
			FROM [dbo].[PortfolioImpact_Master] 
			WHERE [PAPI_JobId] = @PAPI_JobId
			ORDER BY JobId, EdmDataSource, AccountId, AnalysisId;
	END
	ELSE
	BEGIN
		RAISERROR(N'Invalid parameter', 10, 1);
	END

END


