SELECT 
    p.Patient_Identifier,
    p.ART_Number,
    p.File_Number,
    p.Patient_Name,
    p.Age,
    p.DOB,
    p.Gender,
    p.age_group,
    p.Program_Status,
    r.regimen_name,
    e.encounter_date,
    e.follow_up,
    d.drug_duration,
    i.intake_regimen,
    s.ART_Start,
    bv.Blood_drawn,
    bv.VL_result,
    t.TB_Status
FROM
(
    /* =========================
       BASE + PROGRAM STATUS
    ========================== */
    SELECT 
        base.*,

        CASE
            WHEN base.initiated_this_month = 1 THEN 'Initiated'
            WHEN base.seen_this_month = 1 THEN 'Seen'
            WHEN base.seen_this_month = 0
                AND base.latest_follow_up >= '#endDate#'
                AND base.latest_follow_up IS NOT NULL
            THEN 'Seen_Prev_Months'
            WHEN base.days_missed BETWEEN 1 AND 28 THEN 'MissedWithin28Days'
            WHEN base.days_missed BETWEEN 29 AND 89 THEN 'Defaulted'
            WHEN base.days_missed >= 90 THEN 'LTFU'
            ELSE NULL
        END AS Program_Status

    FROM
    (
        SELECT 
            patient.patient_id AS Id,

            pid.identifier AS Patient_Identifier,
            art.identifier AS ART_Number,
            file.identifier AS File_Number,
            CONCAT(pn.given_name, ' ', pn.family_name) AS Patient_Name,

            TIMESTAMPDIFF(YEAR, person.birthdate, '#endDate#') AS Age,
            person.birthdate AS DOB,
            person.gender AS Gender,
            ag.name AS age_group,

            /* FLAGS */
            MAX(CASE 
                WHEN o_init.value_datetime >= DATE_FORMAT('#endDate#','%Y-%m-01')
                AND o_init.value_datetime < DATE_ADD(DATE_FORMAT('#endDate#','%Y-%m-01'), INTERVAL 1 MONTH)
                THEN 1 ELSE 0 END) AS initiated_this_month,

            MAX(CASE 
                WHEN o_seen.obs_datetime >= DATE_FORMAT('#endDate#','%Y-%m-01')
                AND o_seen.obs_datetime < DATE_ADD(DATE_FORMAT('#endDate#','%Y-%m-01'), INTERVAL 1 MONTH)
                THEN 1 ELSE 0 END) AS seen_this_month,

            fu.latest_follow_up,
            DATEDIFF('#endDate#', fu.latest_follow_up) AS days_missed

        FROM patient

        INNER JOIN person 
            ON person.person_id = patient.patient_id AND person.voided = 0

        INNER JOIN person_name pn 
            ON pn.person_id = person.person_id AND pn.preferred = 1

        INNER JOIN patient_identifier pid 
            ON pid.patient_id = patient.patient_id 
            AND pid.identifier_type = 3 
            AND pid.preferred = 1

        LEFT JOIN patient_identifier art 
            ON art.patient_id = patient.patient_id AND art.identifier_type in (5,12)

        LEFT JOIN patient_identifier file 
            ON file.patient_id = patient.patient_id AND file.identifier_type = 11

        INNER JOIN reporting_age_group ag
            ON '#endDate#' BETWEEN 
               DATE_ADD(person.birthdate, INTERVAL ag.min_years YEAR)
               AND DATE_ADD(person.birthdate, INTERVAL ag.max_years YEAR)
            AND ag.report_group_name = 'Modified_Ages'

        /* INITIATION */
        LEFT JOIN obs o_init 
            ON o_init.person_id = patient.patient_id
            AND o_init.concept_id = 2249
            AND o_init.voided = 0

        /* SEEN */
        LEFT JOIN obs o_seen
            ON o_seen.person_id = patient.patient_id
            AND o_seen.concept_id = 3843
            AND o_seen.value_coded IN (3841,3842)
            AND o_seen.voided = 0

        /* FOLLOW-UP */
        LEFT JOIN (
            SELECT person_id,
                   MAX(value_datetime) AS latest_follow_up
            FROM obs
            WHERE concept_id = 3752
            AND voided = 0
            AND obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)
            GROUP BY person_id
        ) fu ON fu.person_id = patient.patient_id

        WHERE patient.voided = 0

        /*Patient Must Either be initiated on ART, have ART Regimen or have an ART Follow up*/  
        AND EXISTS (
            SELECT 1
            FROM obs o
            WHERE o.person_id = patient.patient_id
            AND o.concept_id IN (2249,2403)
            AND o.voided = 0
            AND o.obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)
        )

        /* 🚫 EXCLUDE DEAD */
        AND NOT EXISTS (
            SELECT 1
            FROM person pd
            WHERE pd.person_id = patient.patient_id
            AND pd.dead = 1
            AND pd.death_date <= '#endDate#'
        )

        /* 🚫 EXCLUDE TRANSFER OUT */
        AND NOT (
        /* Patient has transfer out */
            EXISTS (
                SELECT 1
                FROM obs o_to
                WHERE o_to.person_id = patient.patient_id
                AND o_to.concept_id IN (2266,2398)
                AND o_to.voided = 0
                AND o_to.obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)
            )

            /* BUT has NO valid follow-up after transfer-out */
            AND NOT EXISTS (
                SELECT 1
                FROM obs o_fu
                WHERE o_fu.person_id = patient.patient_id
                AND o_fu.concept_id = 3752   -- follow-up date
                AND o_fu.voided = 0
    
                /* ✅ CORE FIX */
                AND o_fu.value_datetime > (
                    SELECT MAX(COALESCE(o2.obs_datetime, o2.value_datetime)) 
                    -- MAX(o2.obs_datetime)
                    FROM obs o2
                    WHERE o2.person_id = patient.patient_id
                    AND o2.concept_id IN (2266,2398)
                    AND o2.voided = 0
                )

                AND o_fu.obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)
            )
        )

        GROUP BY patient.patient_id
    ) base
) p

/* =========================
   FULL REGIMEN MAPPING
========================= */
LEFT JOIN (
    SELECT person_id,
           CASE 
                WHEN regimen = 4714 THEN "1a"
                WHEN regimen = 4715 THEN "1b"
                WHEN regimen = 2201 THEN '1c'
                WHEN regimen = 2203 THEN '1d'
                WHEN regimen = 2205 THEN '1e'
                WHEN regimen = 2207 THEN '1f'
                WHEN regimen = 3672 THEN '1g'
                WHEN regimen = 3673 THEN '1h'
                WHEN regimen = 4678 THEN '1j'
                WHEN regimen = 4679 THEN '1k'
                WHEN regimen = 4680 THEN '1m'
                WHEN regimen = 4681 THEN '1n'
                WHEN regimen = 4682 THEN '1p'
                WHEN regimen = 4683 THEN '1q'
                WHEN regimen = 2143 THEN 'other'
                WHEN regimen = 2210 THEN '2c'
                WHEN regimen = 2209 THEN '2d'
                WHEN regimen = 3674 THEN '2e'
                WHEN regimen = 3675 THEN '2f'
                WHEN regimen = 3676 THEN '2g'
                WHEN regimen = 3677 THEN '2h'
                WHEN regimen = 3678 THEN '2i'
                WHEN regimen = 4689 THEN '2j'
                WHEN regimen = 4690 THEN '2k'
                WHEN regimen = 4691 THEN '2L'
                WHEN regimen = 4692 THEN '2m'
                WHEN regimen = 4693 THEN '2n'
                WHEN regimen = 4694 THEN '2o'
                WHEN regimen = 4695 THEN '2p'
                WHEN regimen = 4849 THEN '2q'
                WHEN regimen = 4850 THEN '2r'
                WHEN regimen = 4851 THEN '2s'
                WHEN regimen = 3683 THEN '3a'
                WHEN regimen = 3684 THEN '3b'
                WHEN regimen = 3685 THEN '3c'
                WHEN regimen = 4706 THEN '3d'
                WHEN regimen = 4707 THEN '3e'
                WHEN regimen = 4708 THEN '3f'
                WHEN regimen = 4709 THEN '3g'
                WHEN regimen = 4710 THEN '3h'
                WHEN regimen = 2202 THEN "4c"
                WHEN regimen = 2204 THEN "4d"
                WHEN regimen = 3679 THEN "4e"
                WHEN regimen = 3680 THEN "4f"
                WHEN regimen = 4684 THEN "4g"
                WHEN regimen = 4685 THEN "4h"
                WHEN regimen = 4686 THEN "4j"
                WHEN regimen = 4687 THEN "4k"
                WHEN regimen = 4688 THEN "4L"
                WHEN regimen = 3681 THEN "5a"
                WHEN regimen = 3682 THEN "5b"
                WHEN regimen = 4696 THEN "5c"
                WHEN regimen = 4697 THEN "5d"
                WHEN regimen = 4698 THEN "5e"
                WHEN regimen = 4699 THEN "5f"
                WHEN regimen = 4700 THEN "5g"
                WHEN regimen = 4701 THEN "5h"
                WHEN regimen = 3686 THEN "6a"
                WHEN regimen = 3687 THEN "6b"
                WHEN regimen = 4702 THEN "6c"
                WHEN regimen = 4703 THEN "6d"
                WHEN regimen = 4704 THEN "6e"
                WHEN regimen = 4705 THEN "6f"
                
                ELSE 'New Regimen'
           END AS regimen_name
    FROM (
        SELECT person_id,
               SUBSTRING(MAX(CONCAT(obs_datetime, value_coded)),20) AS regimen
        FROM obs
        WHERE concept_id = 2250
        AND voided = 0
        AND obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)
        GROUP BY person_id
    ) latest_reg
) r ON p.Id = r.person_id

/* =========================
   ENCOUNTER
========================= */

LEFT JOIN (
    SELECT 
        latest.person_id,
        DATE(latest.max_obs_date) AS encounter_date,
        DATE(latest.latest_follow_up) AS follow_up

    FROM (
        SELECT 
            a.person_id,

            /* latest encounter */
            MAX(a.obs_datetime) AS max_obs_date,

            /* linked follow-up from same obs group */
            SUBSTRING_INDEX(
                MAX(CONCAT(a.obs_datetime, '|', b.value_datetime)),
                '|',
                -1
            ) AS latest_follow_up

        FROM obs a

        INNER JOIN obs b
            ON a.obs_id = b.obs_group_id
            AND b.concept_id = 3752
            AND b.voided = 0

        WHERE a.concept_id IN (3753,6515,2397)  /* encounter types */
        AND a.voided = 0
        AND a.obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)

        GROUP BY a.person_id
    ) latest
) e ON p.Id = e.person_id

/* =========================
   DRUG DURATION
========================= */
LEFT JOIN (
    SELECT 
        x.person_id,

        CASE
            WHEN x.days_diff >= 10  AND x.days_diff < 28  THEN '2 weeks'
            WHEN x.days_diff >= 28  AND x.days_diff < 56  THEN '1 month'
            WHEN x.days_diff >= 56  AND x.days_diff < 84  THEN '2 months'
            WHEN x.days_diff >= 84  AND x.days_diff < 112 THEN '3 months'
            WHEN x.days_diff >= 112 AND x.days_diff < 140 THEN '4 months'
            WHEN x.days_diff >= 140 AND x.days_diff < 168 THEN '5 months'
            WHEN x.days_diff >= 168 AND x.days_diff < 196 THEN '6 months'
            WHEN x.days_diff >= 196 AND x.days_diff < 224 THEN '7 months'
            WHEN x.days_diff >= 224 AND x.days_diff < 252 THEN '8 months'
            WHEN x.days_diff >= 252 AND x.days_diff < 280 THEN '9 months'
            WHEN x.days_diff >= 280 AND x.days_diff < 308 THEN '10 months'
            WHEN x.days_diff >= 308 AND x.days_diff < 336 THEN '11 months'
            WHEN x.days_diff >= 336 AND x.days_diff < 364 THEN '12 months'
            WHEN x.days_diff >= 364 THEN '>1year'
            ELSE 'Other supply'
        END AS drug_duration

    FROM (
        /* =========================
           GET LATEST DISPENSING EVENT
        ========================== */
        SELECT 
            latest.person_id,

            /* difference between next appointment and encounter */
            DATEDIFF(latest.latest_follow_up, latest.max_obs_date) AS days_diff

        FROM (
            SELECT 
                a.person_id,

                /* latest encounter date */
                MAX(a.obs_datetime) AS max_obs_date,

                /* latest follow-up date (linked correctly via obs_group_id) */
                SUBSTRING(
                    MAX(CONCAT(a.obs_datetime, b.value_datetime)), 
                    20
                ) AS latest_follow_up

            FROM obs a
            INNER JOIN obs b 
                ON a.obs_id = b.obs_group_id

            WHERE 
                a.concept_id in (3753,6515)   /* encounter */
                AND b.concept_id = 3752  /* next appointment */
                AND a.voided = 0
                AND b.voided = 0
                AND a.obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)

            GROUP BY a.person_id
        ) latest
    ) x
) d ON p.Id = d.person_id

/*
=========================
   INTAKE REGIMEN
=========================
*/
LEFT JOIN (
    SELECT 
        init.person_id,

        CASE
            WHEN reg.value_coded = 2201 THEN '1c'
            WHEN reg.value_coded = 2203 THEN '1d'
            WHEN reg.value_coded = 2205 THEN '1e'
            WHEN reg.value_coded = 2207 THEN '1f'
            WHEN reg.value_coded = 3672 THEN '1g'
            WHEN reg.value_coded = 3673 THEN '1h'
            WHEN reg.value_coded = 4678 THEN '1j'
            WHEN reg.value_coded = 4679 THEN '1k'
            WHEN reg.value_coded = 4680 THEN '1m'
            WHEN reg.value_coded = 4681 THEN '1n'
            WHEN reg.value_coded = 4682 THEN '1p'
            WHEN reg.value_coded = 4683 THEN '1q'
            WHEN reg.value_coded = 2143 THEN 'other'
            WHEN reg.value_coded = 2210 THEN '2c'
            WHEN reg.value_coded = 2209 THEN '2d'
            WHEN reg.value_coded = 3674 THEN '2e'
            WHEN reg.value_coded = 3675 THEN '2f'
            WHEN reg.value_coded = 3676 THEN '2g'
            WHEN reg.value_coded = 3677 THEN '2h'
            WHEN reg.value_coded = 3678 THEN '2i'
            WHEN reg.value_coded = 4689 THEN '2j'
            WHEN reg.value_coded = 4690 THEN '2k'
            WHEN reg.value_coded = 4691 THEN '2L'
            WHEN reg.value_coded = 4692 THEN '2m'
            WHEN reg.value_coded = 4693 THEN '2n'
            WHEN reg.value_coded = 4694 THEN '2o'
            WHEN reg.value_coded = 4695 THEN '2p'
            WHEN reg.value_coded = 4849 THEN '2q'
            WHEN reg.value_coded = 4850 THEN '2r'
            WHEN reg.value_coded = 4851 THEN '2s'
            WHEN reg.value_coded = 3683 THEN '3a'
            WHEN reg.value_coded = 3684 THEN '3b'
            WHEN reg.value_coded = 3685 THEN '3c'
            WHEN reg.value_coded = 4706 THEN '3d'
            WHEN reg.value_coded = 4707 THEN '3e'
            WHEN reg.value_coded = 4708 THEN '3f'
            WHEN reg.value_coded = 4709 THEN '3g'
            WHEN reg.value_coded = 4710 THEN '3h'
            WHEN reg.value_coded = 2202 THEN '4c'
            WHEN reg.value_coded = 2204 THEN '4d'
            WHEN reg.value_coded = 3679 THEN '4e'
            WHEN reg.value_coded = 3680 THEN '4f'
            WHEN reg.value_coded = 4684 THEN '4g'
            WHEN reg.value_coded = 4685 THEN '4h'
            WHEN reg.value_coded = 4686 THEN '4j'
            WHEN reg.value_coded = 4687 THEN '4k'
            WHEN reg.value_coded = 4688 THEN '4L'
            WHEN reg.value_coded = 3681 THEN '5a'
            WHEN reg.value_coded = 3682 THEN '5b'
            WHEN reg.value_coded = 4696 THEN '5c'
            WHEN reg.value_coded = 4697 THEN '5d'
            WHEN reg.value_coded = 4698 THEN '5e'
            WHEN reg.value_coded = 4699 THEN '5f'
            WHEN reg.value_coded = 4700 THEN '5g'
            WHEN reg.value_coded = 4701 THEN '5h'
            WHEN reg.value_coded = 3686 THEN '6a'
            WHEN reg.value_coded = 3687 THEN '6b'
            WHEN reg.value_coded = 4702 THEN '6c'
            WHEN reg.value_coded = 4703 THEN '6d'
            WHEN reg.value_coded = 4704 THEN '6e'
            WHEN reg.value_coded = 4705 THEN '6f'
            WHEN reg.value_coded = 4714 THEN '1a'
            WHEN reg.value_coded = 4715 THEN '1b'
            ELSE 'New Regimen'
        END AS intake_regimen

    FROM (
        /* ART START */
        SELECT person_id, value_datetime AS art_start
        FROM obs
        WHERE concept_id = 2249
        AND voided = 0
        GROUP BY person_id
    ) init

    LEFT JOIN obs reg
        ON reg.person_id = init.person_id
        AND reg.concept_id = 2250
        AND reg.voided = 0

        /* 👇 pick regimen CLOSEST to ART start */
        AND reg.obs_datetime = (
            SELECT MIN(o2.obs_datetime)
            FROM obs o2
            WHERE o2.person_id = init.person_id
            AND o2.concept_id = 2250
            AND o2.voided = 0
            AND o2.obs_datetime >= init.art_start
        )
) i ON p.Id = i.person_id

/* 
=========================
   ART START
========================= 
*/
LEFT JOIN (
    SELECT person_id, DATE(value_datetime) AS ART_Start
    FROM obs
    WHERE concept_id = 2249 AND voided = 0
    GROUP BY person_id
) s ON p.Id = s.person_id

/* 
=========================================
   BLOOD DRAWN + VIRAL LOAD (OPTIMIZED)
========================================= 
*/
LEFT JOIN (
    SELECT 
        vl.person_id,

        /* Blood Drawn */
        MAX(CASE 
            WHEN vl.concept_id IN (4267,5494) 
            THEN DATE(vl.obs_datetime) 
        END) AS Blood_drawn,

        /* Viral Load Result */
        SUBSTRING(
            MAX(
                CASE 
                    WHEN vl.concept_id IN (2254,5485,5489,4266)
                    AND vl.obs_datetime >= IFNULL(bd.blood_date, '1900-01-01')
                    THEN CONCAT(
                        vl.obs_datetime,
                        ' ',
                        CASE 
                            WHEN vl.concept_id = 2254 THEN 
                                CASE 
                                    WHEN vl.value_numeric < 20 THEN 'Less than 20 copies/ml'
                                    ELSE CONCAT(vl.value_numeric,' copies/ml')
                                END
                            WHEN vl.concept_id = 5485 THEN 
                                CONCAT(vl.value_numeric,' copies/ml')
                            WHEN vl.concept_id = 5489 THEN 'LDL'
                            WHEN vl.concept_id = 4266 THEN
                                CASE 
                                    WHEN vl.value_coded = 4263 THEN 'Undetectable'
                                    WHEN vl.value_coded = 4264 THEN 'Greater or Equal to 20 copies/ml'
                                    WHEN vl.value_coded = 4265 THEN 'Less than 20 copies/ml'
                                    ELSE CONCAT(vl.value_numeric,' copies/ml')
                                END
                        END
                    )
                END
            ), 
        20) AS VL_result

    FROM obs vl

    /* 🔗 Precompute Blood Drawn once */
    LEFT JOIN (
        SELECT person_id, MAX(obs_datetime) AS blood_date
        FROM obs
        WHERE concept_id IN (4267,5494)
        AND voided = 0
        AND obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)
        GROUP BY person_id
    ) bd ON bd.person_id = vl.person_id

    WHERE vl.voided = 0
    AND vl.obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)
    AND vl.concept_id IN (4267,5494,2254,5485,5489,4266)

    GROUP BY vl.person_id

) bv ON p.Id = bv.person_id

/* =========================
   TB STATUS
========================= */
LEFT JOIN (
    SELECT person_id,
           CASE 
               WHEN value_coded = 3709 THEN 'No Signs'
               WHEN value_coded = 1876 THEN 'Suspected'
               WHEN value_coded = 3639 THEN 'On TB Treatment'
           END AS TB_Status
    FROM (
        SELECT person_id,
               SUBSTRING(MAX(CONCAT(obs_datetime, value_coded)),20) AS value_coded
        FROM obs
        WHERE concept_id = 3710
        AND voided = 0
        AND obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)
        GROUP BY person_id
    ) tb
) t ON p.Id = t.person_id;
