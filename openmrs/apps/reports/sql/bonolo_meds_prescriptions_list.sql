-- Main query to get patient names and their latest ART encounter information
SELECT 

    -- Combine first and last name to create full patient name
    CONCAT(pn.given_name, ' ', pn.family_name) AS "Patient Name",

    -- Subquery to get the patient's HIV program ID
    (
        SELECT identifier
        FROM patient_identifier pi
        WHERE pi.patient_id = pn.person_id
            AND pi.identifier_type = 5  -- HIV program ID type
        LIMIT 1
    ) AS "HIV Program ID",

     -- Subquery to get the most recent HIV diagnosis date from intake form (concept 2249)
    (
        -- Select the diagnosis date (converted from datetime to just date)
        SELECT DATE(o2.value_datetime) 
        FROM obs o2 
        WHERE o2.person_id = pn.person_id           -- Match current patient
            AND o2.concept_id = 2249                 -- HIV diagnosis date concept
            AND o2.obs_datetime = (                  -- Only get the most recent one using MAX
                SELECT MAX(o3.obs_datetime)          -- Find the latest observation datetime
                FROM obs o3
                WHERE o3.person_id = pn.person_id    -- For this same patient
                    AND o3.concept_id = 2249          -- HIV diagnosis date concept
            )
        LIMIT 1                                       -- Just in case of ties, take one
    ) AS "HIV Diagnosis Date",
    

    -- Subquery to get the type of visit (New, Repeat or Restarted) from the latest ART encounter
    (
        -- Get the readable name from concept_name table for the coded value
        SELECT cn.name
        FROM obs o4

        -- Join with concept_name to convert value_coded to readable text
        INNER JOIN concept_name cn ON o4.value_coded = cn.concept_id 
            
        -- Filter to the specific encounter and concept
        WHERE o4.encounter_id = latest_art.encounter_id  -- From our latest ART encounter
            AND o4.concept_id = 4538                   -- Type of visit concept
        LIMIT 1                                         -- Get just one value
    ) AS "New or Revisit",

    DATE(latest_art.obs_datetime) AS "Prescription Date",  -- Convert datetime to just date for display

    -- Subquery to get the regimen prescribed from the latest ART encounter
    (
        -- Get the readable name from concept_name table for the coded value
        SELECT cn.name
        FROM obs o4
        INNER JOIN concept_name cn ON o4.value_coded = cn.concept_id 
        AND cn.locale_preferred = 1  -- Ensure we get the preferred name in the default locale
        WHERE o4.encounter_id = latest_art.encounter_id  -- From latest ART encounter
            AND o4.concept_id = 2250                   -- Regimen prescribed concept (stores a concept ID)
        LIMIT 1                                         -- Get just one value
    ) AS "Regimen Prescribed",

    -- Subquery to get the next clinical appointment date from the latest ART encounter
    (
        -- Select the next appointment date (converted from datetime to just date)
        SELECT DATE(o2.value_datetime) 
        FROM obs o2 
        WHERE o2.encounter_id = latest_art.encounter_id  -- From latest ART encounter
            AND o2.concept_id = 3752                   -- Next clinical appointment date concept
        LIMIT 1                                         -- Just in case of ties, take one
    ) AS "Next Clinical Appointment Date",

    -- Subquery to get the next drug pickup date from the latest ART encounter
    (
        -- Select the next drug pickup date (converted from datetime to just date)
        SELECT DATE(o2.value_datetime) 
        FROM obs o2 
        WHERE o2.encounter_id = latest_art.encounter_id  -- From latest ART encounter
            AND o2.concept_id = 6567                   -- Next drug pickup date concept
        LIMIT 1                                         -- Just in case of ties, take one
    ) AS "Next Drug Pickup Date",

    -- Subquery to select the drug pickup point from the latest ART encounter
    (
        -- Get the readable name from concept_name table for the coded value
        SELECT cn.name
        FROM obs o4
        INNER JOIN concept_name cn ON o4.value_coded = cn.concept_id 
                      
        WHERE o4.encounter_id = latest_art.encounter_id  -- From latest ART encounter
            AND o4.concept_id = 6511                   -- Drug pickup point concept (stores a concept ID)
        LIMIT 1                                         -- Get just one value
    ) AS "Drug Pickup Point",

    -- Subquery to get E-locker district from the latest ART encounter
    (
        -- Get the readable name from concept_name table for the coded value
        SELECT cn.name
        FROM obs o4
        INNER JOIN concept_name cn ON o4.value_coded = cn.concept_id 
                   
        WHERE o4.encounter_id = latest_art.encounter_id  -- From latest ART encounter
            AND o4.concept_id = 6510                   -- E-locker district concept (stores a concept ID)
        LIMIT 1                                         -- Get just one value
    ) AS "E-locker District",

    -- Subquery to get the latest VL collection date
    (
        SELECT DATE(o5.value_datetime)
        FROM obs o5
        WHERE o5.person_id = pn.person_id
            AND o5.concept_id = 5494           -- VL collection date concept
            AND o5.voided = 0
        ORDER BY o5.obs_datetime DESC, o5.date_created DESC
        LIMIT 1
    ) AS "Latest VL Collection Date",

    -- Subquery to get the latest VL result (concept 4266)
    (
        SELECT cn.name
        FROM obs o6
        INNER JOIN concept_name cn ON o6.value_coded = cn.concept_id
        WHERE o6.person_id = pn.person_id
            AND o6.concept_id = 4266           -- VL result concept
            AND o6.voided = 0
        ORDER BY o6.obs_datetime DESC, o6.date_created DESC
        LIMIT 1
    ) AS "Latest VL Result",

    -- Subquery to get if patient has allergies
    (
        -- Get the readable name from concept_name table for the coded value
        SELECT cn.name
        FROM obs o4
        INNER JOIN concept_name cn ON o4.value_coded = cn.concept_id 
        WHERE o4.person_id = pn.person_id           -- Match current patient
            AND o4.concept_id = 5591                 -- Allergy concept
            AND o4.voided = 0
        LIMIT 1                                         -- Just in case of multiple allergies, take one
    ) AS "Has Allergies",

    -- Subquery to get specific allergies if any
    (
        SELECT o4.value_text
        FROM obs o4
        WHERE o4.person_id = pn.person_id           -- Match current patient
            AND o4.concept_id = 5592                 -- Allergy concept
            AND o4.voided = 0
        LIMIT 1                                         -- Just in case of multiple allergies, take one
    ) AS "Allergies",

    -- Add provider name column
    prov.name AS "Prescriber Name",

    -- Subquery to get primary contact
    (
        SELECT value 
        FROM person_attribute pa 
        WHERE pa.person_id = pn.person_id 
            AND pa.person_attribute_type_id = 26
        LIMIT 1
    ) AS "Primary Contact",

    -- Subquery to get secondary contact
    (
        SELECT value 
        FROM person_attribute pa 
        WHERE pa.person_id = pn.person_id 
            AND pa.person_attribute_type_id = 15
        LIMIT 1
    ) AS "Secondary Contact",

    -- Subquery to get the gender of the patient
    (
        SELECT value
        FROM person_attribute pa 
        WHERE pa.person_id = pn.person_id 
            AND pa.person_attribute_type_id = 33
        LIMIT 1
    ) AS "Gender",

    -- Subquery to get the DOB of the patient
    (
        SELECT birthdate
        FROM person p 
        WHERE p.person_id = pn.person_id
        LIMIT 1
    ) AS "DOB",

    -- Subquery to the address of the patient
    (
        SELECT CONCAT(city_village, ', ', address2, ', ', state_province)
        FROM person_address pa
            WHERE pa.person_id = pn.person_id 
            AND pa.preferred = 1
        LIMIT 1
    ) AS "Address",

    -- Select the name of the location where the ART encounter took place
    parent_loc.name AS "Location"

-- Main table: person_name (contains patient names)
FROM 
    person_name pn
    
    -- INNER JOIN with a subquery that finds the latest ART encounter for each patient
    INNER JOIN (
        -- Subquery to get the latest ART encounter (concept 6491 with value 2146)
        SELECT o1.person_id, o1.encounter_id, o1.obs_datetime
        FROM obs o1
        -- INNER JOIN with another subquery that finds the MAX date for each patient
        INNER JOIN (
            -- Find the most recent observation datetime for each patient
            SELECT person_id, MAX(obs_datetime) AS max_datetime
            FROM obs
            WHERE concept_id = 6491                    -- ART form concept
                AND value_coded = 2146                  -- Specific value we're looking for
                AND obs_datetime >= CAST('#startDate#' AS DATE)  -- Start date filter
                AND obs_datetime < CAST('#endDate#' AS DATE)     -- End date filter
            GROUP BY person_id                          -- Get max per patient
        ) latest ON o1.person_id = latest.person_id    -- Join back to get full record
                AND o1.obs_datetime = latest.max_datetime  -- Match the max datetime
        WHERE o1.concept_id = 6491                     -- Ensure it's the right concept
            AND o1.value_coded = 2146                   -- Ensure it's the right value
    ) latest_art ON pn.person_id = latest_art.person_id  -- Connect to patient names

     -- Join to get provider information
    LEFT JOIN encounter_provider ep ON latest_art.encounter_id = ep.encounter_id
    LEFT JOIN provider prov ON ep.provider_id = prov.provider_id

    -- Join to get location information
    LEFT JOIN encounter e ON latest_art.encounter_id = e.encounter_id
    LEFT JOIN location loc ON e.location_id = loc.location_id
    LEFT JOIN location parent_loc ON loc.parent_location = parent_loc.location_id


-- Order results by the date of the ART encounter
ORDER BY 
    latest_art.obs_datetime DESC;