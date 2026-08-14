SELECT
    Age_Group,
    Males_Seen,
    Females_Seen,
    Males_Seen_Previous,
    Females_Seen_Previous,
    Total
FROM
(
    /* =====================================================
       AGE GROUP LEVEL
    ===================================================== */
    SELECT
        base.Age_Group,

        SUM(CASE WHEN base.Program_Status = 'Seen' AND base.Gender = 'M' THEN 1 ELSE 0 END) AS Males_Seen,
        SUM(CASE WHEN base.Program_Status = 'Seen' AND base.Gender = 'F' THEN 1 ELSE 0 END) AS Females_Seen,

        SUM(CASE WHEN base.Program_Status = 'Seen Previous' AND base.Gender = 'M' THEN 1 ELSE 0 END) AS Males_Seen_Previous,
        SUM(CASE WHEN base.Program_Status = 'Seen Previous' AND base.Gender = 'F' THEN 1 ELSE 0 END) AS Females_Seen_Previous,

        COUNT(*) AS Total

    FROM
    (
        /* =====================================================
           BASE COHORT (ALIGNED WITH FINAL MODEL)
        ===================================================== */
        SELECT
            p.patient_id AS Id,
            per.gender AS Gender,
            rag.name AS Age_Group,

            CASE
                WHEN latest_prep.obs_datetime BETWEEN '#startDate#' AND '#endDate#'
                    THEN 'Seen'
                WHEN latest_prep.obs_datetime < '#startDate#'
                    THEN 'Seen Previous'
                ELSE 'Unknown'
            END AS Program_Status

        FROM patient p

        INNER JOIN (
            SELECT o1.*
            FROM obs o1
            INNER JOIN (
                SELECT person_id, MAX(obs_datetime) AS max_date
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

        INNER JOIN obs next_appt
            ON next_appt.person_id = p.patient_id
           AND next_appt.concept_id = 3752
           AND next_appt.voided = 0
           AND next_appt.obs_datetime = latest_prep.obs_datetime
           AND next_appt.value_datetime > '#endDate#'

        LEFT JOIN (
            SELECT o1.person_id
            FROM obs o1
            INNER JOIN (
                SELECT person_id, MAX(obs_datetime) AS max_date
                FROM obs
                WHERE concept_id IN (4994,5005)
                  AND voided = 0
                  AND obs_datetime >= '#startDate#'
                  AND obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)
                GROUP BY person_id
            ) x
            ON x.person_id = o1.person_id
           AND x.max_date = o1.obs_datetime
            WHERE o1.concept_id IN (4994,5005)
              AND o1.voided = 0
        ) excl
            ON excl.person_id = p.patient_id

        INNER JOIN person per
            ON per.person_id = p.patient_id
           AND per.voided = 0

        INNER JOIN reporting_age_group rag
            ON rag.report_group_name = 'Modified_Ages'
           AND CAST('#endDate#' AS DATE) BETWEEN
               DATE_ADD(DATE_ADD(per.birthdate, INTERVAL rag.min_years YEAR), INTERVAL rag.min_days DAY)
               AND
               DATE_ADD(DATE_ADD(per.birthdate, INTERVAL rag.max_years YEAR), INTERVAL rag.max_days DAY)

        WHERE p.voided = 0
          AND excl.person_id IS NULL

    ) base

    GROUP BY base.Age_Group

    UNION ALL

    /* =====================================================
       TOTAL ROW
    ===================================================== */
    SELECT
        'Total' AS Age_Group,

        SUM(CASE WHEN base.Program_Status = 'Seen' AND base.Gender = 'M' THEN 1 ELSE 0 END),
        SUM(CASE WHEN base.Program_Status = 'Seen' AND base.Gender = 'F' THEN 1 ELSE 0 END),

        SUM(CASE WHEN base.Program_Status = 'Seen Previous' AND base.Gender = 'M' THEN 1 ELSE 0 END),
        SUM(CASE WHEN base.Program_Status = 'Seen Previous' AND base.Gender = 'F' THEN 1 ELSE 0 END),

        COUNT(*)

    FROM
    (
        /* same base cohort reused */
        SELECT
            p.patient_id AS Id,
            per.gender AS Gender,
            rag.name AS Age_Group,

            CASE
                WHEN latest_prep.obs_datetime BETWEEN '#startDate#' AND '#endDate#'
                    THEN 'Seen'
                WHEN latest_prep.obs_datetime < '#startDate#'
                    THEN 'Seen Previous'
                ELSE 'Unknown'
            END AS Program_Status

        FROM patient p

        INNER JOIN (
            SELECT o1.*
            FROM obs o1
            INNER JOIN (
                SELECT person_id, MAX(obs_datetime) AS max_date
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

        INNER JOIN obs next_appt
            ON next_appt.person_id = p.patient_id
           AND next_appt.concept_id = 3752
           AND next_appt.voided = 0
           AND next_appt.obs_datetime = latest_prep.obs_datetime
           AND next_appt.value_datetime > '#endDate#'

        LEFT JOIN (
            SELECT o1.person_id
            FROM obs o1
            INNER JOIN (
                SELECT person_id, MAX(obs_datetime) AS max_date
                FROM obs
                WHERE concept_id IN (4994,5005)
                  AND voided = 0
                  AND obs_datetime >= '#startDate#'
                  AND obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)
                GROUP BY person_id
            ) x
            ON x.person_id = o1.person_id
           AND x.max_date = o1.obs_datetime
            WHERE o1.concept_id IN (4994,5005)
              AND o1.voided = 0
        ) excl
            ON excl.person_id = p.patient_id

        INNER JOIN person per
            ON per.person_id = p.patient_id
           AND per.voided = 0

        INNER JOIN reporting_age_group rag
            ON rag.report_group_name = 'Modified_Ages'
           AND CAST('#endDate#' AS DATE) BETWEEN
               DATE_ADD(DATE_ADD(per.birthdate, INTERVAL rag.min_years YEAR), INTERVAL rag.min_days DAY)
               AND
               DATE_ADD(DATE_ADD(per.birthdate, INTERVAL rag.max_years YEAR), INTERVAL rag.max_days DAY)

        WHERE p.voided = 0
          AND excl.person_id IS NULL

    ) base
) final;