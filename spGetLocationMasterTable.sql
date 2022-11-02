	USE [Z_PAPI_PROD]
	GO
	/****** Object:  StoredProcedure [dbo].[spGetLocationMasterTable]    Script Date: 10/19/2022 9:25:23 AM ******/
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO

	ALTER PROCEDURE [dbo].[spGetLocationMasterTable] 
		@EDM varchar(60) = '',				-- JEM_MGU_EDM
		@RDM varchar(60) = '',				-- JEM_MGU_RDM
		@PAPI_JobId int = 0,				-- 60001106
		@DLM_JobId int = 0,					-- 41979
		@AccountID varchar (max) = '',		-- 21053
		@AnalysisIDList varchar (max) = ''	-- 19034,19036,19037
	AS
	-----------------------------------------------------------------------------------------------------------------
	-- Created by Ming Tsai 2020-05-13
	-- 
	-- Description:
	--
	-- History:
	--	2020-05-13	Ming Tsai	Added
	--	2020-05-14	Ming Tsai	Add @PAPI_JobId; ren @AccountID/@AccountIDList; chg length to max; add query mode
	--	2020-08-17	Ming Tsai	Script revised in template
	--	2020-09-24	Ming Tsai	##DB_NAME## used to map to current DB
	--	2020-10-19	Ming Tsai	Apply Hongchi's changes on [MATCH LEVEL] and [Year Upgraded]
	--	2021-01-13	Ming Tsai	Rebuild the stored procedure from script captured
	--	2021-02-05	Ming Tsai	Rebuild the stored procedure from script captured (v12)
	--	2021-02-26	Ming Tsai	Rebuild the stored procedure from script captured (v12.5)
	--  2022-10-19  Yunting Chiu  Add condition policy terms to the table [CONDxNAME] [CONDxPOLICYNUM] [CONDxINCLUDED]
	--
	-----------------------------------------------------------------------------------------------------------------
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

		-- Insert/Updatemode
		IF @EDM <> ''
		BEGIN

			DECLARE @dynaSQL nvarchar(max)
			SET @dynaSQL = N'



	IF OBJECT_ID("tempdb..#master_data") IS NOT NULL
	DROP TABLE #master_data
	IF OBJECT_ID("tempdb..#EDM_Info") IS NOT NULL
	DROP TABLE #EDM_Info
	IF OBJECT_ID("tempdb..#AAL_Info") IS NOT NULL
	DROP TABLE #AAL_Info
	IF OBJECT_ID("tempdb..#Layers") IS NOT NULL
	DROP TABLE #Layers
	IF OBJECT_ID("tempdb..#loc_master") IS NOT NULL
	DROP TABLE  #loc_master
	IF OBJECT_ID("tempdb..#cond_lookup") IS NOT NULL
	DROP TABLE  #cond_lookup
	IF OBJECT_ID("tempdb..#cond_pol") IS NOT NULL
	DROP TABLE  #cond_pol
	use [##EDM##]

	SELECT 
	LocPolAcg.LOCID, 
	LocPolAcg.CONDITIONID, 
	LocPolAcg.POLICYID, 
	LocPolAcg.CONDITIONNAME, 
	LocPolAcg.PREDEFINED, 
	LocPolAcg.LIMIT, 
	LocPolAcg.DEDUCTIBLE,
	LocPolAcg.DEDUCTIBLETYPE, 
	LocPolAcg.CONDITIONTYPE, 
	LocPolAcg.PARENTCONDITIONID, 
	p.ACCGRPID, 
	p.POLICYNUM, 
	p.POLICYTYPE
	into #cond_lookup
	FROM 
	(SELECT
	lcon.LOCID, 
	lcon.CONDITIONID, 
	pcon.POLICYID, 
	pcon.CONDITIONNAME, 
	pcon.PREDEFINED, 
	pcon.LIMIT,
	pcon.DEDUCTIBLE, 
	pcon.DEDUCTIBLETYPE, 
	pcon.CONDITIONTYPE, 
	pcon.PARENTCONDITIONID
	FROM dbo.locconditions lcon 
	INNER JOIN 
	dbo.policyconditions pcon 
	ON lcon.CONDITIONID = pcon.CONDITIONID) LocPolAcg
	INNER JOIN
	dbo.policy p ON LocPolAcg.POLICYID = p.POLICYID

	select
	max(LOCID) as LOCID,
	max(CONDITIONNAME) as COND1NAME,
	max((case when CONDPOLICYCNT = 1 then POLICYNUM end)) as COND1POLICYNUM,
	max(CONDITIONNAME) as COND2NAME,
	max((case when CONDPOLICYCNT = 2 then POLICYNUM end)) as COND2POLICYNUM,
	max(CONDITIONNAME) as COND3NAME,
	max((case when CONDPOLICYCNT = 3 then POLICYNUM end)) as COND3POLICYNUM,
	max(CONDITIONNAME) as COND4NAME,
	max((case when CONDPOLICYCNT = 4 then POLICYNUM end)) as COND4POLICYNUM,
	max(CONDITIONNAME) as COND5NAME,
	max((case when CONDPOLICYCNT = 5 then POLICYNUM end)) as COND5POLICYNUM
	into #cond_pol
	from
	(select *,
	row_number() over (partition by LOCID order by CONDITIONID asc) CONDPOLICYCNT 
	from #cond_lookup) CONDPOL
	group by CONDPOL.LOCID
	order by CONDPOL.LOCID

	Select
	--ap.PORTINFOID,
	ag.ACCGRPID,
	ag.ACCGRPNUM,
	ag.ACCGRPNAME,
	loc.LOCID,
	loc.LOCNUM,
	loc.LOCNAME,
	loc.STREETNAME [Steet Address],
	loc.CITY,
	loc.COUNTY,
	loc.STATECODE STATE,
	loc.POSTALCODE [ZIP Code],
	loc.LATITUDE,
	loc.LONGITUDE,
	loc.COUNTRY,
	loc.CRESTA [CRESTA Zone],
	CASE WHEN loc.ADDRMATCH=0 THEN "UNGEOCODED" WHEN loc.ADDRMATCH=1 THEN "COORDINATE" WHEN loc.ADDRMATCH =2 AND loc.GEODATASOURCE=16 THEN "BUILDING" WHEN loc.ADDRMATCH =2 AND loc.GEODATASOURCE=4 THEN "PARCEL" 
	WHEN loc.ADDRMATCH =2 AND loc.GEODATASOURCE IN (0, 2, 8,32) THEN "STREET" WHEN loc.ADDRMATCH =3 THEN "HIGH RES POSTCODE" WHEN loc.ADDRMATCH =4 THEN "BLOCK" WHEN loc.ADDRMATCH =5 THEN "POSTCODE" WHEN loc.ADDRMATCH =6 THEN "NEIGHBORHOOD" 
	WHEN loc.ADDRMATCH =7 THEN "CITY" WHEN loc.ADDRMATCH=8 then "DISTRICT/MUNICIPALITY" WHEN loc.ADDRMATCH=9 then "COUNTY" WHEN loc.ADDRMATCH=10 then "STATE" WHEN loc.ADDRMATCH=11 then "CRESTA" WHEN loc.ADDRMATCH=12 then "MULTIPLE"
	WHEN loc.ADDRMATCH=13 then "USER DEFINED" WHEN loc.ADDRMATCH =14 THEN "COUNTRY" else "UNGEOCODED" end [MATCH LEVEL],
	ISNULL(lcvTIV.TIV_EQ_BLDG,0) [EQ Building Value],
	ISNULL(lcvTIV.TIV_EQ_CONT,0) [EQ Contents Value],
	ISNULL(lcvTIV.TIV_EQ_BI,0) [EQ BI Value],
	ISNULL(lcvTIV.TIV_WS_BLDG,0) [WS Building Value],
	ISNULL(lcvTIV.TIV_WS_CONT,0) [WS Contents Value],
	ISNULL(lcvTIV.TIV_WS_BI,0) [WS BI Value],
	ISNULL(lcvTIV.TIV_SCS_BLDG,0) [SCS Building Value],
	ISNULL(lcvTIV.TIV_SCS_CONT,0) [SCS Contents Value],
	ISNULL(lcvTIV.TIV_SCS_BI,0) [SCS BI Value],
	ltiv.TIV [Location TIV],
	loc.BLDGSCHEME [Construction Class Scheme],
	upper(const_desc.C_DESC) [Construction Class],
	loc.BLDGCLASS [Construction Class Code],
	bda.[C_ABBR] Const_Cls_Abbr,
	loc.OCCSCHEME [Occupancy Type Scheme],
	occ_desc.O_DESC [Occupancy Type],
	oda.[O_ABBRV] Occ_Tp_Abbr,
	loc.OCCTYPE [Occupancy Code],
	loc.NUMSTORIES [# of Stories],
	loc.BLDGHEIGHT [Building Height],
	CASE loc.HEIGHTUNIT WHEN 0 THEN "CENTIMETER" WHEN 1 THEN "INCH" WHEN 2 THEN "FEET" WHEN 3 THEN "YARD" WHEN 4 THEN "METER" ELSE "" END [HEIGHT UNIT],
	loc.YEARBUILT [Year Built],
	case when year(le.YEARUPGRAD) <> 9999 and le.YEARUPGRAD is not null then le.YEARUPGRAD when year(lh.YEARUPGRAD) <> 9999 and lh.YEARUPGRAD is not null then lh.YEARUPGRAD when year(lscs.YEARUPGRAD) <> 9999 and lscs.YEARUPGRAD is not null then lscs.YEARUPGRAD else null end [Year Upgraded],
	loc.FLOORAREA [Floor Area],
	Case loc.AREAUNIT when 2 then "SQUARE FEET" when 4 then "SQUARE METERS" else "SQUARE FEET" end [AREA UNIT],
	loc.NUMBLDGS [# of Bldgs],
	loc.DWELLTIME [Dwell Time (days)],
	prp.NSHIP [# SHIPMENTS],
	isnull(le.SINKHOLEZONE,0) [Sinkhole Hazard Zone],
	isnull(le.DISTSINKHOLE,0) [Distance to Closest Sinkhole],
	isnull(lfl.FLZONE, "") [Flood Zone],
	isnull(lfl.BFE, "") [BASE FLOOD ELEVATION],
	isnull(le.MMI250,0) [250 Year MMI],
	lfl.RMS100FLZONE,
	lfl.RMS500FLZONE,
	lfl.CONFIDENCE,
	lfl.DURATION,
	lfl.VELOCITY,
	lfl.SFHA,
	isnull(lh.DISTCOAST,0) [Distance To Coast],
	case when le.SOILTYPE = 0.01 then "Very Hard Rock" else isnull(sltp.SOIL_TYPE_NAME,"") end [Soil Type],
	isnull(case lh.ROOFAGE when 0 then "Unknown" when 1 then "1-5 Years" when 2 then "6-10 Years" when 3 then "11 Years or more" end, "") [RoofAge],
	case le.EQSLINS when 1 then "100%" else "0%" end [Percent Sprinklered],
	case le.EQSLINS when 1 then "Y" else "N" end [Sprinklered (Y/N)],
	case when le.LANDSLIDE= 1 then "Very Low" else isnull(ldsl.landslide_name,"") end LANDSLIDE,
	case when le.LIQUEFACT= 1 then "Very Low" else isnull(lqfc.liquefaction_name,"") end LIQUEFACT,
	le.DISTMINE,
	le.DISTFAULT1,
	le.EQSLOPE,
	case lfr.WFHAZARD when 0 then "Unknown" when 1 then "Very Low" when 2 then "Low" when 3 then "Moderate" when 4 then "High" when 5 then "Very High" when 6 then "Extreme" else "" end WFHAZARD,
	case lfr.WFSUSCEPT when 0 then "Unknown" when 1 then "Very Low" when 2 then "Low" when 3 then "Moderate" when 4 then "High" when 5 then "Very High" when 6 then "Extreme" else "" end WFSUSCEPT,
	case lfr.WFTHREAT when 0 then "Unknown" when 1 then "Very Low" when 2 then "Low" when 3 then "Moderate" when 4 then "High" when 5 then "Very High" when 6 then "Extreme" else "" end WFTHREAT,
	case lfr.WFSURFFUEL when "NF" then "Non-fuel, dirt, barren, rock, desert, water" when "F1" then "Grass and grass dominated" when "F2" then "Chaparral and shrub" when "F3" then "Timber litter" 
	when "F4" then "Slash" when "AG" then "Agricultural" when "URB" then "Urban" when "MIX" then "Mixed fuel" else "" end WFSURFFUEL,
	case lfr.WFAREADESC when 10 then "Wildland Mixed" when 11 then "Wildland Limited" when 12 then "Wildland" when 20 then "Intermix-Mixed Density" when 21 then "Intermix-Low Density" when 22 then "Intermix-Medium Density"
	when 23 then "Intermix-High Density" when 30 then "Interface-Mixed Density" when 31 then "Interface-Low Density" when 32 then "Interface-Medium Density" when 33 then "Interface-High Density" when 40 then "Urban-Mixed Density"
	when 41 then "Urban-Low Density" when 42 then "Urban-Medium Density" when 43 then "Urban-High Density" when 50 then "Mixed Fuel" when 51 then "Limited Fuel" when 52 then "Significant Fuel" when 98 then "Uninhabited-Mixed" 
	when 99 then "Water" else "" end WFAREADESC,
	lfr.WFNEARHIST,
	isnull(polAAL.UNDCOVAMT, "") UNDCOVAMT,
	isnull(polAAL.PARTOF, "") PARTOF,
	isnull(polAAL.Layer, "") Layer,
	isnull(loc_stat.AAL_LOC_GU_EQ, 0) AAL_GU_EQ,
	isnull(CASE WHEN polGrAAL.AAL_POL_AllLayer_GR_EQ = 0 THEN 0 ELSE polAAL.AAL_POL_GR_EQ / polGrAAL.AAL_POL_AllLayer_GR_EQ * ISNULL(AAL_LOC_GR_EQ, 0) END, 0) AS AAL_GR_EQ,
	isnull(loc_stat.AAL_LOC_GU_WS, 0) AAL_GU_WS,
	isnull(CASE WHEN polGrAAL.AAL_POL_AllLayer_GR_WS = 0 THEN 0 ELSE polAAL.AAL_POL_GR_WS / polGrAAL.AAL_POL_AllLayer_GR_WS * ISNULL(AAL_LOC_GR_WS, 0) END, 0) AS AAL_GR_WS,
	isnull(loc_stat.AAL_LOC_GU_CS, 0) AAL_GU_CS,
	isnull(CASE WHEN polGrAAL.AAL_POL_AllLayer_GR_CS = 0 THEN 0 ELSE polAAL.AAL_POL_GR_CS / polGrAAL.AAL_POL_AllLayer_GR_CS * ISNULL(AAL_LOC_GR_CS, 0) END, 0) AS AAL_GR_CS,
	isnull(loc_stat.AAL_LOC_GU_FL, 0) AAL_GU_FL,
	isnull(CASE WHEN polGrAAL.AAL_POL_AllLayer_GR_FL = 0 THEN 0 ELSE polAAL.AAL_POL_GR_FL / polGrAAL.AAL_POL_AllLayer_GR_FL * ISNULL(AAL_LOC_GR_FL, 0) END, 0) AS AAL_GR_FL,
	isnull(loc_stat.AAL_LOC_GU_FR, 0) AAL_GU_FR,
	isnull(CASE WHEN polGrAAL.AAL_POL_AllLayer_GR_FR = 0 THEN 0 ELSE polAAL.AAL_POL_GR_FR / polGrAAL.AAL_POL_AllLayer_GR_FR * ISNULL(AAL_LOC_GR_FR, 0) END, 0) AS AAL_GR_FR,
	isnull(loc_stat.AAL_LOC_GU_TR, 0) AAL_GU_TR,
	isnull(CASE WHEN polGrAAL.AAL_POL_AllLayer_GR_TR = 0 THEN 0 ELSE polAAL.AAL_POL_GR_TR / polGrAAL.AAL_POL_AllLayer_GR_TR * ISNULL(AAL_LOC_GR_TR, 0) END, 0) AS AAL_GR_TR,
	lcvDedLim.EQ_BLD_Ded,
	lcvDedLim.EQ_BLD_Lim,
	lcvDedLim.EQ_CNT_Ded,
	lcvDedLim.EQ_CNT_Lim,
	lcvDedLim.EQ_BI_Ded,
	lcvDedLim.EQ_BI_Lim,
	lcvDedLim.WS_BLD_Ded,
	lcvDedLim.WS_BLD_Lim,
	lcvDedLim.WS_CNT_Ded,
	lcvDedLim.WS_CNT_Lim,
	lcvDedLim.WS_BI_Ded,
	lcvDedLim.WS_BI_Lim,
	lcvDedLim.SCS_BLD_Ded,
	lcvDedLim.SCS_BLD_Lim,
	lcvDedLim.SCS_CNT_Ded,
	lcvDedLim.SCS_CNT_Lim,
	lcvDedLim.SCS_BI_Ded,
	lcvDedLim.SCS_BI_Lim,
	le.SITELIMAMT EQ_SITELIMAMT,
	le.SITEDEDAMT EQ_SITEDEDAMT,
	lh.SITELIMAMT WS_SITELIMAMT,
	lh.SITEDEDAMT WS_SITEDEDAMT,
	lscs.SITELIMAMT SCS_SITELIMAMT,
	lscs.SITEDEDAMT SCS_SITEDEDAMT,
	CASE WHEN pol_peril.EQ > 0 then 1 else 0 end EQ,
	CASE WHEN pol_peril.WS > 0 then 1 else 0 end WS,
	CASE WHEN pol_peril.SCS > 0 then 1 else 0 end SCS,
	CASE WHEN loc.YEARBUILT between 1700 and 1936 then "1700 - 1936"
	WHEN year(loc.YEARBUILT) between 1937 and 1956 then "1937 - 1956"
	WHEN year(loc.YEARBUILT) between 1957 and 1973 then "1957 - 1973"
	WHEN year(loc.YEARBUILT) between 1974 and 1988 then "1974 - 1988"
	WHEN year(loc.YEARBUILT) between 1989 and 1994 then "1989 - 1994"
	WHEN year(loc.YEARBUILT) between 1995 and 2001 then "1995 - 2001"
	WHEN year(loc.YEARBUILT) >= 2002 and year(loc.YEARBUILT) <> 9999 then "Post 2002" 
	else "Unknown" end [YrBld_Band],
	case when loc.NUMSTORIES = 1 then "1"
	when loc.NUMSTORIES between 2 and 3 then "2 - 3"
	when loc.NUMSTORIES between 4 and 7 then "4 - 7"
	when loc.NUMSTORIES between 8 and 14 then "8 - 14"
	when loc.NUMSTORIES between 15 and 40 then "15 - 40"
	when loc.NUMSTORIES >= 41 then "Above 40" 
	else "Unknown" end [Stories_Band],
	isnull(cty.[RSG_FINAL REGION_WS], "xWind")  WS_County_Region,
	Case when loc.STATECODE = "CA" and loc.cresta <> "" then concat("Zone ", left(loc.cresta,1), " - California") else isnull(cty.[RSG_FINAL REGION_EQ], "Other") end EQ_County_Region,
	case loc.STATECODE when "CO" then "COLORADO"  when "KS" then "KANSAS" when "KY" then "KENTUCKY" when "MO" then "MISSOURI" when "NE" then "NEBRASKA" when "OK" then "OKLAHOMA" when "TN" then "TENNESSEE" when "TX" then "TEXAS" else "Other" end CS_ZIP_Region
	Into #master_data
	FROM dbo.accgrp ag 
	--INNER JOIN dbo.portacct ap ON ag.ACCGRPID = ap.ACCGRPID
	--left JOIN dbo.portinfo pr ON ap.PORTINFOID = pr.PORTINFOID
	INNER JOIN dbo.loc loc ON ag.ACCGRPID = loc.ACCGRPID
	left JOIN dbo.Property prp on prp.LOCID = loc.LOCID
	left JOIN dbo.eqdet le ON loc.LOCID = le.LOCID
	left JOIN dbo.hudet lh ON loc.LOCID = lh.LOCID
	left JOIN dbo.frdet lfr ON loc.LOCID = lfr.LOCID
	left JOIN dbo.todet lscs ON loc.LOCID = lscs.LOCID
	left JOIN dbo.fldet lfl ON loc.LOCID = lfl.LOCID
	left JOIN dbo.trdet ltr ON loc.LOCID = ltr.LOCID
	left JOIN RMS_VULNERABILITY.dbo.acvccus const_desc on const_desc.C_CLASSIF = loc.BLDGSCHEME AND const_desc.C_CLASS = loc.BLDGCLASS
	left JOIN RMS_VULNERABILITY.dbo.acvoccus occ_desc on occ_desc.O_CLASSIF = loc.OCCSCHEME and occ_desc.O_CLASS = loc.OCCTYPE
	left JOIN CAT_Reference.[dbo].[RSG_County_Regions] cty on upper(cty.StateCode) = upper(loc.STATECODE) and right(cty.[County FIPS], 3) *1 = loc.[countycode] *1
	left JOIN [CAT_Reference].[dbo].[RSG_ZIP_Regions] zp on zp.Zip_Enc = loc.POSTALCODE
	left JOIN [CAT_Reference].[dbo].[BLDG_Desc_Abbr] bda on bda.C_CLASSIF = loc.BLDGSCHEME AND bda.C_CLASS = loc.BLDGCLASS 
	left JOIN [CAT_Reference].[dbo].[OCC_Desc_Abbr] oda on oda.O_CLASSIF = loc.OCCSCHEME and oda.O_CLASS = loc.OCCTYPE
	left JOIN 
	(SELECT LOCID,
	sum(CASE WHEN lcvg.LOSSTYPE = 1 AND PERIL =1 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_EQ_BLDG,
	sum(CASE WHEN lcvg.LOSSTYPE = 1 AND PERIL =2 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_WS_BLDG,
	sum(CASE WHEN lcvg.LOSSTYPE = 1 AND PERIL =3 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_SCS_BLDG,
	sum(CASE WHEN lcvg.LOSSTYPE = 1 AND PERIL =4 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_FL_BLDG,
	sum(CASE WHEN lcvg.LOSSTYPE = 1 AND PERIL =5 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_FR_BLDG,
	sum(CASE WHEN lcvg.LOSSTYPE = 1 AND PERIL =6 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_TR_BLDG,
	sum(CASE WHEN lcvg.LOSSTYPE = 2 AND PERIL =1 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_EQ_CONT,
	sum(CASE WHEN lcvg.LOSSTYPE = 2 AND PERIL =2 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_WS_CONT,
	sum(CASE WHEN lcvg.LOSSTYPE = 2 AND PERIL =3 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_SCS_CONT,
	sum(CASE WHEN lcvg.LOSSTYPE = 2 AND PERIL =4 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_FL_CONT,
	sum(CASE WHEN lcvg.LOSSTYPE = 2 AND PERIL =5 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_FR_CONT,
	sum(CASE WHEN lcvg.LOSSTYPE = 2 AND PERIL =6 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_TR_CONT,
	sum(CASE WHEN lcvg.LOSSTYPE = 3 AND PERIL =1 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_EQ_BI,
	sum(CASE WHEN lcvg.LOSSTYPE = 3 AND PERIL =2 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_WS_BI,
	sum(CASE WHEN lcvg.LOSSTYPE = 3 AND PERIL =3 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_SCS_BI,
	sum(CASE WHEN lcvg.LOSSTYPE = 3 AND PERIL =4 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_FL_BI,
	sum(CASE WHEN lcvg.LOSSTYPE = 3 AND PERIL =5 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_FR_BI,
	sum(CASE WHEN lcvg.LOSSTYPE = 3 AND PERIL =6 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_TR_BI,
	sum(CASE WHEN PERIL =1 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_EQ_TOT,
	sum(CASE WHEN PERIL =2 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_WS_TOT,
	sum(CASE WHEN PERIL =3 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_SCS_TOT,
	sum(CASE WHEN PERIL =4 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_FL_TOT,
	sum(CASE WHEN PERIL =5 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_FR_TOT,
	sum(CASE WHEN PERIL =6 THEN lcvg.VALUEAMT ELSE 0 END) as TIV_TR_TOT
	FROM dbo.loccvg lcvg
	GROUP BY LOCID) AS lcvTIV on loc.LOCID = lcvTIV.LOCID
  
	left join [dbo].[LocTIV] ltiv on loc.LOCID = ltiv.LOCID
	left JOIN
	(SELECT lcv3.LOCID,
	SUM(ISNULL(lcv3.EQ_BLD_Ded,0))  EQ_BLD_Ded,
	SUM(ISNULL(lcv3.EQ_BLD_Lim,0))  EQ_BLD_Lim,
	SUM(ISNULL(lcv3.EQ_CNT_Ded,0))  EQ_CNT_Ded,
	SUM(ISNULL(lcv3.EQ_CNT_Lim,0))  EQ_CNT_Lim,
	SUM(ISNULL(lcv3.EQ_BI_Ded,0))  EQ_BI_Ded,
	SUM(ISNULL(lcv3.EQ_BI_Lim,0))  EQ_BI_Lim,
	SUM(ISNULL(lcv3.WS_BLD_Ded,0))  WS_BLD_Ded,
	SUM(ISNULL(lcv3.WS_BLD_Lim,0))  WS_BLD_Lim,
	SUM(ISNULL(lcv3.WS_CNT_Ded,0))  WS_CNT_Ded,
	SUM(ISNULL(lcv3.WS_CNT_Lim,0))  WS_CNT_Lim,
	SUM(ISNULL(lcv3.WS_BI_Ded,0))  WS_BI_Ded,
	SUM(ISNULL(lcv3.WS_BI_Lim,0))  WS_BI_Lim,
	SUM(ISNULL(lcv3.SCS_BLD_Ded,0))  SCS_BLD_Ded,
	SUM(ISNULL(lcv3.SCS_BLD_Lim,0))  SCS_BLD_Lim,
	SUM(ISNULL(lcv3.SCS_CNT_Ded,0))  SCS_CNT_Ded,
	SUM(ISNULL(lcv3.SCS_CNT_Lim,0))  SCS_CNT_Lim,
	SUM(ISNULL(lcv3.SCS_BI_Ded,0))  SCS_BI_Ded,
	SUM(ISNULL(lcv3.SCS_BI_Lim,0))  SCS_BI_Lim,
	SUM(ISNULL(lcv3.FL_BLD_Ded,0))  FL_BLD_Ded,
	SUM(ISNULL(lcv3.FL_BLD_Lim,0))  FL_BLD_Lim,
	SUM(ISNULL(lcv3.FL_CNT_Ded,0))  FL_CNT_Ded,
	SUM(ISNULL(lcv3.FL_CNT_Lim,0))  FL_CNT_Lim,
	SUM(ISNULL(lcv3.FL_BI_Ded,0))  FL_BI_Ded,
	SUM(ISNULL(lcv3.FL_BI_Lim,0))  FL_BI_Lim,
	SUM(ISNULL(lcv3.FR_BLD_Ded,0))  FR_BLD_Ded,
	SUM(ISNULL(lcv3.FR_BLD_Lim,0))  FR_BLD_Lim,
	SUM(ISNULL(lcv3.FR_CNT_Ded,0))  FR_CNT_Ded,
	SUM(ISNULL(lcv3.FR_CNT_Lim,0))  FR_CNT_Lim,
	SUM(ISNULL(lcv3.FR_BI_Ded,0))  FR_BI_Ded,
	SUM(ISNULL(lcv3.FR_BI_Lim,0))  FR_BI_Lim,
	SUM(ISNULL(lcv3.TR_BLD_Ded,0))  TR_BLD_Ded,
	SUM(ISNULL(lcv3.TR_BLD_Lim,0))  TR_BLD_Lim,
	SUM(ISNULL(lcv3.TR_CNT_Ded,0))  TR_CNT_Ded,
	SUM(ISNULL(lcv3.TR_CNT_Lim,0))  TR_CNT_Lim,
	SUM(ISNULL(lcv3.TR_BI_Ded,0))  TR_BI_Ded,
	SUM(ISNULL(lcv3.TR_BI_Lim,0)) TR_BI_Lim
	FROM
	(
	SELECT distinct lcv2.LOCID,
	case when lcv2.PERIL=1 and LOSSTYPE = 1 then lcv2.DEDUCTAMT end EQ_BLD_Ded,
	case when lcv2.PERIL=1 and LOSSTYPE = 1 then lcv2.LIMITAMT end EQ_BLD_Lim,
	case when lcv2.PERIL=1 and LOSSTYPE = 2 then lcv2.DEDUCTAMT end EQ_CNT_Ded,
	case when lcv2.PERIL=1 and LOSSTYPE = 2 then lcv2.LIMITAMT end EQ_CNT_Lim,
	case when lcv2.PERIL=1 and LOSSTYPE = 3 then lcv2.DEDUCTAMT end EQ_BI_Ded,
	case when lcv2.PERIL=1 and LOSSTYPE = 3 then lcv2.LIMITAMT end EQ_BI_Lim,
	case when lcv2.PERIL=2 and LOSSTYPE = 1 then lcv2.DEDUCTAMT end WS_BLD_Ded,
	case when lcv2.PERIL=2 and LOSSTYPE = 1 then lcv2.LIMITAMT end WS_BLD_Lim,
	case when lcv2.PERIL=2 and LOSSTYPE = 2 then lcv2.DEDUCTAMT end WS_CNT_Ded,
	case when lcv2.PERIL=2 and LOSSTYPE = 2 then lcv2.LIMITAMT end WS_CNT_Lim,
	case when lcv2.PERIL=2 and LOSSTYPE = 3 then lcv2.DEDUCTAMT end WS_BI_Ded,
	case when lcv2.PERIL=2 and LOSSTYPE = 3 then lcv2.LIMITAMT end WS_BI_Lim,
	case when lcv2.PERIL=3 and LOSSTYPE = 1 then lcv2.DEDUCTAMT end SCS_BLD_Ded,
	case when lcv2.PERIL=3 and LOSSTYPE = 1 then lcv2.LIMITAMT end SCS_BLD_Lim,
	case when lcv2.PERIL=3 and LOSSTYPE = 2 then lcv2.DEDUCTAMT end SCS_CNT_Ded,
	case when lcv2.PERIL=3 and LOSSTYPE = 2 then lcv2.LIMITAMT end SCS_CNT_Lim,
	case when lcv2.PERIL=3 and LOSSTYPE = 3 then lcv2.DEDUCTAMT end SCS_BI_Ded,
	case when lcv2.PERIL=3 and LOSSTYPE = 3 then lcv2.LIMITAMT end SCS_BI_Lim,
	case when lcv2.PERIL=4 and LOSSTYPE = 1 then lcv2.DEDUCTAMT end FL_BLD_Ded,
	case when lcv2.PERIL=4 and LOSSTYPE = 1 then lcv2.LIMITAMT end FL_BLD_Lim,
	case when lcv2.PERIL=4 and LOSSTYPE = 2 then lcv2.DEDUCTAMT end FL_CNT_Ded,
	case when lcv2.PERIL=4 and LOSSTYPE = 2 then lcv2.LIMITAMT end FL_CNT_Lim,
	case when lcv2.PERIL=4 and LOSSTYPE = 3 then lcv2.DEDUCTAMT end FL_BI_Ded,
	case when lcv2.PERIL=4 and LOSSTYPE = 3 then lcv2.LIMITAMT end FL_BI_Lim,
	case when lcv2.PERIL=5 and LOSSTYPE = 1 then lcv2.DEDUCTAMT end FR_BLD_Ded,
	case when lcv2.PERIL=5 and LOSSTYPE = 1 then lcv2.LIMITAMT end FR_BLD_Lim,
	case when lcv2.PERIL=5 and LOSSTYPE = 2 then lcv2.DEDUCTAMT end FR_CNT_Ded,
	case when lcv2.PERIL=5 and LOSSTYPE = 2 then lcv2.LIMITAMT end FR_CNT_Lim,
	case when lcv2.PERIL=5 and LOSSTYPE = 3 then lcv2.DEDUCTAMT end FR_BI_Ded,
	case when lcv2.PERIL=5 and LOSSTYPE = 3 then lcv2.LIMITAMT end FR_BI_Lim,
	case when lcv2.PERIL=6 and LOSSTYPE = 1 then lcv2.DEDUCTAMT end TR_BLD_Ded,
	case when lcv2.PERIL=6 and LOSSTYPE = 1 then lcv2.LIMITAMT end TR_BLD_Lim,
	case when lcv2.PERIL=6 and LOSSTYPE = 2 then lcv2.DEDUCTAMT end TR_CNT_Ded,
	case when lcv2.PERIL=6 and LOSSTYPE = 2 then lcv2.LIMITAMT end TR_CNT_Lim,
	case when lcv2.PERIL=6 and LOSSTYPE = 3 then lcv2.DEDUCTAMT end TR_BI_Ded,
	case when lcv2.PERIL=6 and LOSSTYPE = 3 then lcv2.LIMITAMT end TR_BI_Lim
	FROM dbo.loccvg lcv2 ) as lcv3
	GROUP BY lcv3.LOCID
	) AS lcvDedLim on loc.LOCID = lcvDedLim.LOCID
	LEFT JOIN
	(SELECT ACCGRPID,
	SUM( CASE WHEN POLICYTYPE = 2 THEN 2 ELSE 0 END) WS,
	SUM( CASE WHEN POLICYTYPE = 1 THEN 1 ELSE 0 END) EQ,
	SUM( CASE WHEN POLICYTYPE = 3 THEN 3 ELSE 0 END) SCS,
	SUM( CASE WHEN POLICYTYPE = 4 THEN 4 ELSE 0 END) FL,
	SUM( CASE WHEN POLICYTYPE = 5 THEN 5 ELSE 0 END) FR,
	SUM( CASE WHEN POLICYTYPE = 6 THEN 6 ELSE 0 END) TR
	FROM dbo.policy
	GROUP BY ACCGRPID) pol_peril 
	on pol_peril.ACCGRPID = loc.ACCGRPID
	left join
	(Select LOCID, max(COVGMOD) COVGMOD
	from dbo.loccvg
	group by LOCID) loc_cvmd on loc_cvmd.LOCID = loc.LOCID
	left join 
	(Select ls.ID,
	sum(isnull(case when ls.PERSPCODE = "GU" and an.PERIL = "EQ" then PUREPREMIUM end,0)) AAL_LOC_GU_EQ,
	sum(isnull(case when ls.PERSPCODE = "GR" and an.PERIL = "EQ" then PUREPREMIUM end,0)) AAL_LOC_GR_EQ,
	sum(isnull(case when ls.PERSPCODE = "GU" and an.PERIL = "WS" then PUREPREMIUM end,0)) AAL_LOC_GU_WS,
	sum(isnull(case when ls.PERSPCODE = "GR" and an.PERIL = "WS" then PUREPREMIUM end,0)) AAL_LOC_GR_WS,
	sum(isnull(case when ls.PERSPCODE = "GU" and an.PERIL = "CS" then PUREPREMIUM end,0)) AAL_LOC_GU_CS,
	sum(isnull(case when ls.PERSPCODE = "GR" and an.PERIL = "CS" then PUREPREMIUM end,0)) AAL_LOC_GR_CS,
	sum(isnull(case when ls.PERSPCODE = "GU" and an.PERIL = "FL" then PUREPREMIUM end,0)) AAL_LOC_GU_FL,
	sum(isnull(case when ls.PERSPCODE = "GR" and an.PERIL = "FL" then PUREPREMIUM end,0)) AAL_LOC_GR_FL,
	sum(isnull(case when ls.PERSPCODE = "GU" and an.PERIL = "FR" then PUREPREMIUM end,0)) AAL_LOC_GU_FR,
	sum(isnull(case when ls.PERSPCODE = "GR" and an.PERIL = "FR" then PUREPREMIUM end,0)) AAL_LOC_GR_FR,
	sum(isnull(case when ls.PERSPCODE = "GU" and an.PERIL = "TR" then PUREPREMIUM end,0)) AAL_LOC_GU_TR,
	sum(isnull(case when ls.PERSPCODE = "GR" and an.PERIL = "TR" then PUREPREMIUM end,0)) AAL_LOC_GR_TR
	from [##RDM##].dbo.rdm_locstats ls
	inner join [##RDM##].dbo.rdm_analysis an ON  ls.ANLSID= an.ID
	where an.ID in (##ANALYSISIDLIST##)
	group by ls.ID) loc_stat on loc_stat.ID = loc.LOCID
	left join
	[Lookup].[LandSlide] ldsl on le.LANDSLIDE > ldsl.band_min and le.LANDSLIDE <= ldsl.band_max
	left join
	[Lookup].[Liquefaction] lqfc on le.LIQUEFACT > lqfc.band_min and le.LIQUEFACT <= lqfc.band_max
	left join
	[Lookup].[SoilType] sltp on le.SOILTYPE > sltp.band_min and SOILTYPE <= sltp.band_max
	LEFT JOIN
	(select
	[ACCGRPID]
	,UNDCOVAMT
	,PARTOF
	,BLANLIMAMT
	,concat(pol.PARTOF/1000000 , "xs" , pol.UNDCOVAMT/1000000 ) as Layer
	,sum(isnull( AAL_POL_GU_EQ,0))  AAL_POL_GU_EQ
	,sum(isnull(AAL_POL_GR_EQ,0)) AAL_POL_GR_EQ
	,sum(isnull(AAL_POL_GU_WS,0)) AAL_POL_GU_WS
	,sum(isnull(AAL_POL_GR_WS,0)) AAL_POL_GR_WS
	,sum(isnull(AAL_POL_GU_CS,0)) AAL_POL_GU_CS
	,sum(isnull(AAL_POL_GR_CS,0)) AAL_POL_GR_CS
	,sum(isnull(AAL_POL_GU_FL,0)) AAL_POL_GU_FL
	,sum(isnull(AAL_POL_GR_FL,0)) AAL_POL_GR_FL
	,sum(isnull(AAL_POL_GU_FR,0)) AAL_POL_GU_FR
	,sum(isnull(AAL_POL_GR_FR,0)) AAL_POL_GR_FR
	,sum(isnull(AAL_POL_GU_TR,0)) AAL_POL_GU_TR
	,sum(isnull(AAL_POL_GR_TR,0)) AAL_POL_GR_TR
	from
	[dbo].[policy] pol
	left join 
	(Select ps.ID,
	sum(isnull(case when ps.PERSPCODE = "GU" and an.PERIL = "EQ" then PUREPREMIUM end,0)) AAL_POL_GU_EQ,
	sum(isnull(case when ps.PERSPCODE = "GR" and an.PERIL = "EQ" then PUREPREMIUM end,0)) AAL_POL_GR_EQ,
	sum(isnull(case when ps.PERSPCODE = "GU" and an.PERIL = "WS" then PUREPREMIUM end,0)) AAL_POL_GU_WS,
	sum(isnull(case when ps.PERSPCODE = "GR" and an.PERIL = "WS" then PUREPREMIUM end,0)) AAL_POL_GR_WS,
	sum(isnull(case when ps.PERSPCODE = "GU" and an.PERIL = "CS" then PUREPREMIUM end,0)) AAL_POL_GU_CS,
	sum(isnull(case when ps.PERSPCODE = "GR" and an.PERIL = "CS" then PUREPREMIUM end,0)) AAL_POL_GR_CS,
	sum(isnull(case when ps.PERSPCODE = "GU" and an.PERIL = "FL" then PUREPREMIUM end,0)) AAL_POL_GU_FL,
	sum(isnull(case when ps.PERSPCODE = "GR" and an.PERIL = "FL" then PUREPREMIUM end,0)) AAL_POL_GR_FL,
	sum(isnull(case when ps.PERSPCODE = "GU" and an.PERIL = "FR" then PUREPREMIUM end,0)) AAL_POL_GU_FR,
	sum(isnull(case when ps.PERSPCODE = "GR" and an.PERIL = "FR" then PUREPREMIUM end,0)) AAL_POL_GR_FR,
	sum(isnull(case when ps.PERSPCODE = "GU" and an.PERIL = "TR" then PUREPREMIUM end,0)) AAL_POL_GU_TR,
	sum(isnull(case when ps.PERSPCODE = "GR" and an.PERIL = "TR" then PUREPREMIUM end,0)) AAL_POL_GR_TR
	from [##RDM##].dbo.rdm_policystats ps
	inner join [##RDM##].dbo.rdm_analysis an ON  ps.ANLSID= an.ID
	where an.ID in (##ANALYSISIDLIST##)
	group by ps.ID ) polstat 
	on pol.POLICYID = polstat.ID
	group by
	[ACCGRPID]
	,UNDCOVAMT
	,PARTOF
	,BLANLIMAMT
	,concat(pol.PARTOF/1000000 , "mxs" , pol.UNDCOVAMT/1000000 ,"m"))  polAAL on polAAL.ACCGRPID = ag.ACCGRPID
	LEFT JOIN
	(select
	ACCGRPID 
	,sum(isnull(AAL_POL_GR_EQ,0)) AAL_POL_AllLayer_GR_EQ
	,sum(isnull(AAL_POL_GR_WS,0)) AAL_POL_AllLayer_GR_WS
	,sum(isnull(AAL_POL_GR_CS,0)) AAL_POL_AllLayer_GR_CS
	,sum(isnull(AAL_POL_GR_FL,0)) AAL_POL_AllLayer_GR_FL
	,sum(isnull(AAL_POL_GR_FR,0)) AAL_POL_AllLayer_GR_FR
	,sum(isnull(AAL_POL_GR_TR,0)) AAL_POL_AllLayer_GR_TR
	from
	[dbo].[policy] pol
	left join 
	(Select ps.ID,
	sum(isnull(case when ps.PERSPCODE = "GU" and an.PERIL = "EQ" then PUREPREMIUM end,0)) AAL_POL_GU_EQ,
	sum(isnull(case when ps.PERSPCODE = "GR" and an.PERIL = "EQ" then PUREPREMIUM end,0)) AAL_POL_GR_EQ,
	sum(isnull(case when ps.PERSPCODE = "GU" and an.PERIL = "WS" then PUREPREMIUM end,0)) AAL_POL_GU_WS,
	sum(isnull(case when ps.PERSPCODE = "GR" and an.PERIL = "WS" then PUREPREMIUM end,0)) AAL_POL_GR_WS,
	sum(isnull(case when ps.PERSPCODE = "GU" and an.PERIL = "CS" then PUREPREMIUM end,0)) AAL_POL_GU_CS,
	sum(isnull(case when ps.PERSPCODE = "GR" and an.PERIL = "CS" then PUREPREMIUM end,0)) AAL_POL_GR_CS,
	sum(isnull(case when ps.PERSPCODE = "GU" and an.PERIL = "FL" then PUREPREMIUM end,0)) AAL_POL_GU_FL,
	sum(isnull(case when ps.PERSPCODE = "GR" and an.PERIL = "FL" then PUREPREMIUM end,0)) AAL_POL_GR_FL,
	sum(isnull(case when ps.PERSPCODE = "GU" and an.PERIL = "FR" then PUREPREMIUM end,0)) AAL_POL_GU_FR,
	sum(isnull(case when ps.PERSPCODE = "GR" and an.PERIL = "FR" then PUREPREMIUM end,0)) AAL_POL_GR_FR,
	sum(isnull(case when ps.PERSPCODE = "GU" and an.PERIL = "TR" then PUREPREMIUM end,0)) AAL_POL_GU_TR,
	sum(isnull(case when ps.PERSPCODE = "GR" and an.PERIL = "TR" then PUREPREMIUM end,0)) AAL_POL_GR_TR
	from [##RDM##].dbo.rdm_policystats ps
	left join [##RDM##].dbo.rdm_analysis an ON  ps.ANLSID= an.ID
	where an.ID in (##ANALYSISIDLIST##)
	group by ps.ID ) polstat 
	on pol.POLICYID = polstat.ID
	group by
	ACCGRPID)  polGrAAL on polGrAAL.ACCGRPID = ag.ACCGRPID
	where ag.ACCGRPID in (##ACCGRPID##)
	order by LOCID

	select jd.JobId, jd.EdmDataSource, m.*,
	c.COND1NAME,
	c.COND1POLICYNUM,
	(case when c.COND1POLICYNUM is not null then 1 else 0 end) as COND1INCLUDED,
	c.COND2NAME,
	c.COND2POLICYNUM,
	(case when c.COND2POLICYNUM is not null then 1 else 0 end) as COND2INCLUDED,
	c.COND3NAME,
	c.COND3POLICYNUM,
	(case when c.COND3POLICYNUM is not null then 1 else 0 end) as COND3INCLUDED,
	c.COND4NAME,
	c.COND4POLICYNUM,
	(case when c.COND4POLICYNUM is not null then 1 else 0 end) as COND4INCLUDED,
	c.COND5NAME,
	c.COND5POLICYNUM,
	(case when c.COND5POLICYNUM is not null then 1 else 0 end) as COND5INCLUDED
	into #loc_master
	from #master_data m
	left join
	rms_web_jobs.dbo.JobDetails jd
	on
	m.ACCGRPID = jd.AccountId
	left join #cond_pol c
	on m.LOCID = c.LOCID
	where JobId = ##DLM_JOBID##
	and REPLACE(jd.EdmDataSource, " ", "_") = REPLACE("##EDM##" , " ", "_");



	DELETE [##DB_NAME##].[dbo].[Location_Master] WHERE [JobId]="##DLM_JOBID##";

	INSERT INTO [##DB_NAME##].[dbo].[Location_Master]
	select ##PAPI_JOBID##, getdate(), * from #loc_master;

	-- select ##PAPI_JOBID##, * from #loc_master;

	'

			SET @dynaSQL = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@dynaSQL,'##DB_NAME##', DB_NAME()), '##EDM##', @EDM), '##RDM##', @RDM), '##ACCGRPID##', @AccountID), '##ANALYSISIDLIST##', @AnalysisIDList), '##DLM_JOBID##', @DLM_JobId), '##PAPI_JOBID##', @PAPI_JobId),'"', '''');
			-- print @dynaSQL


			EXEC sp_executesql @dynaSQL
		END


		-- Query mode
		IF @DLM_JobId <> 0
		BEGIN
			/*
			SELECT 
					[JobId],[EdmDataSource],[ACCGRPID],[ACCGRPNUM],[ACCGRPNAME],[LOCID],[LOCNUM],[LOCNAME],
					[Steet Address],[CITY],[COUNTY],[STATE],[ZIP Code],[LATITUDE],[LONGITUDE],[COUNTRY],
					[CRESTA Zone],[MATCH LEVEL],
					[EQ Building Value],[EQ Contents Value],[EQ BI Value],
					[WS Building Value],[WS Contents Value],[WS BI Value],
					[SCS Building Value],[SCS Contents Value],[SCS BI Value],
					[Location TIV],[Construction Class Scheme],[Construction Class],[Construction Class Code],
					[Const_Cls_Abbr],[Occupancy Type Scheme],[Occupancy Type],[Occ_Tp_Abbr],[Occupancy Code],
					[# of Stories],[Building Height],[HEIGHT UNIT],[Year Built],[Year Upgraded],[Floor Area],
					[AREA UNIT],[# of Bldgs],[Dwell Time (days)],[# SHIPMENTS],[Sinkhole Hazard Zone],
					[Distance to Closest Sinkhole],[Flood Zone],[BASE FLOOD ELEVATION],[250 Year MMI],
					[Distance To Coast],[Soil Type],[RoofAge],[Percent Sprinklered],[Sprinklered (Y/N)],
					[UNDCOVAMT],[PARTOF],[Layer],[AAL_GU_EQ],[AAL_GR_EQ],[AAL_GU_WS],[AAL_GR_WS],[AAL_GU_CS],
					[AAL_GR_CS],[AAL_GU_FL],[AAL_GR_FL],[AAL_GU_FR],[AAL_GR_FR],[AAL_GU_TR],[AAL_GR_TR],
					[EQ_BLD_Ded],[EQ_BLD_Lim],[EQ_CNT_Ded],[EQ_CNT_Lim],[EQ_BI_Ded],[EQ_BI_Lim],[WS_BLD_Ded],
					[WS_BLD_Lim],[WS_CNT_Ded],[WS_CNT_Lim],[WS_BI_Ded],[WS_BI_Lim],[SCS_BLD_Ded],[SCS_BLD_Lim],
					[SCS_CNT_Ded],[SCS_CNT_Lim],[SCS_BI_Ded],[SCS_BI_Lim],[EQ_SITELIMAMT],[EQ_SITEDEDAMT],
					[WS_SITELIMAMT],[WS_SITEDEDAMT],[SCS_SITELIMAMT],[SCS_SITEDEDAMT],[EQ],[WS],[SCS],
					[YrBld_Band],[Stories_Band],[WS_County_Region],[EQ_County_Region],[CS_ZIP_Region],
					[COND1NAME], [COND1POLICYNUM], [COND1INCLUDED], 
					[COND2NAME], [COND2POLICYNUM], [COND2INCLUDED],
					[COND3NAME], [COND3POLICYNUM], [COND3INCLUDED],
					[COND4NAME], [COND4POLICYNUM], [COND4INCLUDED],
					[COND5NAME], [COND5POLICYNUM], [COND5INCLUDED],
					[PAPI_JobId],[Timestamp]
			*/
			SELECT *
				FROM [dbo].[Location_Master] 
				WHERE [JobId] = @DLM_JobId
				ORDER BY [LOCID],[LOCNUM];
		END
		ELSE IF @PAPI_JobId <> 0
		BEGIN
			/*
			SELECT 
					[JobId],[EdmDataSource],[ACCGRPID],[ACCGRPNUM],[ACCGRPNAME],[LOCID],[LOCNUM],[LOCNAME],
					[Steet Address],[CITY],[COUNTY],[STATE],[ZIP Code],[LATITUDE],[LONGITUDE],[COUNTRY],
					[CRESTA Zone],[MATCH LEVEL],
					[EQ Building Value],[EQ Contents Value],[EQ BI Value],
					[WS Building Value],[WS Contents Value],[WS BI Value],
					[SCS Building Value],[SCS Contents Value],[SCS BI Value],
					[Location TIV],[Construction Class Scheme],[Construction Class],[Construction Class Code],
					[Const_Cls_Abbr],[Occupancy Type Scheme],[Occupancy Type],[Occ_Tp_Abbr],[Occupancy Code],
					[# of Stories],[Building Height],[HEIGHT UNIT],[Year Built],[Year Upgraded],[Floor Area],
					[AREA UNIT],[# of Bldgs],[Dwell Time (days)],[# SHIPMENTS],[Sinkhole Hazard Zone],
					[Distance to Closest Sinkhole],[Flood Zone],[BASE FLOOD ELEVATION],[250 Year MMI],
					[Distance To Coast],[Soil Type],[RoofAge],[Percent Sprinklered],[Sprinklered (Y/N)],
					[UNDCOVAMT],[PARTOF],[Layer],[AAL_GU_EQ],[AAL_GR_EQ],[AAL_GU_WS],[AAL_GR_WS],[AAL_GU_CS],
					[AAL_GR_CS],[AAL_GU_FL],[AAL_GR_FL],[AAL_GU_FR],[AAL_GR_FR],[AAL_GU_TR],[AAL_GR_TR],
					[EQ_BLD_Ded],[EQ_BLD_Lim],[EQ_CNT_Ded],[EQ_CNT_Lim],[EQ_BI_Ded],[EQ_BI_Lim],[WS_BLD_Ded],
					[WS_BLD_Lim],[WS_CNT_Ded],[WS_CNT_Lim],[WS_BI_Ded],[WS_BI_Lim],[SCS_BLD_Ded],[SCS_BLD_Lim],
					[SCS_CNT_Ded],[SCS_CNT_Lim],[SCS_BI_Ded],[SCS_BI_Lim],[EQ_SITELIMAMT],[EQ_SITEDEDAMT],
					[WS_SITELIMAMT],[WS_SITEDEDAMT],[SCS_SITELIMAMT],[SCS_SITEDEDAMT],[EQ],[WS],[SCS],
					[YrBld_Band],[Stories_Band],[WS_County_Region],[EQ_County_Region],[CS_ZIP_Region],
					[COND1NAME], [COND1POLICYNUM], [COND1INCLUDED], 
					[COND2NAME], [COND2POLICYNUM], [COND2INCLUDED],
					[COND3NAME], [COND3POLICYNUM], [COND3INCLUDED],
					[COND4NAME], [COND4POLICYNUM], [COND4INCLUDED],
					[COND5NAME], [COND5POLICYNUM], [COND5INCLUDED],
					[PAPI_JobId],[Timestamp]
			*/
			SELECT *
				FROM [dbo].[Location_Master] 
				WHERE [PAPI_JobId] = @PAPI_JobId
				ORDER BY [LOCID],[LOCNUM];
		END
		ELSE
		BEGIN
			RAISERROR(N'Invalid parameter', 10, 1);
		END

	END





