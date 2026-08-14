SELECT DISTINCT
    pi.identifier AS patientIdentifier,
    CONCAT(pn.given_name,' ',pn.family_name) AS patientName,
    TIMESTAMPDIFF(YEAR, per.birthdate, CAST('#endDate#' AS DATE)) AS Age,
    per.gender AS Gender,
    rag.name AS age_group,

    CASE prep_option.value_coded
        WHEN 6096 THEN 'Daily'
        WHEN 6097 THEN 'ED_PreP'
        WHEN 6098 THEN 'Ring'
        WHEN 6099 THEN 'Cab-La'
        WHEN 6597 THEN 'Lenacapavir'
        WHEN 4991 THEN 'Other'
    END AS PrEP_Option,

    'Initiation' AS Program_Status,

    loc.name AS Location

FROM obs init

INNER JOIN patient p
    ON p.patient_id = init.person_id
   AND p.voided = 0

INNER JOIN person per
    ON per.person_id = p.patient_id
   AND per.voided = 0

INNER JOIN person_name pn
    ON pn.person_id = p.patient_id
   AND pn.preferred = 1
   AND pn.voided = 0

INNER JOIN patient_identifier pi
    ON pi.patient_id = p.patient_id
   AND pi.identifier_type = 3
   AND pi.preferred = 1
   AND pi.voided = 0

INNER JOIN location loc
    ON loc.location_id = init.location_id
   AND loc.retired = 0

/* Same encounter PrEP option */
LEFT JOIN obs prep_option
    ON prep_option.obs_id =
    (
        SELECT po.obs_id
        FROM obs po
        WHERE po.person_id = init.person_id
          AND po.encounter_id = init.encounter_id
          AND po.concept_id = 6100
          AND po.voided = 0
        ORDER BY po.obs_datetime DESC, po.obs_id DESC
        LIMIT 1
    )

INNER JOIN reporting_age_group rag
    ON rag.report_group_name = 'Modified_Ages'
   AND CAST('#endDate#' AS DATE) BETWEEN
       DATE_ADD(DATE_ADD(per.birthdate, INTERVAL rag.min_years YEAR), INTERVAL rag.min_days DAY)
       AND
       DATE_ADD(DATE_ADD(per.birthdate, INTERVAL rag.max_years YEAR), INTERVAL rag.max_days DAY)

WHERE init.concept_id = 4994
  AND init.voided = 0
  AND init.value_datetime >= '#startDate#'
  AND init.value_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)

  AND NOT EXISTS (
      SELECT 1
      FROM obs x
      WHERE x.person_id = init.person_id
        AND x.concept_id = 5070
        AND x.value_coded = 2146
        AND x.voided = 0
  )

  AND NOT EXISTS (
      SELECT 1
      FROM obs x
      WHERE x.person_id = init.person_id
        AND x.concept_id = 5003
        AND x.value_coded = 1
        AND x.voided = 0
  )

ORDER BY patientName