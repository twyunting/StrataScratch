/***** PortImpact Master *****/
--WKFC_R
--Prod Server: DC02RSGRLDB01

IF OBJECT_ID('tempdb..#port_analysis_tb') IS NOT NULL
DROP TABLE  #port_analysis_tb;
IF OBJECT_ID('tempdb..#poleq_data') IS NOT NULL
    DROP TABLE #poleq_data
IF OBJECT_ID('tempdb..#EP') IS NOT NULL
    DROP TABLE #EP
IF OBJECT_ID('tempdb..#master_data') IS NOT NULL
    DROP TABLE #master_data
IF OBJECT_ID('tempdb..#master_data_up') IS NOT NULL
    DROP TABLE #master_data_up
IF OBJECT_ID('tempdb..#master_data_down') IS NOT NULL
    DROP TABLE #master_data_down
IF OBJECT_ID('tempdb..#first_up') IS NOT NULL
    DROP TABLE #first_up
IF OBJECT_ID('tempdb..#first_down') IS NOT NULL
    DROP TABLE #first_down
IF OBJECT_ID('tempdb..#Pol_RP_Loss') IS NOT NULL
    DROP TABLE #Pol_RP_Loss
IF OBJECT_ID('tempdb..#Pol_RP_Final') IS NOT NULL
    DROP TABLE #Pol_RP_Final

------------------start #port_analysis_tb------------------
SELECT  
--S.Driver,
distinct GS.GroupId,
GI.GroupName,
GS.ServiceId,
S.ReportLabel,
CASE WHEN LEN(GS.RbSettings) > 0
THEN 
CAST(SUBSTRING(GS.RbSettings,
CHARINDEX('=',GS.RbSettings) + 1, 
CHARINDEX(';',GS.RbSettings) - CHARINDEX('=',GS.RbSettings) - 1) AS int) 
ELSE NULL END AS PortfolioAnalysisId,
CASE WHEN S.ReportLabel like '%EQ%' THEN 'EQ'
WHEN S.ReportLabel like '%WS%' THEN 'WS'
WHEN S.ReportLabel like '%SCS%' THEN 'SCS'
ELSE 'other' END AS Peril,
GS.RbSettings,
GS.DetReportId,
GS.SumReportId,
GS.Billable,
GS.ExpireDate,
GS.ExpireCount,
GS.EverExpired,
GS.IsRequired
into #port_analysis_tb
FROM rms_web.dbo.GroupService GS
INNER JOIN [rms_web].[dbo].[GroupInfo] GI ON GS.GroupId = GI.GroupId
LEFT JOIN [rms_web].[dbo].[Service] S ON GS.ServiceId = S.ServiceId 
--WHERE GS.GroupId IN (11, 12, 13, 15) AND S.Driver like '%portfolioimpact%'AND GS.ServiceId IN (542, 543, 544)
--ORDER BY GS.GroupId, GS.RbSettings
WHERE S.Driver like '%portfolioimpact%' and LEN(GS.RbSettings) > 0
ORDER BY GS.GroupId, GS.RbSettings
------------------end #port_analysis_tb------------------

------------------start Portfolio Retrun Period table------------------
select
pe.ID as PortID,
pe.ANLSID,
pe.EPTYPE As EP_Distribition, 
an.NAME As AnalysisName, 
an.DESCRIPTION, 
an.PERIL, 
pe.PERSPCODE, 
pe.PERSPVALUE As Loss, 
pe.EP 
into #poleq_data
From 
[WKFC_C_PORT_RDM].dbo.rdm_portep pe
Inner Join  
[WKFC_C_PORT_RDM].dbo.rdm_analysis an
On pe.ANLSID = an.ID
--#EPTYPE: 0 is AEP; 1 is OEP
Where pe.EPTYPE in (0)
--AND [ANLSID] IN (2,3,1)
AND pe.[PERSPCODE] IN ('GR', 'GU') 
Order By Loss Desc

create table #EP (
Critical_Prob float
)
insert into #EP (Critical_Prob)
values
 (0.0001),
 (0.0002), 
 (0.0010), 
 (0.0020),
 (0.0040),
 (0.0050),
 (0.0100),
 (0.0200),
 (0.0400),
 (0.0500),
 (0.100), 
 (0.2)

select #EP.*, #poleq_data.*
into #master_data
from #EP, #poleq_data

select *
into #master_data_down
--select *
from #master_data
where Critical_Prob > EP

select *
into #master_data_up
--select *
from #master_data
where Critical_Prob <= EP

select * 
into #first_up
from (
select 
Critical_Prob,
PortID,
ANLSID,
EP_Distribition, 
AnalysisName, 
DESCRIPTION, 
PERIL, 
PERSPCODE, 
Loss, 
EP,
ROW_NUMBER() OVER (
  PARTITION BY Critical_Prob, PERSPCODE, ANLSID, PERIL, EP_Distribition
  ORDER BY EP - Critical_Prob 
) row_num
from #master_data_up
) a
where a.row_num =1
order by
Critical_Prob,
ANLSID,
EP_Distribition,
PERIL,
PERSPCODE

select * 
into #first_down
from (
select 
Critical_Prob,
PortID,
ANLSID,
EP_Distribition, 
AnalysisName, 
DESCRIPTION, 
PERIL, 
PERSPCODE, 
Loss, 
EP,
ROW_NUMBER() OVER (
  PARTITION BY Critical_Prob, PERSPCODE, ANLSID, PERIL, EP_Distribition
  ORDER BY Critical_Prob - EP 
) row_num
from #master_data_down
) b
where b.row_num = 1
order by
Critical_Prob,
ANLSID,
EP_Distribition,
PERIL,
PERSPCODE

select
c.PortID,
c.ANLSID,
c.Critical_Prob,
1/c.Critical_Prob Return_Period,
c.EP_Distribition,
c.AnalysisName,
c.PERIL,
c.PERSPCODE,
--(Loss_u - Loss_d) * (c.Critical_Prob - EP_d) / (EP_u - EP_d) + Loss_d Loss_Interp
(case when Loss_d is not null or EP_d is not null then (Loss_u - Loss_d) * (c.Critical_Prob - EP_d) / (EP_u - EP_d) + Loss_d 
else Loss_u 
end) Loss_Interp
into #Pol_RP_Loss
from
(select
u.PortID,
u.ANLSID,
u.Critical_Prob,
u.EP_Distribition, 
u.AnalysisName, 
u.PERIL, 
u.PERSPCODE, 
u.Loss Loss_u,
u.EP EP_u,
d.Loss Loss_d,
d.EP EP_d
from #first_up u
full outer join 
#first_down d 
on u.PortID = d.PortID
and u.ANLSID = d.ANLSID
and u.Critical_Prob = d.Critical_Prob
and u.EP_Distribition = d.EP_Distribition
and u.AnalysisName = d.AnalysisName
and u.PERIL = d.PERIL
and u.PERSPCODE = d.PERSPCODE
) c
where 
(Loss_u - Loss_d) * (c.Critical_Prob - EP_d) / (EP_u - EP_d) + Loss_d is not null
order by
PortID,
ANLSID,
EP_Distribition, 
PERIL, 
PERSPCODE,
Critical_Prob,
AnalysisName

select
distinct
PortID,
ANLSID as PortfolioAnalysisId,
Return_Period,
--PERIL,
case when PERIL = 'CS' then 'SCS' else PERIL end Peril,
SUM(CASE WHEN PERSPCODE = 'GU' THEN Loss_Interp END) GroundUpLoss,
SUM(CASE WHEN PERSPCODE = 'GR' THEN Loss_Interp END) GrossLoss
into #Pol_RP_Final
from 
#Pol_RP_Loss
GROUP BY
PortID,
ANLSID,
Return_Period,
Peril
--select * from #Pol_RP_Final
------------------end Portfolio Retrun Period table------------------

select 
job.JobId,
pa.GroupName,
job.EdmDataSource,
pa.GroupId,
pa.ServiceId,
pa.PortfolioAnalysisId,
pa.ReportLabel,
--portImp.*,
portImp.AccountId,
portImp.AnalysisId,
portImp.AnalysisName,
portImp.PortImpRept,
portImp.Peril,
portImp.ReportId,
portImp.ExposureId,
portImp.ExposureType,
portImp.ExposureName,
portImp.ExposureNumber,
portImp.EDMName,
portImp.EDMSqlServer,
portImp.FPCode,
portImp.MethodType,
portImp.OutputType,
portImp.Comment,
portImp.ReturnPeriod,
case when portImp.FPCode = 'GU' then portRP.GroundUpLoss
when portImp.FPCode = 'GR' then portRP.GrossLoss
else null end Loss,
portImp.Amount,
portImp.Ratio,
--case when portImp.FPCode = 'GU' then portRP.GroundUpLoss * portImp.Ratio
--when portImp.FPCode = 'GR' then portRP.GrossLoss * portImp.Ratio
--else null end Amount_from_RDM,
job.WebServerName
from
(select 
r.[AccountId], 
a.[AnalysisId], 
a.[AnalysisName],
case when a.[AnalysisName] like '%Earthquake%' then 'US EQ Portfolio Impact Report'
when a.[AnalysisName] like '%EQ%' then 'US EQ Portfolio Impact Report'
when a.[AnalysisName] like '%Severe Convective Storm%' then 'US SCS Portfolio Impact Report' 
when a.[AnalysisName] like '%Windstorm%' then 'US WS Portfolio Impact Report' else 'other' end PortImpRept,
case when a.[AnalysisName] like '%Earthquake%' then 'EQ'
when a.[AnalysisName] like '%EQ%' then 'EQ'
when a.[AnalysisName] like '%Severe Convective Storm%' then 'SCS' 
when a.[AnalysisName] like '%Windstorm%' then 'WS' else 'other' end Peril,
e.ReportId,
e.ExposureId,
e.ExposureType,
e.ExposureName,
e.ExposureNumber,
REPLACE(e.EDMName, '_', ' ') EDMName,
e.EDMSqlServer,
--case when e.EDMSqlServer = 'DC02RSGRLDB01' then 'DC02RSGRLAS01' else 'other' end EDMSqlServer,
p.FPCode,
p.MethodType,
p.OutputType,
p.Comment,
p.ReturnPeriod,
p.Amount,
p.[Percent] Ratio,
--p.Amount / NULLIF(p.[Percent], 0) PortRpLoss,
p.[Status]
from
[WKFC_C_REPORTING].dbo.[ExposureInfo] e
inner join
[WKFC_C_REPORTING].dbo.[PortfolioImpactReport] p
on
e.ReportID = p.ReportID
and e.[ExposureId] = p.[ExposureId]
and e.[ExposureType] = p.[ExposureType]
inner join
[WKFC_C_REPORTING].dbo.[Report] r
on r.ID = e.ReportID
inner join
[WKFC_C_REPORTING].dbo.[AnalysisInfo] a
on a.ReportID = e.ReportID
and p.Comment = case when a.[AnalysisName] like '%Earthquake%' then 'US EQ Portfolio Impact Report'
when a.[AnalysisName] like '%EQ%' then 'US EQ Portfolio Impact Report'
when a.[AnalysisName] like '%Severe Convective Storm%' then 'US SCS Portfolio Impact Report' 
when a.[AnalysisName] like '%Windstorm%' then 'US WS Portfolio Impact Report' else 'other' end
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
and portImp.EDMName = REPLACE(job.[EdmDataSource], '_', ' ')
--and portImp.EDMSqlServer = job.[WebServerName]
left join
#port_analysis_tb pa
on portImp.EDMName like CONCAT('%', REPLACE(pa.GroupName, '_', ' '), '%')
and portImp.Peril = pa.Peril
left join
#Pol_RP_Final portRP
on pa.PortfolioAnalysisId = portRP.PortfolioAnalysisId
and portImp.ReturnPeriod = portRP.Return_Period
and portImp.Peril = portRP.Peril
where
portImp.[AccountId] = 97
and portImp.[AnalysisId] in (181, 182, 183)
and job.JobId = 939
and REPLACE(job.EdmDataSource, ' ', '_') = REPLACE('WKFC_C_EDM' , ' ', '_')
order by JobId, EdmDataSource, AccountId, AnalysisId


----------------------------NOTE--------------------------------------
--select * from [WKFC_C_REPORTING].dbo.[ExposureInfo]

--select * from #port_analysis_tb where GroupName = 'WKFC_R'
--and portRP.Peril = 'EQ' and portImp.ReturnPeriod = 100
