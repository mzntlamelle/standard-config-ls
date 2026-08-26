import org.apache.commons.lang.StringUtils
import org.hibernate.Query
import org.hibernate.SessionFactory;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.Concept;
import org.openmrs.Encounter;
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniObservation
import org.openmrs.util.OpenmrsUtil;
import org.openmrs.api.context.Context;
import org.openmrs.module.bahmniemrapi.obscalculator.ObsValueCalculator;
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniEncounterTransaction
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction;
import org.openmrs.util.LocaleUtility;

import org.joda.time.LocalDate;
import org.joda.time.Months;
import org.joda.time.Days;

public class BahmniObsValueCalculator implements ObsValueCalculator {

    static Double BMI_VERY_SEVERELY_UNDERWEIGHT = 16.0;
    static Double BMI_SEVERELY_UNDERWEIGHT = 17.0;
    static Double BMI_UNDERWEIGHT = 18.5;
    static Double BMI_NORMAL = 25.0;
    static Double BMI_OVERWEIGHT = 30.0;
    static Double BMI_OBESE = 35.0;
    static Double BMI_SEVERELY_OBESE = 40.0;
    static Double ZERO = 0.0;
    static Map<BahmniObservation, BahmniObservation> obsParentMap = new HashMap<BahmniObservation, BahmniObservation>();

    public static enum BmiStatus {
        VERY_SEVERELY_UNDERWEIGHT("Very Severely Underweight"),
        SEVERELY_UNDERWEIGHT("Severely Underweight"),
        UNDERWEIGHT("Underweight"),
        NORMAL("Normal"),
        OVERWEIGHT("Overweight"),
        OBESE("Obese"),
        SEVERELY_OBESE("Severely Obese"),
        VERY_SEVERELY_OBESE("Very Severely Obese");

        private String status;

        BmiStatus(String status) {
            this.status = status
        }

        @Override
        public String toString() {
            return status;
        }
    }


    public void run(BahmniEncounterTransaction bahmniEncounterTransaction) {
        calculateAndAdd(bahmniEncounterTransaction);
        createFollowUpAppointment(bahmniEncounterTransaction);
    }

    static def calculateAndAdd(BahmniEncounterTransaction bahmniEncounterTransaction) {
        Collection<BahmniObservation> observations = bahmniEncounterTransaction.getObservations()

        // ART Adherence calculator (server-side port of adherenceCalculatorOne.js).
        // Handles its own concepts and returns; non-adherence encounters fall through to BMI etc.
        if (calculateAdherence(bahmniEncounterTransaction, observations)) {
            return
        }

        def nowAsOfEncounter = bahmniEncounterTransaction.getEncounterDateTime() != null ? bahmniEncounterTransaction.getEncounterDateTime() : new Date();

        BahmniObservation heightObservation = find("Height", observations, null)
        BahmniObservation weightObservation = find("Weight", observations, null)
        BahmniObservation parent = null;

        if (hasValue(heightObservation) || hasValue(weightObservation)) {
            def heightObs = null, weightObs = null;
            Encounter encounter = Context.getEncounterService().getEncounterByUuid(bahmniEncounterTransaction.getEncounterUuid());
            if (encounter != null) {
                Set<Obs> latestObsOfEncounter = encounter.getObsAtTopLevel(true);
                latestObsOfEncounter.each { Obs latestObs ->
                    for (Obs groupMember : latestObs.groupMembers) {
                        heightObs = heightObs ? heightObs : (groupMember.concept.getName().name.equalsIgnoreCase("HEIGHT") ? groupMember : null);
                        weightObs = weightObs ? weightObs : (groupMember.concept.getName().name.equalsIgnoreCase("WEIGHT") ? groupMember : null);
                    }
                }
                if (isSameObs(heightObservation, heightObs) && isSameObs(weightObservation, weightObs)) {
                    return;
                }
            }


            BahmniObservation bmiDataObservation = find("BMI Data", observations, null)
            BahmniObservation bmiObservation = find("BMI", bmiDataObservation ? [bmiDataObservation] : [], null)
            BahmniObservation bmiAbnormalObservation = find("BMI Abnormal", bmiDataObservation ? [bmiDataObservation]: [], null)

            BahmniObservation bmiStatusDataObservation = find("BMI Status Data", observations, null)
            BahmniObservation bmiStatusObservation = find("BMI Status", bmiStatusDataObservation ? [bmiStatusDataObservation] : [], null)
            BahmniObservation bmiStatusAbnormalObservation = find("BMI Status Abnormal", bmiStatusDataObservation ? [bmiStatusDataObservation]: [], null)

            Patient patient = Context.getPatientService().getPatientByUuid(bahmniEncounterTransaction.getPatientUuid())
            def patientAgeInMonthsAsOfEncounter = Months.monthsBetween(new LocalDate(patient.getBirthdate()), new LocalDate(nowAsOfEncounter)).getMonths()

            parent = obsParent(heightObservation, parent)
            parent = obsParent(weightObservation, parent)

            if ((heightObservation && heightObservation.voided) && (weightObservation && weightObservation.voided)) {
                voidObs(bmiDataObservation);
                voidObs(bmiObservation);
                voidObs(bmiStatusDataObservation);
                voidObs(bmiStatusObservation);
                voidObs(bmiAbnormalObservation);
                return
            }

            def previousHeightValue = fetchLatestValue("Height", bahmniEncounterTransaction.getPatientUuid(), heightObservation, nowAsOfEncounter)
            def previousWeightValue = fetchLatestValue("Weight", bahmniEncounterTransaction.getPatientUuid(), weightObservation, nowAsOfEncounter)

            Double height = hasValue(heightObservation) && !heightObservation.voided ? heightObservation.getValue() as Double : previousHeightValue
            Double weight = hasValue(weightObservation) && !weightObservation.voided ? weightObservation.getValue() as Double : previousWeightValue
            Date obsDatetime = getDate(weightObservation) != null ? getDate(weightObservation) : getDate(heightObservation)

            if (height == null || weight == null) {
                voidObs(bmiDataObservation)
                voidObs(bmiObservation)
                voidObs(bmiStatusDataObservation)
                voidObs(bmiStatusObservation)
                voidObs(bmiAbnormalObservation)
                return
            }

            if(encounter != null) {
                voidPreviousBMIObs(encounter.getObsAtTopLevel(false));
                voidPreviousBMIObs(encounter.getObs());
            }

            bmiDataObservation = bmiDataObservation ?: createObs("BMI Data", null, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
            bmiStatusDataObservation = bmiStatusDataObservation ?: createObs("BMI Status Data", null, bahmniEncounterTransaction, obsDatetime) as BahmniObservation

            def bmi = bmi(height, weight)
            bmiObservation = bmiObservation ?: createObs("BMI", bmiDataObservation, bahmniEncounterTransaction, obsDatetime) as BahmniObservation;
            bmiObservation.setValue(bmi);

            def bmiStatus = bmiStatus(bmi, patientAgeInMonthsAsOfEncounter, patient.getGender());
            bmiStatusObservation = bmiStatusObservation ?: createObs("BMI Status", bmiStatusDataObservation, bahmniEncounterTransaction, obsDatetime) as BahmniObservation;
            bmiStatusObservation.setValue(bmiStatus);

            def bmiAbnormal = bmiAbnormal(bmiStatus);
            bmiAbnormalObservation =  bmiAbnormalObservation ?: createObs("BMI Abnormal", bmiDataObservation, bahmniEncounterTransaction, obsDatetime) as BahmniObservation;
            bmiAbnormalObservation.setValue(bmiAbnormal);

            bmiStatusAbnormalObservation =  bmiStatusAbnormalObservation ?: createObs("BMI Status Abnormal", bmiStatusDataObservation, bahmniEncounterTransaction, obsDatetime) as BahmniObservation;
            bmiStatusAbnormalObservation.setValue(bmiAbnormal);

            return
        }

        BahmniObservation waistCircumferenceObservation = find("Waist Circumference", observations, null)
        BahmniObservation hipCircumferenceObservation = find("Hip Circumference", observations, null)
        if (hasValue(waistCircumferenceObservation) && hasValue(hipCircumferenceObservation)) {
            def calculatedConceptName = "Waist/Hip Ratio"
            BahmniObservation calculatedObs = find(calculatedConceptName, observations, null)
            parent = obsParent(waistCircumferenceObservation, null)

            Date obsDatetime = getDate(waistCircumferenceObservation)
            def waistCircumference = waistCircumferenceObservation.getValue() as Double
            def hipCircumference = hipCircumferenceObservation.getValue() as Double
            def waistByHipRatio = waistCircumference/hipCircumference
            if (calculatedObs == null)
                calculatedObs = createObs(calculatedConceptName, parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation

            calculatedObs.setValue(waistByHipRatio)
            return
        }

        BahmniObservation lmpObservation = find("Obstetrics, Last Menstrual Period", observations, null)
        def calculatedConceptName = "Estimated Date of Delivery"
        if (hasValue(lmpObservation)) {
            parent = obsParent(lmpObservation, null)
            def calculatedObs = find(calculatedConceptName, observations, null)

            Date obsDatetime = getDate(lmpObservation)

            LocalDate edd = new LocalDate(lmpObservation.getValue()).plusMonths(9).plusWeeks(1)
            if (calculatedObs == null)
                calculatedObs = createObs(calculatedConceptName, parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
            calculatedObs.setValue(edd)
            return
        } else {
            def calculatedObs = find(calculatedConceptName, observations, null)
            if (hasValue(calculatedObs)) {
                voidObs(calculatedObs)
            }
        }
    }

    // ART Adherence (ported from adherenceCalculatorOne.js).
    //   D = Return Date - Dispensed Date
    //   Percentage Adherence = floor(((A - B) / C / D) * 100)
    //   ART Treatment Adherence: <85 || >105 = Poor, 85..94 = Fair, 95..105 = Good
    // Returns true if this encounter was an adherence encounter (so BMI etc. are skipped).
    static boolean calculateAdherence(BahmniEncounterTransaction etx, Collection<BahmniObservation> observations) {
        BahmniObservation dispensedObs = find("HIVTC, Adherence Date ARVs Dispensed", observations, null)
        BahmniObservation returnObs    = find("HIVTC, Adherence Return Date", observations, null)

        BahmniObservation daysObs = find("HIVTC, Adherence Number of Days since refill", observations, null)
        BahmniObservation pctObs  = find("HIVTC, Percentage Adherence", observations, null)
        BahmniObservation adhObs  = find("HIVTC, ART Treatment Adherence", observations, null)

        // Not an adherence encounter -> let the other calculators run.
        if (dispensedObs == null && returnObs == null && daysObs == null && pctObs == null && adhObs == null) {
            return false
        }

        // No usable dates -> clear any previously calculated outputs and stop.
        if (!hasValue(dispensedObs) || !hasValue(returnObs)) {
            voidObs(daysObs); voidObs(pctObs); voidObs(adhObs)
            return true
        }

        BahmniObservation parent = obsParent(dispensedObs, null) ?: obsParent(returnObs, null)
        Date obsDatetime = getDate(dispensedObs) ?: getDate(returnObs)

        LocalDate dispensedDate = toLocalDate(dispensedObs.getValue())
        LocalDate returnDate    = toLocalDate(returnObs.getValue())
        int daysSinceRefill = Days.daysBetween(dispensedDate, returnDate).getDays()

        System.out.println("eReg — Days Since Refill = " + daysSinceRefill + " -----eReg eReg eReg eReg")

        daysObs = daysObs ?: createObs("HIVTC, Adherence Number of Days since refill", parent, etx, obsDatetime) as BahmniObservation
        daysObs.setValue(daysSinceRefill as Double)

        BahmniObservation aObs = find("HIVTC, Adherence Total amount taken home", observations, null) // A
        BahmniObservation bObs = find("HIVTC, Adherence Pill count", observations, null)              // B
        BahmniObservation cObs = find("HIVTC, Adherence Daily ARV Dose", observations, null)          // C

        if (!(hasValue(aObs) && hasValue(bObs) && hasValue(cObs)) || daysSinceRefill == 0) {
            voidObs(pctObs); voidObs(adhObs)
            return true
        }

        double a = aObs.getValue() as Double
        double b = bObs.getValue() as Double
        double c = cObs.getValue() as Double
        double percentage = Math.floor(((a - b) / c / daysSinceRefill) * 100)

        pctObs = pctObs ?: createObs("HIVTC, Percentage Adherence", parent, etx, obsDatetime) as BahmniObservation
        pctObs.setValue(percentage)

        String adherence
        if (percentage < 85 || percentage > 105) {
            adherence = "Poor adherence"
        } else if (percentage >= 85 && percentage < 95) {
            adherence = "Fair adherence"
        } else { // 95..105 inclusive
            adherence = "Good adherence"
        }

        // ART Treatment Adherence is a CODED concept. The emrapi ObsMapper resolves coded values
        // by reading the "uuid" key off a Map, so the value must carry the answer concept's UUID
        // (a plain String would resolve to null and NPE during save).
        adhObs = adhObs ?: createObs("HIVTC, ART Treatment Adherence", parent, etx, obsDatetime) as BahmniObservation
        adhObs.setValue(codedValue(adherence))
        return true
    }

    // Builds the {uuid, name} value map the ObsMapper expects for a coded obs answer.
    private static Map codedValue(String answerConceptName) {
        Concept answer = Context.getConceptService().getConceptByName(answerConceptName)
        if (answer == null) {
            throw new IllegalArgumentException("Adherence answer concept not found by name: '" + answerConceptName + "'")
        }
        Map value = new LinkedHashMap()
        value.put("uuid", answer.getUuid())
        value.put("name", answer.getName().getName())
        return value
    }

    private static LocalDate toLocalDate(Object value) {
        if (value == null) return null
        if (value instanceof Date) return new LocalDate(value)
        return new LocalDate(value.toString())  // ISO date / datetime string
    }

    private static BahmniObservation obsParent(BahmniObservation child, BahmniObservation parent) {
        if (parent != null) return parent;

        if(child != null) {
            return obsParentMap.get(child)
        }
    }

    private static Date getDate(BahmniObservation observation) {
        return hasValue(observation) && !observation.voided ? observation.getObservationDateTime() : null;
    }

    private static boolean isSameObs(BahmniObservation observation, Obs editedObs) {
        if(observation && editedObs) {
            return  (editedObs.uuid == observation.encounterTransactionObservation.uuid && editedObs.valueNumeric == observation.value);
        } else if(observation == null && editedObs == null) {
            return true;
        }
        return false;
    }

    private static boolean hasValue(BahmniObservation observation) {
        return observation != null && observation.getValue() != null && !StringUtils.isEmpty(observation.getValue().toString());
    }

    private static void voidObs(BahmniObservation bmiObservation) {
        if (hasValue(bmiObservation)) {
            bmiObservation.voided = true
        }
    }

    private static void voidPreviousBMIObs(Set<Obs> bmiObs) {
        if(bmiObs) {
            bmiObs.each { Obs obs ->
                Concept concept = Context.getConceptService().getConceptByUuid(obs.getConcept().uuid);
                if (concept.getName().name.equalsIgnoreCase("BMI Data") || concept.getName().name.equalsIgnoreCase("BMI") ||
                        concept.getName().name.equalsIgnoreCase("BMI ABNORMAL") || concept.getName().name.equalsIgnoreCase("BMI Status Data")
                        || concept.getName().name.equalsIgnoreCase("BMI STATUS") || concept.getName().name.equalsIgnoreCase("BMI STATUS ABNORMAL")) {

                    obs.voided = true;
                    obs.setVoidReason("Replaced with a new one because it was changed");
                    Context.getObsService().saveObs(obs, "Replaced with a new one because it was changed");
                }
            }
        }
    }

    static BahmniObservation createObs(String conceptName, BahmniObservation parent, BahmniEncounterTransaction encounterTransaction, Date obsDatetime) {
        def concept = Context.getConceptService().getConceptByName(conceptName)
        if (concept == null && !LocaleUtility.getDefaultLocale().equals(Context.getLocale())) {
            List<Concept> conceptsByName = Context.getConceptService().getConceptsByName(conceptName, LocaleUtility.getDefaultLocale(), false);
            if (!conceptsByName.isEmpty()) {
                concept = conceptsByName[0];
            }
        }
        BahmniObservation newObservation = new BahmniObservation()
        newObservation.setConcept(new EncounterTransaction.Concept(concept.getUuid(), conceptName))
        newObservation.setObservationDateTime(obsDatetime);
        parent == null ? encounterTransaction.addObservation(newObservation) : parent.addGroupMember(newObservation)
        return newObservation
    }

    static def bmi(Double height, Double weight) {
        if (height == ZERO) {
            throw new IllegalArgumentException("Please enter Height greater than zero")
        } else if (weight == ZERO) {
            throw new IllegalArgumentException("Please enter Weight greater than zero")
        }
        Double heightInMeters = height / 100;
        Double value = weight / (heightInMeters * heightInMeters);
        return new BigDecimal(value).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
    };

    static def bmiStatus(Double bmi, Integer ageInMonth, String gender) {
        BMIChart bmiChart = readCSV(OpenmrsUtil.getApplicationDataDirectory() + "obscalculator/BMI_chart.csv");
        def bmiChartLine = bmiChart.get(gender, ageInMonth);
        if(bmiChartLine != null ) {
            return bmiChartLine.getStatus(bmi);
        }

        if (bmi < BMI_VERY_SEVERELY_UNDERWEIGHT) {
            return BmiStatus.VERY_SEVERELY_UNDERWEIGHT;
        }
        if (bmi < BMI_SEVERELY_UNDERWEIGHT) {
            return BmiStatus.SEVERELY_UNDERWEIGHT;
        }
        if (bmi < BMI_UNDERWEIGHT) {
            return BmiStatus.UNDERWEIGHT;
        }
        if (bmi < BMI_NORMAL) {
            return BmiStatus.NORMAL;
        }
        if (bmi < BMI_OVERWEIGHT) {
            return BmiStatus.OVERWEIGHT;
        }
        if (bmi < BMI_OBESE) {
            return BmiStatus.OBESE;
        }
        if (bmi < BMI_SEVERELY_OBESE) {
            return BmiStatus.SEVERELY_OBESE;
        }
        if (bmi >= BMI_SEVERELY_OBESE) {
            return BmiStatus.VERY_SEVERELY_OBESE;
        }
        return null
    }

    static def bmiAbnormal(BmiStatus status) {
        return status != BmiStatus.NORMAL;
    };

    static Double fetchLatestValue(String conceptName, String patientUuid, BahmniObservation excludeObs, Date tillDate) {
        SessionFactory sessionFactory = Context.getRegisteredComponents(SessionFactory.class).get(0)
        def excludedObsIsSaved = excludeObs != null && excludeObs.uuid != null
        String excludeObsClause = excludedObsIsSaved ? " and obs.uuid != :excludeObsUuid" : ""
        Query queryToGetObservations = sessionFactory.getCurrentSession()
                .createQuery("select obs " +
                " from Obs as obs, ConceptName as cn " +
                " where obs.person.uuid = :patientUuid " +
                " and cn.concept = obs.concept.conceptId " +
                " and cn.name = :conceptName " +
                " and obs.voided = false" +
                " and obs.obsDatetime <= :till" +
                excludeObsClause +
                " order by obs.obsDatetime desc ");
        queryToGetObservations.setString("patientUuid", patientUuid);
        queryToGetObservations.setParameterList("conceptName", conceptName);
        queryToGetObservations.setParameter("till", tillDate);
        if (excludedObsIsSaved) {
            queryToGetObservations.setString("excludeObsUuid", excludeObs.uuid)
        }
        queryToGetObservations.setMaxResults(1);
        List<Obs> observations = queryToGetObservations.list();
        if (observations.size() > 0) {
            return observations.get(0).getValueNumeric();
        }
        return null
    }

    static BahmniObservation find(String conceptName, Collection<BahmniObservation> observations, BahmniObservation parent) {
        for (BahmniObservation observation : observations) {
            if (conceptName.equalsIgnoreCase(observation.getConcept().getName())) {
                obsParentMap.put(observation, parent);
                return observation;
            }
            BahmniObservation matchingObservation = find(conceptName, observation.getGroupMembers(), observation)
            if (matchingObservation) return matchingObservation;
        }
        return null
    }

    static BMIChart readCSV(String fileName) {
        def chart = new BMIChart();
        try {
            new File(fileName).withReader { reader ->
                def header = reader.readLine();
                reader.splitEachLine(",") { tokens ->
                    chart.add(new BMIChartLine(tokens[0], tokens[1], tokens[2], tokens[3], tokens[4], tokens[5]));
                }
            }
        } catch (FileNotFoundException e) {
        }
        return chart;
    }

    static class BMIChartLine {
        public String gender;
        public Integer ageInMonth;
        public Double third;
        public Double fifteenth;
        public Double eightyFifth;
        public Double ninetySeventh;

        BMIChartLine(String gender, String ageInMonth, String third, String fifteenth, String eightyFifth, String ninetySeventh) {
            this.gender = gender
            this.ageInMonth = ageInMonth.toInteger();
            this.third = third.toDouble();
            this.fifteenth = fifteenth.toDouble();
            this.eightyFifth = eightyFifth.toDouble();
            this.ninetySeventh = ninetySeventh.toDouble();
        }

        public BmiStatus getStatus(Double bmi) {
            if(bmi < third) {
                return BmiStatus.SEVERELY_UNDERWEIGHT
            } else if(bmi < fifteenth) {
                return BmiStatus.UNDERWEIGHT
            } else if(bmi < eightyFifth) {
                return BmiStatus.NORMAL
            } else if(bmi < ninetySeventh) {
                return BmiStatus.OVERWEIGHT
            } else {
                return BmiStatus.OBESE
            }
        }
    }

    static class BMIChart {
        List<BMIChartLine> lines;
        Map<BMIChartLineKey, BMIChartLine> map = new HashMap<BMIChartLineKey, BMIChartLine>();

        public add(BMIChartLine line) {
            def key = new BMIChartLineKey(line.gender, line.ageInMonth);
            map.put(key, line);
        }

        public BMIChartLine get(String gender, Integer ageInMonth) {
            def key = new BMIChartLineKey(gender, ageInMonth);
            return map.get(key);
        }
    }

    static class BMIChartLineKey {
        public String gender;
        public Integer ageInMonth;

        BMIChartLineKey(String gender, Integer ageInMonth) {
            this.gender = gender
            this.ageInMonth = ageInMonth
        }

        boolean equals(o) {
            if (this.is(o)) return true
            if (getClass() != o.class) return false

            BMIChartLineKey bmiKey = (BMIChartLineKey) o

            if (ageInMonth != bmiKey.ageInMonth) return false
            if (gender != bmiKey.gender) return false

            return true
        }

        int hashCode() {
            int result
            result = (gender != null ? gender.hashCode() : 0)
            result = 31 * result + (ageInMonth != null ? ageInMonth.hashCode() : 0)
            return result
        }
    }

    // ─────────────────────────────────────────────────────────────────────────────
    // eReg — Auto-create the ART follow-up appointment from the
    //        "HIV Treatment and Care Progress Template" observations.
    //
    //   Trigger : "Appointment scheduled" == Yes  AND  "ART, Follow-up date" has a value.
    //   Creates : an appointment for the SAME patient, at the SAME encounter location,
    //             on the follow-up date, starting at APPOINTMENT_START_HOUR:00.
    //   Skips   : if a non-cancelled appointment for that patient + service already
    //             exists on that date (so re-saving the encounter is safe).
    //
    //   Field mapping (mirrors what the Appointments UI posts to
    //   POST /openmrs/ws/rest/v1/appointment):
    //       encounter patientUuid   -> appointment.patient
    //       encounter locationUuid  -> appointment.location
    //       "ART, Follow-up date"   -> appointment.startDateTime (at 08:00)
    //                                  endDateTime = start + service-type duration
    //       (constant)              -> appointment.service      = ART Clinic
    //       (constant)              -> appointment.serviceType  = Refill
    //       (constant)              -> appointmentKind = Scheduled, status = Scheduled
    //
    //   NOTE ON "visit type": an Appointment has no visitType field — visit type is set
    //   on the VISIT when the patient is checked in, not on the appointment. The nearest
    //   equivalent on an appointment is the service type; APPT_SERVICE_TYPE_NAME below is
    //   set to "Refill", the ART Clinic service type closest to the "ARV Drug Pickup"
    //   visit type. Change it to "Follow up" if you would rather the appointment read as
    //   a clinical follow-up than as a drug pickup.
    //
    //   The appointments module is reached reflectively (Context.loadClass) on purpose:
    //   if that module is ever absent or renamed, this method logs and returns instead of
    //   failing to compile and taking BMI / adherence / the whole encounter save with it.
    // ─────────────────────────────────────────────────────────────────────────────

    static final String APPT_SERVICE_UUID       = "0c8dfd62-776a-4ddd-bcee-f2570c0721fa"  // ART Clinic
    static final String APPT_SERVICE_TYPE_NAME  = "Refill"                                 // closest to "ARV Drug Pickup"
    static final String FOLLOW_UP_DATE_CONCEPT  = "ART, Follow-up date"
    static final String APPT_SCHEDULED_CONCEPT  = "Appointment scheduled"
    static final String APPT_SCHEDULED_ANSWER   = "Yes"
    static final int    APPOINTMENT_START_HOUR  = 8
    static final int    DEFAULT_DURATION_MINS   = 30

    static void createFollowUpAppointment(BahmniEncounterTransaction etx) {
        try {
            Collection<BahmniObservation> observations = etx.getObservations()
            if (observations == null || observations.isEmpty()) return

            BahmniObservation followUpObs  = find(FOLLOW_UP_DATE_CONCEPT, observations, null)
            BahmniObservation scheduledObs = find(APPT_SCHEDULED_CONCEPT, observations, null)

            // Not this form, or the clinician did not schedule anything -> nothing to do.
            if (!hasValue(followUpObs) || followUpObs.voided) return
            if (!hasValue(scheduledObs) || scheduledObs.voided) return
            if (!APPT_SCHEDULED_ANSWER.equalsIgnoreCase(codedName(scheduledObs))) return

            LocalDate followUpDate = toLocalDate(followUpObs.getValue())
            if (followUpDate == null) return

            def appointmentsService = openmrsService("org.openmrs.module.appointments.service.AppointmentsService")
            if (appointmentsService == null) {
                log("appointments module not available - no appointment created")
                return
            }

            def serviceDefinitionService = openmrsService("org.openmrs.module.appointments.service.AppointmentServiceDefinitionService")
            if (serviceDefinitionService == null) {
                // older appointments modules
                serviceDefinitionService = openmrsService("org.openmrs.module.appointments.service.AppointmentServiceService")
            }
            if (serviceDefinitionService == null) {
                log("appointment service definition service not available - no appointment created")
                return
            }

            def appointmentService = serviceDefinitionService.getAppointmentServiceByUuid(APPT_SERVICE_UUID)
            if (appointmentService == null) {
                log("appointment service not found by uuid " + APPT_SERVICE_UUID + " - no appointment created")
                return
            }

            def serviceType = findServiceType(appointmentService, APPT_SERVICE_TYPE_NAME)
            Integer durationMins = durationOf(serviceType, appointmentService)

            // Follow-up date at APPOINTMENT_START_HOUR:00 in the server's timezone.
            Calendar cal = Calendar.getInstance()
            cal.clear()
            cal.set(followUpDate.getYear(), followUpDate.getMonthOfYear() - 1, followUpDate.getDayOfMonth(),
                    APPOINTMENT_START_HOUR, 0, 0)
            Date startDateTime = cal.getTime()
            cal.add(Calendar.MINUTE, durationMins)
            Date endDateTime = cal.getTime()

            Patient patient = Context.getPatientService().getPatientByUuid(etx.getPatientUuid())
            if (patient == null) {
                log("patient not found by uuid " + etx.getPatientUuid() + " - no appointment created")
                return
            }

            def location = etx.getLocationUuid() != null ?
                    Context.getLocationService().getLocationByUuid(etx.getLocationUuid()) : null

            if (hasExistingAppointment(appointmentsService, patient, startDateTime)) {
                log("appointment already exists for " + patient.getUuid() + " on " + followUpDate + " - skipping")
                return
            }

            def appointment = Context.loadClass("org.openmrs.module.appointments.model.Appointment").newInstance()
            appointment.setPatient(patient)
            appointment.setService(appointmentService)
            if (serviceType != null) appointment.setServiceType(serviceType)
            if (location != null) appointment.setLocation(location)
            appointment.setStartDateTime(startDateTime)
            appointment.setEndDateTime(endDateTime)
            appointment.setAppointmentKind(enumValue("org.openmrs.module.appointments.model.AppointmentKind", "Scheduled"))
            appointment.setStatus(enumValue("org.openmrs.module.appointments.model.AppointmentStatus", "Scheduled"))
            appointment.setComments("Auto-created from HIV Treatment and Care - Follow Up")

            saveAppointment(appointmentsService, appointment)
            log("created appointment for " + patient.getUuid() + " on " + startDateTime)
        } catch (Exception e) {
            // Never let appointment creation block a clinical save.
            log("failed to create follow-up appointment: " + e)
            e.printStackTrace()
        }
    }

    // Is there already a live appointment for this patient + service on that day?
    private static boolean hasExistingAppointment(def appointmentsService, Patient patient, Date onDate) {
        def sameDay = null
        try {
            sameDay = appointmentsService.getAllAppointments(onDate)
        } catch (Exception e) {
            log("could not read existing appointments (" + e + ") - continuing")
            return false
        }
        if (sameDay == null) return false
        return sameDay.any { appt ->
            appt.getPatient() != null &&
            patient.getUuid().equals(appt.getPatient().getUuid()) &&
            appt.getService() != null &&
            APPT_SERVICE_UUID.equals(appt.getService().getUuid()) &&
            !"Cancelled".equalsIgnoreCase(String.valueOf(appt.getStatus())) &&
            !Boolean.TRUE.equals(appt.getVoided())
        }
    }

    private static void saveAppointment(def appointmentsService, def appointment) {
        try {
            appointmentsService.validateAndSave(appointment)   // current appointments module
        } catch (MissingMethodException ignored) {
            appointmentsService.save(appointment)              // older appointments module
        }
    }

    private static def findServiceType(def appointmentService, String typeName) {
        if (typeName == null) return null
        def types = null
        try {
            types = appointmentService.getServiceTypes(false)
        } catch (MissingMethodException ignored) {
            try { types = appointmentService.getServiceTypes() } catch (Exception e) { return null }
        } catch (Exception e) {
            return null
        }
        if (types == null) return null
        return types.find { t -> typeName.equalsIgnoreCase(String.valueOf(t.getName())) }
    }

    private static Integer durationOf(def serviceType, def appointmentService) {
        try {
            if (serviceType != null && serviceType.getDuration() != null) return serviceType.getDuration() as Integer
        } catch (Exception ignored) { }
        try {
            if (appointmentService.getDurationMins() != null) return appointmentService.getDurationMins() as Integer
        } catch (Exception ignored) { }
        return DEFAULT_DURATION_MINS
    }

    // Resolve an OpenMRS module service without a compile-time dependency on the module.
    private static Object openmrsService(String className) {
        try {
            return Context.getService(Context.loadClass(className))
        } catch (Exception ignored) {
            return null
        }
    }

    private static Object enumValue(String enumClassName, String constantName) {
        return Enum.valueOf(Context.loadClass(enumClassName), constantName)
    }

    // Coded obs values arrive as a {uuid, name} Map (see codedValue above), but can also be a
    // plain String or an EncounterTransaction.Concept depending on how the obs was built.
    private static String codedName(BahmniObservation observation) {
        return displayName(observation == null ? null : observation.getValue())
    }

    private static String displayName(Object value) {
        if (value == null) return null
        if (value instanceof CharSequence) return value.toString()
        if (value instanceof Map) return displayName(((Map) value).get("name"))
        def name = null
        try { name = value.getName() } catch (Exception ignored) { return value.toString() }
        if (name == null) return value.toString()
        if (name instanceof CharSequence) return name.toString()
        return displayName(name)
    }

    private static void log(String message) {
        System.out.println("eReg — follow-up appointment: " + message)
    }

}
