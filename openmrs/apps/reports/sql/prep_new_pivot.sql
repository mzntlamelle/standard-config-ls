SELECT
    AgeGroup,
    SUM(Males) AS Males,
    SUM(Females) AS Females,
    SUM(Males + Females) AS Total
FROM
(
    /* =====================================================
       BASE DATASET
    ===================================================== */
    SELECT
        rag.name AS AgeGroup,

        CASE WHEN per.gender = 'M' THEN 1 ELSE 0 END AS Males,
        CASE WHEN per.gender = 'F' THEN 1 ELSE 0 END AS Females

    FROM obs init

    INNER JOIN patient p
        ON p.patient_id = init.person_id
       AND p.voided = 0

    INNER JOIN person per
        ON per.person_id = p.patient_id
       AND per.voided = 0

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

) base

GROUP BY AgeGroup

UNION ALL

/* =====================================================
   GRAND TOTAL ROW
===================================================== */
SELECT
    'TOTAL' AS AgeGroup,
    SUM(Males) AS Males,
    SUM(Females) AS Females,
    SUM(Males + Females) AS Total
FROM
(
    SELECT
        CASE WHEN per.gender = 'M' THEN 1 ELSE 0 END AS Males,
        CASE WHEN per.gender = 'F' THEN 1 ELSE 0 END AS Females

    FROM obs init

    INNER JOIN patient p
        ON p.patient_id = init.person_id
       AND p.voided = 0

    INNER JOIN person per
        ON per.person_id = p.patient_id
       AND per.voided = 0

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
) totals

ORDER BY
    CASE WHEN AgeGroup = 'TOTAL' THEN 1 ELSE 0 END,
    AgeGroup;