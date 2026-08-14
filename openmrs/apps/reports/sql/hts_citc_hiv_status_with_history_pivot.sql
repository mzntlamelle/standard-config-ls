SELECT *
FROM (
    -- ==============================
    -- Main Summary by AgeGroup and Sex
    -- ==============================
    SELECT
        ag.name AS AgeGroup,
        p.gender AS Sex,

        SUM(CASE WHEN tr.value_coded = 1738 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Positives,
        SUM(CASE WHEN tr.value_coded = 1016 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Negatives,
        SUM(CASE WHEN tr.value_coded = 4220 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Indeterminate,

        SUM(CASE WHEN tr.value_coded = 1738 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Positives,
        SUM(CASE WHEN tr.value_coded = 1016 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Negatives,
        SUM(CASE WHEN tr.value_coded = 4220 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Indeterminate,

        SUM(CASE WHEN tr.value_coded IN (1738,1016,4220) THEN 1 ELSE 0 END) AS Total

    FROM person p

    JOIN patient_identifier pi 
        ON pi.patient_id = p.person_id
        AND pi.identifier_type = 3
        AND pi.preferred = 1
        AND pi.voided = 0

    JOIN obs tr 
        ON tr.person_id = p.person_id
        AND tr.concept_id = 2165
        AND tr.voided = 0
        AND tr.obs_datetime >= CAST('#startDate#' AS DATE) AND tr.obs_datetime < DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL 1 DAY)

    -- Require PITC selected in same encounter
    JOIN obs pitc
        ON pitc.person_id = tr.person_id
        AND pitc.encounter_id = tr.encounter_id
        AND pitc.concept_id = 4228
        AND pitc.value_coded = 4226
        AND pitc.voided = 0

    -- Require Mode of Entry selected in same encounter
    JOIN obs moe
        ON moe.person_id = tr.person_id
        AND moe.encounter_id = tr.encounter_id
        AND moe.concept_id = 4238
        AND moe.value_coded IS NOT NULL
        AND moe.voided = 0

    -- Latest Testing History per patient
    JOIN (
        SELECT o.person_id,
               IF(o.value_coded = 2146, 'Repeat', 'New') AS Testing_History
        FROM obs o
        INNER JOIN (
            SELECT person_id, MAX(obs_datetime) AS latest_date
            FROM obs
            WHERE concept_id = 4798
              AND voided = 0
              AND obs_datetime >= CAST('#startDate#' AS DATE) AND obs_datetime < DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL 1 DAY)
            GROUP BY person_id
        ) latest
            ON latest.person_id = o.person_id
           AND latest.latest_date = o.obs_datetime
        WHERE o.concept_id = 4798
          AND o.voided = 0
    ) th 
        ON th.person_id = p.person_id

    -- Age Group
    JOIN reporting_age_group ag
        ON CAST('#endDate#' AS DATE) BETWEEN 
            DATE_ADD(DATE_ADD(p.birthdate, INTERVAL ag.min_years YEAR), INTERVAL ag.min_days DAY)
        AND DATE_ADD(DATE_ADD(p.birthdate, INTERVAL ag.max_years YEAR), INTERVAL ag.max_days DAY)
        AND ag.report_group_name = 'Modified_Ages'

    WHERE p.voided = 0
    GROUP BY ag.name, p.gender

    UNION ALL

    -- ==============================
    -- Final Totals Row
    -- ==============================
    SELECT
        'Total' AS AgeGroup,
        '' AS Sex,

        SUM(CASE WHEN tr.value_coded = 1738 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Positives,
        SUM(CASE WHEN tr.value_coded = 1016 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Negatives,
        SUM(CASE WHEN tr.value_coded = 4220 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Indeterminate,

        SUM(CASE WHEN tr.value_coded = 1738 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Positives,
        SUM(CASE WHEN tr.value_coded = 1016 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Negatives,
        SUM(CASE WHEN tr.value_coded = 4220 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Indeterminate,

        SUM(CASE WHEN tr.value_coded IN (1738,1016,4220) THEN 1 ELSE 0 END) AS Total

    FROM person p

    JOIN patient_identifier pi 
        ON pi.patient_id = p.person_id
        AND pi.identifier_type = 3
        AND pi.preferred = 1
        AND pi.voided = 0

    JOIN obs tr 
        ON tr.person_id = p.person_id
        AND tr.concept_id = 2165
        AND tr.voided = 0
        AND tr.obs_datetime >= CAST('#startDate#' AS DATE) AND tr.obs_datetime < DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL 1 DAY)
    
    -- Require PITC selected in same encounter
    JOIN obs pitc
        ON pitc.person_id = tr.person_id
        AND pitc.encounter_id = tr.encounter_id
        AND pitc.concept_id = 4228
        AND pitc.value_coded = 4226
        AND pitc.voided = 0

    -- Require Mode of Entry selected in same encounter
    JOIN obs moe
        ON moe.person_id = tr.person_id
        AND moe.encounter_id = tr.encounter_id
        AND moe.concept_id = 4238
        AND moe.value_coded IS NOT NULL
        AND moe.voided = 0

    -- Latest Testing History per patient
    JOIN (
        SELECT o.person_id,
               IF(o.value_coded = 2146, 'Repeat', 'New') AS Testing_History
        FROM obs o
        INNER JOIN (
            SELECT person_id, MAX(obs_datetime) AS latest_date
            FROM obs
            WHERE concept_id = 4798
              AND voided = 0
            AND obs_datetime >= CAST('#startDate#' AS DATE) AND obs_datetime < DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL 1 DAY)
          
            GROUP BY person_id
        ) latest
            ON latest.person_id = o.person_id
           AND latest.latest_date = o.obs_datetime
        WHERE o.concept_id = 4798
          AND o.voided = 0
    ) th 
        ON th.person_id = p.person_id

    WHERE p.voided = 0
) q
ORDER BY
    CASE
        WHEN q.AgeGroup = 'Under 1yr' THEN 0
        WHEN q.AgeGroup = '1-4yrs' THEN 1
        WHEN q.AgeGroup = '5-9yrs' THEN 2
        WHEN q.AgeGroup = '10-14yrs' THEN 3
        WHEN q.AgeGroup = '15-19yrs' THEN 4
        WHEN q.AgeGroup = '20-24yrs' THEN 5
        WHEN q.AgeGroup = '25-29yrs' THEN 6
        WHEN q.AgeGroup = '30-34yrs' THEN 7
        WHEN q.AgeGroup = '35-39yrs' THEN 8
        WHEN q.AgeGroup = '40-44yrs' THEN 9
        WHEN q.AgeGroup = '45-49yrs' THEN 10
        WHEN q.AgeGroup = '50+' THEN 11
        WHEN q.AgeGroup = 'Total' THEN 99
        ELSE 98
    END,
    q.Sex;
