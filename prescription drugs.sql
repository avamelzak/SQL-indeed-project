-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

SELECT npi, SUM(total_claim_count) AS total_claims
FROM prescription
JOIN prescriber
USING (npi)
GROUP BY npi
ORDER BY total_claims DESC;

SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS total_claims
FROM prescription
JOIN prescriber
USING (npi)
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY total_claims DESC;


-- 2a. Which specialty had the most total number of claims (totaled over all drugs)?
-- Family Practice
-- b. Which specialty had the most total number of claims for opioids?
-- Nurse Practitioner
-- c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
-- d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
-- if I did this right, General Acute Care Hospital and Critical Care have the highest percentage of opioids at 9.09%

SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescription
JOIN prescriber
USING (npi)
GROUP BY specialty_description
ORDER BY total_claims DESC;

SELECT specialty_description, SUM(total_claim_count) AS total_opioid_claims
FROM prescriber
JOIN prescription
USING (npi)
JOIN drug
USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY total_opioid_claims DESC;

SELECT specialty_description
FROM prescriber
GROUP BY specialty_description
EXCEPT
SELECT specialty_description
FROM prescriber
INNER JOIN prescription
USING (npi)
GROUP BY specialty_description;

WITH opioids AS (
	SELECT drug_name
	FROM drug
	WHERE opioid_drug_flag = 'Y'
	)
SELECT specialty_description,
	ROUND((COUNT(opioids.drug_name)/SUM(total_claim_count)*100), 2) AS opioid_percent
FROM prescriber
JOIN prescription
USING (npi)
JOIN opioids
USING (drug_name)
GROUP BY specialty_description
ORDER BY opioid_percent DESC;


-- 3a. Which drug (generic_name) had the highest total drug cost?
-- Insulin Glargine
-- b. Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places.
-- C1 Esterase Inhibitor

SELECT generic_name, SUM(total_drug_cost) AS total_cost
FROM drug
JOIN prescription
USING (drug_name)
GROUP BY generic_name
ORDER BY total_cost DESC;

SELECT generic_name, ROUND(SUM(total_drug_cost)/SUM(total_day_supply), 2) AS total_cost_per_day
FROM drug
JOIN prescription
USING (drug_name)
GROUP BY generic_name
ORDER BY total_cost_per_day DESC;


-- 4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
-- b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
-- more was spent on opioids

SELECT drug_name,
	CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
	END AS drug_type
FROM drug;

SELECT
	CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
	END AS drug_type,
SUM(total_drug_cost)::MONEY AS total_cost
FROM drug
JOIN prescription
USING (drug_name)
GROUP BY drug_type
ORDER BY total_cost DESC;


-- 5a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.
-- 33
-- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
-- largest: Nashville-Davidson--Murfreesboro--Franklin
-- smallest: Morristown
-- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
-- Sevier, pop 95523

SELECT COUNT(cbsaname) AS tn_cbsas
FROM cbsa
WHERE cbsaname LIKE '%TN';

SELECT cbsaname, SUM(population) AS total_pop
FROM cbsa
JOIN population
USING (fipscounty)
GROUP BY cbsaname
ORDER BY total_pop DESC;

SELECT cbsaname, SUM(population) AS total_pop
FROM cbsa
JOIN population
USING (fipscounty)
GROUP BY cbsaname
ORDER BY total_pop ASC;

SELECT county, population
FROM fips_county
JOIN population
USING (fipscounty)
FULL JOIN cbsa
USING (fipscounty)
WHERE cbsa IS NULL
ORDER BY population DESC;


-- 6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
-- b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
-- c. Add another column to your answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

SELECT drug_name, total_claim_count, 
	CASE
	WHEN opioid_drug_flag = 'Y' THEN 'yes'
	ELSE 'no'
	END AS is_opioid
FROM drug
JOIN prescription
USING (drug_name)
WHERE total_claim_count >= 3000;

WITH over3000_claims AS (
	SELECT npi, drug_name, total_claim_count, 
		CASE
		WHEN opioid_drug_flag = 'Y' THEN 'yes'
		ELSE 'no'
		END AS is_opioid
	FROM drug
	JOIN prescription
	USING (drug_name)
	WHERE total_claim_count >= 3000
	)
SELECT drug_name, total_claim_count, is_opioid, nppes_provider_first_name, nppes_provider_last_org_name
FROM prescriber
JOIN over3000_claims
USING (npi);


-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.
-- a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
-- b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
-- c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT npi, drug_name
FROM drug
CROSS JOIN prescriber
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y';

WITH npi_drug_combo AS (
	SELECT npi, drug_name
	FROM drug
	CROSS JOIN prescriber
	WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
	)
SELECT npi_drug_combo.npi, npi_drug_combo.drug_name,
	COALESCE (total_claim_count, '0') AS total_claims
FROM npi_drug_combo
LEFT JOIN prescription
USING (npi, drug_name)
ORDER BY total_claims DESC;