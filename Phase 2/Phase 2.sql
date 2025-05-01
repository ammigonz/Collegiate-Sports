/* Creating tables and renaming columns */

CREATE OR REPLACE TABLE `collegiate-sports-458022.sports_dataset.sports_cleaned` AS
SELECT
  YEAR,
  UNITID,
  `INSTITUTION_ ME` AS institution_name,
  CITY_TXT,
  STATE_CD,
  CAST(ZIP_TEXT AS STRING) AS zip_text,  -- ZIPs should be string to preserve leading zeros
  CLASSIFICATION_CODE,
  `CLASSIFICATION_ ME` AS classification_name,
  CLASSIFICATION_OTHER,
  EF_TOTAL_COUNT,
  EF_MALE_COUNT,
  EF_FEMALE_COUNT,
  SECTOR_CD,
  `SECTOR_ ME` AS sector_name,
  SPORTSCODE,
  SAFE_CAST(PARTIC_MEN AS INT64) AS partic_men,
  SAFE_CAST(PARTIC_WOMEN AS INT64) AS partic_women,
  SAFE_CAST(PARTIC_COED_MEN AS INT64) AS partic_coed_men,
  SAFE_CAST(PARTIC_COED_WOMEN AS INT64) AS partic_coed_women,
  SUM_PARTIC_MEN,
  SUM_PARTIC_WOMEN,
  SAFE_CAST(REV_MEN AS FLOAT64) AS rev_men,
  SAFE_CAST(REV_WOMEN AS FLOAT64) AS rev_women,
  SAFE_CAST(TOTAL_REV_MENWOMEN AS FLOAT64) AS total_rev_menwomen,
  SAFE_CAST(EXP_MEN AS FLOAT64) AS exp_men,
  SAFE_CAST(EXP_WOMEN AS FLOAT64) AS exp_women,
  SAFE_CAST(TOTAL_EXP_MENWOMEN AS FLOAT64) AS total_exp_menwomen,
  SPORTS AS sport_name
FROM `collegiate-sports-458022.sports_dataset.sports`;


/* Created my first table with sector information */
select count(*)
	from `collegiate-sports-458022.sports_dataset.sports_cleaned`; 

CREATE OR REPLACE TABLE `collegiate-sports-458022.sports_dataset.sector` AS
SELECT DISTINCT SECTOR_CD, SECTOR_NAME
	FROM `collegiate-sports-458022.sports_dataset.sports_cleaned`;

/* Created my second table with location information */
CREATE OR REPLACE TABLE `collegiate-sports-458022.sports_dataset.location` AS
SELECT DISTINCT ZIP_TEXT, CITY_TXT, STATE_CD
	FROM `collegiate-sports-458022.sports_dataset.sports_cleaned`;

/* Created my third table with enrollment information */
CREATE OR REPLACE TABLE `collegiate-sports-458022.sports_dataset.enrollment` AS
SELECT DISTINCT UNITID, YEAR, EF_TOTAL_COUNT, EF_MALE_COUNT, EF_FEMALE_COUNT
	FROM `collegiate-sports-458022.sports_dataset.sports_cleaned`;

/* Created my fourth table with university information */
CREATE OR REPLACE TABLE `collegiate-sports-458022.sports_dataset.university` AS
SELECT DISTINCT UNITID, ZIP_TEXT, INSTITUTION_NAME, SECTOR_CD, CLASSIFICATION_CODE
	FROM `collegiate-sports-458022.sports_dataset.sports_cleaned`;

/* Created my fifth table with sports information */
CREATE OR REPLACE TABLE `collegiate-sports-458022.sports_dataset.sportname` AS
SELECT DISTINCT SPORTSCODE, sport_name
	FROM `collegiate-sports-458022.sports_dataset.sports_cleaned`;

/* Created my sixth table with sports division information */
CREATE OR REPLACE TABLE `collegiate-sports-458022.sports_dataset.division` AS
SELECT DISTINCT CLASSIFICATION_CODE , CLASSIFICATION_NAME
	FROM `collegiate-sports-458022.sports_dataset.sports_cleaned`;

/* Created my seventh table with division 8 "other" information */
CREATE OR REPLACE TABLE `collegiate-sports-458022.sports_dataset.other_division` AS
SELECT DISTINCT CLASSIFICATION_NAME, CLASSIFICATION_OTHER
	FROM `collegiate-sports-458022.sports_dataset.sports_cleaned`
	WHERE CLASSIFICATION_NAME = "Other";

/* I have two ID's I need to create because I had two many to many relationships that needed to be fixed.*/
/* trying to first add it to collegiate sports */
/* I created an empty column first for my program ID, fixing the first many to many relationship*/

ALTER TABLE `collegiate-sports-458022.sports_dataset.sports`
  ADD COLUMN program_id STRING;
/* then I combined all the values in the columns i need to create a unique ID for all the different combinations of sport within a university and division */
UPDATE `collegiate-sports-458022.sports_dataset.sports`
  SET PROGRAM_ID = CONCAT(CAST(UNITID AS STRING), "-", CAST(CLASSIFICATION_CODE AS STRING), "-", CAST(SPORTSCODE AS STRING))
WHERE TRUE;

/* I  then created the eigth table that program ID would be the primary key for, and where it would be stored */
CREATE OR REPLACE TABLE `collegiate-sports-458022.sports_dataset.program` AS
SELECT DISTINCT program_id, UNITID, CLASSIFICATION_CODE, Sportscode
	FROM `collegiate-sports-458022.sports_dataset.sports`;

/* now I have to make the second ID */
/* I also began with altering the collegiate sports table and adding a column */
ALTER TABLE `collegiate-sports-458022.sports_dataset.sports`
ADD COLUMN participation_id STRING;

/* then I combined all the values in the columns i need to create a unique ID for all the different combinations of sport within a university and division */
UPDATE `collegiate-sports-458022.sports_dataset.sports`
SET participation_id = CONCAT(cast(program_id as string), "-", CAST(year AS STRING))
WHERE TRUE;

/* I  then created the ninth table that PARTICIPATION ID would be the primary key for, and where it would be stored */
CREATE OR REPLACE TABLE `collegiate-sports-458022.sports_dataset.participation` AS
SELECT DISTINCT 
    participation_id, program_id, year, partic_women, 
    partic_men, partic_coed_women, partic_coed_men, sum_partic_women, 
    sum_partic_men, rev_women, rev_men, total_rev_menwomen,
    total_exp_menwomen, exp_men, exp_women
FROM `collegiate-sports-458022.sports_dataset.sports`;


/*run my queries*/
## how many universities are there
select distinct count( unitid )
	from `collegiate-sports-458022.sports_dataset.university`;
 /*3669*/  

# are all states observed?

with cte as (
  SELECT distinct (state_cd) as unique_state
    FROM `collegiate-sports-458022.sports_dataset.location`
)
select count(unique_state) as total
  from cte;
/* 54 , which is weird*/

with cte as (
  SELECT distinct (state_cd) as unique_state
    FROM `collegiate-sports-458022.sports_dataset.location`
)
select distinct unique_state
  from cte;
/* one blank and the territories of DC – District of Columbia, PR – Puerto Rico, VI – U.S. Virgin Islands in my data set*/

/* find blanks */
SELECT DISTINCT STATE_CD
FROM `collegiate-sports-458022.sports_dataset.sports`
WHERE TRIM(STATE_CD) IS NULL OR STATE_CD = '';
/* nothing to show */


### how many universities are in DC
SELECT COUNT(DISTINCT u.unitid) AS university_count
FROM `collegiate-sports-458022.sports_dataset.university` u
JOIN `collegiate-sports-458022.sports_dataset.location` l ON u.zip_text = l.zip_text
WHERE l.state_cd = 'DC';


### how many universities are in CA
SELECT COUNT(DISTINCT u.unitid) AS university_count
FROM `collegiate-sports-458022.sports_dataset.university` u
JOIN `collegiate-sports-458022.sports_dataset.location` l ON u.zip_text = l.zip_text
WHERE l.state_cd = 'CA';
/* 187 */

##Which state has the most universities in this dataset, what is the heiharcy of other states?
SELECT state_cd, COUNT(DISTINCT unitid) AS university_count
FROM `collegiate-sports-458022.sports_dataset.university` u
JOIN `collegiate-sports-458022.sports_dataset.location` l ON u.zip_text = l.zip_text
GROUP BY state_cd
ORDER BY university_count DESC;

### what schools and sports are the top revenues from (top 10 )

SELECT distinct u.INSTITUTION_NAME, s.sport_name, p.total_rev_menwomen
FROM `collegiate-sports-458022.sports_dataset.participation` p
JOIN `collegiate-sports-458022.sports_dataset.program` sp ON p.program_id = sp.program_id
JOIN `collegiate-sports-458022.sports_dataset.university` u ON sp.unitid = u.unitid
JOIN `collegiate-sports-458022.sports_dataset.sportname` s ON sp.sportscode = s.sportscode
ORDER BY p.total_rev_menwomen DESC
LIMIT 10;

/* INSTITUTION_NAME	sport_name	total_rev_menwomen
Lehigh University	Softball	999948
California State University-Fullerton	Softball	999922
Lake Erie College	Football	999899
Mara tha Baptist University	Basketball	99983
SUNY College at Oswego	Softball	99982
Salisbury University	Tennis	99981
SUNY Polytechnic Institute	Baseball	99973
Broward College	Volleyball	99967
Pratt Institute-Main	Soccer	99963
Concordia College at Moorhead	Baseball	99961 */

### what school and sports are the top participations from (top 10 )
SELECT DISTINCT 
  u.INSTITUTION_NAME, 
  s.sport_name, 
  d.classification_name AS division,
  sec.sector_name,
  (p.sum_partic_men + p.sum_partic_women) AS total_participation
FROM `collegiate-sports-458022.sports_dataset.participation` p
JOIN `collegiate-sports-458022.sports_dataset.program` sp ON p.program_id = sp.program_id
JOIN `collegiate-sports-458022.sports_dataset.university` u ON sp.unitid = u.unitid
JOIN `collegiate-sports-458022.sports_dataset.sportname` s ON sp.sportscode = s.sportscode
JOIN `collegiate-sports-458022.sports_dataset.division` d ON sp.classification_code = d.classification_code
JOIN `collegiate-sports-458022.sports_dataset.sector` sec ON u.sector_cd = sec.sector_cd
ORDER BY total_participation DESC
LIMIT 10;

/*INSTITUTION_NAME	sport_name	division	sector_name	total_participation
University of Vermont	All Track Combined	NCAA Division I without football	"Public, 4-year or above"	617
University of Vermont	All Track Combined	NCAA Division I without football	"Public, 4-year or above"	529
University of Vermont	All Track Combined	NCAA Division I without football	"Public, 4-year or above"	439
Cornell University	All Track Combined	NCAA Division I-FCS	"Private nonprofit, 4-year or above"	427
Grand Valley State University	All Track Combined	NCAA Division II with football	"Public, 4-year or above"	412
Cornell University	All Track Combined	NCAA Division I-FCS	"Private nonprofit, 4-year or above"	411
Grand Valley State University	All Track Combined	NCAA Division II with football	"Public, 4-year or above"	409
Cornell University	All Track Combined	NCAA Division I-FCS	"Private nonprofit, 4-year or above"	408
Augusta  College	All Track Combined	NCAA Division III with football	"Private nonprofit, 4-year or above"	402
University of St Thomas	All Track Combined	NCAA Division III with football	"Private nonprofit, 4-year or above"	400*/


### what sports are the top participations of women from (top 10 )
SELECT DISTINCT 
  u.INSTITUTION_NAME,
  s.sport_name, 
  d.classification_name AS division,
  sec.sector_name,
  p.sum_partic_women AS total_women_participation, state_cd, city_txt
FROM `collegiate-sports-458022.sports_dataset.participation` p
JOIN `collegiate-sports-458022.sports_dataset.program` sp ON p.program_id = sp.program_id
JOIN `collegiate-sports-458022.sports_dataset.university` u ON sp.unitid = u.unitid
JOIN `collegiate-sports-458022.sports_dataset.sportname` s ON sp.sportscode = s.sportscode
JOIN `collegiate-sports-458022.sports_dataset.division` d ON sp.classification_code = d.classification_code
JOIN `collegiate-sports-458022.sports_dataset.sector` sec ON u.sector_cd = sec.sector_cd
JOIN `collegiate-sports-458022.sports_dataset.location` l ON u.zip_text = l.zip_text
ORDER BY total_women_participation DESC
LIMIT 10;
/*INSTITUTION_NAME	sport_name	division	sector_name	total_women_participation
University of Vermont	All Track Combined	NCAA Division I without football	"Public, 4-year or above"	327
University of Vermont	All Track Combined	NCAA Division I without football	"Public, 4-year or above"	293
University of Vermont	All Track Combined	NCAA Division I without football	"Public, 4-year or above"	248
Cornell University	All Track Combined	NCAA Division I-FCS	"Private nonprofit, 4-year or above"	240
Cornell University	All Track Combined	NCAA Division I-FCS	"Private nonprofit, 4-year or above"	229
Florida Atlantic University	All Track Combined	NCAA Division I-FBS	"Public, 4-year or above"	222
University of Minnesota-Twin Cities	All Track Combined	NCAA Division I-FBS	"Public, 4-year or above"	215
University of Minnesota-Twin Cities	All Track Combined	NCAA Division I-FBS	"Public, 4-year or above"	213
Cornell University	All Track Combined	NCAA Division I-FCS	"Private nonprofit, 4-year or above"	211
Bucknell University	All Track Combined	NCAA Division I-FCS	"Private nonprofit, 4-year or above"	206*/


### what sports are the top participations  of men from (top 10 )
SELECT DISTINCT 
  u.INSTITUTION_NAME,
  s.sport_name, 
  d.classification_name AS division,
  sec.sector_name,
  p.sum_partic_men AS total_men_participation,
  state_cd, city_txt
FROM `collegiate-sports-458022.sports_dataset.participation` p
JOIN `collegiate-sports-458022.sports_dataset.program` sp ON p.program_id = sp.program_id
JOIN `collegiate-sports-458022.sports_dataset.university` u ON sp.unitid = u.unitid
JOIN `collegiate-sports-458022.sports_dataset.sportname` s ON sp.sportscode = s.sportscode
JOIN `collegiate-sports-458022.sports_dataset.division` d ON sp.classification_code = d.classification_code
JOIN `collegiate-sports-458022.sports_dataset.sector` sec ON u.sector_cd = sec.sector_cd
JOIN `collegiate-sports-458022.sports_dataset.location` l ON u.zip_text = l.zip_text
ORDER BY total_men_participation DESC
LIMIT 10;
/*INSTITUTION_NAME	sport_name	division	sector_name	total_men_participation	state_cd	city_txt
ASA College	Football	NJCAA Division I	"Private for-profit, 2-year"	331	NY	Brooklyn
ASA College	Football	NJCAA Division I	"Private for-profit, 2-year"	331	NY	Brooklyn Heights
University of Vermont	All Track Combined	NCAA Division I without football	"Public, 4-year or above"	290	VT	Burlington
University of Mount Union	Football	NCAA Division III with football	"Private nonprofit, 4-year or above"	251	OH	Alliance
University of Mount Union	Football	NCAA Division III with football	"Private nonprofit, 4-year or above"	249	OH	Alliance
ASA College	Football	NJCAA Division I	"Private for-profit, 2-year"	246	NY	Brooklyn
ASA College	Football	NJCAA Division I	"Private for-profit, 2-year"	246	NY	Brooklyn Heights
University of St Thomas	All Track Combined	NCAA Division III with football	"Private nonprofit, 4-year or above"	239	MN	Saint Paul
University of Vermont	All Track Combined	NCAA Division I without football	"Public, 4-year or above"	236	VT	Burlington
Lindenwood University	Football	NCAA Division II with football	"Private nonprofit, 4-year or above"	234	MO	Saint Charles*/

## what were sports highest participations?
SELECT 
  s.sport_name,
  AVG(p.sum_partic_men + p.sum_partic_women) AS avg_participation
FROM `collegiate-sports-458022.sports_dataset.participation` p
JOIN `collegiate-sports-458022.sports_dataset.program` sp ON p.program_id = sp.program_id
JOIN `collegiate-sports-458022.sports_dataset.sportname` s ON sp.sportscode = s.sportscode
GROUP BY s.sport_name
ORDER BY avg_participation DESC;
/*sport_name	avg_participation
All Track Combined	118.50780287474332
Football	86.656120527306868
Soccer	46.777610732045709
Lacrosse	34.785393818544364
Baseball	34.195511337343881
Basketball	31.070200000000117
"Track and Field, Outdoor"	28.73456433929606
Swimming and Diving	26.313437703848678
"Track and Field, Indoor"	25.66845740598615
Rowing	23.4457088667615
Softball	18.859929906542018
Wrestling	17.399353796445855
Volleyball	17.05733391800047
"Track and Field, X-Country"	16.192159252488338
Ice Hockey	16.035434882650705
Tennis	15.579152383920256
Swimming	14.891527827011677
Golf	13.271671388101961
Field Hockey	11.355462822458279
Other Sports	10.893370421882247
Water Polo	8.5619625695498272
Rodeo	5.9059734513274371
Bowling	5.8878676470588234
Equestrian	5.7893274041133971
Gym stics	5.394890899414583
Beach Volleyball	4.3475855130784753
Fencing	4.013633669235328
Sailing	3.2879901960784341
Skiing	2.638755980861244
Squash	2.6211104331909709
Rifle	1.1903881700554511
Archery	0.833654463712267
Weight Lifting	0.67692307692307674
Badminton	0.36936936936936926
Table Tennis	0.31298200514138813
Synchronized Swimming	0.22563417890520693
Diving	0.10196078431372549
Team Handball	0.0*/

## checking team handball since average participation is 0.0
SELECT *
FROM `collegiate-sports-458022.sports_dataset.sports`
WHERE sports = 'Team Handball';
/* turns out there is. alot of team handball but no participation or revenue metrics available.. */

## What sector of school’s have the most revenue?
SELECT 
    sec.sector_name AS sector,
    SUM(p.total_rev_menwomen) AS total_revenue
FROM Participation p
JOIN Program sp ON p.program_id = sp.program_id
JOIN University u ON sp.unitid = u.unitid
JOIN Sector sec ON u.sector_cd = sec.sector_cd
GROUP BY sec.sector_name
ORDER BY total_revenue DESC;

SELECT 
  sec.sector_name AS sector,
  SUM(SAFE_CAST(p.total_rev_menwomen AS FLOAT64)) AS total_revenue
FROM `collegiate-sports-458022.sports_dataset.participation` p
JOIN `collegiate-sports-458022.sports_dataset.program` sp ON p.program_id = sp.program_id
JOIN `collegiate-sports-458022.sports_dataset.university` u ON sp.unitid = u.unitid
JOIN `collegiate-sports-458022.sports_dataset.sector` sec ON u.sector_cd = sec.sector_cd
GROUP BY sec.sector_name
ORDER BY total_revenue DESC;
/* sector	total_revenue
"Public, 4-year or above"	65364291624.0
"Private nonprofit, 4-year or above"	41128900198.0
"Public, 2-year"	3639848516.0
"Private for-profit, 4-year or above"	374345784.0
"Private nonprofit, 2-year"	114903264.0
"Private for-profit, 2-year"	33728418.0
 	28755390.0 */


## what sport has the highest combined revenue from all schools?

SELECT 
  s.sport_name,
  SUM(SAFE_CAST(p.total_rev_menwomen AS FLOAT64)) AS total_revenue
FROM `collegiate-sports-458022.sports_dataset.participation` p
JOIN `collegiate-sports-458022.sports_dataset.program` sp ON p.program_id = sp.program_id
JOIN `collegiate-sports-458022.sports_dataset.sportname` s ON sp.sportscode = s.sportscode
GROUP BY s.sport_name
ORDER BY total_revenue DESC;

/*sport_name	total_revenue
Football	27656662780.0
Basketball	15080044942.0
Soccer	4437216001.0
Baseball	3491245241.0
All Track Combined	2859152770.0
Volleyball	2657342705.0
Softball	2308131793.0
Tennis	1647758263.0
Golf	1646888264.0
Lacrosse	1518166788.0
Ice Hockey	1107635977.0
Swimming and Diving	923601437.0
Wrestling	596459485.0
Rowing	538830054.0
Field Hockey	417089242.0
Swimming	377751141.0
"Track and Field, X-Country"	377731976.0
"Track and Field, Outdoor"	331131665.0
Gym stics	249580814.0
"Track and Field, Indoor"	174541575.0
Water Polo	167497338.0
Bowling	136404821.0
Other Sports	122799485.0
Equestrian	92083018.0
Skiing	76846718.0
Beach Volleyball	76291676.0
Rodeo	74481445.0
Fencing	51404988.0
Squash	49501836.0
Sailing	14660906.0
Rifle	7954624.0
Weight Lifting	6303877.0
Archery	5443449.0
Synchronized Swimming	3974279.0
Diving	3722366.0
Badminton	3048248.0
Table Tennis	2298055.0
Team Handball	*/

## What division has the most expenditure?
SELECT 
  d.classification_name AS division,
  SUM(SAFE_CAST(p.total_rev_menwomen AS FLOAT64)) AS total_expenditure
FROM `collegiate-sports-458022.sports_dataset.participation` p
JOIN `collegiate-sports-458022.sports_dataset.program` sp ON p.program_id = sp.program_id
JOIN `collegiate-sports-458022.sports_dataset.division` d ON sp.classification_code = d.classification_code
GROUP BY d.classification_name
ORDER BY total_expenditure DESC;
/*division	total_expenditure
NCAA Division I-FBS	35363482150.0
NCAA Division I-FCS	8851113379.0
NCAA Division I without football	6105874984.0
NCAA Division II with football	4520270689.0
NCAA Division III with football	3079198509.0
NCAA Division II without football	3000510503.0
 IA Division II	2292049920.0
 IA Division I	1906097221.0
NJCAA Division I	1416669806.0
NCAA Division III without football	1209643981.0
CCCAA	430063746.0
Other	372829803.0
NJCAA Division II	346686728.0
NJCAA Division III	165524377.0
NWAC	77786460.0
USCAA	75048845.0
NCCAA Division I	41168137.0
NCCAA Division II	32634368.0
Independent	5026436.0*/

## What school has the highest expenditure
SELECT 
  u.INSTITUTION_NAME AS school_name,
  SUM(safe_cast(p.total_exp_menwomen as float64)) AS total_expenditure
FROM `collegiate-sports-458022.sports_dataset.participation` p
JOIN `collegiate-sports-458022.sports_dataset.program` sp ON p.program_id = sp.program_id
JOIN `collegiate-sports-458022.sports_dataset.university` u ON sp.unitid = u.unitid
GROUP BY u.INSTITUTION_NAME
ORDER BY total_expenditure DESC
limit 50;

/*school_name	total_expenditure
Florida State University	1541606040.0
The University of Alabama	1035333738.0
Pennsylvania State University-Main Campus	912947954.0
Texas A & M University-College Station	860980704.0
University of Oklahoma-Norman Campus	860230512.0
University of Wisconsin-Madison	819474798.0
University of California-Los Angeles	793833604.0
University of Washington-Seattle Campus	782563808.0
University of Louisville	776142030.0
Michigan State University	760403628.0
University of Kentucky	749096178.0
Louisia  State University and Agricultural & Mechanical College	741772054.0
University of Iowa	735165140.0
University of Minnesota-Twin Cities	716560946.0
University of Mississippi	678993038.0
India  University-Bloomington	674125112.0
University of Virginia-Main Campus	668957760.0
Virginia Polytechnic Institute and State University	651620650.0
Rutgers University-New Brunswick	608745960.0
University of Arizo 	572355826.0
University of Illinois at Urba -Champaign	564464458.0
University of Utah	550843816.0
North Caroli  State University at Raleigh	545148212.0
Purdue University-Main Campus	532381774.0
Ohio State University-Main Campus	531373526.0
Texas Tech University	509826502.0
Southern Methodist University	509337898.0
Iowa State University	502346754.0
University of Michigan-Ann Arbor	499652199.0
West Virginia University	498593140.0
Georgia Institute of Technology-Main Campus	483107118.0
Oklahoma State University-Main Campus	477622282.0
Coastal Caroli  University	459984524.0
University of Colorado Boulder	454423698.0
University of Notre Dame	453588850.0
Temple University	441286314.0
Washington State University	440122322.0
The University of Texas at Austin	439309401.0
Texas Christian University	435887695.0
Auburn University	433312245.0
University of Arkansas	408976584.0
Duke University	405992348.0
Clemson University	392851748.0
University of Florida	391903453.0
University of Georgia	391360954.0
University of South Caroli -Columbia	374693945.0
Baylor University	369688452.0
The University of Tennessee-Knoxville	369292610.0
University of Miami	368306141.0
Stanford University	367879663.0
*/

## What schools in CA have the highest expenditure
SELECT 
  u.INSTITUTION_NAME AS school_name,
  SUM(safe_cast(p.total_exp_menwomen AS FLOAT64)) AS total_expenditure
FROM `collegiate-sports-458022.sports_dataset.participation` p
JOIN `collegiate-sports-458022.sports_dataset.program` sp ON p.program_id = sp.program_id
JOIN `collegiate-sports-458022.sports_dataset.university` u ON sp.unitid = u.unitid
JOIN `collegiate-sports-458022.sports_dataset.location` l ON u.zip_text = l.zip_text
WHERE l.state_cd = 'CA'
GROUP BY u.INSTITUTION_NAME
ORDER BY total_expenditure DESC
limit 50;
/*school_name	total_expenditure
University of California-Los Angeles	793833604.0
Stanford University	367879663.0
University of Southern California	333717596.0
University of California-Berkeley	304507058.0
San Jose State University	231698246.0
California Baptist University	204480261.0
University of California-Davis	204460722.0
San Diego State University	189536301.0
Loyola Marymount University	189309206.0
Pepperdine University	174600152.0
University of the Pacific	170996892.0
California State University-Fresno	169032241.0
University of San Francisco	164603364.0
University of San Diego	164580654.0
California State University-Sacramento	160115560.0
University of California-Santa Barbara	158550214.0
California State University-Long Beach	124703544.0
California State University-Fullerton	115515162.0
Azusa Pacific University	102648142.0
California State University-Bakersfield	92729068.0
California Polytechnic State University-San Luis Obispo	83791119.0
Santa Clara University	82133289.0
Menlo College	80019040.0
Saint Mary's College of California	71140323.0
Concordia University-Irvine	68188956.0
University of California-Irvine	60153494.0
Humboldt State University	60151728.0
California State University-Northridge	59736922.0
Fresno Pacific University	59329596.0
Hope Inter tio l University	53073948.0
Simpson University	52166188.0
University of California-Riverside	51707237.0
Biola University	51102720.0
Point Loma  zarene University	47603366.0
University of California-San Diego	44490238.0
Sonoma State University	41865722.0
Westmont College	38511734.0
California State University-Chico	38131306.0
California State University-Stanislaus	36799710.0
California State University-San Ber rdino	36007086.0
Holy  mes University	35901554.0
California State University-San Marcos	35308650.0
Marymount California University	35059728.0
California State University-Dominguez Hills	34764258.0
Academy of Art University	34716396.0
California State University-Monterey Bay	34284772.0
William Jessup University	34158720.0
Claremont McKen  College	33181432.0
Whittier College	30398937.0
Pomo  College	29975156.0*/

## Find sports with the most significant year-over-year percentage changes in total participation, highlighting potential anomalies in growth or decline.
WITH
  ParticipationChanges AS (
  SELECT
    year,
    sports,
    SUM(sum_partic_men + sum_partic_women) AS total_participation,
    LAG(SUM(sum_partic_men + sum_partic_women), 1) OVER (PARTITION BY sports ORDER BY year) AS previous_year_participation
  FROM
    `sports_dataset.sports`
  GROUP BY
    year,
    sports )
SELECT
  year,
  sports,
  total_participation,
  previous_year_participation,
  SAFE_DIVIDE((total_participation - previous_year_participation), previous_year_participation) * 100 AS percentage_change
FROM
  ParticipationChanges
WHERE
  previous_year_participation IS NOT NULL and sports <> 'Other Sports'
ORDER BY
  ABS(percentage_change) DESC
LIMIT
  10;
/*year	sports	total_participation	previous_year_participation	percentage_change
2017	Weight Lifting	208	124	67.741935483870961
2017	Table Tennis	109	76	43.421052631578952
2016	Table Tennis	76	133	-42.857142857142854
2017	Diving	27	41	-34.146341463414636
2016	Weight Lifting	124	186	-33.333333333333329
2019	Diving	29	22	31.818181818181817
2019	Table Tennis	71	98	-27.551020408163261
2019	"Track and Field, Outdoor"	16419	21696	-24.322455752212392
2017	Archery	261	210	24.285714285714285
2018	Weight Lifting	256	208	23.076923076923077*/

## Identify the sports with the largest increase in female participation
SELECT
  sports,
  AVG(safe_cast(ef_female_count as float64)) AS avg_female_participants
FROM
  `sports_dataset.sports`
WHERE
  year BETWEEN 2018
  AND 2023
GROUP BY
  sports
ORDER BY
  avg_female_participants DESC
LIMIT
  10;

/*sports	avg_female_participants
Swimming and Diving	2822.4160768452939
All Track Combined	2789.2448575949343
Gym stics	2725.5716945996246
Tennis	2645.0841467519335
Football	2636.802795617677
Rowing	2608.8638805970127
Beach Volleyball	2557.800119331745
Golf	2489.4379746835434
Water Polo	2483.506707317074
Field Hockey	2460.3169667212228*/

## Find the correlation between the number of female athletes and the total expenses on women's sports for each sport.
SELECT
  sports,
  CORR(sum_partic_women, SAFE_CAST(REPLACE(REPLACE(exp_women, ',', ''), '$', '') AS FLOAT64)) AS correlation
FROM
  `sports_dataset.sports`
GROUP BY
  sports
order by correlation desc;
/*sports	correlation
Synchronized Swimming	0.92225113354449917
Diving	0.91615539472277818
Rowing	0.76717432129494634
Lacrosse	0.67506521353555071
Wrestling	0.654857540712726
Weight Lifting	0.62928698597773947
Water Polo	0.623130562098448
Table Tennis	0.61935041827766979
Archery	0.57157395354787843
Fencing	0.55445469347620091
Rifle	0.52804979997701285
Swimming	0.52332536874570723
Equestrian	0.51929265193954666
All Track Combined	0.51854095654580368
Rodeo	0.501128834335637
Other Sports	0.47201315827734663
Swimming and Diving	0.46506916132945564
Skiing	0.46329806807341217
Beach Volleyball	0.44408296319352775
Badminton	0.4045736354867755
"Track and Field, Outdoor"	0.404562039469884
Bowling	0.4020828649484135
Soccer	0.37598327148101396
Basketball	0.34112789913429953
"Track and Field, X-Country"	0.33646424758338456
Softball	0.30400579040000186
"Track and Field, Indoor"	0.28434769449910141
Field Hockey	0.26893165623041654
Golf	0.25539436652948505
Volleyball	0.22464632128164078
Ice Hockey	0.14216966452485921
Squash	0.0627507413588915
Tennis	0.046995181177563877
Sailing	0.035076236056289976
Gym stics	-0.12127467051555468
Baseball	
Football	
Team Handball	*/

# What is the percentage of male and female athletes in each sport?

SELECT
  sports,
  SUM(sum_partic_men) * 100 / SUM(sum_partic_men + sum_partic_women) AS percentage_male,
  SUM(sum_partic_women) * 100 / SUM(sum_partic_men + sum_partic_women) AS percentage_female
FROM
  `sports_dataset.sports`
WHERE sum_partic_men <> 0 AND sum_partic_women <> 0
GROUP BY
  sports;
/*
sports	percentage_male	percentage_female
Basketball	53.0529908459596	46.9470091540404
Tennis	52.275578247760734	47.724421752239266
"Track and Field, Indoor"	53.307146477445514	46.692853522554486
"Track and Field, Outdoor"	54.999894672536918	45.000105327463082
All Track Combined	50.723323049290983	49.276676950709017
Soccer	53.901808074414511	46.098191925585489
Golf	57.835449013848091	42.164550986151909
Lacrosse	61.142817432396043	38.857182567603957
Swimming and Diving	49.320343707790904	50.679656292209096
"Track and Field, X-Country"	51.791570345680341	48.208429654319659
Swimming	49.369747899159663	50.630252100840337
Skiing	51.64632742344002	48.35367257655998
Rodeo	57.67533564923481	42.32466435076519
Volleyball	46.930015371675516	53.069984628324484
Archery	50.08278145695364	49.91721854304636
Other Sports	47.147327075427732	52.852672924572268
Wrestling	62.963416126269422	37.036583873730578
Gym stics	52.692003167062552	47.307996832937448
Water Polo	53.49818181818182	46.50181818181818
Fencing	54.112554112554115	45.887445887445885
Rowing	47.849252299932509	52.150747700067491
Sailing	42.479634412875022	57.520365587124978
Diving	53.658536585365852	46.341463414634148
Ice Hockey	55.37111959768594	44.62888040231406
Squash	52.50247770069376	47.49752229930624
Bowling	55.140698565641081	44.859301434358919
Weight Lifting	54.266538830297222	45.733461169702778
Rifle	53.964497041420117	46.035502958579883
Equestrian	7.92910447761194	92.070895522388057
Table Tennis	51.748251748251747	48.251748251748253
Beach Volleyball	48.967551622418881	51.032448377581119 */


## Finding the most popular sport in each state for women
select sports, state_cd, sum(sum_partic_women) as total_women,
dense_rank() over (partition by state_cd order by sum(sum_partic_women) desc) as highest_participation_rank
from `sports_dataset.sports`
where state_cd <> ' '
group by state_cd, sports
qualify highest_participation_rank = 1
order by state_cd;
/*
sports	state_cd	total_women	highest_participation_rank
Volleyball	AK	155	1
All Track Combined	AL	5135	1
All Track Combined	AR	3372	1
All Track Combined	AZ	2381	1
Soccer	CA	19915	1
All Track Combined	CO	4746	1
All Track Combined	CT	5332	1
All Track Combined	DC	1398	1
All Track Combined	DE	1091	1
All Track Combined	FL	6770	1
All Track Combined	GA	5440	1
Soccer	HI	562	1
All Track Combined	IA	6094	1
All Track Combined	ID	2176	1
All Track Combined	IL	11799	1
All Track Combined	IN	8077	1
All Track Combined	KS	8863	1
All Track Combined	KY	4819	1
All Track Combined	LA	4549	1
All Track Combined	MA	10678	1
All Track Combined	MD	4548	1
All Track Combined	ME	2215	1
All Track Combined	MI	10546	1
All Track Combined	MN	7441	1
All Track Combined	MO	9595	1
Softball	MS	2918	1
All Track Combined	MT	2170	1
All Track Combined	NC	11634	1
All Track Combined	ND	2335	1
All Track Combined	NE	4081	1
All Track Combined	NH	2574	1
All Track Combined	NJ	6012	1
All Track Combined	NM	2136	1
All Track Combined	NV	590	1
All Track Combined	NY	16964	1
All Track Combined	OH	15604	1
All Track Combined	OK	3735	1
All Track Combined	OR	3279	1
All Track Combined	PA	22432	1
Volleyball	PR	1306	1
All Track Combined	RI	1773	1
All Track Combined	SC	6650	1
All Track Combined	SD	4140	1
All Track Combined	TN	5868	1
All Track Combined	TX	14303	1
All Track Combined	UT	3890	1
All Track Combined	VA	8027	1
Basketball	VI	47	1
All Track Combined	VT	1147	1
All Track Combined	WA	5068	1
All Track Combined	WI	6288	1
All Track Combined	WV	3191	1
Volleyball	WY	605	1 */

## Finding the most popular sport in each state for men

select sports, state_cd, sum(sum_partic_men) as total_men, 
dense_rank() over (partition by state_cd order by sum(sum_partic_men) desc) as highest_participation_rank
from `sports_dataset.sports`
where state_cd <> ' '
group by state_cd, sports
qualify highest_participation_rank = 1
order by state_cd;

/*sports	state_cd	total_men	highest_participation_rank
Ice Hockey	AK	287	1
Football	AL	10016	1
Football	AR	7440	1
Football	AZ	5032	1
Football	CA	36767	1
All Track Combined	CO	5932	1
All Track Combined	CT	4656	1
Football	DC	1757	1
Football	DE	1570	1
Football	FL	10432	1
Football	GA	10273	1
Baseball	HI	594	1
Football	IA	15220	1
Football	ID	1957	1
Football	IL	17456	1
Football	IN	10773	1
Football	KS	14453	1
Football	KY	9553	1
Football	LA	6989	1
Football	MA	13785	1
Football	MD	4996	1
Football	ME	2667	1
Football	MI	13078	1
Football	MN	13628	1
Football	MO	11728	1
Football	MS	9578	1
Football	MT	3883	1
Football	NC	18616	1
Football	ND	4831	1
Football	NE	6393	1
All Track Combined	NH	2438	1
All Track Combined	NJ	6776	1
Football	NM	3235	1
Football	NV	1147	1
Soccer	NY	18656	1
Football	OH	23780	1
Football	OK	8605	1
Football	OR	5827	1
Football	PA	27724	1
Baseball	PR	1600	1
Football	RI	2043	1
Football	SC	8092	1
Football	SD	5227	1
Football	TN	9574	1
Football	TX	26940	1
Football	UT	3970	1
Football	VA	13566	1
Soccer	VI	69	1
Football	VT	1512	1
Baseball	WA	4715	1
Football	WI	9142	1
Football	WV	7099	1
Basketball	WY	644	1*/


# unique zipcodes:

select distinct city_txt from `sports_dataset.sports`;