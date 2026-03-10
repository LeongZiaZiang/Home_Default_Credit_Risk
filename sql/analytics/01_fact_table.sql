-- CREATE SCHEMA analytics;

--------------------------------------------------------
/* Categorize data in application_train.csv */
--------------------------------------------------------
DROP TABLE IF EXISTS analytics.demog_table;
CREATE TABLE analytics.demog_table AS
SELECT sk_id_curr, 
-- Map cnt_fam_members
	CASE
		WHEN tr.cnt_fam_members = '1' THEN 'Alone'
		WHEN tr.cnt_fam_members IN ('2','3','4') THEN 'Small'
		WHEN tr.cnt_fam_members IN ('5','6') THEN 'Medium'
		WHEN tr.cnt_fam_members IN ('7','8','9','10','11','12',
									'13','14','15','16','20') THEN 'Large'
	END AS family_size_grouped,
-- Map name_income_type
	CASE
		WHEN tr.name_income_type IN ('Businessman', 
								     'Commercial associate', 
								     'Maternity leave', 
								     'State servant', 
								     'Working') THEN 'Employed'
		WHEN tr.name_income_type = 'Pensioner' THEN 'Retired'
		WHEN tr.name_income_type IN ('Student',
									 'Unemployed') THEN 'Unemployed'
	END AS employment_status,
-- Map name_education_type
	CASE
		WHEN tr.name_education_type = 'Academic degree' THEN 'Degrees'
		WHEN tr.name_education_type IN ('Incomplete higher',
										'Higher education') THEN 'Higher education'
		WHEN tr.name_education_type IN ('Lower secondary',
										'Secondary / secondary special') THEN 'Secondary'
	END AS education_level,
-- Map name_family_status
	CASE
		WHEN tr.name_family_status = 'Single / not married' THEN 'Single'
		WHEN tr.name_family_status = 'Married' THEN 'Married'
		WHEN tr.name_family_status = 'Civil marriage' THEN 'Civil marriage'
		WHEN tr.name_family_status = 'Separated' THEN 'Separated'
		WHEN tr.name_family_status = 'Widow' THEN 'Widow'
		WHEN tr.name_family_status = 'Unknown' THEN 'Unknown'
	END AS marriage_status
FROM staging.application_train AS tr;
--------------------------------------------------------
/* Aggregate data in bureau.csv */
--------------------------------------------------------

DROP TABLE IF EXISTS analytics.loan_table;
CREATE TABLE analytics.loan_table AS
SELECT bu.sk_id_curr, 
-- total loans
	COUNT(*) AS total_loans,
-- active counts
	COUNT(CASE 
			WHEN bu.credit_active = 'Active' THEN 1
		  END) AS active_count,
-- close counts
	COUNT(CASE 
			WHEN bu.credit_active = 'Closed' THEN 1 
		  END) AS closed_count,
-- bad debt counts
	COUNT(CASE 
			WHEN bu.credit_active = 'Bad debt' THEN 1 
		  END) AS bad_debt_count,
-- credit sold counts
	COUNT(CASE 
			WHEN bu.credit_active = 'Sold' THEN 1 
		  END) AS sold_credit_count,
-- total past default
	COUNT(CASE 
			WHEN bu.credit_active = 'Closed' 
			AND bu.amt_credit_sum_overdue >= 0 THEN 1
		  END) AS total_past_default,
-- total active debt
    SUM(bu.amt_credit_sum_debt) AS total_active_debt,
-- total active credit
	SUM(bu.amt_credit_sum) AS total_active_credit,
-- total active overdue credit
	SUM(bu.amt_credit_sum_overdue) AS total_active_overdue
FROM staging.bureau AS bu
GROUP BY bu.sk_id_curr
ORDER BY bu.sk_id_curr;
--------------------------------------------------------
/* Aggregate data in bureau_balance.csv */
--------------------------------------------------------
-- Map status 
DROP TABLE IF EXISTS analytics.status_table;
CREATE TABLE analytics.status_table AS
SELECT bu.sk_id_curr, bb.sk_bureau_id, 
	CASE
		WHEN bb.status IN ('0','C','X') THEN 0
		WHEN bb.status = '1' THEN 1
		WHEN bb.status = '2' THEN 2
		WHEN bb.status = '3' THEN 3
		WHEN bb.status = '4' THEN 4
		WHEN bb.status = '5' THEN 5
	END AS status
FROM staging.bureau_balance AS bb
LEFT JOIN staging.bureau AS bu ON bb.sk_bureau_id = bu.sk_bureau_id
ORDER BY bu.sk_id_curr;

-- Max delinquency, delinquent months, total months
DROP TABLE IF EXISTS analytics.deliq_table;
CREATE TABLE analytics.deliq_table AS
SELECT st.sk_id_curr, 
	MAX(st.status) AS max_deliq,
	SUM(st.status) AS deliq_month,
	COUNT(*) AS total_deliq_month
FROM analytics.status_table AS st
GROUP BY st.sk_id_curr
ORDER BY st.sk_id_curr;
--------------------------------------------------------
/* Create main table */
--------------------------------------------------------
DROP TABLE IF EXISTS analytics.fact_table;
CREATE TABLE analytics.fact_table AS
SELECT
	tr.sk_id_curr,
	tr.target,
	tr.name_contract_type,
	tr.code_gender,
	tr.flag_own_car,
	tr.flag_own_realty,
	tr.amt_income_total,
	tr.amt_credit,
	tr.amt_annuity,
	tr.amt_goods_price,
	tr.name_housing_type,
	tr.region_population_relative,
	ABS(tr.days_employed) as days_employed,
	ABS(tr.days_registration) as days_registration,
	ABS(tr.days_id_publish) as days_id_publish,
	ABS(tr.own_car_age) as own_car_age,
	tr.region_rating_client,
	tr.reg_region_not_live_region,
	tr.reg_region_not_work_region,
	tr.live_region_not_work_region,
	tr.ext_source_1,
	tr.ext_source_2,
	tr.ext_source_3,
	tr.apartments_avg,
	tr.years_build_mode,
	tr.obs_30_cnt_social_circle,
	ABS(tr.days_last_phone_change) as days_last_phone_change,
	tr.amt_req_credit_bureau_year,
	dg.family_size_grouped,
	dg.employment_status,
	dg.education_level,
	dg.marriage_status,
	ROUND(ABS(tr.days_birth/365.25),0) as age,
	lt.total_loans,
	lt.active_count,
	lt.closed_count,
	lt.bad_debt_count,
	lt.sold_credit_count,
	lt.total_past_default,
	lt.total_active_debt,
	lt.total_active_credit,
	lt.total_active_overdue,
	dq.max_deliq,
	dq.deliq_month,
	dq.total_deliq_month
FROM staging.application_train tr
LEFT JOIN analytics.demog_table dg ON tr.sk_id_curr = dg.sk_id_curr
LEFT JOIN analytics.loan_table lt ON tr.sk_id_curr = lt.sk_id_curr
LEFT JOIN analytics.deliq_table dq ON tr.sk_id_curr = dq.sk_id_curr
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,
		 24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,
		 45;

SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'fact_table';