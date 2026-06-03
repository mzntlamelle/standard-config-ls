window.buildAdherenceCalculatorConditions = window.buildAdherenceCalculatorConditions || {};

window.buildAdherenceCalculatorConditions = function (formName, formFieldValues) {
        var conditions = { show: [], hide: [], assignedValues: [], disable: [] };

        console.log("[Adherence Calc] formName received:", formName);

        if (formName == "eReg, Adherence Calculator One" || formName == "eReg, Adherence Calculator Two") {
                var dateUtil = Bahmni.Common.Util.DateUtil;
                var dispensedDate = formFieldValues['HIVTC, Adherence Date ARVs Dispensed'];
                var returnDate = formFieldValues['HIVTC, Adherence Return Date'];
                // var conditions = {  show: [], hide: [], assignedValues: [], disable: [], error: []};
                // var retrospectiveDate = $.cookie(Bahmni.Common.Constants.retrospectiveEntryEncounterDateCookieName);

                // conditions.disable.push("HIVTC, Adherence Number of Days since refill");

                if (dispensedDate && returnDate) {
                        var daysSinceRefill = dateUtil.diffInDaysRegardlessOfTime(dispensedDate, returnDate);

                        console.log("[Adherence Calc] Days since refill:", daysSinceRefill);

                        conditions.assignedValues.push({ 
                                field: 'HIVTC, Adherence Number of Days since refill', 
                                fieldValue: daysSinceRefill, 
                                autocalculate: true 
                        });

                        // A, B, C, D together calculate pill count and adherence:
                        // A = Total pills taken home | B = Pill count (remaining) | C = Daily ARV dose | D = Days since refill
                        // Formula: ((A - B) / C / D) * 100 = % Adherence
                        var adherence_A = formFieldValues['HIVTC, Adherence Total amount taken home'];
                        var adherence_B = formFieldValues['HIVTC, Adherence Pill count'];
                        var adherence_C = formFieldValues['HIVTC, Adherence Daily ARV Dose'];
                        var adherence_D = daysSinceRefill;

                        console.log("[Adherence Calc] Inputs - A:", adherence_A, "| B:", adherence_B, "| C:", adherence_C, "| D:", adherence_D);

                        if (adherence_A != null && adherence_B != null && adherence_C != null && adherence_D) {
                                var percentageAdh = Math.floor(((adherence_A - adherence_B) / adherence_C / adherence_D) * 100);

                                console.log("[Adherence Calc] Percentage Adherence:", percentageAdh + "%");

                                conditions.assignedValues.push({ 
                                        field: 'HIVTC, Percentage Adherence', 
                                        fieldValue: percentageAdh, 
                                        autocalculate: true 
                                });

                                switch (true) {
                                        case (percentageAdh < 85 || percentageAdh > 105):
                                                console.log("[Adherence Calc] Result: Poor adherence");
                                                conditions.assignedValues.push({ field: 'HIVTC, ART Treatment Adherence', fieldValue: 'Poor adherence', autocalculate: true });
                                                conditions.show.push('Poor or Fair ART adherence reason');
                                                break;
                                        case (percentageAdh >= 85 && percentageAdh < 95):
                                                console.log("[Adherence Calc] Result: Fair adherence");
                                                conditions.assignedValues.push({ field: 'HIVTC, ART Treatment Adherence', fieldValue: 'Fair adherence', autocalculate: true });
                                                conditions.show.push('Poor or Fair ART adherence reason');
                                                break;
                                        case (percentageAdh >= 95 && percentageAdh <= 105):
                                                console.log("[Adherence Calc] Result: Good adherence");
                                                conditions.assignedValues.push({ field: 'HIVTC, ART Treatment Adherence', fieldValue: 'Good adherence', autocalculate: true });
                                                conditions.hide.push('Poor or Fair ART adherence reason');
                                                break;
                                }
                        } else {
                                console.log("[Adherence Calc] Skipping percentage calculation — one or more inputs (A, B, C) are missing");
                        }
                } else {
                        console.log("[Adherence Calc] Skipping — dispensed date or return date missing");
                }
        }

        return conditions;
};
