-- INCLUDE MISSED APPOINTMENTS WITHIN 28 DAYS ACCORDING TO THE NEW PEPFAR GUIDELINE
(SELECT ART_Number, patientIdentifier , patientName , Age, Gender, 'MissedWithin28Days' AS 'Program_Status',Date_Missed ,location_name, Contacts, Village
FROM
                (select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
                        p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						person.gender AS Gender,
						cast(max(value_datetime) as date) as Date_Missed,
						pa.value as Contacts,
						person_address.city_village AS Village,
						l.name as location_name

						

                from obs o
						-- CLIENTS WHO MISSED APPOINTMENTS < 28 DAYS
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (

						  -- Latest followup date from the lastest followup form, exclude voided followup date
								select active_clients.person_id
										from
										(  select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
											from obs B
											inner join 
											(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id IN (3753,6515)
											and obs_datetime <= cast('#endDate#' as date)
											group by person_id) as A
											on A.observation_id = B.obs_group_id
											where concept_id = 3752
											and A.observation_id = B.obs_group_id
											and voided = 0	
											group by B.person_id
										) as active_clients
										where active_clients.latest_follow_up < cast('#endDate#' as date)
										and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) > 0
										and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) <= 28
						
						
										and active_clients.person_id not in (
											select distinct os.person_id
											from obs os
											where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											)
								
										and active_clients.person_id not in (
											select distinct os.person_id
											from obs os
											where concept_id = 2249
											AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
											)

										and active_clients.person_id not in (
									
											-- TOUTS
											select tout_clients.person_id
										from
										(select B.person_id, B.obs_group_id, B.obs_datetime AS latest_consultation
											from obs B
											inner join
											(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 2403
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as A
											on A.observation_id = B.obs_group_id
											where concept_id = 2398
											and A.observation_id = B.obs_group_id
											and voided = 0
											group by B.person_id
										) as tout_clients
										where tout_clients.latest_consultation < cast('#endDate#' as date)
														
											)
					
									-- DEAD
											and active_clients.person_id not in (
											select person_id 
											from person 
											where death_date <= cast('#endDate#' as date)
											and dead = 1
										)
						 )
						 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN person_address ON person_address.person_id =  person.person_id AND person_address.voided = 0
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN location l on o.location_id = l.location_id and l.retired=0
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
						LEFT OUTER JOIN person_attribute pa ON pa.person_id = person.person_id AND pa.person_attribute_type_id in (26) AND p.voided = 0
                        INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages' and cast(value_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 3752 
				   Group  BY patientIdentifier 
				   order by Date_Missed desc) AS TwentyEightDayDefaulters

                    

order by TwentyEightDayDefaulters.patientName)

UNION

-- INCLUDE MISSED APPOINTMENTS WITH MORE THAN 28 AND LESS THAN 89 DAYS ACCORDING TO THE NEW PEPFAR GUIDELINE
(SELECT ART_Number, patientIdentifier , patientName , Age, Gender, 'Defaulted' AS 'Program_Status',Date_Missed, location_name, Contacts, Village
FROM
                (select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
                        p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						person.gender AS Gender,
						observed_age_group.name AS age_group,
						cast(max(value_datetime) as date) as Date_Missed,
						pa.value as Contacts,
						person_address.city_village AS Village,
                        l.name as location_name
						

                from obs o
						-- CLIENTS WHO MISSED APPOINTMENTS > 28 and < 89 DAYS
						INNER JOIN patient ON o.person_id = patient.patient_id
						AND o.person_id in (

						 -- Latest followup date from the lastest followup form, exclude voided followup date
						select active_clients.person_id
								from
								(  select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id IN (3753,6515)
									and obs_datetime <= cast('#endDate#' as date)
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id
								) as active_clients
								where active_clients.latest_follow_up < cast('#endDate#' as date)
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) > 28
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) <= 89
				
		                        and active_clients.person_id not in (
                                    select distinct os.person_id
                                    from obs os
                                    where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
                                    AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                    AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
						
		                        and active_clients.person_id not in (
                                    select distinct os.person_id
                                    from obs os
                                    where concept_id = 2249
                                    AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                    AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )

		                        and active_clients.person_id not in (
							
                                    -- TOUTS
                                    select tout_clients.person_id
										from
										(select B.person_id, B.obs_group_id, B.obs_datetime AS latest_consultation
											from obs B
											inner join
											(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 2403
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as A
											on A.observation_id = B.obs_group_id
											where concept_id = 2398
											and A.observation_id = B.obs_group_id
											and voided = 0
											group by B.person_id
										) as tout_clients
										where tout_clients.latest_consultation < cast('#endDate#' as date)

                                )
                                    -- DEAD

		                        and active_clients.person_id not in (
                                    select person_id 
                                    from person 
                                    where death_date <= cast('#endDate#' as date)
                                    and dead = 1
						         )
						 )
						 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN person_address ON person_address.person_id =  person.person_id AND person_address.voided = 0
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                        LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                        LEFT OUTER JOIN person_attribute pa ON pa.person_id = person.person_id AND pa.person_attribute_type_id in (26) AND p.voided = 0
						INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages' and cast(value_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 3752 
				   Group  BY patientIdentifier 
				   order by Date_Missed desc) AS MoreThanTwentyEightDayDefaulters
order by MoreThanTwentyEightDayDefaulters.patientName)


UNION

-- INCLUDE MISSED APPOINTMENTS WITH MORE THAN 89 ACCORDING TO THE NEW PEPFAR GUIDELINE
(SELECT ART_Number, patientIdentifier , patientName , Age, Gender, 'LTFU' AS 'Program_Status',Date_Missed , location_name, Contacts, Village
FROM
                 (select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
                        p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						person.gender AS Gender,
						observed_age_group.name AS age_group,
						cast(max(value_datetime) as date) as Date_Missed,
						pa.value as Contacts,
						person_address.city_village AS Village,
                        l.name as location_name
						

                from obs o
						-- CLIENTS WHO MISSED APPOINTMENTS < 89 DAYS
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (
						 -- begin
						select active_clients.person_id
								from
								(  select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id IN (3753,6515)
									and obs_datetime <= cast('#endDate#' as date)
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id
								) as active_clients
								where active_clients.latest_follow_up < cast('#endDate#' as date)
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) > 89
				
				
		                        and active_clients.person_id not in (
                                    select distinct os.person_id
                                    from obs os
                                    where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
                                    AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                    AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
						
		                        and active_clients.person_id not in (
                                    select distinct os.person_id
                                    from obs os
                                    where concept_id = 2249
                                    AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                    AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )

		                        and active_clients.person_id not in (
							
									-- TOUTS
									select tout_clients.person_id
										from
										(select B.person_id, B.obs_group_id, B.obs_datetime AS latest_consultation
											from obs B
											inner join
											(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 2403
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as A
											on A.observation_id = B.obs_group_id
											where concept_id = 2398
											and A.observation_id = B.obs_group_id
											and voided = 0
											group by B.person_id
										) as tout_clients
										where tout_clients.latest_consultation < cast('#endDate#' as date)

                                )
			
                                -- DEAD
		                        and active_clients.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('#endDate#' as date)
									and dead = 1
						 )
					 )
						 
					    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN person_address ON person_address.person_id =  person.person_id AND person_address.voided = 0
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                        LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                        LEFT OUTER JOIN person_attribute pa ON pa.person_id = person.person_id AND pa.person_attribute_type_id in (26) AND p.voided = 0
						INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                        WHERE observed_age_group.report_group_name = 'Modified_Ages' and cast(value_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 3752 
				   		Group  BY patientIdentifier 
				   		order by Date_Missed desc) AS MoreThanEightyNineDayDefaulters
order by MoreThanEightyNineDayDefaulters.patientName)