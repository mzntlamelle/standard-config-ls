SELECT age_group as 'AgeGroup',
IF(self_tests.Id IS NULL, 0, SUM(IF(Self_Test_Kits = 'Distributed_Kits', 1, 0))) AS Distributed_Kits,
IF(self_tests.Id IS NULL, 0, SUM(IF(Self_Test_Kits = 'Kits_Returned', 1, 0))) AS Returned_Kits
  -- ahd_clients.sort_order
FROM
(Select Id, patientIdentifier, patientName, Age, HIV_Status, Gender, age_group, Self_Test_Kits
from
(
  (select patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         "Distributed_Kits" as "Self_Test_Kits"
            from obs o
                -- HTS SELF TEST STRATEGY
                INNER JOIN patient ON o.person_id = patient.patient_id 
                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                 AND o.concept_id = 4833  and o.value_coded IN (4834,6535)
                 AND patient.voided = 0 AND o.voided = 0
                 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 INNER JOIN reporting_age_group AS observed_age_group ON
              CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
              AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages'
                 )

UNION ALL
(select patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         "Distributed_Kits" as "Self_Test_Kits"
            from obs o
                -- HTS SELF TEST STRATEGY
                INNER JOIN patient ON o.person_id = patient.patient_id 
                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                AND o.concept_id = 4836  and o.value_coded in (4837, 4838, 4839)
                 AND patient.voided = 0 AND o.voided = 0
                 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 INNER JOIN reporting_age_group AS observed_age_group ON
              CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
              AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages'
                 )
UNION ALL
(select patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         "Kits_Returned" as "Self_Test_Kits"
            from obs o
                -- HTS SELF TEST STRATEGY
                INNER JOIN patient ON o.person_id = patient.patient_id 
                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                AND ( (o.concept_id = 4845 AND value_coded = 4822) OR o.concept_id = 6370 )
                 AND patient.voided = 0 AND o.voided = 0
                 AND o.person_id in (
                    select o.person_id as Id
                    from obs o
                    INNER JOIN patient ON o.person_id = patient.patient_id 
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                
                    AND o.voided=0
                    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                                                
                    AND concept_id in (4844) and value_coded not in (2148)
                    AND patient.voided = 0 AND o.voided = 0
                  Group by o.person_id
                  )
                 INNER JOIN reporting_age_group AS observed_age_group ON
              CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
              AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages'
                 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 )
)as self_test
)self_tests
GROUP by self_tests.age_group

UNION ALL

(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Self_Test_Kits = 'Distributed_Kits', 1, 0))) AS 'Distributed_Kits'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Self_Test_Kits = 'Kits_Returned', 1, 0))) AS 'Returned_Kits'
		
FROM

		(Select Id, patientIdentifier, patientName, Age, HIV_Status, Gender, age_group, Self_Test_Kits
from
(
  (select patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         "Distributed_Kits" as "Self_Test_Kits"
            from obs o
                -- HTS SELF TEST STRATEGY
                INNER JOIN patient ON o.person_id = patient.patient_id 
                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                 AND o.concept_id = 4833  and o.value_coded IN (4834,6535)
                 AND patient.voided = 0 AND o.voided = 0
                 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 INNER JOIN reporting_age_group AS observed_age_group ON
              CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
              AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages'
                 )

UNION ALL
(select patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         "Distributed_Kits" as "Self_Test_Kits"
            from obs o
                -- HTS SELF TEST STRATEGY
                INNER JOIN patient ON o.person_id = patient.patient_id 
                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                AND o.concept_id = 4836  and o.value_coded in (4837, 4838, 4839)
                 AND patient.voided = 0 AND o.voided = 0
                 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 INNER JOIN reporting_age_group AS observed_age_group ON
              CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
              AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages'
                 )
UNION ALL
(select patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         "Kits_Returned" as "Self_Test_Kits"
            from obs o
                -- HTS SELF TEST STRATEGY
                INNER JOIN patient ON o.person_id = patient.patient_id 
                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                AND ( (o.concept_id = 4845 AND value_coded = 4822) OR o.concept_id = 6370 )
                 AND patient.voided = 0 AND o.voided = 0
                 AND o.person_id in (
                    select o.person_id as Id
                    from obs o
                    INNER JOIN patient ON o.person_id = patient.patient_id 
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                
                    AND o.voided=0
                    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                                                
                    AND concept_id in (4844) and value_coded not in (2148)
                    AND patient.voided = 0 AND o.voided = 0
                  Group by o.person_id
                  )
                 INNER JOIN reporting_age_group AS observed_age_group ON
              CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
              AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages'
                 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 )
)as self_test
)Totals
)


