(SELECT DISTINCT
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
)

UNION ALL 
(
    SELECT
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

    CASE
        WHEN latest_prep.obs_datetime BETWEEN '#startDate#' AND '#endDate#'
            THEN 'Seen'
        WHEN latest_prep.obs_datetime < '#startDate#'
            THEN 'Seen Previous'
        ELSE 'Unknown'
    END AS Program_Status,

    loc.name AS Location

FROM patient p

/* =====================================================
   1. Latest PrEP observation (as-of endDate)
===================================================== */
INNER JOIN (
    SELECT o1.*
    FROM obs o1
    INNER JOIN (
        SELECT person_id,
               MAX(obs_datetime) AS max_date
        FROM obs
        WHERE concept_id = 5029
          AND voided = 0
          AND obs_datetime <= '#endDate#'
        GROUP BY person_id
    ) x
      ON x.person_id = o1.person_id
     AND x.max_date = o1.obs_datetime
    WHERE o1.concept_id = 5029
      AND o1.voided = 0
) latest_prep
    ON latest_prep.person_id = p.patient_id

/* =====================================================
   2. Active PrEP logic (supply window)
===================================================== */
INNER JOIN obs next_appt
    ON next_appt.person_id = p.patient_id
   AND next_appt.concept_id = 3752
   AND next_appt.voided = 0
   AND next_appt.obs_datetime = latest_prep.obs_datetime
   AND next_appt.value_datetime > '#endDate#'

/* =====================================================
   3. Latest PrEP option (as-of endDate)
===================================================== */
LEFT JOIN (
    SELECT o1.person_id,
           o1.value_coded
    FROM obs o1
    INNER JOIN (
        SELECT person_id,
               MAX(obs_datetime) AS max_date
        FROM obs
        WHERE concept_id = 6100
          AND voided = 0
          AND obs_datetime <= '#endDate#'
        GROUP BY person_id
    ) x
      ON x.person_id = o1.person_id
     AND x.max_date = o1.obs_datetime
    WHERE o1.concept_id = 6100
      AND o1.voided = 0
) prep_option
    ON prep_option.person_id = p.patient_id

/* =====================================================
   4. Latest exclusion (as-of endDate)
===================================================== */
LEFT JOIN (
    SELECT o1.person_id
    FROM obs o1
    INNER JOIN (
        SELECT person_id,
               MAX(obs_datetime) AS max_date
        FROM obs
        WHERE concept_id IN (4994,5005)
          AND voided = 0
          AND obs_datetime >= '#startDate#'
          AND obs_datetime < DATE_ADD("#endDate#", INTERVAL 1 DAY)
        GROUP BY person_id
    ) x
      ON x.person_id = o1.person_id
     AND x.max_date = o1.obs_datetime
    WHERE o1.concept_id IN (4994,5005)
      AND o1.voided = 0
) excl
    ON excl.person_id = p.patient_id

/* =====================================================
   5. Location (from latest PrEP obs)
===================================================== */
INNER JOIN location loc
    ON loc.location_id = latest_prep.location_id
   AND loc.retired = 0

/* =====================================================
   6. Demographics
===================================================== */
INNER JOIN person per
    ON per.person_id = p.patient_id
   AND per.voided = 0

INNER JOIN person_name pn
    ON pn.person_id = per.person_id
   AND pn.preferred = 1
   AND pn.voided = 0

INNER JOIN patient_identifier pi
    ON pi.patient_id = p.patient_id
   AND pi.identifier_type = 3
   AND pi.preferred = 1
   AND pi.voided = 0

/* =====================================================
   7. Age group
===================================================== */
INNER JOIN reporting_age_group rag
    ON rag.report_group_name = 'Modified_Ages'
   AND CAST('#endDate#' AS DATE) BETWEEN
       DATE_ADD(DATE_ADD(per.birthdate, INTERVAL rag.min_years YEAR), INTERVAL rag.min_days DAY)
       AND
       DATE_ADD(DATE_ADD(per.birthdate, INTERVAL rag.max_years YEAR), INTERVAL rag.max_days DAY)

/* =====================================================
   8. EXCLUSIONS
===================================================== */
WHERE p.voided = 0
  AND excl.person_id IS NULL

ORDER BY    patientName
);
