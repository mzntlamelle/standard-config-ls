SELECT Patient_Identifier, Patient_Name, Age, Gender, age_group,location_name, Testing_Strategies , Testing_History , HIV_Status, Mode_of_Entry, Linkage_to_Care
FROM
(SELECT Id, Patient_Identifier, Patient_Name, Age, Gender, age_group,location_name, Testing_Strategies , Testing_History , HIV_Status, sort_order
FROM (

		(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,location_name, 'PITC' AS 'Testing_Strategies'
				, 'Repeat' AS 'Testing_History' , HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   l.name as location_name,
											   observed_age_group.sort_order AS sort_order

						from obs o
								-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 2165 and o.value_coded = 1738
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            	 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
								 
								 -- PROVIDER INITIATED TESTING AND COUNSELING
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4228 and os.value_coded = 4227
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 -- REPEAT TESTER, HAS A HISTORY OF PREVIOUS TESTING
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 2137 and os.value_coded = 2146
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
                                 
								INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								INNER JOIN location l on o.location_id = l.location_id and l.retired=0
								INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)


		UNION

		(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,location_name, 'PITC' AS 'Testing_Strategies'
				, 'New' AS 'Testing_History' , HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   l.name as location_name,
											   observed_age_group.sort_order AS sort_order

						from obs o
								-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 2165 and o.value_coded = 1738
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            	 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
								 
								 -- PROVIDER INITIATED TESTING AND COUNSELING
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4228 and os.value_coded = 4227
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 -- NEW TESTER, DOES NOT HAVE HISTORY OF PREVIOUS TESTING
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 2137 and os.value_coded = 2147
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
                                 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)

		UNION
		(SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, location_name,'PITC' AS 'Testing_Strategies'
				, 'Repeat' AS 'Testing_History' , HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   l.name as location_name,
											   observed_age_group.sort_order AS sort_order

						from obs o
								-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 2165 and o.value_coded = 1016
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            	 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
								 
								 -- PROVIDER INITIATED TESTING AND COUNSELING
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4228 and os.value_coded = 4227
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 -- REPEATER, DOES NOT HAVE HISTORY OF PREVIOUS TESTING
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 2137 and os.value_coded = 2146
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
                                 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)


		UNION

		(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,location_name, 'PITC' AS 'Testing_Strategies'
				, 'New' AS 'Testing_History' , HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   l.name as location_name,
											   observed_age_group.sort_order AS sort_order

						from obs o
								-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 2165 and o.value_coded = 1016
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            	 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
								 
								 -- PROVIDER INITIATED TESTING AND COUNSELING
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4228 and os.value_coded = 4227
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 -- NEW TESTER, DOES NOT HAVE HISTORY OF PREVIOUS TESTING
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 2137 and os.value_coded = 2147
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)
		UNION
		

		(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,location_name, 'CITC' AS 'Testing_Strategies'
				, 'Repeat' AS 'Testing_History' , HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   l.name as location_name,
											   observed_age_group.sort_order AS sort_order

						from obs o
								-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 2165 and o.value_coded = 1738
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            	 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
								 
								 -- CLIENT INITIATED TESTING AND COUNSELING
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4228 and os.value_coded = 4226
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 -- REPEAT TESTER, HAS A HISTORY OF PREVIOUS TESTING
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 2137 and os.value_coded = 2146
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								  
                                 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)


		UNION

		(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,location_name, 'CITC' AS 'Testing_Strategies'
				, 'New' AS 'Testing_History' , HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   l.name as location_name,
											   observed_age_group.sort_order AS sort_order

						from obs o
								-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 2165 and o.value_coded = 1738
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            	 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
								 
								 -- CLIENT INITIATED TESTING AND COUNSELING
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4228 and os.value_coded = 4226
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 -- NEW TESTER, DOES NOT HAVE HISTORY OF PREVIOUS TESTING
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 2137 and os.value_coded = 2147
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
                                 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)

		UNION
		(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,location_name, 'CITC' AS 'Testing_Strategies'
				, 'Repeat' AS 'Testing_History' , HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   l.name as location_name,
											   observed_age_group.sort_order AS sort_order

						from obs o
								-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 2165 and o.value_coded = 1016
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            	 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
								 
								 -- CLIENT INITIATED TESTING AND COUNSELING
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4228 and os.value_coded = 4226
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 -- REPEATER, DOES NOT HAVE HISTORY OF PREVIOUS TESTING
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 2137 and os.value_coded = 2146
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								
                                 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)


		UNION

		(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,location_name, 'CITC' AS 'Testing_Strategies'
				, 'New' AS 'Testing_History' , HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   l.name as location_name,
											   observed_age_group.sort_order AS sort_order

						from obs o
								-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 2165 and o.value_coded = 1016
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            	 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
								 
								 -- CLIENT INITIATED TESTING AND COUNSELING
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4228 and os.value_coded = 4226
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 -- NEW TESTER, DOES NOT HAVE HISTORY OF PREVIOUS TESTING
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 2137 and os.value_coded = 2147
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)

) AS HTS_Status_Detailed

-- ORDER BY HTS_Status_Detailed.Testing_Strategies
			-- , HTS_Status_Detailed.Testing_History
			-- , HTS_Status_Detailed.sort_order
			-- , HTS_Status_Detailed.Gender
			-- , HTS_Status_Detailed.HIV_Status


UNION



Select Id, Patient_Identifier, Patient_Name,Age, Gender, age_group,location_name,Testing_Strategies,Testing_History, HIV_Status, sort_order
from(
SELECT Id,Patient_Identifier, Patient_Name, Age, Gender, age_group,location_name, Testing_Strategies  ,Testing_History, HIV_Status,sort_order
FROM (
(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,location_name, 'Self-test' AS 'Testing_Strategies'
                          ,'N/A' AS 'Testing_History', HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   l.name as location_name,
											   observed_age_group.sort_order AS sort_order
						from obs o
								-- HTS SELF TEST STRATEGY
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND ( (o.concept_id = 4845 AND value_coded = 4822) OR o.concept_id = 6370 )
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
								 
								 -- HAS HIV POSITIVE RESULTS 
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 4844 and os.value_coded = 1738
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								  INNER JOIN location l on o.location_id = l.location_id and l.retired=0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 ) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)
		
UNION
(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,location_name, 'Self-test' AS 'Testing_Strategies'
				,'N/A' AS 'Testing_History', HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   l.name as location_name,
											   observed_age_group.sort_order AS sort_order
						from obs o
								-- HTS SELF TEST STRATEGY
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND ( (o.concept_id = 4845 AND value_coded = 4822) OR o.concept_id = 6370 )
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
								 
								 -- HAS HIV NEGATIVE RESULTS 
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 4844 and os.value_coded = 1016
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 ) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)
		
UNION
(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,location_name, 'Self-test' AS 'Testing_Strategies'
				 , 'N/A' AS 'Testing_History', HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 2148 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   l.name as location_name,
											   observed_age_group.sort_order AS sort_order
						from obs o
								-- HTS SELF TEST STRATEGY
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND ( (o.concept_id = 4845 AND value_coded = 4822) OR o.concept_id = 6370 )
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

            								 
								 -- HAS HIV UNKNOWN RESULTS 
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 4844 and os.value_coded = 2148
									AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 ) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)
		
) AS HTS_Status_Detailed
ORDER BY HTS_Status_Detailed.HIV_Status desc
			, HTS_Status_Detailed.sort_order ) AS SelfTest
            
     UNION

     (SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,location_name, 'Patient_Retested_Only' AS 'Testing_Strategies'
				, 'N/A' AS 'Testing_History' , HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   l.name as location_name,
											   observed_age_group.sort_order AS sort_order

						from obs o
								-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4269 -- and o.value_coded = 1016
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            	 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))


								 -- REPEATER, DOES NOT HAVE HISTORY OF PREVIOUS TESTING
								 AND o.person_id not in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 2386 -- and os.value_coded = 2146
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 4817 and os.value_coded = 1016
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
                                 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)     

        UNION 

        (SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,location_name, 'Patient_Retested_Only' AS 'Testing_Strategies'
				, 'N/A' AS 'Testing_History' , HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   l.name as location_name,
											   observed_age_group.sort_order AS sort_order

						from obs o
								-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4269 -- and o.value_coded = 1016
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            	 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))


								 -- REPEATER, DOES NOT HAVE HISTORY OF PREVIOUS TESTING
								 AND o.person_id not in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 2386 -- and os.value_coded = 2146
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 4817 and os.value_coded = 1738
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                            		AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
                                 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)  
            
            )Tested_Patients


-- ORDER BY Tested_Patients.HIV_Status desc
          -- , Tested_Patients.Testing_Strategies
		-- , Tested_Patients.Testing_History
			-- , Tested_Patients.sort_order
			-- , Tested_Patients.Gender
            -- , Tested_Patients.age_group
			


-- Mode of Entry
left outer join

(select
       o.person_id,
       case
           when value_coded = 4234 then "Antiretroviral"
           when value_coded = 4233 then "Anti Natal Care"
           when value_coded = 2191 then "Outpatient"
           when value_coded = 2190 then "Tuberculosis Entry Point"
           when value_coded = 4235 then "VMMC"
           when value_coded = 4236 then "Adolescent"
           when value_coded = 2192 then "Inpatient"
           when value_coded = 3632 then "PEP"
           when value_coded = 2139 then "STI"
           when value_coded = 4788 then "PEADS"
           when value_coded = 4789 then "Malnutrition"
           when value_coded = 4790 then "Subsequent ANC"
           when value_coded = 4791 then "Emergency ward"
           when value_coded = 4792 then "Index Testing"
           when value_coded = 4796 then "Other Cummunity"
           when value_coded = 4237 then "Self Testing"
           when value_coded = 4816 then "PrEP"
           when value_coded = 2143 then "Other"
           else ""
       end AS Mode_of_Entry
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as entry_mode
		 from obs oss
		 where oss.concept_id = 4238 and oss.voided=0
		 and oss.obs_datetime < cast('#endDate#' as date)
         AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
		AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4238
	and  o.obs_datetime = max_observation
	) moderesults
ON Tested_Patients.Id = moderesults.person_id

-- Linkage to Care
left outer join

(select
       o.person_id,
       case
           when value_coded = 2146 then "Linked to Care"
           when value_coded = 2147 then "Not Linked to Care"
           when value_coded = 2922 then "Referred"
           else ""
       end AS Linkage_to_Care
from obs o
inner join
		(
		 select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
            from obs where concept_id = 4269
            and obs_datetime <= cast('#endDate#' as date)
            AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
            group by person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4239
	) linkage_to_care
ON Tested_Patients.Id = linkage_to_care.person_id

 ORDER BY Tested_Patients.HIV_Status desc
 , Tested_Patients.Testing_Strategies
 , Tested_Patients.Testing_History
 , Tested_Patients.sort_order
 , Tested_Patients.Gender
 , Tested_Patients.age_group