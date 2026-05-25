Bahmni.ConceptSet.FormConditions.rules = {


        //////////////////////////////////////////////////////////////////////////
        /////////////////////////// Tuberculosis - Intake Form ///////////////////
        /////////////////////////////////////////////////////////////////////////
        'Genotypic test type performed': function (formName, formFieldValues) {
                var genexpertTest = formFieldValues['Genotypic test type performed'];
                var conditions = { show: [], hide: [] };
                switch (genexpertTest) {
                        case "GeneXpert test type":
                                conditions.show.push("GeneXpert results");
                                break;

                        case "Line Probe Assay test type":
                                conditions.hide.push("GeneXpert results");
                                break;
                }
                return conditions;
        },

        // 'TB Transfer in': function (formName, formFieldValues) {
        //         var conditionConcept = formFieldValues['TB Transfer in'];
        //         var conditions = { show: [], hide: [] };

        //         switch (conditionConcept) {
        //                 case "Transfer In":
        //                 case "Moved in":
        //                         conditions.show.push("HIVTC, Transferred in from");
        //                         conditions.hide.push("TB, Transferred In From Outside Country");
        //                         conditions.hide.push("TB, Transferred In From Outside Facility");
        //                         break;

        //                 case "Transfer in from outside Lesotho":
        //                         conditions.hide.push("HIVTC, Transferred in from");
        //                         conditions.show.push("TB, Transferred In From Outside Country");
        //                         conditions.show.push("TB, Transferred In From Outside Facility");
        //                         break;
        //                 default:
        //                         conditions.hide.push("HIVTC, Transferred in from");
        //                         conditions.hide.push("TB, Transferred In From Outside Country");
        //                         conditions.hide.push("TB, Transferred In From Outside Facility");
        //         }

        //         return conditions;
        // },
        'TB History of previous treatment': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['TB History of previous treatment'];
                var conditions = { show: [], hide: [] };
                if (conditionConcept == "Other Answer") {
                        conditions.show.push("TB History of previous treatment Specify");
                } else {
                        conditions.hide.push("TB History of previous treatment Specify");
                }
                return conditions;
        },
        'Intervention(action taken)': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['Intervention(action taken)'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("Intervention(action taken) Specify");
                } else {
                        conditions.hide.push("Intervention(action taken) Specify");
                }

                return conditions;
        },
        /*** TB COMORBIDITY ***/
        'TB Comorbidities, Clinical Status': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['TB Comorbidities, Clinical Status'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept) {
                        conditions.show.push("Drug");
                        conditions.show.push("Dosage");
                } else {
                        conditions.hide.push("Drug");
                        conditions.hide.push("Dosage");
                }

                return conditions;
        },
        /**** AUTOFILL WEIGHT VALUES */
        'WEIGHT': function (formName, formFieldValues) {
                var conditions = { assignedValues: [], disable: [] };
                if (formName == "ANC, ANC Program" || formName == "HIV Treatment and Care Progress Template" || formName == "Vitals") {
                        conditions.assignedValues.push(
                                {
                                        field: "WEIGHT",
                                        fieldValue:
                                        {
                                                isAutoFill: true,
                                                scopedEncounter: "CurrentVisit",
                                                isFilledOnRetrospectiveMode: false,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false
                                        }
                                });
                }
                return conditions;
        },

        /**** AUTOFILL SYSTOLIC VALUES */
        'Systolic': function (formName, formFieldValues) {
                var conditions = { assignedValues: [], disable: [] };
                if (formName == "ANC, ANC Program" || formName == "Vitals" || formName == "HIV Treatment and Care Progress Template") {
                        conditions.assignedValues.push(
                                {
                                        field: "Systolic",
                                        fieldValue:
                                        {
                                                isAutoFill: true,
                                                scopedEncounter: "CurrentVisit",
                                                isFilledOnRetrospectiveMode: false,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false
                                        }
                                });
                }
                return conditions;
        },

        /**** AUTOFILL DIASTOLIC VALUES */
        'Diastolic': function (formName, formFieldValues) {
                var conditions = { assignedValues: [], disable: [] };
                if (formName == "ANC, ANC Program" || formName == "Vitals" || formName == "HIV Treatment and Care Progress Template") {
                        conditions.assignedValues.push(
                                {
                                        field: "Diastolic",
                                        fieldValue:
                                        {
                                                isAutoFill: true,
                                                scopedEncounter: "CurrentVisit",
                                                isFilledOnRetrospectiveMode: false,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false
                                        }
                                });
                }
                return conditions;
        },

        /*** AUTOFILL MUAC VALUES ****/

        'IMAM, MUAC': function (formName, formFieldValues) {
                var conditions = { assignedValues: [], disable: [] };
                if (formName == "ANC, ANC Program" || formName == "HIV Treatment and Care Progress Template") {
                        conditions.assignedValues.push(
                                {
                                        field: "IMAM, MUAC",
                                        fieldValue:
                                        {
                                                isAutoFill: true,
                                                scopedEncounter: "CurrentVisit",
                                                isFilledOnRetrospectiveMode: false,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false
                                        }
                                });
                }
                return conditions;
        },

        'HTC, Patient type': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HTC, Patient type'];
                var conditions = { show: [], hide: [], assignedValues: [] };
                if (conditionConcept == undefined) {
                        conditions.hide.push("HEIGHT");
                        conditions.hide.push("WEIGHT");
                        conditions.hide.push("TB Status");
                        conditions.hide.push("Systolic Data");
                        conditions.hide.push("Diastolic Data");
                        conditions.hide.push("IMAM, MUAC");

                } 
                else if (conditionConcept == "HTC, Patient") {
                        conditions.assignedValues.push({
                                field: "HEIGHT",
                                fieldValue: {
                                        isAutoFill: true,
                                        scopedEncounter: "latestvisit",
                                        isFilledOnRetrospectiveMode: true,
                                        enableDefaultValue: false,
                                        enableEditAfterAutoFill: true
                                }
                        });

                        conditions.show.push("HEIGHT");
                        conditions.show.push("WEIGHT");
                        conditions.assignedValues.push({
                                field: "WEIGHT",
                                fieldValue: {
                                        isAutoFill: true,
                                        scopedEncounter: "latestvisit",
                                        isFilledOnRetrospectiveMode: true,
                                        enableDefaultValue: true,
                                        enableEditAfterAutoFill: true
                                }
                        });
                        conditions.show.push("TB Status");
                        conditions.show.push("Systolic Data");
                        conditions.show.push("Diastolic Data");
                        conditions.show.push("IMAM, MUAC");


                } else if (conditionConcept == "HTC, Buddy") {
                        conditions.hide.push("HEIGHT");
                        conditions.hide.push("WEIGHT");
                        conditions.hide.push("TB Status");
                        conditions.hide.push("Systolic Data");
                        conditions.hide.push("Diastolic Data");
                        conditions.hide.push("IMAM, MUAC");

                }

                return conditions;
        },

        'Phenotypic Test type performed': function (formName, formFieldValues) {
                var phenotipicTest = formFieldValues['Phenotypic Test type performed'];
                var conditions = { show: [], hide: [] };
                if (phenotipicTest) {
                        conditions.show.push("Phenotypic Test Results (ZN or C)");
                } else {
                        conditions.hide.push("Phenotypic Test Results (ZN or C)");
                }
                return conditions;
        },


        'TB, HIV Status': function (formName, formFieldValues) {
                var result = formFieldValues['TB, HIV Status'];
                var conditions = { show: [], hide: [] };
                if (!result || result == 'New Negative' || result == 'Known Negative') {
                        conditions.hide.push("TB, HIV Management");
                        conditions.hide.push("TB, Prevention of OIs")
                } else {
                        conditions.show.push("TB, HIV Management");
                        conditions.show.push("TB, Prevention of OIs")
                }
                return conditions;
        },


        'Site : P/EP': function (formName, formFieldValues) {
                var result = formFieldValues['Site : P/EP'];
                var conditions = { show: [], hide: [] };
                if (!result || result != 'Extra Pulmonary') {
                        conditions.hide.push("TB, Site of Extra-pulmonary TB");
                } else {
                        conditions.show.push("TB, Site of Extra-pulmonary TB");
                }
                return conditions;
        },

        'HIVTC, TB Screened': function (formName, formFieldValues) {
                var result = formFieldValues['HIVTC, TB Screened'];
                var conditions = { show: [], hide: [] };
                if (result == 'Yes') {
                        conditions.show.push("TB Status");
                } else {
                        conditions.hide.push("TB Status");
                }
                return conditions;
        },


        // 'HIVTC, Prior ART': function (formName, formFieldValues) {
        //         var conditionConcept = formFieldValues['HIVTC, Prior ART'];

        //         var conditions = { show: [], hide: [] };

        //         if (conditionConcept == "Transfer In") {
        //                 conditions.show.push("HIVTC, Transferred in");
        //                 //conditions.hide.push("HIVTC, ART start date");
        //         } else {
        //                 conditions.hide.push("HIVTC, Transferred in");
        //                 //conditions.show.push("HIVTC, ART start date");
        //         }
        //         return conditions;
        // },

        'Refer or Consult': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['Refer or Consult'];

                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Provide nutritional support or infant feeding") {
                        conditions.show.push("HIVTC, Nutritional products");
                } else {
                        //conditions.hide.push("HIVTC, Nutritional products");
                }
                return conditions;
        },


        'HTS, Referral': function (formName, formFieldValues) {
                var result = formFieldValues['HTS, Referral'];

                var conditions = { show: [], hide: [] };

                if (result == "Referred") {
                        conditions.show.push("HTC, Referred Facility");
                } else {
                        conditions.hide.push("HTC, Referred Facility");
                }
                return conditions;
        },


        /*--------------------------MCH Programme------------------------------*/
        'Delivery Note, Delivery location': function (formName, formFieldValues) {
                var DeliveryPlace = formFieldValues['Delivery Note, Delivery location'];

                if ((formName == "PostNatal Care Register") || (formName == "Delivery Information") || (formName == "Lesotho Obstetric Record")) {
                        var conditions = { assignedValues: [], show: [], hide: [] };

                        if ((DeliveryPlace == "Institutional Delivery") || (DeliveryPlace == "Home Delivery")) {
                                conditions.show.push("Mode of Delivery");
                        } else {
                                conditions.hide.push("Mode of Delivery");
                        }
                }
                if ((formName == "PostNatal Care Register") || (formName == "Delivery Information")) {

                        conditions.assignedValues.push({
                                field: "Delivery Note, Delivery location",
                                fieldValue: {
                                        isAutoFill: true,
                                        scopedEncounter: "latestvisit",
                                        isFilledOnRetrospectiveMode: true,
                                        enableDefaultValue: true,
                                        enableEditAfterAutoFill: true
                                }
                        });

                }

                return conditions;
        },

        'ANC, Gravida': function (formName, formFieldValues) {
                var ANCGravida = formFieldValues['ANC, Gravida'];
                var AncVisits = formFieldValues['ANC, Visit Types'];
                var conditions = { show: [], hide: [], disable: [], assignedValues: [] };

                conditions.assignedValues.push({
                        field: "ANC, Gravida",
                        fieldValue: {
                                isAutoFill: true,
                                scopedEncounter: "latestvisit",
                                isFilledOnRetrospectiveMode: true,
                                enableDefaultValue: true,
                                enableEditAfterAutoFill: true
                        }
                });

                if (formName == "ANC, Obstetric History") {

                        if (ANCGravida > "1") {
                                conditions.show.push("ANC, Parity");
                                conditions.show.push("ANC, History of Past Pregnancies");
                        }

                        else {
                                conditions.hide.push("ANC, Parity");
                                conditions.hide.push("ANC, Alive");
                                conditions.hide.push("ANC, Number of Miscarriages");
                                conditions.hide.push("ANC, History of Past Pregnancies");

                        }
                }
                if (formName == "ANC, Examinations") {
                        if (ANCGravida > "1") {
                                conditions.show.push("ANC, Number of Miscarriages");
                                conditions.show.push("ANC, Parity");
                        }

                        else {

                                conditions.hide.push("ANC, Parity");
                                conditions.hide.push("ANC, Number of Miscarriages");
                        }
                }
                return conditions;

        },

        'ANC, Parity': function (formName, formFieldValues) {
                var ANCGravida1 = formFieldValues['ANC, Gravida'];
                var ANCParity = formFieldValues['ANC, Parity'];
                var AncVisits = formFieldValues['ANC, Visit Types'];
                var conditions = { show: [], hide: [], disable: [], enable: [], assignedValues: [] };

                conditions.assignedValues.push({
                        field: "ANC, Parity",
                        fieldValue: {
                                isAutoFill: true,
                                scopedEncounter: "latestvisit",
                                isFilledOnRetrospectiveMode: true,
                                enableDefaultValue: true,
                                enableEditAfterAutoFill: true
                        }
                });

                if (formName == "ANC, Obstetric History") {
                        if (ANCParity >= ANCGravida1) {
                                alert("Parity should be less than Gravida");
                                conditions.hide.push("ANC, Alive");
                                conditions.hide.push("ANC, Number of Miscarriages");
                        }
                        else if (ANCParity < ANCGravida1) {
                                conditions.enable.push("ANC, Alive");
                        }
                        else {
                                conditions.disable.push("ANC, Alive");
                                conditions.hide.push("ANC, Alive");
                        }
                }
                if (formName == "ANC, Examinations") {
                        if (ANCParity >= ANCGravida1) {
                                alert("Parity should be less than Gravida");
                                conditions.disable.push("ANC, Number of Miscarriages");
                        }
                        else if (ANCParity < ANCGravida1) {
                                conditions.enable.push("ANC, Number of Miscarriages");
                        }
                        else {
                                conditions.disable.push("ANC, Number of Miscarriages");
                                conditions.hide.push("ANC, Number of Miscarriages");
                        }
                }
                return conditions;

        },

        'ANC, Alive': function (formName, formFieldValues) {
                var ANCAlive = formFieldValues['ANC, Alive'];
                var ANCParity = formFieldValues['ANC, Parity'];
                var conditions = { show: [], hide: [], enable: [], disable: [], assignedValues: [] };
                if (formName == "ANC, Obstetric History") {

                        if (ANCAlive < ANCParity) {
                                conditions.show.push("ANC, Number of Miscarriages");
                                conditions.enable.push("ANC, Number of Miscarriages");
                        }
                        else if (ANCAlive > ANCParity) {
                                alert("Parity should be more or equal to alive");
                                conditions.hide.push("ANC, Number of Miscarriages");
                        }
                        else {
                                conditions.hide.push("ANC, Number of Miscarriages");
                        }
                } return conditions;

        },

        'ANC, Family Planning Ever Used': function (formName, formFieldValues) {
                var FPUsed = formFieldValues['ANC, Family Planning Ever Used'];

                if (formName == "ANC, Gynaecological History") {
                        var conditions = { show: [], hide: [] };

                        if (FPUsed == "Yes") {
                                conditions.show.push("ANC, Family Planning Method")
                                conditions.show.push("ANC, Date Family Planning Stopped");
                        }
                        else {
                                conditions.hide.push("ANC, Family Planning Method");
                                conditions.hide.push("ANC, Date Family Planning Stopped");
                        }
                }
                return conditions;
        },

        'ANC, History of STI': function (formName, formFieldValues) {
                var STIScreening = formFieldValues['ANC, History of STI'];

                if (formName == "ANC, Gynaecological History") {
                        var conditions = { show: [], hide: [] };

                        if (STIScreening == "Yes") {
                                conditions.show.push("STI Treated");
                                conditions.show.push("ANC, Date STI Treated");
                        }

                        else {
                                conditions.hide.push("STI Treated");
                                conditions.hide.push("ANC, Date STI Treated");
                        }
                }
                return conditions;
        },

        'ANC, Number of Miscarriages': function (formName, formFieldValues) {
                var HistoryMis = formFieldValues['ANC, Number of Miscarriages'];
                var conditions = { show: [], hide: [], assignedValues: [] };

                conditions.assignedValues.push({
                        field: "ANC, Number of Miscarriages",
                        fieldValue: {
                                isAutoFill: true,
                                scopedEncounter: "latestvisit",
                                isFilledOnRetrospectiveMode: true,
                                enableDefaultValue: true,
                                enableEditAfterAutoFill: true,
                                autocalculate: true
                        }
                });

                if (formName == "ANC, Gynaecological History") {

                        if (HistoryMis == "Yes") {
                                conditions.show.push("ANC, When")
                                conditions.show.push("Delivery Note, Gestation period");
                                conditions.show.push("Dilation and Curettage");
                        }
                        else {
                                conditions.hide.push("ANC, When");
                                conditions.hide.push("Delivery Note, Gestation period");
                                conditions.hide.push("Dilation and Curettage");
                        }
                }
                return conditions;
        },

        'ANC, TB': function (formName, formFieldValues) {
                var TBHistory = formFieldValues['ANC, TB'];

                if (formName == "ANC, Previous Medical History") {
                        var conditions = { show: [], hide: [] };

                        if (TBHistory == "Yes") {
                                conditions.show.push("ANC, Year");
                                conditions.show.push("ANC, TB Treatment Completed");
                                conditions.show.push("ANC, Date Completed");
                        }
                        else {
                                conditions.hide.push("ANC, Year");
                                conditions.hide.push("ANC, TB Treatment Completed");
                                conditions.hide.push("ANC, Date Completed");
                        }
                }
                return conditions;
        },

        'Any Surgery': function (formName, formFieldValues) {
                var anySurgery = formFieldValues['Any Surgery'];
                var conditions = { show: [], hide: [] };

                if (anySurgery == "Yes") {
                        conditions.show.push("ANC, Type of Surgery");
                } else if (!anySurgery || anySurgery != "Yes") {
                        conditions.hide.push("ANC, Type of Surgery");
                }
                return conditions;
        },


        'ANC, Type of Surgery': function (formName, formFieldValues) {
                var typeOfSurgery = formFieldValues['ANC, Type of Surgery'];
                var conditions = { show: [], hide: [] };

                if (typeOfSurgery == "Surgery, Other") {
                        conditions.show.push("ANC, Surgery Specify");
                } else if (!typeOfSurgery || typeOfSurgery != "Surgery, Other") {
                        conditions.hide.push("ANC, Surgery Specify");
                }
                return conditions;
        },



        'ANC, Came together': function (formName, formFieldValues) {
                var MalePartner = formFieldValues['ANC, Came together'];

                if (formName == "Male Partner Involvement") {
                        var conditions = { show: [], hide: [] };

                        if (MalePartner == "Yes") {
                                conditions.show.push("ANC, Partner HIV Status");
                        }

                        else {
                                conditions.hide.push("ANC, Partner HIV Status");
                        }
                }
                return conditions;
        },

        'ANC, Tested as Couple': function (formName, formFieldValues) {
                var CoupleTest = formFieldValues['ANC, Tested as Couple'];

                if (formName == "LOR, PMTCT") {
                        var conditions = { show: [], hide: [] };

                        if (CoupleTest == "Yes") {
                                conditions.show.push("ANC, Partner HIV Status");
                        }

                        else {
                                conditions.hide.push("ANC, Partner HIV Status");
                        }
                }
                return conditions;
        },

        'ANC, Syphilis Screening Results': function (formName, formFieldValues) {
                var SyphilisScreening = formFieldValues['ANC, Syphilis Screening Results'];
                var conditions = { show: [], hide: [] };

                if (formName == "ANC, Investigations and Immunisations") {


                        if (SyphilisScreening == "Reactive") {
                                conditions.show.push("ANC, Syphilis Screening Treatment");
                        }

                        else {
                                conditions.hide.push("ANC, Syphilis Screening Treatment");
                        }
                }
                if ((formName == "LD, Syphillis Screening") || (formName == "Labour and Delivery Register")) {

                        if (SyphilisScreening == "Not Done" || SyphilisScreening == "undefined") {
                                conditions.show.push("LD, Screened at Maternity");
                        } else {
                                conditions.hide.push("LD, Screened at Maternity");
                        }
                }
                return conditions;
        },

        'ANC, Ever Had Pap Smear': function (formName, formFieldValues) {
                var PapSmear = formFieldValues['ANC, Ever Had Pap Smear'];

                if (formName == "ANC, Gynaecological History") {
                        var conditions = { show: [], hide: [] };

                        if (PapSmear == "Yes") {
                                conditions.show.push("Results of Pap Smear");
                                conditions.show.push("ANC, Pap Smear Date");
                        }

                        else {
                                conditions.hide.push("Results of Pap Smear");
                                conditions.hide.push("ANC, Pap Smear Date");
                        }
                }
                return conditions;
        },

        'ANC, Type of Mother Baby Pack': function (formName, formFieldValues) {
                var MBPack = formFieldValues['ANC, Type of Mother Baby Pack'];

                if (formName == "ANC Register") {
                        var conditions = { show: [], hide: [] };

                        if (MBPack == "ANC, No Pack Given") {
                                conditions.hide.push("ANC, Adherence level to MBP");
                        } else {
                                conditions.show.push("ANC, Adherence level to MBP");
                        }
                }
                return conditions;
        },

        'Tested in PNC': function (formName, formFieldValues) {
                var TestedInPNC = formFieldValues['Tested in PNC'];

                if ((formName == "PostNatal Care Register") || (formName == "HIV Prevention, Care, and Treatment")) {
                        var conditions = { show: [], hide: [] };

                        if (TestedInPNC == "Positive") {
                                conditions.show.push("PMTCT, WHO clinical staging")
                                conditions.show.push("PNC, On ART Treatment");
                        }
                        else {
                                conditions.hide.push("PMTCT, WHO clinical staging")
                                conditions.hide.push("PNC, On ART Treatment");
                        }
                }
                return conditions;
        },

        'ANC, Visit Types': function (formName, formFieldValues) {
                var AncVisits = formFieldValues['ANC, Visit Types'];
                if (formName == "ANC, ANC Program") {
                        var conditions = { show: [], hide: [], disable: [] };
                        conditions.hide.push("ANC, Parity");
                        conditions.hide.push("ANC, Alive");
                        conditions.hide.push("ANC, Number of Miscarriages");
                        conditions.hide.push("ANC, History of Past Pregnancies");
                        conditions.hide.push("ANC, Syphilis Screening Treatment");
                        conditions.hide.push("Results of Pap Smear");
                        conditions.hide.push("ANC, Pap Smear Date");
                        conditions.hide.push("STI Treated");
                        conditions.hide.push("ANC, Date STI Treated");
                        conditions.hide.push("ANC, When");
                        conditions.hide.push("Delivery Note, Gestation period");
                        conditions.hide.push("Dilation and Curettage");
                        conditions.hide.push("ANC, Type of Surgery");
                        conditions.hide.push("ANC, Initial Test during this pregnancy");
                        conditions.hide.push("HIV Prophylaxis/Treatment");
                        conditions.hide.push("HIVTC, Viral Load Monitoring Template");
                        conditions.hide.push("ANC, Partner HIV Status");

                        if (AncVisits == "ANC, First Visit") {
                                conditions.hide.push("ANC, Visit order Number");
                                conditions.show.push("Lesotho Obstetric Record")
                                conditions.show.push("ANC Register");
                                conditions.hide.push("Subsequent HIV Test Results");
                        }
                        else if (AncVisits == "ANC, Subsequent Visit") {
                                conditions.show.push("ANC, Visit order Number");
                                conditions.show.push("ANC Register");
                                conditions.hide.push("ANC, TT Doses Previous");
                                conditions.hide.push("ANC From Lesotho");
                                conditions.hide.push("Lesotho Obstetric Record");
                        }
                        else {
                                conditions.hide.push("ANC, Visit order Number");
                                conditions.hide.push("Lesotho Obstetric Record")
                                conditions.hide.push("ANC Register");
                        }

                }
                return conditions;

        },

        'ANC, Initiated on ART': function (formName, formFieldValues) {
                var initiation = formFieldValues['ANC, Initiated on ART'];
                var conditions = { show: [], hide: [], disable: [] };

                if (formName == 'HIV Prophylaxis/Treatment') {
                        if ((initiation == "Already on ART") || (initiation == "ANC, Initiated on ART during pregnancy")) {
                                conditions.show.push("PMTCT, ART start date");
                                conditions.show.push("HIVTC, ART Regimen");
                                conditions.show.push("HIV, Program ID");
                                conditions.show.push("PMTCT, WHO clinical staging");
                                conditions.show.push("HIVTC, Viral Load Monitoring Template");
                        }
                        else {
                                conditions.hide.push("PMTCT, ART start date");
                                conditions.hide.push("HIVTC, ART Regimen");
                                conditions.hide.push("HIV, Program ID");
                                conditions.hide.push("PMTCT, WHO clinical staging");
                                conditions.hide.push("HIVTC, Viral Load Monitoring Template");
                        }
                }
                return conditions;
        },

        'ANC, HIV Test Result': function (formName, formFieldValues) {
                var conditions = { show: [], hide: [], disable: [], enable: [] };
                var result = formFieldValues['ANC, HIV Test Result'];

                if (formName == 'ANC, Initial Test during this pregnancy') {
                        if ((result == "Positive") || (result == "Negative")) {
                                conditions.hide.push("ANC, HIV Result Received");
                                conditions.show.push("ANC, HIV Result Received");
                        }
                        else {
                                conditions.hide.push("ANC, HIV Result Received");
                                conditions.hide.push("HIV Prophylaxis/Treatment");
                        }
                } return conditions;
        },

        'ANC, HIV Result Received': function (formName, formFieldValues) {
                var conditions = { show: [], hide: [], disable: [], enable: [] };
                var result_recieved = formFieldValues['ANC, HIV Result Received'];
                var result = formFieldValues['ANC, HIV Test Result'];

                if (formName == 'ANC, Initial Test during this pregnancy') {
                        if (!result_recieved) {
                                conditions.hide.push("Subsequent HIV Test Results");
                        }
                        if (result_recieved == "Yes") {
                                conditions.show.push("HIV Prophylaxis/Treatment");

                                if (result == "Positive") {
                                        conditions.show.push("ANC, Initiated on ART");
                                        conditions.hide.push("ANC, Initiated in Prep");
                                        conditions.hide.push("PMTCT, ART start date");
                                        conditions.hide.push("HIVTC, ART Regimen");
                                        conditions.hide.push("HIV, Program ID");
                                        conditions.hide.push("PMTCT, WHO clinical staging");
                                        conditions.hide.push("Subsequent HIV Test Results");
                                        conditions.hide.push("HIVTC, Viral Load Monitoring Template");
                                }
                                else if (result == "Negative") {
                                        conditions.hide.push("EIM, Cotrimoxazole given");
                                        conditions.hide.push("ANC, Initiated on ART");
                                        conditions.show.push("Subsequent HIV Test Results");
                                        conditions.hide.push("PMTCT, ART start date");
                                        conditions.hide.push("HIVTC, ART Regimen");
                                        conditions.hide.push("HIV, Program ID");
                                        conditions.hide.push("PMTCT, WHO clinical staging");
                                        conditions.show.push("ANC, Initiated in Prep");
                                        conditions.hide.push("HIVTC, Viral Load Monitoring Template");
                                }
                        }
                        else {
                                conditions.hide.push("HIV Prophylaxis/Treatment");
                        }
                }
                return conditions;
        },

        /*-----
                'HTC, Partner Testing and Counseling' : function (formName, formFieldValues) {
                 var coupleTest = formFieldValues['HTC, Partner Testing and Counseling'];

                if(formName == "LOR, PMTCT") {
                        var conditions = {show: [], hide: [], enable: [], disable: []};

                        if(coupleTest == "Yes") {
                                conditions.show.push("Partner HIV Status");
                        }
                        else {
                                conditions.hide.push("Partner HIV Status");

                        }
                        return conditions;
                              },
        -----*/

        'PNC, Initiated on Family Planning': function (formName, formFieldValues) {
                var InitiatedFP = formFieldValues['PNC, Initiated on Family Planning'];

                if (formName == "PostNatal Care Register") {
                        var conditions = { show: [], hide: [] };

                        if (InitiatedFP == "Yes") {
                                conditions.show.push("FP, Family Planning Method");
                        } else {
                                conditions.hide.push("FP, Family Planning Method");
                        }
                }
                return conditions;
        },




        /*--------------------------------CERVICAL CANCER SCREENING----------------------------------------------------------*/

        'Cervical Cancer Screening': function (formName, formFieldValues) {
                var CancerScreened = formFieldValues['Cervical Cancer Screening'];

                if (formName == "PostNatal Care Register") {
                        var conditions = { show: [], hide: [] };

                        if (CancerScreened == "Yes") {
                                conditions.show.push("Cervical Cancer Assessment Method");
                        } else {
                                conditions.hide.push("Cervical Cancer Assessment Method")
                                conditions.hide.push("VIA Test")
                                conditions.hide.push("Results of Pap Smear");
                        }
                }
                return conditions;
        },
        'Cervical Cancer Screening Register': function (formName, formFieldValues, patient) {
                if (formName == "Cervical Cancer Screening Register") {
                        //var conditionConcept = formFieldValues['HTC, Pregnancy Status'];
                        var patientAge = patient['age'];
                        var patientGender = patient['gender'];

                        var conditions = { show: [], hide: [], enable: [], disable: [] };

                        if (patientGender == "F" && patientAge > 12) {

                                conditions.enable.push("Cervical Cancer Screening Register");
                        }

                        else {

                                conditions.hide.push("Level of Education");
                        }
                        return conditions;
                }
        },


        'Previous Screening for CACX': function (formName, formFieldValues) {
                var PreviousCancer = formFieldValues['Previous Screening for CACX'];
                var conditions = { show: [], hide: [] };

                if (formName == "Previous Cancer Screening") {
                        if (PreviousCancer == "Yes") {
                                conditions.show.push("CACX Screening Date");
                                conditions.show.push("CACX Screening Results");
                        }
                        else {
                                conditions.hide.push("CACX Screening Date");
                                conditions.hide.push("CACX Screening Results");
                        }
                }
                return conditions;
        },

        'Type of Screening Offered': function (formName, formFieldValues) {
                var CancerAssessment = formFieldValues['Type of Screening Offered'];
                var conditions = { show: [], hide: [] };


                if (formName == "Cervical Cancer Screening Register") {

                        if (CancerAssessment == "Cervical VIA Test") {
                                conditions.show.push("VIA Test");
                                conditions.hide.push("Results of Pap Smear");

                        }
                        else if (CancerAssessment == "Pap Smear") {
                                conditions.show.push("Results of Pap Smear");
                                conditions.hide.push("VIA Test");

                        }

                        else if (CancerAssessment == "HPV Test") {
                                conditions.hide.push("Results of Pap Smear");
                                conditions.hide.push("VIA Test");

                        }

                        else if (CancerAssessment == "Both") {
                                conditions.show.push("Results of Pap Smear");
                                conditions.show.push("VIA Test");
                        }

                        else {
                                conditions.hide.push("VIA Test");
                                conditions.hide.push("Results of Pap Smear");
                        }
                }
                return conditions;
        },
        //Cervical Cancer Screening Register - Show PITC Results only when PITC has been Offered nkepanem
        'PITC Offered': function (formName, formFieldValues) {
                var CancerPitcOffered = formFieldValues['PITC Offered'];
                var conditions = { show: [], hide: [] };

                if (formName == "Cervical Cancer Screening Register") {


                        if (CancerPitcOffered == "Yes") {
                                conditions.show.push("PITC Results");
                        }


                        else {
                                conditions.hide.push("PITC Results");
                        }
                }
                return conditions;
        },

        'HIV Status': function (formName, formFieldValues) {
                var Cancerhivstatusresults = formFieldValues['HIV Status'];
                var conditions = { show: [], hide: [] };

                if (formName == "Cervical Cancer Screening Register") {


                        if (Cancerhivstatusresults == "Positive") {
                                conditions.hide.push("PITC Offered");
                                conditions.hide.push("PITC Results");
                        }


                        else {
                                conditions.show.push("PITC Offered");
                                conditions.show.push("PITC Results");
                        }
                }
                return conditions;
        },

        'PITC Offered': function (formName, formFieldValues) {
                var Cancerhivtestoffered = formFieldValues['PITC Offered'];
                var conditions = { show: [], hide: [] };

                if (formName == "Cervical Cancer Screening Register") {


                        if (Cancerhivtestoffered == "Yes") {
                                conditions.show.push("PITC Results");
                        }


                        else {
                                conditions.hide.push("PITC Results");
                        }
                }
                return conditions;
        },

        'Cervical Cancer Assessment Method': function (formName, formFieldValues) {
                var CancerAssessment = formFieldValues['Cervical Cancer Assessment Method'];

                if (formName == "PostNatal Care Register") {
                        var conditions = { show: [], hide: [] };

                        if (CancerAssessment == "VIA") {
                                conditions.show.push("VIA Test")
                                conditions.hide.push("Results of Pap Smear");
                        }
                        else if (CancerAssessment == "Pap Smear") {
                                conditions.show.push("Results of Pap Smear")
                                conditions.hide.push("VIA Test");
                        }
                        else {
                                conditions.hide.push("VIA Test")
                                conditions.hide.push("Results of Pap Smear");
                        }
                }
                return conditions;
        },

        'Refer or Consult': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['Refer or Consult'];

                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Provide nutritional support or infant feeding") {
                        conditions.show.push("HIVTC, Nutritional products");
                } else {
                        //conditions.hide.push("HIVTC, Nutritional products");
                }
                return conditions;
        },

        /*-----
           'HIVTC, Treatment substituted date' : function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HIVTC, Treatment substituted date'];
                var conditions = {enable: [], disable: [], show: [], hide: []};

                if (conditionConcept){
                    conditions.enable.push("HIVTC, Adult 1st Line Regimen")
                    conditions.enable.push("HIVTC, Adult 2nd Line Regimen")
                    conditions.enable.push("HIVTC, Children 1st Line Regimen")
                    conditions.enable.push("HIVTC, Children 2nd Line Regimen")
                    conditions.enable.push("HIVTC, Adult 3rd Line Regimen")
                    conditions.enable.push("HIVTC, Children 3rd Line Regimen")
                    conditions.enable.push("HIVTC, Reason for treatment substitution");
                }else {
                    conditions.disable.push("HIVTC, Reason for treatment substitution")
                    conditions.disable.push("HIVTC, Adult 1st Line Regimen")
                    conditions.disable.push("HIVTC, Adult 2nd Line Regimen")
                    conditions.disable.push("HIVTC, Adult 3rd Line Regimen")
                    conditions.disable.push("HIVTC, Children 1st Line Regimen")
                    conditions.disable.push("HIVTC, Children 2nd Line Regimen")
                    conditions.disable.push("HIVTC, Children 3rd Line Regimen");
                }
                return conditions;
            },
        -----*/

        'HIVTC, Treatment switched date': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HIVTC, Treatment switched date'];

                var conditions = { enable: [], disable: [] };

                if (conditionConcept) {
                        conditions.enable.push("HIVTC, Reason for treatment switch")
                        conditions.enable.push("HIVTC, Name of Switched Regimen");
                } else {
                        conditions.disable.push("HIVTC, Reason for treatment switch")
                        conditions.disable.push("HIVTC, Name of Switched Regimen");
                }
                return conditions;
        },


        'HIVTC, Viral Load Result': function (formName, formFieldValues, ViralLoadDate) {
                var conditionConcept = formFieldValues['HIVTC, Viral Load Result'];
                var viralloadDate = ViralLoadDate['HIVTC, Viral load blood results return date'];

                var conditions = { show: [], hide: [] };

                if (conditionConcept == 'Greater or equals to 20' || 'Less than 20' || 'Undetectable') {
                        //conditions.show.push("HIVTC, Date VL Results received");
                        if (conditionConcept == 'Greater or equals to 20') {
                                conditions.show.push("HIVTC, Viral Load");
                                conditions.show.push("HIVTC, Viral Load Data");
                        }
                        else {
                                conditions.hide.push("HIVTC, Viral Load");
                                conditions.hide.push("HIVTC, Viral Load Data");
                        }
                }
                else {
                        //condition.hide.push("HIVTC, Date VL Results received");
                }

                return conditions;
        },


        'HIVTC, Action to Record Viral Load Results': function (formName, formFieldValues, patient) {
                var conditionConcept = formFieldValues['HIVTC, Action to Record Viral Load Results'];
                var patientAge = patient['age'];
                var patientGender = patient['gender'];
                var conditions = { show: [], hide: [], enable: [], disable: [] };
                if (conditionConcept.includes('Viral Load Result') && !conditionConcept.includes('HIVTC, Draw Blood for VL Test')) {
                        // Visible fields
                        conditions.show.push("HIVTC, Viral Load Result");
                        conditions.show.push("HIVTC, Viral Load Data");
                        conditions.show.push("HIVTC, Viral load blood results return date");
                        conditions.show.push("HIVTC, Date VL Result given to patient");
                        // Hidden fields
                        conditions.hide.push("HIVTC, Viral Load Blood drawn date");
                        conditions.hide.push("HIVTC, VL Pregnancy Status");
                        conditions.hide.push("HIVTC, VL Breastfeeding Status");
                        conditions.hide.push("HIVTC, Viral Load Monitoring Type");
                        // Hide Pregnancy and Breastfeeding fields for Males and Young children
                        if (patientAge < 12 || patientAge > 49 || patientGender == "M") {
                                conditions.hide.push("HIVTC, VL Pregnancy Status");
                                conditions.hide.push("HIVTC, VL Breastfeeding Status");
                        }
                } else if (conditionConcept.includes('HIVTC, Draw Blood for VL Test') && !conditionConcept.includes('Viral Load Result')) {
                        conditions.show.push("HIVTC, Viral Load Blood drawn date");
                        conditions.show.push("HIVTC, VL Pregnancy Status");
                        conditions.show.push("HIVTC, VL Breastfeeding Status");
                        conditions.show.push("HIVTC, Viral Load Monitoring Type");
                        // Hidden fields
                        conditions.hide.push("HIVTC, Viral Load Result");
                        conditions.hide.push("HIVTC, Viral Load Data");
                        conditions.hide.push("HIVTC, Viral load blood results return date");
                        conditions.hide.push("HIVTC, Date VL Result given to patient");
                        // Hide Pregnancy and Breastfeeding fields for Males and Young children
                        if (patientAge < 12 || patientAge > 49 || patientGender == "M") {
                                conditions.hide.push("HIVTC, VL Pregnancy Status");
                                conditions.hide.push("HIVTC, VL Breastfeeding Status");
                        }
                } else if (conditionConcept.includes('HIVTC, Draw Blood for VL Test') && conditionConcept.includes('Viral Load Result')) {
                        // Visible fields
                        conditions.show.push("HIVTC, Viral Load Result");
                        conditions.show.push("HIVTC, Viral Load Data");
                        conditions.show.push("HIVTC, Viral load blood results return date");
                        conditions.show.push("HIVTC, Date VL Result given to patient");
                        conditions.show.push("HIVTC, Viral Load Blood drawn date");
                        conditions.show.push("HIVTC, VL Pregnancy Status");
                        conditions.show.push("HIVTC, VL Breastfeeding Status");
                        conditions.show.push("HIVTC, Viral Load Monitoring Type");
                        // Hide Pregnancy and Breastfeeding fields for Males and Young children
                        if (patientAge < 12 || patientAge > 49 || patientGender == "M") {
                                conditions.hide.push("HIVTC, VL Pregnancy Status");
                                conditions.hide.push("HIVTC, VL Breastfeeding Status");
                        }
                } else {
                        // Hide everything except Record Viral Load Results field
                        conditions.hide.push("HIVTC, Viral Load Data");
                        conditions.hide.push("HIVTC, Viral load blood results return date");
                        conditions.hide.push("HIVTC, Date VL Result given to patient");
                        conditions.hide.push("HIVTC, Viral Load Blood drawn date");
                        conditions.hide.push("HIVTC, VL Pregnancy Status");
                        conditions.hide.push("HIVTC, VL Breastfeeding Status");
                        conditions.hide.push("HIVTC, Viral Load Monitoring Type");
                        conditions.hide.push("HIVTC, Viral Load Result");
                }
                return conditions;

        },

        // 'HTC, Pregnancy Status': function (formName, formFieldValues, patient) {
        //         if ((formName == "HIV Treatment and Care Progress Template") || (formName == "HIVTC, Patient Register")) {
        //                 var conditionConcept = formFieldValues['HTC, Pregnancy Status'];
        //                 var patientAge = patient['age'];
        //                 var patientGender = patient['gender'];

        //                 var conditions = { show: [], hide: [], enable: [], disable: [] };

        //                 if (patientGender == "F" && conditionConcept == "Pregnancy") {
        //                         conditions.show.push("HIVTC, Pregnancy Estimated Date of Delivery");
        //                         conditions.hide.push("Currently on FP");
        //                         conditions.hide.push("HIVTC, FP methods used by the patient");
        //                 }
        //                 else if ((patientGender == "F" && patientAge > 12 && conditionConcept == "Pregnancy") || patientAge < 5) {
        //                         conditions.show.push("IMAM, MUAC");
        //                         if (patientAge < 5) {
        //                                 conditions.hide.push("HIVTC, Pregnancy Estimated Date of Delivery");
        //                                 conditions.hide.push("Currently on FP");
        //                                 conditions.hide.push("HIVTC, FP methods used by the patient");
        //                                 conditions.hide.push("PMTCT, Referred if the status is unknown");
        //                         }
        //                 }

        //                 else {
        //                         conditions.hide.push("IMAM, MUAC");
        //                         conditions.hide.push("HIVTC, Pregnancy Estimated Date of Delivery");
        //                         conditions.hide.push("Currently on FP");
        //                         conditions.hide.push("HIVTC, FP methods used by the patient");
        //                         conditions.hide.push("PMTCT, Referred if the status is unknown");

        //                 }
        //                 return conditions;
        //         }
        // },

        'Is Client Visitor': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['Is Client Visitor'];
                var conditions = { show: [], hide: [] };

                if (formName == 'HIV Treatment and Care Progress Template') {
                        if (conditionConcept == 'True') {
                                conditions.show.push('HIVTC, Transferred in from');
                        }
                        else {
                                conditions.hide.push('HIVTC, Transferred in from');
                        }
                }
                return conditions;
        },

        // 'TB Status': function (formName, formFieldValues) {
        //         var conditionConcept = formFieldValues['TB Status'];
        //         var conditions = { show: [], hide: [] };
        //         TBStatusTracker = conditionConcept; // assign the global variable of TB status to the selected TB status

        //         if (conditionConcept == "Suspected / Probable") {
        //                 conditions.show.push("TB Suspect signs");
        //                 if ((formName == "VMMC, Medical history") || (formName == "VMMC - Intake")) {
        //                         conditions.show.push("VMMC, Referred to TB Clinic");

        //                 }
        //         } else {
        //                 conditions.hide.push("TB Suspect signs");
        //                 if ((formName == "VMMC, Medical history") || (formName == "VMMC - Intake")) {
        //                         conditions.hide.push("VMMC, Referred to TB Clinic");

        //                 }
        //         }
        //         return conditions;
        // },
        'PNC, HIV Status Known Before Visit': function (formName, formFieldValues) {
                var status = formFieldValues['PNC, HIV Status Known Before Visit'];
                var conditions = { show: [], hide: [], assignedValues: [] };
                if (formName == "HIV Prevention, Care, and Treatment") {
                        if (status == "Positive") {
                                conditions.hide.push("Tested in PNC");
                        }
                        else {
                                conditions.show.push("Tested in PNC");
                        }
                }

                if (formName == "ANC, ANC Program") {
                        conditions.assignedValues.push({
                                field: "PNC, HIV Status Known Before Visit",
                                fieldValue: {
                                        isAutoFill: true,
                                        scopedEncounter: "latestvisit",
                                        isFilledOnRetrospectiveMode: true,
                                        enableDefaultValue: true,
                                        enableEditAfterAutoFill: true
                                }
                        });


                }


                if (formName == 'ANC HIV Testing Services') {

                        if (status == "Positive") {
                                conditions.show.push("HIV Prophylaxis/Treatment");
                                conditions.hide.push("ANC, Initiated in Prep");
                                conditions.hide.push("PMTCT, ART start date");
                                conditions.hide.push("HIVTC, ART Regimen");
                                conditions.hide.push("HIV, Program ID");
                                conditions.hide.push("PMTCT, WHO clinical staging");
                                conditions.show.push("ANC, Initial Test during this pregnancy");
                                conditions.hide.push("ANC, HIV Test Done");
                                conditions.hide.push("ANC, HIV Test Result");
                                conditions.hide.push("ANC, HIV Result Received");
                                conditions.hide.push("Subsequent HIV Test Results");
                                conditions.show.push("HIVTC, Viral Load Monitoring Template");
                        }
                        else if ((status == "Negative") || (status == "Unknown")) {
                                conditions.show.push("ANC, Initial Test during this pregnancy");
                                conditions.hide.push("ANC, HIV Test Result");
                                conditions.hide.push("ANC, HIV Result Received");
                                conditions.hide.push("Subsequent HIV Test Results");
                                conditions.hide.push("HIV Prophylaxis/Treatment");
                                conditions.hide.push("HIVTC, Viral Load Monitoring Template");
                        }
                        else {
                                conditions.hide.push("ANC, Initial Test during this pregnancy");
                        }
                }

                if ((formName == 'VMMC, HIV Screening and Testing') || (formName == "VMMC - Intake")) {
                        if (status == "Positive") {
                                conditions.show.push("Already on ART");
                                conditions.hide.push("VMMC, Accepted HIV test");
                                conditions.hide.push("VMMC, Reason");
                        } else if (status == "Negative") {
                                conditions.hide.push("Already on ART");
                                conditions.hide.push("VMMC, Accepted HIV test");
                                conditions.hide.push("VMMC, Reason");
                        } else if (status == "Unknown") {
                                conditions.hide.push("Already on ART");
                                conditions.show.push("VMMC, Accepted HIV test");
                                conditions.hide.push("VMMC, Reason");
                        } else {
                                conditions.hide.push("Already on ART");
                                conditions.hide.push("VMMC, Accepted HIV test");
                                conditions.hide.push("VMMC, Reason");
                        }
                }

                return conditions;
        },
        'Blood Group': function (formName, formFieldValues) {
                var conditions = { assignedValues: [], disable: [] };
                if (formName == "ANC, ANC Program") {
                        conditions.assignedValues.push({
                                field: "Blood Group",
                                fieldValue: {
                                        isAutoFill: true,
                                        scopedEncounter: "latestvisit",
                                        isFilledOnRetrospectiveMode: true,
                                        enableDefaultValue: true,
                                        enableEditAfterAutoFill: true,
                                }
                        });
                }
                return conditions;
        },
        'ANC, TT Doses Previous': function (formName, formFieldValues) {
                var conditions = { hide: [] };
                if (formName == "ANC, ANC Program" && visitTypeTracker == "ANC, Subsequent Visit") {
                        conditions.hide.push("ANC, TT Doses Previous");
                }
                return conditions;
        },


        /*---------------------HIV Care and Treatment-------------------*/

        'Transfer Out to another site': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['Transfer Out to another site'];
                var conditions = { show: [], hide: [] };

                if (formName == "Tuberculosis Followup Template" || formName == "TB, Transfer out") {

                        if (conditionConcept == "Yes") {
                                conditions.show.push("HIVTC, Transferred out to");
                        } else {
                                conditions.hide.push("HIVTC, Transferred out to");
                        }

                }

                if (formName == "HIV Treatment and Care Progress Template") {
                        if (conditionConcept == "Yes") {
                                conditions.show.push("HIVTC, Transferred out");

                        } else {
                                conditions.hide.push("HIVTC, Transferred out");
                        }
                }
                return conditions;
        },

        // Hide WHO staging is T-Staging is selected -- Shale
        // 'HIVTC, Treatment Staging': function (formName, formFieldValues) {
        //         var conditionConcept = formFieldValues['HIVTC, Treatment Staging'];
        //         var conditions = { show: [], hide: [] };
        //         if (conditionConcept) {
        //                 conditions.hide.push("HIVTC, HIV care WHO Staging");
        //         }
        //         else {
        //                 conditions.show.push("HIVTC, HIV care WHO Staging")
        //         }
        //         return conditions;
        // },

        'Type of client': function (formName, formFieldValues, patient) {
                var conditionConcept = formFieldValues['Type of client'];
                var conditions = { show: [], hide: [], enable: [], disable: [] };
                var patientAge = patient['age'];
                var patientGender = patient['gender'];

                /*-- Ensure that the ART regimen field is always disabled --*/
                conditions.disable.push("HIVTC, ART Regimen");


                if (conditionConcept == "ART patient") {

                        if ((patientGender == "M") || (patientAge < 12 || patientAge > 50)) {
                                // conditions.hide.push("HTC, Pregnancy Status");
                        }
                        else {
                                // conditions.show.push("HTC, Pregnancy Status");
                        }

                        //conditions.show.push("HTC, Pregnancy Status");
                        // conditions.show.push("Function");
                        // conditions.show.push("HIVTC, HIV care WHO Staging");
                        // conditions.show.push("HIVTC, Treatment Staging");
                        conditions.show.push("TB Status");
                        // conditions.show.push("TB Suspect signs");
                        // conditions.show.push("Sexually Transmitted Infection");
                        conditions.show.push("Potential Side Effects");
                        conditions.show.push("OI, Opportunistic infections");
                        conditions.show.push("Refer or Consult");
                        // conditions.show.push("Number of days hospitalised");

                }
                else {

                        // conditions.hide.push("HTC, Pregnancy Status");
                        // conditions.hide.push("Function");
                        // conditions.hide.push("HIVTC, HIV care WHO Staging");
                        // conditions.hide.push("HIVTC, Treatment Staging");
                        conditions.hide.push("TB Status");
                        // conditions.hide.push("TB Suspect signs");
                        // conditions.hide.push("Sexually Transmitted Infection");
                        conditions.hide.push("Potential Side Effects");
                        conditions.hide.push("OI, Opportunistic infections");
                        conditions.hide.push("Refer or Consult");
                        // conditions.hide.push("Number of days hospitalised");
                }

                return conditions;
        },


        /*--- ARV Drug days and drug supply duration generic autocalculations---- */
        'ART, Follow-up date': function (formName, formFieldValues) {
                if (formName == "Regimen") {
                        var followUpDate = formFieldValues['ART, Follow-up date'];
                        var conditions = { assignedValues: [], error: [] };
                        var dateUtil = Bahmni.Common.Util.DateUtil;
                        var retrospectiveDate = $.cookie(Bahmni.Common.Constants.retrospectiveEntryEncounterDateCookieName);

                        if (followUpDate) {
                                var daysDispesed;

                                if (!retrospectiveDate) {
                                        daysDispensed = dateUtil.diffInDaysRegardlessOfTime(dateUtil.now(), followUpDate);
                                } else {
                                        daysDispensed = dateUtil.diffInDaysRegardlessOfTime(dateUtil.parse(retrospectiveDate.substr(1, 10)), followUpDate);
                                }

                                // if(daysDispensed <= 0) {
                                // conditions.error.push("Invalid input for Follow-up Date, must be a date in the future. Please correct.");
                                // conditions.assignedValues.push({ field: "ARV drugs No. of days dispensed", fieldValue: daysDispensed });
                                // }
                                // else {
                                var drugSupplyPeriod = "";

                                if (daysDispensed >= 10 && daysDispensed < 21) {
                                        // Providing 3 days slack from 2 weeks, in case of weekends or other reasons
                                        drugSupplyPeriod = "HIVTC, Two weeks supply";
                                } else if (daysDispensed >= 28 && daysDispensed < 56) {
                                        drugSupplyPeriod = "HIVTC, One month supply";
                                } else if (daysDispensed >= 56 && daysDispensed < 84) {
                                        drugSupplyPeriod = "HIVTC, Two months supply";
                                } else if (daysDispensed >= 84 && daysDispensed < 112) {
                                        drugSupplyPeriod = "HIVTC, Three months supply";
                                } else if (daysDispensed >= 112 && daysDispensed < 140) {
                                        drugSupplyPeriod = "HIVTC, Four months supply";
                                } else if (daysDispensed >= 140 && daysDispensed < 168) {
                                        drugSupplyPeriod = "HIVTC, Five months supply";
                                } else if (daysDispensed >= 168 && daysDispensed < 196) {
                                        drugSupplyPeriod = "HIVTC, Six months supply";
                                } else if (daysDispensed >= 196) {
                                        drugSupplyPeriod = "HIVTC, Seven+ months supply";
                                } else {
                                        // No action
                                }

                                conditions.assignedValues.push({ field: "ARV drugs No. of days dispensed", fieldValue: daysDispensed, autocalculate: true });
                                conditions.assignedValues.push({ field: "HIVTC, ARV drugs supply duration", fieldValue: drugSupplyPeriod, autocalculate: true });

                                // }
                        }
                        return conditions;
                }
                else if (formName == "PrEP , Follow Up Template") {
                        var followUpDate = formFieldValues['ART, Follow-up date'];
                        var conditions = { assignedValues: [], error: [] };
                        var dateUtil = Bahmni.Common.Util.DateUtil;
                        var retrospectiveDate = $.cookie(Bahmni.Common.Constants.retrospectiveEntryEncounterDateCookieName);

                        if (followUpDate) {
                                var daysDispesed;

                                if (!retrospectiveDate) {
                                        daysDispensed = dateUtil.diffInDaysRegardlessOfTime(dateUtil.now(), followUpDate);
                                } else {
                                        daysDispensed = dateUtil.diffInDaysRegardlessOfTime(dateUtil.parse(retrospectiveDate.substr(1, 10)), followUpDate);
                                }

                                // if(daysDispensed <= 0) {
                                // conditions.error.push("Invalid input for Follow-up Date, must be a date in the future. Please correct.");
                                // conditions.assignedValues.push({ field: "ARV drugs No. of days dispensed", fieldValue: daysDispensed });
                                // } else {
                                var drugSupplyPeriod = "";

                                if (daysDispensed >= 10 && daysDispensed < 21) {
                                        // Providing 3 days slack from 2 weeks, in case of weekends or other reasons
                                        drugSupplyPeriod = "HIVTC, Two weeks supply";
                                } else if (daysDispensed >= 28 && daysDispensed < 56) {
                                        drugSupplyPeriod = "HIVTC, One month supply";
                                } else if (daysDispensed >= 56 && daysDispensed < 84) {
                                        drugSupplyPeriod = "HIVTC, Two months supply";
                                } else if (daysDispensed >= 84 && daysDispensed < 112) {
                                        drugSupplyPeriod = "HIVTC, Three months supply";
                                } else if (daysDispensed >= 112 && daysDispensed < 140) {
                                        drugSupplyPeriod = "HIVTC, Four months supply";
                                } else if (daysDispensed >= 140 && daysDispensed < 168) {
                                        drugSupplyPeriod = "HIVTC, Five months supply";
                                } else if (daysDispensed >= 168 && daysDispensed < 196) {
                                        drugSupplyPeriod = "HIVTC, Six months supply";
                                } else if (daysDispensed >= 196) {
                                        drugSupplyPeriod = "HIVTC, Seven+ months supply";
                                } else {
                                        // No action
                                }


                                conditions.assignedValues.push({ field: "PrEP drugs supply duration", fieldValue: drugSupplyPeriod, autocalculate: true });
                                conditions.assignedValues.push({ field: "ARV drugs No. of days dispensed", fieldValue: daysDispensed, autocalculate: true });


                                // }
                        }
                        return conditions;

                }
        },
        /*--- TB number of days dispensed generic autocalculation----*/
        'TB, Next appointment/refill date': function (formName, formFieldValues) {
                if (formName == "Tuberculosis Followup Template") {
                        var followUpDate = formFieldValues['TB, Next appointment/refill date'];
                        var conditions = { assignedValues: [], error: [] };
                        var dateUtil = Bahmni.Common.Util.DateUtil;
                        var retrospectiveDate = $.cookie(Bahmni.Common.Constants.retrospectiveEntryEncounterDateCookieName);

                        if (followUpDate) {
                                var daysDispesed;

                                if (!retrospectiveDate) {
                                        daysDispensed = dateUtil.diffInDaysRegardlessOfTime(dateUtil.now(), followUpDate);
                                } else {
                                        daysDispensed = dateUtil.diffInDaysRegardlessOfTime(dateUtil.parse(retrospectiveDate.substr(1, 10)), followUpDate);
                                }

                                conditions.assignedValues.push({ field: "ARV drugs No. of days dispensed", fieldValue: daysDispensed, autocalculate: true });

                        }
                        return conditions;
                }
        },
        'Type Of Lab Test': function (formName, formFieldValues) {
                var conditions = { show: [], hide: [] };
                var showTest = formFieldValues['Type Of Lab Test']

                if (formName == 'Lab Test') {
                        if (showTest == 'Tuberculosis') {
                                conditions.show.push('Tuberculosis Lab Test');
                                conditions.hide.push('Viral Load Lab Test');

                        }
                        else if (showTest == 'HIVTC, Lab Test, Viral Load') {
                                conditions.hide.push('Tuberculosis Lab Test');
                                conditions.show.push('Viral Load Lab Test');
                        }
                        else {
                                conditions.hide.push('Tuberculosis Lab Test');
                                conditions.hide.push('Viral Load Lab Test');

                        }
                        console.log(showTest);
                }
                return conditions;
        },
        /*--- EDD generic autocalculation----*/
        'ANC, Last Normal Menstrual Period': function (formName, formFieldValues) {
                var conditions = { assignedValues: [], error: [] };
                var LNMP = formFieldValues['ANC, Last Normal Menstrual Period'];
                var dateUtil = Bahmni.Common.Util.DateUtil;

                if (formName == "ANC, Obstetric History" || formName == "ANC, Examinations") {

                        var LNMPDate = new Date(LNMP);
                        var EDDWithTime = dateUtil.addDays(LNMPDate, 280);
                        var EDDWithoutTime = dateUtil.getDateWithoutTime(EDDWithTime);
                        var AncVisits = formFieldValues["ANC, Visit Types"];
                        if (AncVisits == "Subsquent Visit") {
                                conditions.assignedValues.push({
                                        field: "ANC, Parity",
                                        fieldValue: {
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: true,
                                                enableEditAfterAutoFill: true
                                        }
                                });
                        }
                        if (LNMP) {
                                conditions.assignedValues.push({ field: "ANC, Estimated Date of Delivery", fieldValue: EDDWithoutTime, autocalculate: true });
                        }
                }
                if (formName == "ANC, ANC Program") {
                        conditions.assignedValues.push({
                                field: "ANC, Last Normal Menstrual Period",
                                fieldValue: {
                                        isAutoFill: true,
                                        scopedEncounter: "latestvisit",
                                        isFilledOnRetrospectiveMode: true,
                                        enableDefaultValue: true,
                                        enableEditAfterAutoFill: true
                                }
                        });

                }
                return conditions;
        },
        'ANC, Estimated Date of Delivery': function (formName, formFieldValues) {
                var conditions = { assignedValues: [], disable: [] };
                var conditionConcept;
                if (formName == "ANC, ANC Program") {
                        conditions.assignedValues.push({
                                field: "ANC, Estimated Date of Delivery",
                                fieldValue: {
                                        isAutoFill: true,
                                        scopedEncounter: "latestvisit",
                                        isFilledOnRetrospectiveMode: true,
                                        enableDefaultValue: true,
                                        enableEditAfterAutoFill: true
                                }
                        });

                }
                return conditions;
        },

        'HIVTC, Enhanced adherence counseling done': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HIVTC, Enhanced adherence counseling done'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("HIVTC, Enhanced adherence counseling monitoring set");
                } else {
                        conditions.hide.push("HIVTC, Enhanced adherence counseling monitoring set");
                }
                return conditions;
        },

        'HIVTC, HIV care IPT started': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HIVTC, HIV care IPT started'];
                var conditions = { assignedValues: [], show: [], hide: [] };

                if (conditionConcept == "Treatment complete") {
                        conditions.show.push("HIVTC, TPT completion Date");


                }

                else if (conditionConcept == "Yes") {
                        // conditions.show.push("IPT Adherence");
                        // conditions.show.push("IPT No. of days dispensed");
                } else {
                        // conditions.hide.push("IPT Adherence");
                        // conditions.hide.push("IPT No. of days dispensed");
                        conditions.hide.push("HIVTC, TPT completion Date");
                }

                if (formName == "HIVTC, Patient Register" || formName == "HIV Treatment and Care Progress Template") {
                        conditions.assignedValues.push({
                                field: "HIVTC, HIV care IPT started",
                                fieldValue: {
                                        isAutoFill: true,
                                        scopedEncounter: "latestvisit",
                                        isFilledOnRetrospectiveMode: true,
                                        enableDefaultValue: true,
                                        enableEditAfterAutoFill: true
                                }
                        });
                }
                return conditions;
        },

        'ARV Treatment Substituted': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['ARV Treatment Substituted'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("HIVTC, Treatment Substitution");
                } else {
                        conditions.hide.push("HIVTC, Treatment Substitution");
                }
                return conditions;
        },

        'ARV Treatment Switch to another line': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['ARV Treatment Switch to another line'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("HIVTC, Treatment Switch");
                } else {
                        conditions.hide.push("HIVTC, Treatment Switch");
                }
                return conditions;
        },

        'ARV Treatment Interrupted': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['ARV Treatment Interrupted'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("ARV treatment interruptions Set");
                } else {
                        conditions.hide.push("ARV treatment interruptions Set");
                }
                return conditions;
        },

        'ART test results from Lab': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['ART test results from Lab'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("HIVTC, ART Lab Test Results");
                        //conditions.hide.push("HIVTC, Viral load blood results return date");
                        //conditions.hide.push("HIVTC, Viral Load");
                } else {
                        conditions.hide.push("HIVTC, ART Lab Test Results");
                }
                return conditions;
        },


        'ART Treatment interruption type': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['ART Treatment interruption type'];

                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Stopped") {
                        conditions.show.push("ART treatment interruption stopped reason");
                } else {
                        conditions.hide.push("ART treatment interruption stopped reason");
                }
                return conditions;
        },

        'HIVTC, ART Treatment Adherence': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HIVTC, ART Treatment Adherence'];

                var conditions = { show: [], hide: [] };

                if ((conditionConcept == "Poor adherence") || (conditionConcept == "Fair adherence")) {
                        conditions.show.push("Poor or Fair ART adherence reason");
                } else {
                        conditions.hide.push("Poor or Fair ART adherence reason");
                }
                return conditions;
        },

        'HIVTC, Status at enrolment': function (formName, formFieldValues, patient) {
                var patientAge = patient['age'];
                var patientGender = patient['gender'];

                if (patientAge < 1) {
                        return {
                                // show: ["ART, HIV Exposed Baby"]
                        }
                } else {
                        return {
                                // hide: ["ART, HIV Exposed Baby"]
                        }
                }
        },
        /*--------------------- HIV TESTING AND COUNSELING (HTC)----------------------*/

        'HTC, Initiated Testing and Counseling': function (formName, formFieldValues) {
                if (formName == "HIV Testing and Counseling Intake Template") {
                        var citcOrPitc = formFieldValues['HTC, Initiated Testing and Counseling'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };
                        console.log("citcOrPitc", !citcOrPitc);
                        if(!citcOrPitc){
                                conditions.hide.push("Testing Eligibility, Tested For HIV");
                        }
                        else{
                                conditions.show.push("Testing Eligibility, Tested For HIV");
                        }
                        return conditions;
                }
        },
        'Testing Eligibility, Last Test Results': function (formName, formFieldValues) {
                if (formName == "HIV Testing and Counseling Intake Template") {
                        var lastResults=formFieldValues['Testing Eligibility, Last Test Results'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };     
                                
                        if(lastResults){
                                console.log(lastResults, lastResults);
                                if(lastResults=="Positive"){
                                        conditions.hide.push("HTC, Post-test Counseling Set");
                                        conditions.hide.push("HTC, HIV Test");
                                        conditions.show.push("Testing Eligibility, Time Last Test Done");
                                        conditions.hide.push("HTC, Pre-test Counseling Set");
                                }
                                else if(lastResults=="Negative" || lastResults == "Do Not Know"){
                                        conditions.show.push("HTC, Post-test Counseling Set");
                                        conditions.show.push("HTC, HIV Test");
                                        conditions.show.push("HTC, Pre-test Counseling Set");
                                        conditions.show.push("Testing Eligibility, Time Last Test Done");
                                }
                                
                        }
                        else{
                                // conditions.hide.push("HTC, Pre-test Counseling Set");
                                conditions.hide.push("Testing Eligibility, Time Last Test Done");
                        }
                        return conditions;
                }
        },
        'HTC, Pre-test Counseling Set': function (formName, formFieldValues) {
                
                var conditions = { show: [], hide: [], enable: [], disable: [] };
                if (formName == "HIV Testing and Counseling Intake Template") {
                        conditions.hide.push("HTC, Declined");
                        conditions.hide.push("HTC, Result if tested");
                }
                return conditions;
        },
        'HTC, HIV Test': function (formName, formFieldValues) {
                
                var conditions = { show: [], hide: [], enable: [], disable: [] };
                if (formName == "HIV Testing and Counseling Intake Template") {
                        conditions.hide.push("HTC, HIV Dual Test");
                        conditions.hide.push("HTC, Initial HIV Test Determine");
                        conditions.hide.push("HTC, Initial HIV Test Unigold Confirmatory");
                        conditions.hide.push("HTC, HIV Test Meriscreen");
                        conditions.hide.push("HTC, Repeat HIV Test Determine");
                        conditions.hide.push("HTC, DNA PCR Test Results");
                }
                        
                return conditions;
        },
        'Testing Eligibility, Tested For HIV': function (formName, formFieldValues) {
                if (formName == "HIV Testing and Counseling Intake Template") {
                        var everTestedForHIV = formFieldValues['Testing Eligibility, Tested For HIV'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };
                        if(everTestedForHIV){
                                if (everTestedForHIV == "Yes") {
                                        console.log("yes",everTestedForHIV);
                                        conditions.hide.push("HTC, Post-test Counseling Set");
                                        conditions.hide.push("HTC, Pre-test Counseling Set");
                                        conditions.hide.push("HTC, HIV Test");
                                        conditions.show.push("Testing Eligibility, Last Test Results");
                                        conditions.hide.push("Testing Eligibility, Time Last Test Done");
                                                                
                                }
                                else if (everTestedForHIV == "No") {
                                        console.log("No",everTestedForHIV);
                                        conditions.show.push("HTC, Post-test Counseling Set");
                                        conditions.show.push("HTC, Pre-test Counseling Set");
                                        conditions.show.push("HTC, HIV Test");
                                        conditions.hide.push("Testing Eligibility, Time Last Test Done");
                                        conditions.hide.push("Testing Eligibility, Last Test Results");
                                }
                                return conditions;
                        }
                        else{
                                conditions.hide.push("HTC, Post-test Counseling Set");
                                conditions.hide.push("HTC, HIV Test");
                                conditions.hide.push("HTC, Pre-test Counseling Set");
                                conditions.hide.push("Testing Eligibility, Time Last Test Done");
                                conditions.hide.push("Testing Eligibility, Last Test Results");
                                return conditions;
                        }
                        
                }
        },
        
        'HTC, Initial HIV Test Determine': function (formName, formFieldValues) {
                var conditions = { show: [], hide: [] };
                var initialHIVTestDetermine = formFieldValues['HTC, Initial HIV Test Determine'];
                if (formName == "HIV Testing and Counseling Intake Template" || formName == "HTC, HIV Test") {
                        if (initialHIVTestDetermine) {
                                if (initialHIVTestDetermine == "Positive") {
                                        conditions.show.push("HTC, Initial HIV Test Unigold Confirmatory");
                                        conditions.show.push("HTC, Repeat HIV Test Determine");
                                        conditions.show.push("HTC, HIV Test Meriscreen");
                                        conditions.show.push("HTC, DNA PCR Test Results");
                                }
                                else{
                                        conditions.hide.push("HTC, Initial HIV Test Unigold Confirmatory");
                                        conditions.hide.push("HTC, Repeat HIV Test Determine");
                                        conditions.hide.push("HTC, HIV Test Meriscreen");
                                        conditions.hide.push("HTC, DNA PCR Test Results");
                                }
                                return conditions;
                        }
                }
        },

        // 'HTC, Initial HIV Test Determine': function (formName, formFieldValues, patient) {

        //         if ((formName == "HTC, HIV Test") || (formName == "HIV Testing and Counseling Intake Template") ||
        //                 (formName == "HIV Testing Services Retesting Template")) {
        //                 var determineResult = formFieldValues['HTC, Initial HIV Test Determine'];
        //                 var conditions = { show: [], hide: [], disable: [] };

        //                 if (determineResult == "Positive") {
        //                         conditions.show.push("HTC, Initial HIV Test Unigold Confirmatory")
        //                         return conditions;
        //                 }
        //                 if (determineResult == "Negative") {
        //                         for (var i = 0; i < formFieldValues['HTC, Final HIV status'].length, i++) {

        //                         }
        //                         conditions.hide.push("HTC, Linked To Care");
        //                         conditions.disable.push();
        //                         conditions.hide.push("HTC, Initial HIV Test Unigold Confirmatory")
        //                         conditions.hide.push("HTC, Repeat HIV Test Determine")
        //                         conditions.hide.push("HTC, Repeat Unigold Test")
        //                         conditions.hide.push("HTC, SD Bioline Tie Breaker")
        //                         conditions.hide.push("HTC, DNA PCR Test Results");
        //                         return conditions;
        //                 }
        //         }

        // },ANC, Estimated Date of Delivery

        // 'HTC, HIV Test':function(formName, formFieldValues){
        //         if ((formName == "HTC, HIV Test") || (formName == "HIV Testing Services Retesting Template")) {
        //                 var determineResult = formFieldValues['HTC, Initial HIV Test Determine'];
        //                 var conditions = { show: [], hide: [] };
        //                 if(!determineResult){
        //                         conditions.hide.push("HTC, Initial HIV Test Unigold Confirmatory")
        //                         conditions.hide.push("HTC, Repeat HIV Test Determine")
        //                         conditions.hide.push("HTC, Repeat Unigold Test")
        //                         conditions.hide.push("HTC, SD Bioline Tie Breaker")
        //                         conditions.hide.push("HTC, DNA PCR Test Results");
        //                 }
                        
        //         }
        //         return conditions;       
        // },

        // 'HTC, Initial HIV Test Determine': function (formName, formFieldValues, patient) {

        //         if ( (formName == "HIV Testing Services Retesting Template")) {
        //                 var determineResult = formFieldValues['HTC, Initial HIV Test Determine'];
        //                 var conditions = { show: [], hide: [] };
                       
        //                 if (determineResult == "Positive") {
        //                         conditions.show.push("HTC, Initial HIV Test Unigold Confirmatory")
        //                 }
        //                 else {
        //                         conditions.hide.push("HTC, Initial HIV Test Unigold Confirmatory")
        //                         conditions.hide.push("HTC, Repeat HIV Test Determine")
        //                         conditions.hide.push("HTC, Repeat Unigold Test")
        //                         conditions.hide.push("HTC, SD Bioline Tie Breaker")
        //                         conditions.hide.push("HTC, DNA PCR Test Results");
        //                 }
        //         }
        //         return conditions;
        // },


        // 'HTC, Initial HIV Test Unigold Confirmatory': function (formName, formFieldValues) {

        //         if ((formName == "HIV Testing Services Retesting Template")) {
        //                 var unigoldResult = formFieldValues['HTC, Initial HIV Test Unigold Confirmatory'];
        //                 var determineResults = formFieldValues['HTC, Initial HIV Test Determine'];
        //                 var conditions = { show: [], hide: [], enable: [], disable: [] };

        //                 if ((unigoldResult == "Negative") && (determineResults == "Positive")) {
        //                         conditions.show.push("HTC, Repeat HIV Test Determine")
        //                         conditions.show.push("HTC, Repeat Unigold Test");
        //                 }
        //                 else {
        //                         conditions.hide.push("HTC, SD Bioline Tie Breaker")
        //                         conditions.hide.push("HTC, DNA PCR Test Results")
        //                         conditions.hide.push("HTC, Repeat HIV Test Determine")
        //                         conditions.hide.push("HTC, Repeat Unigold Test");

        //                 }
        //                 return conditions;
        //         }
        // },

        // 'HTC, Repeat Unigold Test': function (formName, formFieldValues) {

        //         if ((formName == "HIV Testing Services Retesting Template")) {
        //                 var unigoldRepeat = formFieldValues['HTC, Repeat Unigold Test'];
        //                 var determineRepeat = formFieldValues['HTC, Repeat HIV Test Determine'];
        //                 var conditions = { show: [], hide: [], enable: [], disable: [] };

        //                 if ((unigoldRepeat == "Negative" && determineRepeat == "Positive") || (unigoldRepeat == "Positive" && determineRepeat == "Negative")) {
        //                         conditions.show.push("HTC, SD Bioline Tie Breaker");
        //                 }
        //                 else {
        //                         conditions.hide.push("HTC, SD Bioline Tie Breaker");

        //                 }
        //                 return conditions;
        //         }
        // },

        // 'HTC, SD Bioline Tie Breaker': function (formName, formFieldValues) {

        //         if ((formName == "HIV Testing Services Retesting Template")) {
        //                 var sdBiolineResult = formFieldValues['HTC, SD Bioline Tie Breaker'];
        //                 var conditions = { show: [], hide: [], enable: [], disable: [] };

        //                 if (sdBiolineResult == "Positive") {
        //                         conditions.show.push("HTC, DNA PCR Test Results");
        //                 }
        //                 else {
        //                         conditions.hide.push("HTC, DNA PCR Test Results");

        //                 }
        //                 return conditions;
        //         }
        // },

        
        
        /*-----
        'HTC, Linked To Care' : function (formName, formFieldValues) {

                if((formName=="HIV Testing and Counseling Intake Template") || (formName=="HIV Testing Services Retesting Template") ) {
                        var careLink = formFieldValues['HTC, Linked To Care'];
                        var conditions = {show: [], hide: [], enable: [], disable: []};

                        if(careLink == "Yes") {
                                conditions.show.push("HTC, Date Linked To Care");
                                conditions.hide.push("HTC, Referred Facility");
                        }
                        else if(careLink == "Referred") {
                                conditions.show.push("HTC, Referred Facility");
                                conditions.hide.push("HTC, Date Linked To Care");
                        }
                        else{
                                conditions.hide.push("HTC, Date Linked To Care")
                                conditions.hide.push("HTC, Referred Facility");
                        }
                        return conditions;
                }
        },
        -----*/

        'HTC, Linked To Care': function (formName, formFieldValues) {

                if ((formName == "HIV Testing Services Retesting Template")) {
                        var careLink = formFieldValues['HTC, Linked To Care'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };

                        if (careLink == "Yes") {
                                // conditions.show.push("HTC, Date Linked To Care");
                                conditions.hide.push("HTC, Referred Facility");
                                conditions.hide.push("HTC, Specify");
                        }
                        if (careLink == "No") {
                                conditions.show.push("HTC, Specify");
                                // conditions.hide.push("HTC, Date Linked To Care");
                                conditions.hide.push("HTC, Referred Facility");
                        }
                        else if (careLink == "Referred") {
                                conditions.show.push("HTC, Referred Facility");
                                // conditions.hide.push("HTC, Date Linked To Care");
                                conditions.hide.push("HTC, Specify");
                        }
                        else {
                                // conditions.hide.push("HTC, Date Linked To Care")
                                conditions.hide.push("HTC, Specify")
                                conditions.hide.push("HTC, Referred Facility");
                        }
                        return conditions;
                }
        },


        'HIVTC, Adult 2nd Line Regimen': function (formName, formFieldValues) {
                var subDate = formFieldValues['HIVTC, Adult 2nd Line Regimen'];

                var conditions = { enable: [], disable: [] };

                if (subDate) {
                        conditions.disable.push("HIVTC, Reason for treatment substitution")
                        conditions.disable.push("HIVTC, Adult 1st Line Regimen")
                        //conditions.disable.push("HIVTC, Adult 2nd Line Regimen")
                        conditions.disable.push("HIVTC, Adult 3rd Line Regimen")
                        conditions.disable.push("HIVTC, Children 1st Line Regimen")
                        conditions.disable.push("HIVTC, Children 2nd Line Regimen")
                        conditions.disable.push("HIVTC, Children 3rd Line Regimen");
                } else {
                        conditions.enable.push("HIVTC, Reason for treatment substitution")
                        conditions.enable.push("HIVTC, Adult 1st Line Regimen")
                        //conditions.enable.push("HIVTC, Adult 2nd Line Regimen")
                        conditions.enable.push("HIVTC, Adult 3rd Line Regimen")
                        conditions.enable.push("HIVTC, Children 1st Line Regimen")
                        conditions.enable.push("HIVTC, Children 2nd Line Regimen")
                        conditions.enable.push("HIVTC, Children 3rd Line Regimen");
                }
                return conditions;
        },


        'AHD Client': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['AHD Client'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        // conditions.show.push("AHD Details");
                } else {
                        // conditions.hide.push("AHD Details");
                }
                return conditions;
        },

        // 'Detailed TPT Information': function (formName, formFieldValues) {
        //         var conditionConcept = formFieldValues['Detailed TPT Information'];
        //         var conditions = { show: [], hide: [] };

        //         if (conditionConcept == "Yes") {
        //                 conditions.show.push("TPT Information");
        //         } else {
        //                 conditions.hide.push("TPT Information");
        //         }
        //         return conditions;
        // },

        'HTC, Distribution Mode': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HTC, Distribution Mode'];
                var SecondarySelfTest = formFieldValues['Take Secondary Self Test'];
                var testedForHIV = formFieldValues['Testing Eligibility, Tested For HIV'];
                var conditions = { show: [], hide: [] };
                conditionConcept = conditionConcept.sort();


                if (JSON.stringify(conditionConcept) === JSON.stringify(['HTC, Secondary', 'HTC, Secondary'])) {
                        conditions.show.push("Self_Test_Buddy");
                        conditions.show.push("HTC, Kit Collected For");
                        conditions.hide.push("HTC, HIVST Results");
                        conditions.show.push("HTC, Date Of Distribution","HTC, Date Of Distribution","HTC, Distribution channel", "HTC, Key Pop");


                } else if (JSON.stringify(conditionConcept) === JSON.stringify(['HTC, Primary', 'HTC, Primary', 'HTC, Secondary', 'HTC, Secondary'])) {
                        conditions.show.push("HTC, Date Of Distribution", "HTC, Key Pop","HTC, Distribution channel", "HTC, HIVST Results");
                        if(testedForHIV == "No"){
                                conditions.hide.push("HTC, Tested for HIV in The Past 12 Months");    
                        }
                        else{
                                conditions.show.push("HTC, Tested for HIV in The Past 12 Months");       
                        }
                        conditions.show.push("Self_Test_Buddy");
                        conditions.show.push("HTC, Kit Collected For");
                        conditions.show.push("HTC, HIVST Results");


                } else if (JSON.stringify(conditionConcept) === JSON.stringify(['HTC, Primary', 'HTC, Primary'])) {
                        conditions.hide.push("Self_Test_Buddy");
                        conditions.hide.push("HTC, Kit Collected For");
                        conditions.show.push("HTC, Date Of Distribution","HTC, Distribution channel", "HTC, Key Pop", "HTC, HIVST Results");
                        if(testedForHIV == "No"){
                                conditions.hide.push("HTC, Tested for HIV in The Past 12 Months");    
                        }
                        else{
                                conditions.show.push("HTC, Tested for HIV in The Past 12 Months");       
                        }
                }
                // else if(JSON.stringify(conditionConcept) === JSON.stringify([])){
                //         if(SecondarySelfTest == "Yes"){
                //                 conditions.show.push("Self_Test_Buddy");
                //                 conditions.show.push("HTC, Kit Collected For");
                //                 conditions.show.push("HTC, Date Of Distribution","HTC, Distribution channel", "HTC, Key Pop");   
                //         }
                //         else{
                //                 conditions.hide.push("Self_Test_Buddy");
                //                 conditions.hide.push("HTC, Kit Collected For");
                //                 conditions.hide.push("HTC, Date Of Distribution","HTC, Distribution channel", "HTC, Key Pop", "HTC, Tested for HIV in The Past 12 Months", "HTC, HIVST Results");
                //         }
                // }
                
                return conditions;
        },



        /*'Testing Eligibility, Last 12 Months': function (formName, formFieldValues) {
                if (formName == "HIV Testing and Counseling Intake Template") {
                        var months = formFieldValues['Testing Eligibility, Last 12 Months'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };

                        if (months == "Had sex with more than 1 sexual partner" ||
                                months == "Had unprotected sex with HIV+ partner" ||
                                months == "Had unprotected sex with partner of unknown HIV status" ||
                                months == "Had /currently have genital sores and/ or discharge" ||
                                months == "None") {
                                conditions.show.push("Test For HIV");
                                conditions.show.push("Offered prevention Counselling and or Linked to prevention services")
                        }
                        
                        return conditions;
                }
        },
        /*
               ------------------------------------------------------
                                Contact index tracing formConditions
               -------------------------------------------------------
         */

        'HTSIDX, Index accepted Index Testing Service': function (formName, formFieldValues) {
                var acceptedIndexing = formFieldValues['HTSIDX, Index accepted Index Testing Service'];

                var conditions = { show: [], hide: [], enable: [], disable: [] };

                if (acceptedIndexing == "Yes") {
                        conditions.show.push("HTSIDX, Index UIC");
                        conditions.show.push("HTSIDX, Index Contact Information");

                        // Show prior tests conditikons
                        conditions.hide.push("HTSIDX, Prior Test Result");
                        conditions.hide.push("HTSIDX, Duration since last test");


                        // Hide conditions if the contact has prior tests and the client knows their status
                        conditions.hide.push("HTSIDX,Tested");
                        conditions.hide.push("HTSIDX, IF No, why");
                        conditions.hide.push("HTSIDX,Date partner/child tested");
                        conditions.hide.push("HTSIDX,Partner/ Child Test Result");
                        conditions.hide.push("HTSIDX,Linked to care and treatment");
                        conditions.hide.push("HTSIDX,Partner/Child's PRE/ART Number");
                        conditions.hide.push("HTSIDX,Referral to Prevention");

                } else {
                        conditions.hide.push("HTSIDX, Index UIC");
                        conditions.hide.push("HTSIDX, Index Contact Information");
                }
                return conditions;
        },

        'HTSIDX, Prior Tested Before Status': function (formName, formFieldValues) {
                var pirorTest = formFieldValues['HTSIDX, Prior Tested Before Status'];

                var conditions = { show: [], hide: [], enable: [], disable: [] };

                if (pirorTest == "Yes") {
                        var positive_priorTest = formFieldValues['HTSIDX, Prior Test Result'];
                        // Show prior tests conditikons
                        conditions.show.push("HTSIDX, Prior Test Result");
                        conditions.show.push("HTSIDX, Duration since last test");

                        // Hide conditions if the contact has prior tests and the client knows their status
                        conditions.show.push("HTSIDX,Tested");
                        conditions.show.push("HTSIDX, IF No, why");
                        conditions.hide.push("HTSIDX,Date partner/child tested");
                        conditions.hide.push("HTSIDX,Partner/ Child Test Result");
                        conditions.hide.push("HTSIDX,Linked to care and treatment");
                        conditions.hide.push("HTSIDX,Partner/Child's PRE/ART Number");
                        conditions.show.push("HTSIDX,Referral to Prevention");

                } else if (pirorTest == "No") {

                        //Hide prior tests conditikons if the
                        conditions.hide.push("HTSIDX, Prior Test Result");
                        conditions.hide.push("HTSIDX, Duration since last test");

                        // Show conditions if the contact has no prior tests and the client knows their status
                        conditions.show.push("HTSIDX,Tested");
                        conditions.show.push("HTSIDX, IF No, why");
                        conditions.hide.push("HTSIDX,Date partner/child tested");
                        conditions.show.push("HTSIDX,Partner/ Child Test Result");
                        conditions.show.push("HTSIDX,Linked to care and treatment");
                        conditions.show.push("HTSIDX,Partner/Child's PRE/ART Number");
                        conditions.show.push("HTSIDX,Referral to Prevention");
                } else {

                        // Show prior tests conditikons
                        conditions.hide.push("HTSIDX, Prior Test Result");
                        conditions.hide.push("HTSIDX, Duration since last test");

                        // Hide conditions if the contact has prior tests and the client knows their status
                        conditions.hide.push("HTSIDX,Tested");
                        conditions.hide.push("HTSIDX, IF No, why");
                        conditions.hide.push("HTSIDX,Date partner/child tested");
                        conditions.hide.push("HTSIDX,Partner/ Child Test Result");
                        conditions.hide.push("HTSIDX,Linked to care and treatment");
                        conditions.hide.push("HTSIDX,Partner/Child's PRE/ART Number");
                        conditions.hide.push("HTSIDX,Referral to Prevention");
                }
                return conditions;
        },

        'HTSIDX,Tested': function (formName, formFieldValues) {
                console.log(formName);
                var tested = formFieldValues['HTSIDX,Tested'];

                var conditions = { show: [], hide: [], enable: [], disable: [] };
                if(formName != "HIV Testing and Counseling Intake Template" && formName != "HTC, Pre-test Counseling Set"){
                        

                        if (tested == "Yes") {
                                conditions.show.push("HTSIDX,Partner/ Child Test Result");
                                conditions.show.push("HTSIDX,Linked to care and treatment");
                                conditions.show.push("HTSIDX,Partner/Child's PRE/ART Number");

                                conditions.hide.push("HTSIDX, IF No, why");
                                conditions.hide.push("HTSIDX,Date partner/child tested");
                                conditions.show.push("HTSIDX,Referral to Prevention");

                        } else if (tested == "No") {

                                conditions.show.push("HTSIDX, IF No, why");
                                conditions.hide.push("HTSIDX,Partner/ Child Test Result");
                                conditions.hide.push("HTSIDX,Linked to care and treatment");
                                conditions.hide.push("HTSIDX,Partner/Child's PRE/ART Number");

                                conditions.show.push("HTSIDX,Referral to Prevention");
                        } else {

                                // Did the client test during their visit to the facility
                                conditions.hide.push("HTSIDX,Partner/ Child Test Result");
                                conditions.hide.push("HTSIDX,Linked to care and treatment");
                                conditions.hide.push("HTSIDX,Partner/Child's PRE/ART Number");
                        }
                        return conditions;
                }
                else if (formName == "HTC, Pre-test Counseling Set") {
                        console.log("yes",tested);
                        if(tested == "Yes"){
                                conditions.hide.push("HTC, Declined");
                                conditions.show.push("HTC, Result if tested");
                        }
                        else if(tested == "No"){
                                conditions.show.push("HTC, Declined");
                                conditions.hide.push("HTC, Result if tested");
                        }
                        else{
                                conditions.hide.push("HTC, Declined");
                                conditions.hide.push("HTC, Result if tested");
                        }
                        return conditions;
                }
        },
        /* Auto populate forms in PNC,REGISTER form */

        'Delivery date and time': function (formName, formFieldValues) {
                var conditions = { assignedValues: [], disable: [] };

                if (formName == "PostNatal Care Register" || formName == "Delivery Information") {
                        conditions.assignedValues.push({
                                field: "Delivery date and time",
                                fieldValue: {
                                        isAutoFill: true,
                                        scopedEncounter: "latestvisit",
                                        isFilledOnRetrospectiveMode: true,
                                        enableDefaultValue: true,
                                        enableEditAfterAutoFill: true
                                }
                        });
                }
                return conditions;
        },

        'Mode of Delivery': function (formName, formFieldValues) {
                var conditions = { assignedValues: [], disable: [] };
                var conditionConcept;
                if (formName == "PostNatal Care Register" || formName == "Delivery Information") {
                        conditions.assignedValues.push({
                                field: "Mode of Delivery",
                                fieldValue: {
                                        isAutoFill: true,
                                        scopedEncounter: "latestvisit",
                                        isFilledOnRetrospectiveMode: true,
                                        enableDefaultValue: true,
                                        enableEditAfterAutoFill: true
                                }
                        });
                }
                return conditions;
        },
        //Autofill TPT completed date - Litsitso Masoebe and Kgomotjo Seipobi
        'HIVTC, TPT completion Date': function (formName, formFieldValues) {
                var conditions = { assignedValues: [], disable: [] };
                var conditionConcept;
                if (formName == "HIVTC, Patient Register" || formName == "HIV Treatment and Care Progress Template") {
                        conditions.assignedValues.push({
                                field: "HIVTC, TPT completion Date",
                                fieldValue: {
                                        isAutoFill: true,
                                        scopedEncounter: "latestvisit",
                                        isFilledOnRetrospectiveMode: true,
                                        enableDefaultValue: true,
                                        enableEditAfterAutoFill: true
                                }
                        });

                }
                return conditions;
        },
        'PrEP ,Entry Point Mode': function (formName, formFieldValues, patient) {
                var EntryMode = formFieldValues['PrEP ,Entry Point Mode'];

                if ((formName == "PrEP , Intake Template") || (formName == "PrEP ,Entry point")) {
                        var conditions = { show: [], hide: [] };


                        if (EntryMode == "PrEP Community Entry Point") {
                                conditions.show.push("PrEP  Entry Point  Community");
                                conditions.hide.push("PrEP , Health Facility")

                        } else if (EntryMode == "PrEP Health Facility Entry Point") {
                                conditions.show.push("PrEP , Health Facility");
                                conditions.hide.push("PrEP  Entry Point  Community");



                        } else {

                                conditions.hide.push("PrEP , Health Facility")
                                conditions.hide.push("PrEP  Entry Point  Community");

                        }
                }
                return conditions;
        },
        'PrEP, Indication for stopping PrEP': function (formName, formFieldValues) {
                var EntryMode = formFieldValues['PrEP, Indication for stopping PrEP'];

                if ((formName == "PrEP , Follow Up Template") || (formName == "PrEP ,Stopping PrEP")) {
                        var conditions = { show: [], hide: [] };

                        if (EntryMode == "PrEP Stopped Due To New HIV status") {
                                conditions.show.push("PrEP stopped due to new HIV infection")

                        } else {
                                conditions.hide.push("PrEP stopped due to new HIV infection")
                        }

                }

                return conditions;
        },

        'PrEP , Pregnancy Test': function (formName, formFieldValues, patient) {
                var EntryMode = formFieldValues['PrEP , Pregnancy Test'];
                var patientGender = patient['gender'];

                if ((formName == "PrEP , Intake Template") || (formName == "PrEP ,Other Tests")) {
                        var conditions = { show: [], hide: [] };

                        if (EntryMode && patientGender == "F") {
                                conditions.show.push("PrEP , Pregnancy Status")


                        } else {

                                conditions.hide.push("PrEP , Pregnancy Status")


                        }
                }
                return conditions;
        },





        'PrEP, STI Screening OrTreatment': function (formName, formFieldValues) {
                var EntryMode = formFieldValues['PrEP, STI Screening OrTreatment'];
                var conditions = { show: [], hide: [] };



                if ((formName == "PrEP , Follow Up Template") || (formName == "PrEP, STI Screening and Treatment")) {


                        if (EntryMode == "PrEP , Treatment") {
                                conditions.show.push("PrEP, STI Treatment");
                                conditions.hide.push("PrEP, STI Screening");



                        } else if (EntryMode == "PrEP , Screening") {

                                conditions.show.push("PrEP, STI Screening");
                                conditions.hide.push("PrEP, STI Treatment");


                        } else {
                                conditions.hide.push("PrEP, STI Treatment");
                                conditions.hide.push("PrEP, STI Screening")

                        }
                }
                return conditions;
        },


        'PrEP ,Entry Point Mode': function (formName, formFieldValues) {

                var conditionConcept = formFieldValues['PrEP ,Entry Point Mode'];
                var conditions = { show: [], hide: [], assignedValues: [] };

                conditions.hide.push("PrEP Entry Point Community")
                conditions.hide.push("PrEP , Health Facility");




                if (conditionConcept == "PrEP Community Entry Point") {


                        conditions.show.push("PrEP Entry Point Community");

                        conditions.hide.push("PrEP , Facilty Outreach");

                }
                else {


                        conditions.hide.push("PrEP Community Program");
                        conditions.show.push("PrEP , Facilty Outreach");

                }
                return conditions;
        },

        'PrEP ,Entry Point Mode': function (formName, formFieldValues) {
                var EntryMode = formFieldValues['PrEP ,Entry Point Mode'];

                if ((formName == "PrEP , Intake Template") || (formName == "PrEP ,Entry point")) {
                        var conditions = { show: [], hide: [] };

                        if (EntryMode == "PrEP Community Entry Point") {
                                conditions.show.push("PrEP  Entry Point  Community");
                                conditions.hide.push("PrEP , Health Facility");

                        } else if (EntryMode == "PrEP Health Facility Entry Point") {
                                conditions.show.push("PrEP , Health Facility");
                                conditions.hide.push("PrEP  Entry Point  Community");


                        } else {

                                conditions.hide.push("PrEP , Health Facility")
                                conditions.hide.push("PrEP  Entry Point  Community");

                        }
                }
                return conditions;
        },


        'PrEP , Stopping PrEP Confirmation': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['PrEP , Stopping PrEP Confirmation'];
                var conditions = { show: [], hide: [] };

                // conditions.hide.push("PrEP ,Stopping PrEP");

                if (conditionConcept) {
                        conditions.show.push("PrEP ,Stopping PrEP")

                }
                else {
                        conditions.hide.push("PrEP ,Stopping PrEP");

                }

                return conditions;
        },


        'PrEP, Transfer Inn': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['PrEP, Transfer Inn'];
                var conditions = { show: [], hide: [] };


                if (conditionConcept == "Yes") {
                        conditions.show.push("PrEP, Transferred in");

                } else {
                        conditions.hide.push("PrEP, Transferred in");
                }
                return conditions;


        },

        'PrEP, Transfer Out Question': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['PrEP, Transfer Out Question'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("PrEP, Transferred out");

                } else {
                        conditions.hide.push("PrEP, Transferred out");
                }
                return conditions;
        },

        /////////////////////////////////////////////////////////////////
        //LABOUR AND DELIVERY REGISTER
        //MALFORMATIONS
        'LD, Visible malformations Present': function (formName, formFieldValues) {
                var conditions = { show: [], hide: [] };
                var conditionConcept = formFieldValues['LD, Visible malformations Present'];

                if (conditionConcept) {
                        conditions.show.push("LD, Visible malformations Description");
                } else {
                        conditions.hide.push("LD, Visible malformations Description");
                }

                return conditions;
        },
        //FEEDING OPTIONS AT BIRTH
        'LD, Feeding Options at birth': function (formName, formFieldValues) {
                var conditions = { show: [], hide: [] };
                var conditionConcept = formFieldValues['LD, Feeding Options at birth'];

                if (conditionConcept == "Birth, Exclusive Breastfeeding" || conditionConcept == "Birth, Mixed Feeding") {
                        conditions.show.push("LD, Breast-feeding Initiation");
                } else {
                        conditions.hide.push("LD, Breast-feeding Initiation");
                }

                return conditions;
        },
        'ANC, Partner HIV Status': function (formName, formFieldValues) {
                var conditions = { show: [], hide: [] };
                if ((formName == "LD,  HIV Status at Maternity") || (formName == "Labour and Delivery Register")) {
                        var conditionConcept = formFieldValues["ANC, Partner HIV Status"];

                        if ((conditionConcept == "Positive") || (conditionConcept == "Known Positive") || (conditionConcept == "undefined")) {
                                conditions.hide.push("LD, Maternity");
                        } else {
                                conditions.show.push("LD, Maternity");
                        }
                }

                return conditions;
        },
        'ANC, HIV Test Done': function (formName, formFieldValues) {
                var conditions = { show: [], hide: [], assignedValues: [], disable: [] };
                var conditionConcept = formFieldValues["ANC, HIV Test Done"];
                if (formName == "LD, Maternity") {
                        if (conditionConcept == "Yes") {
                                conditions.assignedValues.push({ field: "LD, HIV Test Results", fieldValue: "", autocalculate: true });
                        }
                        if (conditionConcept == "No" || conditionConcept == "Declined") {
                                conditions.assignedValues.push({ field: "LD, HIV Test Results", fieldValue: "Unknown", autocalculate: true });
                        }
                        if (conditionConcept == "Not Applicable") {
                                conditions.assignedValues.push({ field: "LD, HIV Test Results", fieldValue: "Not Applicable", autocalculate: true });
                        }
                }
                if (formName == "ANC, Initial Test during this pregnancy") {
                        if (conditionConcept == "Yes") {
                                conditions.show.push("ANC, HIV Test Result");
                        }
                        else {
                                conditions.hide.push("ANC, HIV Test Result");
                        }
                }
                return conditions;
        },
        'LD, Postpartum HIV Test': function (formName, formFieldValues) {
                var conditions = { show: [], hide: [], assignedValues: [], disable: [] };
                if ((formName == "LD, Maternal Morbidity and Mortality") || (formName == "Labour and Delivery Register")) {
                        var conditionConcept = formFieldValues["LD, Postpartum HIV Test"];
                        if (conditionConcept == "Yes") {
                                conditions.show.push("LD, Postpartum HIV Test Results");
                        } else {
                                conditions.hide.push("LD, Postpartum HIV Test Results");
                        }
                }
                return conditions;
        },
        'LD, Postpartum HIV Test Results': function (formName, formFieldValues) {
                var conditions = { show: [], hide: [], assignedValues: [] };
                var postPartumHIVTestResults = formFieldValues["LD, Postpartum HIV Test Results"];

                if ((postPartumHIVTestResults == "Negative") || (postPartumHIVTestResults == "Positive")) {
                        conditions.show.push("LD, Postpartum ART Initiation");
                        if (postPartumHIVTestResults == "Negative") {
                                conditions.assignedValues.push({ field: "LD, Postpartum ART Initiation", fieldValue: "Not Applicable", autocalculate: true });
                        } else {
                                conditions.assignedValues.push({ field: "LD, Postpartum ART Initiation", fieldValue: "", autocalculate: true });
                        }
                } else {
                        conditions.hide.push("LD, Postpartum ART Initiation");
                }
                return conditions;
        },
        'LD, ART Received at ANC': function (formName, formFieldValues) {
                var conditions = { show: [], hide: [], assignedValues: [] };
                var conditionConcept = formFieldValues["LD, ART Received at ANC"];

                if (conditionConcept == "Yes") {
                        conditions.assignedValues.push({ field: "LD, ART initiated during labour", fieldValue: "Already on ART", autocalculate: true });
                } else if (conditionConcept == "Not Applicable") {
                        conditions.assignedValues.push({ field: "LD, ART initiated during labour", fieldValue: "Not Applicable", autocalculate: true });
                } else {
                        conditions.assignedValues.push({ field: "LD, ART initiated during labour", fieldValue: "", autocalculate: true });
                }
                return conditions;
        },
        ///////////////END OF LABOUR AND DELIVERY REGISTER CONDITIONS////////////////
        
        //////////////////////////////UNDER 5 REGISTER CONDITIONS ////////////////////////

        'Under5 Number': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"Under5 Number",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },

        'ANC, Unique Number': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"ANC, Unique Number",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },
        
        'Delivery Note, Delivery location': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"Delivery Note, Delivery location",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },
       
        'Mode of Delivery': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"Mode of Delivery",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },
        
        'Term at Delivery': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"Term at Delivery",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },
   
        'Nutrition, Birth Weight': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"Nutrition, Birth Weight",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },

        'Complications at Birth': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"Complications at Birth",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },
    
        'HIV Exposure Status': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"HIV Exposure Status",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },
      
        'Feeding Options': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"Feeding Options",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },

        //////////////////////////////UNDER 5 REGISTER CONDITIONS ////////////////////////


 //////////////////////////////UNDER 5 REGISTER CONDITIONS ////////////////////////

        'Under5 Number': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"Under5 Number",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },

        'ANC, Unique Number': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"ANC, Unique Number",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },
        
        'Delivery Note, Delivery location': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"Delivery Note, Delivery location",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },
       
        'Mode of Delivery': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"Mode of Delivery",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },
        
        'Term at Delivery': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"Term at Delivery",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },
   
        'Nutrition, Birth Weight': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"Nutrition, Birth Weight",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },

        'Complications at Birth': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"Complications at Birth",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },
    
        'HIV Exposure Status': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"HIV Exposure Status",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },
      
        'Feeding Options': function(formname, formFieldValues){
                var conditions = { assignedValues: [], disable: [] };
                if(formname == "under5 Register"){
                        conditions.assignedValues.push(
                                {
                                        field:"Feeding Options",
                                        fieldValue:{
                                                isAutoFill: true,
                                                scopedEncounter: "latestvisit",
                                                isFilledOnRetrospectiveMode: true,
                                                enableDefaultValue: false,
                                                enableEditAfterAutoFill: false   
                                        }
                                }
                        );
                }
                return conditions;
        },

        //////////////////////////////UNDER 5 REGISTER CONDITIONS ////////////////////////
        
        ///////////////MDR-TB////////////////
        'MDR Forms': function (formName, formFieldValues) {
                var mdrForm = formFieldValues['MDR Forms'];
                var conditions = { show: [], hide: [] };
                switch (mdrForm) {
                        case "MDR Baseline Form":
                                conditions.show.push("MDR-TB, Baseline Assessment"); //show
                                conditions.hide.push("MDR-TB, PHQ9");
                                conditions.hide.push("MDR-TB Followup Form");
                                conditions.hide.push("MDR-TB, followup assessment");
                                conditions.hide.push("MDR-TB Electrocardiogram");
                                conditions.hide.push("MDR-TB, Radiology and Other Tests");
                                conditions.hide.push("MDR-TB, Outcome");
                                break;
                        case "MDR PHQ-9 Form":
                                conditions.hide.push("MDR-TB, Baseline Assessment");
                                conditions.show.push("MDR-TB, PHQ9"); //show
                                conditions.hide.push("MDR-TB Followup Form");
                                conditions.hide.push("MDR-TB, followup assessment");
                                conditions.hide.push("MDR-TB Electrocardiogram");
                                conditions.hide.push("MDR-TB, Radiology and Other Tests");
                                conditions.hide.push("MDR-TB, Outcome");
                                break;
                        case "MDR TB Followup Form":
                                console.log("MDR-TB Followup Form");
                                conditions.hide.push("MDR-TB, Baseline Assessment");
                                conditions.hide.push("MDR-TB, PHQ9");
                                conditions.show.push("MDR-TB Followup Form"); //show
                                conditions.hide.push("MDR-TB, followup assessment");
                                conditions.hide.push("MDR-TB Electrocardiogram");
                                conditions.hide.push("MDR-TB, Radiology and Other Tests");
                                conditions.hide.push("MDR-TB, Outcome");
                                break;
                        case "MDR Followup Assessment Form":
                                conditions.hide.push("MDR-TB, Baseline Assessment");
                                conditions.hide.push("MDR-TB, PHQ9");
                                conditions.hide.push("MDR-TB Followup Form");
                                conditions.show.push("MDR-TB, followup assessment"); //show
                                conditions.hide.push("MDR-TB Electrocardiogram");
                                conditions.hide.push("MDR-TB, Radiology and Other Tests");
                                conditions.hide.push("MDR-TB, Outcome");
                                break;
                        case "MDR Electrocardiogram Form":
                                conditions.hide.push("MDR-TB, Baseline Assessment");
                                conditions.hide.push("MDR-TB, PHQ9");
                                conditions.hide.push("MDR-TB Followup Form");
                                conditions.hide.push("MDR-TB, followup assessment");
                                conditions.show.push("MDR-TB Electrocardiogram"); //show
                                conditions.hide.push("MDR-TB, Radiology and Other Tests");
                                conditions.hide.push("MDR-TB, Outcome");
                                break;
                        case "MDR Radiology Form":
                                conditions.hide.push("MDR-TB, Baseline Assessment");
                                conditions.hide.push("MDR-TB, PHQ9");
                                conditions.hide.push("MDR-TB Followup Form");
                                conditions.hide.push("MDR-TB, followup assessment");
                                conditions.hide.push("MDR-TB Electrocardiogram");
                                conditions.show.push("MDR-TB, Radiology and Other Tests"); //show
                                conditions.hide.push("MDR-TB, Outcome");
                                break;
                        case "MDR Outcome Form":
                                conditions.hide.push("MDR-TB, Baseline Assessment");
                                conditions.hide.push("MDR-TB, PHQ9");
                                conditions.hide.push("MDR-TB Followup Form");
                                conditions.hide.push("MDR-TB, followup assessment");
                                conditions.hide.push("MDR-TB Electrocardiogram");
                                conditions.hide.push("MDR-TB, Radiology and Other Tests");
                                conditions.show.push("MDR-TB, Outcome"); //show
                                break;
                        default:
                                conditions.hide.push("MDR-TB, Baseline Assessment");
                                conditions.hide.push("MDR-TB, PHQ9");
                                conditions.hide.push("MDR-TB Followup Form");
                                conditions.hide.push("MDR-TB, followup assessment");
                                conditions.hide.push("MDR-TB Electrocardiogram");
                                conditions.hide.push("MDR-TB, Radiology and Other Tests");
                                conditions.hide.push("MDR-TB, Outcome");
                }
                return conditions;
        },
        ///////////////END of MDR-TB////////////////
        ////////////////////////////////////////////
        
        // VMMC TOOLS
        'VMMC, Post-MC Follow up Visits': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['VMMC, Post-MC Follow up Visits'];
                var conditions = { show: [], hide: [], assignedValues: [] };

                switch (conditionConcept) {
                        case "ANC, First Visit":
                        case "VMMC, Second Visit":
                                conditions.show.push("VMMC,Follow up visit after surgical MC");
                                conditions.hide.push("VMMC, Third follow up visit after surgical MC (Day 42)");
                                conditions.hide.push("VMMC, AE Type");
                                break;
                        case "VMMC, Third Visit":
                                conditions.hide.push("VMMC,Follow up visit after surgical MC");
                                conditions.show.push("VMMC, Third follow up visit after surgical MC (Day 42)");
                                conditions.hide.push("VMMC, AE Type");
                                break;
                        default:
                                conditions.hide.push("VMMC,Follow up visit after surgical MC");
                                conditions.hide.push("VMMC, Third follow up visit after surgical MC (Day 42)");

                }
                return conditions;
        },
        'VMMC, Does Client have any AEs': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['VMMC, Does Client have any AEs'];
                var conditions = { show: [], hide: [] };

                if (formName == "VMMC,Follow up visit after surgical MC") {
                        if (conditionConcept) {
                                conditions.show.push("VMMC, AE Type");
                        } else {
                                conditions.hide.push("VMMC, AE Type");
                        }

                }
                return conditions;
        },
        'VMMC, Referred by': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['VMMC, Referred by'];
                var conditions = { show: [], hide: [] };
                if (conditionConcept == "PNC, Other") {
                        conditions.show.push("HTC, Specify");
                } else {
                        conditions.hide.push("HTC, Specify");
                }
                return conditions;
        },
        'VMMC, Any medications?': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['VMMC, Any medications?'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept) {
                        conditions.show.push("HTC, Specify");
                } else {
                        conditions.hide.push("HTC, Specify");
                }
                return conditions;
        },
        'VMMC, Complaints': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['VMMC, Complaints'];
                var conditions = { show: [], hide: [] };
                if (conditionConcept.includes("PNC, Other")) {
                        conditions.show.push("HTC, Specify");
                } else {
                        conditions.hide.push("HTC, Specify");
                }
                return conditions;
        },
        'VMMC, Have you ever experienced spontaneous and prolonged nose bleeds?': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['VMMC, Have you ever experienced spontaneous and prolonged nose bleeds?'];
                var conditions = { show: [], hide: [] };
                if (conditionConcept) {
                        conditions.show.push("VMMC, Spontaneous and prolonged nose bleeds");
                } else {
                        conditions.hide.push("VMMC, Spontaneous and prolonged nose bleeds");
                }
                return conditions;
        },
        'VMMC, Any complications related to that surgery?': function (formName, formFieldValues) {

                var conditionConcept = formFieldValues['VMMC, Any complications related to that surgery?'];
                var conditions = { show: [], hide: [] };
                if (conditionConcept) {
                        conditions.show.push("VMMC, Complications related to surgery");
                } else {
                        conditions.hide.push("VMMC, Complications related to surgery");
                }
                return conditions;
        },
        'VMMC, Penile examination Findings': function (formName, formFieldValues) {

                var conditionConcept = formFieldValues['VMMC, Penile examination Findings'];
                var conditions = { show: [], hide: [] };
                if (conditionConcept.includes("PNC, Other")) {
                        conditions.show.push("Other, specify");
                } else {
                        conditions.hide.push("Other, specify");
                }
                return conditions;
        },
        'Is the client medically cleared for MC?': function (formName, formFieldValues) {

                var conditionConcept = formFieldValues['Is the client medically cleared for MC?'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == undefined) {
                        conditions.hide.push("Reason if not cleared");
                }
                if (conditionConcept) {
                        conditions.hide.push("Reason if not cleared");
                }
                if (!conditionConcept) {
                        conditions.show.push("Reason if not cleared");
                }
                return conditions;
        },
        'VMMC, Informed consent signed': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['VMMC, Informed consent signed'];
                var conditions = { show: [], hide: [] };
                if (conditionConcept) {
                        conditions.show.push("VMMC, Relationship");
                } else {
                        conditions.hide.push("VMMC, Relationship");
                }
                return conditions;
        },
        'Method of Surgery': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['Method of Surgery'];
                var conditions = { show: [], hide: [] };
                if (conditionConcept == "Device") {
                        conditions.show.push("Device used");
                } else {
                        conditions.hide.push("Device used");
                }
                return conditions;
        },
        'VMMC, Accepted HIV test': function (formName, formFieldValues,patient) {
                var conditionConcept = formFieldValues['VMMC, Accepted HIV test'];
                var conditions = { show: [], hide: [] };
                var patientGender = patient['gender'];

                if(formName != "HIV Testing and Counseling Intake Template" && formName != "HIV Testing Services Retesting Template" && formName != "HTC, HIV Test"){

                        if(conditionConcept == undefined){
                                conditions.hide.push("VMMC, Reason");
                        } else if (conditionConcept) {
                                conditions.hide.push("VMMC, Reason");
                        } else {
                                conditions.show.push("VMMC, Reason");
                        }
                }
                else if(formName == "HTC, HIV Test"){
                        if (conditionConcept) {
                                if(patientGender == "F"){
                                        conditions.show.push("HTC, HIV Dual Test");
                                }
                                conditions.show.push("HTC, Initial HIV Test Determine");
                        }
                        else{
                                if(patientGender == "F"){
                                        conditions.hide.push("HTC, HIV Dual Test");
                                }
                                conditions.hide.push("HTC, Initial HIV Test Determine");
                        }
                }
                return conditions;
        },



        // New ART form conditions
        'BonoloMeds Client': function (formName, formFieldValues) {
                var conditions = { show: [], hide: [] };
                var conditionConcept = formFieldValues['BonoloMeds Client'];
                if (formName == "HIV Treatment and Care Progress Template") {
                        if (conditionConcept==='Yes') {
                                conditions.show.push("BonoloMeds");
                        } else {
                                conditions.hide.push("BonoloMeds");
                        }
                }
                return conditions;
        },

        //Working on the Adherence Calculator
        'HIVTC, Adherence Date ARVs Dispensed': function (formName, formFieldValues) {
                var conditions = { show: [], hide: [], assignedValues: [], disable: [] };

                if (formName == "eReg, Adherence Calculator One") {
                        var dateUtil = Bahmni.Common.Util.DateUtil;
                        var dispensedDate = formFieldValues['HIVTC, Adherence Date ARVs Dispensed'];
                        var returnDate = formFieldValues['HIVTC, Adherence Return Date'];

                        if (dispensedDate && returnDate) {
                                var daysSinceRefill = dateUtil.diffInDays(dispensedDate, returnDate);

                                console.log("[Adherence Calc] Days since refill:", daysSinceRefill);

                                conditions.assignedValues.push({ concept: 'HIVTC, Adherence Number of Days since refill', value: daysSinceRefill });
                                conditions.disable.push('HIVTC, Adherence Number of Days since refill');

                                var adherence_A = formFieldValues['HIVTC, Adherence Total amount taken home'];
                                var adherence_B = formFieldValues['HIVTC, Adherence Pill count'];
                                var adherence_C = formFieldValues['HIVTC, Adherence Daily ARV Dose'];
                                var adherence_D = daysSinceRefill;

                                console.log("[Adherence Calc] Inputs — A (total taken home):", adherence_A, "| B (pill count):", adherence_B, "| C (daily dose):", adherence_C, "| D (days since refill):", adherence_D);

                                if (adherence_A && adherence_B && adherence_C && adherence_D) {
                                        var percentageAdh = Math.floor(((adherence_A - adherence_B) / adherence_C / adherence_D) * 100);

                                        console.log("[Adherence Calc] Percentage Adherence:", percentageAdh + "%");

                                        conditions.assignedValues.push({ concept: 'HIVTC, Percentage Adherence', value: percentageAdh });
                                        conditions.disable.push('HIVTC, Percentage Adherence');

                                        if (percentageAdh < 85 || percentageAdh > 105) {
                                                console.log("[Adherence Calc] Result: Poor adherence");
                                                conditions.assignedValues.push({ concept: 'HIVTC, ART Treatment Adherence', value: 'Poor adherence' });
                                                conditions.show.push('Poor or Fair ART adherence reason');
                                        } else if (percentageAdh >= 85 && percentageAdh < 95) {
                                                console.log("[Adherence Calc] Result: Fair adherence");
                                                conditions.assignedValues.push({ concept: 'HIVTC, ART Treatment Adherence', value: 'Fair adherence' });
                                                conditions.show.push('Poor or Fair ART adherence reason');
                                        } else if (percentageAdh >= 95 && percentageAdh <= 105) {
                                                console.log("[Adherence Calc] Result: Good adherence");
                                                conditions.assignedValues.push({ concept: 'HIVTC, ART Treatment Adherence', value: 'Good adherence' });
                                                conditions.hide.push('Poor or Fair ART adherence reason');
                                        }
                                } else {
                                        console.log("[Adherence Calc] Skipping percentage calculation — one or more inputs (A, B, C) are missing");
                                }
                        } else {
                                console.log("[Adherence Calc] Skipping — dispensed date or return date missing");
                        }
                }

                return conditions;
        }

};