CREATE OR REPLACE PACKAGE BODY APPS.LOGI_SUPP_ONBRD_PKG
IS
    /*
       REM ==========================================================================
       REM  Copyright (c) 1999 Logitech Inc California, USA
       REM                        All rights reserved.
       REM
       REM ==========================================================================
       REM
       REM Program Name    : LOGI_SUPP_ONBRD_PKG.pkb
       REM
       REM Author          : Renuka Kumar Vemula
       REM
       REM Purpose         :   Supplier on Boarding all validation, Worklflow all
       REM                     activities and Region enabling or disabling Logic
       REM
       REM Revision History
       REM ----------------
       REM
       REM DATE       PROGRAMMER          DESCRIPTION
       REM ---------  -----------------   ------------------------------------------
       REM 25-Jun-18   rvemula             Created
       REM 01-NOv-18   rvemula             Added the logic to access the OAF pages through External URL
       REM 21-Dec-18   rvemula             Added Logic as part of  ITSM-3721
	   REM 17-Jan-19   rvemula             Added Logic Bank Code issue in Workflow Notification
       REM =========================================================================
       */

    PROCEDURE PROSPECTIVE_REGION_ENABLE (p_req_num              NUMBER,
                                         p_DefPurPay        OUT VARCHAR2,
                                         p_ChPurPay         OUT VARCHAR2,
                                         p_DefPreQualQue    OUT VARCHAR2,
                                         p_BrRegDetails     OUT VARCHAR2,
                                         p_DefPaySiteInfo   OUT VARCHAR2,
                                         p_DefBankDetails   OUT VARCHAR2,
                                         p_ChBankDetails    OUT VARCHAR2,
                                         p_TwBankDetails    OUT VARCHAR2,
                                         p_JyBankDetails    OUT VARCHAR2,
                                         p_DefAttJust       OUT VARCHAR2,
                                         p_ChAttJust        OUT VARCHAR2,
                                         p_TwAttJust        OUT VARCHAR2,
                                         p_UsAttJust        OUT VARCHAR2,
                                         p_CaAttJust        OUT VARCHAR2)
    AS
        l_ENTITY_NAME   VARCHAR2 (70);
        l_COUNTRY       VARCHAR2 (20);
        l_CHECK         NUMBER;
    BEGIN
        l_ENTITY_NAME := NULL;
        l_COUNTRY := NULL;

        BEGIN
            SELECT NVL ((SELECT ENTITY_NAME
                           FROM LOTC.LOTC_SUPP_DATA_MANAGEMENT
                          WHERE REGI_REQUEST_NUMBER = p_req_num),
                        REQ.ENTITY_NAME_SUPP_REGI_IN),
                   (SELECT TERRITORY_CODE
                      FROM FND_TERRITORIES_VL
                     WHERE TERRITORY_SHORT_NAME = PREG.COUNTRY)
                       TERRITORY_CODE
              INTO l_ENTITY_NAME, l_COUNTRY
              FROM APPS.LOTC_SUPP_ONBOARD_REQUEST      REQ,
                   APPS.LOTC_PROSPECTIVE_SUPPLIER_REG  PREG
             WHERE     REQ.REGI_REQUEST_NUMBER = PREG.REGI_REQUEST_NUMBER
                   AND REQ.REGI_REQUEST_NUMBER = p_req_num;
        --AND PREG.REGI_REQUEST_ID = p_req_num;
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    123,
                    'PROSPECTIVE_REGION_ENABLE',
                       'p_req_num  -->'
                    || p_req_num
                    || '  ENTITY_NAME and COUNTRY derivation issue  --> '
                    || SQLERRM);
        END;

        p_DefPaySiteInfo := 'Y';

        BEGIN
            SELECT 1
              INTO l_CHECK
              FROM lfnd_lookups
             WHERE     LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_DISPLAY_COND'
                   AND KEY1 = 'Alternate'
                   AND KEY4 = l_entity_name
                   AND KEY5 = l_country
                   AND KEY6 = 'PUR_PAY_INFO_CN'
                   AND KEY2 = 'PUR_PAY_INFO';

            p_DefPurPay := 'N';
            p_ChPurPay := 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                p_DefPurPay := 'Y';
                p_ChPurPay := 'N';
            WHEN OTHERS
            THEN
                p_DefPurPay := 'Y';
                p_ChPurPay := 'N';
                WRITE_CUST_LOG (
                    123,
                    'PROSPECTIVE_REGION_ENABLE',
                       'p_req_num  -->'
                    || p_req_num
                    || '  -->   p_ChPurPay  Derivation Error  --> '
                    || SQLERRM);
        END;

        BEGIN
            SELECT 1
              INTO l_CHECK
              FROM lfnd_lookups
             WHERE     LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_DISPLAY_COND'
                   AND KEY1 = 'Alternate'
                   AND KEY4 = l_ENTITY_NAME
                   AND KEY5 = l_COUNTRY
                   AND KEY6 = 'BANK_DETAILS_CN'
                   AND KEY2 = 'BANK_DETAILS';

            --p_DefBankDetails := 'N';
            p_ChBankDetails := 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                -- p_DefBankDetails := 'Y';
                p_ChBankDetails := 'N';
            WHEN OTHERS
            THEN
                -- p_DefBankDetails := 'Y';
                p_ChBankDetails := 'N';
                WRITE_CUST_LOG (
                    123,
                    'PROSPECTIVE_REGION_ENABLE',
                       'p_req_num  -->'
                    || p_req_num
                    || '  -->   p_ChBankDetails  Derivation Error  --> '
                    || SQLERRM);
        END;

        BEGIN
            SELECT 1
              INTO l_CHECK
              FROM lfnd_lookups
             WHERE     LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_DISPLAY_COND'
                   AND KEY1 = 'Alternate'
                   AND KEY4 = l_ENTITY_NAME
                   AND KEY5 = l_COUNTRY
                   AND KEY6 = 'BANK_DETAILS_TW'
                   AND KEY2 = 'BANK_DETAILS';

            -- p_DefBankDetails := 'N';
            p_TwBankDetails := 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                -- p_DefBankDetails := 'Y';
                p_TwBankDetails := 'N';
            WHEN OTHERS
            THEN
                -- p_DefBankDetails := 'Y';
                p_TwBankDetails := 'N';
                WRITE_CUST_LOG (
                    123,
                    'PROSPECTIVE_REGION_ENABLE',
                       'p_req_num  -->'
                    || p_req_num
                    || '  -->   p_TwBankDetails  Derivation Error  --> '
                    || SQLERRM);
        END;

        BEGIN
            SELECT 1
              INTO l_CHECK
              FROM lfnd_lookups
             WHERE     LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_DISPLAY_COND'
                   AND KEY1 = 'Alternate'
                   AND KEY4 = l_ENTITY_NAME
                   AND KEY5 = l_COUNTRY
                   AND KEY6 = 'BANK_DETAILS_JPY'
                   AND KEY2 = 'BANK_DETAILS';

            -- p_DefBankDetails := 'N';
            p_JyBankDetails := 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                -- p_DefBankDetails := 'Y';
                p_JyBankDetails := 'N';
            WHEN OTHERS
            THEN
                -- p_DefBankDetails := 'Y';
                p_JyBankDetails := 'N';

                WRITE_CUST_LOG (
                    123,
                    'PROSPECTIVE_REGION_ENABLE',
                       'p_req_num  -->'
                    || p_req_num
                    || '  -->   p_JyBankDetails  Derivation Error  --> '
                    || SQLERRM);
        END;

        IF    p_ChBankDetails = 'Y'
           OR p_TwBankDetails = 'Y'
           OR p_JyBankDetails = 'Y'
        THEN
            p_DefBankDetails := 'N';
        ELSE
            p_DefBankDetails := 'Y';
        END IF;

        BEGIN
            SELECT 1
              INTO l_CHECK
              FROM lfnd_lookups
             WHERE     LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_DISPLAY_COND'
                   AND KEY1 = 'Alternate'
                   AND KEY5 = l_COUNTRY
                   AND KEY2 = 'ATT_AND_JUST'
                   AND KEY6 = 'ATT_AND_JUST_CN';

            p_ChAttJust := 'Y';
        --p_DefAttJust := 'N';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                p_ChAttJust := 'N';
            --p_DefAttJust := 'Y';
            WHEN OTHERS
            THEN
                p_ChAttJust := 'N';
                --p_DefAttJust := 'Y';
                WRITE_CUST_LOG (
                    123,
                    'PROSPECTIVE_REGION_ENABLE',
                       'p_req_num  -->'
                    || p_req_num
                    || '  -->   p_ChAttJust  Derivation Error  --> '
                    || SQLERRM);
        END;

        BEGIN
            SELECT 1
              INTO l_CHECK
              FROM lfnd_lookups
             WHERE     LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_DISPLAY_COND'
                   AND KEY1 = 'Alternate'
                   AND KEY5 = l_COUNTRY
                   AND KEY2 = 'ATT_AND_JUST'
                   AND KEY6 = 'ATT_AND_JUST_TW';

            p_TwAttJust := 'Y';
        --p_DefAttJust := 'N';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                p_TwAttJust := 'N';
            --p_DefAttJust := 'Y';
            WHEN OTHERS
            THEN
                p_TwAttJust := 'N';
                --p_DefAttJust := 'Y';
                WRITE_CUST_LOG (
                    123,
                    'PROSPECTIVE_REGION_ENABLE',
                       'p_req_num  -->'
                    || p_req_num
                    || '  -->   p_TwAttJust  Derivation Error  --> '
                    || SQLERRM);
        END;

        BEGIN
            SELECT 1
              INTO l_CHECK
              FROM lfnd_lookups
             WHERE     LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_DISPLAY_COND'
                   AND KEY1 = 'Alternate'
                   AND KEY5 = l_COUNTRY
                   AND KEY2 = 'ATT_AND_JUST'
                   AND KEY6 = 'ATT_AND_JUST_US';

            --p_DefAttJust := 'N';
            p_UsAttJust := 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                p_UsAttJust := 'N';
            --p_DefAttJust := 'Y';
            WHEN OTHERS
            THEN
                p_UsAttJust := 'N';
                --p_DefAttJust := 'Y';
                WRITE_CUST_LOG (
                    123,
                    'PROSPECTIVE_REGION_ENABLE',
                       'p_req_num  -->'
                    || p_req_num
                    || '  -->   p_UsAttJust  Derivation Error  --> '
                    || SQLERRM);
        END;

        BEGIN
            SELECT 1
              INTO l_CHECK
              FROM lfnd_lookups
             WHERE     LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_DISPLAY_COND'
                   AND KEY1 = 'Alternate'
                   AND KEY5 = l_COUNTRY
                   AND KEY2 = 'ATT_AND_JUST'
                   AND KEY6 = 'ATT_AND_JUST_CA';

            --p_DefAttJust := 'N';
            p_CaAttJust := 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                p_CaAttJust := 'N';
            --p_DefAttJust := 'Y';
            WHEN OTHERS
            THEN
                p_CaAttJust := 'N';
                --p_DefAttJust := 'Y';
                WRITE_CUST_LOG (
                    123,
                    'PROSPECTIVE_REGION_ENABLE',
                       'p_req_num  -->'
                    || p_req_num
                    || '  -->   p_CaAttJust  Derivation Error  --> '
                    || SQLERRM);
        END;

        IF    p_ChAttJust = 'Y'
           OR p_TwAttJust = 'Y'
           OR p_UsAttJust = 'Y'
           OR p_CaAttJust = 'Y'
        THEN
            p_DefAttJust := 'N';
        ELSE
            p_DefAttJust := 'Y';
        END IF;

        BEGIN
            SELECT 1
              INTO l_CHECK
              FROM lfnd_lookups
             WHERE     LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_DISPLAY_COND'
                   AND KEY1 = 'Condition'
                   AND KEY5 = l_COUNTRY
                   AND KEY6 = 'BR_REG_DETAILS';

            p_BrRegDetails := 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                p_BrRegDetails := 'N';
            WHEN OTHERS
            THEN
                p_BrRegDetails := 'N';
                WRITE_CUST_LOG (
                    123,
                    'PROSPECTIVE_REGION_ENABLE',
                       'p_req_num  -->'
                    || p_req_num
                    || '  -->   p_BrRegDetails  Derivation Error  --> '
                    || SQLERRM);
        END;

        BEGIN
            SELECT 1
              INTO l_CHECK
              FROM lfnd_lookups
             WHERE     LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_DISPLAY_COND'
                   AND KEY1 = 'Condition'
                   AND KEY5 = l_COUNTRY
                   AND KEY6 = 'PREQUA_QUE';

            p_DefPreQualQue := 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                p_DefPreQualQue := 'N';
            WHEN OTHERS
            THEN
                p_DefPreQualQue := 'N';
                WRITE_CUST_LOG (
                    123,
                    'PROSPECTIVE_REGION_ENABLE',
                       'p_req_num  -->'
                    || p_req_num
                    || '  -->   p_DefPreQualQue  Derivation Error  --> '
                    || SQLERRM);
        END;
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (
                123,
                'PROSPECTIVE_REGION_ENABLE',
                'Error in prospective_region_enable -->  ' || SQLERRM);
    END PROSPECTIVE_REGION_ENABLE;

    PROCEDURE PROSPECTIVE_PAGE_MODE (p_req_num NUMBER, p_mode OUT VARCHAR2)
    AS
        L_COUNT   NUMBER := 0;
    BEGIN
        BEGIN
            SELECT COUNT (1)
              INTO L_COUNT
              FROM LOTC.LOTC_PROSPECTIVE_SUPPLIER_REG
             WHERE REGI_REQUEST_NUMBER = p_req_num;
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (123, 'PROSPECTIVE_PAGE_MODE', SQLERRM);
                L_COUNT := 0;
        END;



        IF L_COUNT = 1
        THEN
            p_mode := 'UPDATE';
        ELSE
            p_mode := 'CREATE';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (123, 'PROSPECTIVE_PAGE_MODE', SQLERRM);
            p_mode := 'CREATE';
    END PROSPECTIVE_PAGE_MODE;



    PROCEDURE PROS_ADD_INFO_PAGE_MODE (p_req_num NUMBER, p_mode OUT VARCHAR2)
    AS
        L_COUNT   NUMBER := 0;
    BEGIN
        BEGIN
            SELECT COUNT (1)
              INTO L_COUNT
              FROM LOTC.LOTC_PROS_SUPP_REG_ADD_INFO
             WHERE REGI_REQUEST_NUMBER = p_req_num;
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (123, 'PROS_ADD_INFO_PAGE_MODE', SQLERRM);
                L_COUNT := 0;
        END;

        IF L_COUNT = 1
        THEN
            p_mode := 'UPDATE';
        ELSE
            p_mode := 'CREATE';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (123, 'PROS_ADD_INFO_PAGE_MODE', SQLERRM);
            p_mode := 'CREATE';
    END PROS_ADD_INFO_PAGE_MODE;



    PROCEDURE BANK_FIELDS_ENABLE (p_country_name       VARCHAR2,
                                  PIban            OUT VARCHAR2,
                                  PIfsc            OUT VARCHAR2,
                                  PAchAbaRouting   OUT VARCHAR2,
                                  PAccountType     OUT VARCHAR2,
                                  PBankCode        OUT VARCHAR2,
                                  PBranchCode      OUT VARCHAR2,
                                  PCnapsCode       OUT VARCHAR2)
    AS
        l_territory_code   VARCHAR2 (5);
        L_Iban             VARCHAR2 (20) := NULL;
        L_Ifsc             VARCHAR2 (20) := NULL;
        L_AchAbaRouting    VARCHAR2 (20) := NULL;
        L_AccountType      VARCHAR2 (20) := NULL;
        L_BankCode         VARCHAR2 (20) := NULL;
        L_BranchCode       VARCHAR2 (20) := NULL;
        L_CnapsCode        VARCHAR2 (20) := NULL;
    BEGIN
        l_territory_code := NULL;


        BEGIN
            SELECT territory_code
              INTO l_territory_code
              FROM fnd_territories_vl
             WHERE territory_short_name = p_country_name;
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    123,
                    'BANK_FIELDS_ENABLE',
                    'l_territory_code derivation issue -->' || SQLERRM);
        END;

        BEGIN
            SELECT KEY2,
                   KEY3,
                   KEY4,
                   KEY5,
                   KEY6,
                   KEY7,
                   KEY8
              INTO L_Iban,
                   L_Ifsc,
                   L_AchAbaRouting,
                   L_AccountType,
                   L_BankCode,
                   L_BranchCode,
                   L_CnapsCode
              FROM lfnd_lookups lkup
             WHERE     1 = 1
                   AND lkup.LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_BANK_FIELDS'
                   AND KEY1 = l_territory_code;
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (123,
                                'BANK_FIELDS_ENABLE',
                                'Attributes derivation issue -->' || SQLERRM);
                PIban := 'Y';
                PIfsc := 'Y';
                PAchAbaRouting := 'Y';
                PAccountType := 'Y';
                PBankCode := 'Y';
                PBranchCode := 'Y';
                PCnapsCode := 'Y';
                RETURN;
        END;

        IF L_Iban = 'IBAN'
        THEN
            PIban := 'Y';
        ELSE
            PIban := 'N';
        END IF;

        IF L_Ifsc = 'IFSC'
        THEN
            PIfsc := 'Y';
        ELSE
            PIfsc := 'N';
        END IF;

        IF L_AchAbaRouting = 'ACH ABA Routing'
        THEN
            PAchAbaRouting := 'Y';
        ELSE
            PAchAbaRouting := 'N';
        END IF;

        IF L_AccountType = 'Account Type'
        THEN
            PAccountType := 'Y';
        ELSE
            PAccountType := 'N';
        END IF;

        IF L_BankCode = 'Bank Code'
        THEN
            PBankCode := 'Y';
        ELSE
            PBankCode := 'N';
        END IF;

        IF L_BranchCode = 'Branch Code'
        THEN
            PBranchCode := 'Y';
        ELSE
            PBranchCode := 'N';
        END IF;

        IF L_CnapsCode = 'CNAPS Code'
        THEN
            PCnapsCode := 'Y';
        ELSE
            PCnapsCode := 'N';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (
                123,
                'BANK_FIELDS_ENABLE',
                'Error @BANK_FIELDS_ENABLE outermost exception ' || SQLERRM);
            PIban := 'Y';
            PIfsc := 'Y';
            PAchAbaRouting := 'Y';
            PAccountType := 'Y';
            PBankCode := 'Y';
            PBranchCode := 'Y';
            PCnapsCode := 'Y';
            RETURN;
    END BANK_FIELDS_ENABLE;

    FUNCTION ENTITY_NAME (P_USER_ID NUMBER)
        RETURN VARCHAR2
    AS
        l_segment1      VARCHAR2 (10);
        l_entity_name   VARCHAR2 (70);
    BEGIN
        l_segment1 := NULL;

        BEGIN
            SELECT gcc.SEGMENT1
              INTO l_segment1
              FROM fnd_user                   fu,
                   per_all_people_f           papf,
                   per_all_assignments_f      asg,
                   hr_all_positions_f         hapf,
                   hr_all_organization_units  haou,
                   gl_code_combinations       gcc
             WHERE     1 = 1
                   AND papf.person_id = asg.person_id(+)
                   AND SYSDATE BETWEEN papf.effective_start_date
                                   AND papf.effective_end_date
                   AND SYSDATE BETWEEN asg.effective_start_date
                                   AND asg.effective_end_date
                   AND asg.position_id = hapf.position_id(+)
                   AND fu.employee_id(+) = papf.person_id
                   AND haou.organization_id = asg.organization_id
                   AND gcc.CODE_COMBINATION_ID = asg.DEFAULT_CODE_COMB_ID
                   AND fu.USER_ID = P_USER_ID;
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (123,
                                'ENTITY_NAME',
                                'Error in p_segment1 derivation ' || SQLERRM);
                RETURN NULL;
        END;

        BEGIN
            SELECT NVL (
                       (SELECT KEY4
                          FROM lfnd_lookups
                         WHERE     1 = 1
                               AND LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_ENTITIES'
                               AND KEY5 = 'Yes'
                               AND KEY1 = l_segment1
                               AND ROWNUM = 1),
                       (SELECT KEY4
                          FROM lfnd_lookups
                         WHERE     1 = 1
                               AND LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_ENTITIES'
                               AND KEY5 = 'No'
                               AND KEY1 = l_segment1
                               AND ROWNUM = 1))
                       ENTITY_NAME
              INTO l_ENTITY_NAME
              FROM DUAL;
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (123,
                                'ENTITY_NAME',
                                'Error in l_segment1 derivation ' || SQLERRM);
                RETURN NULL;
        END;

        RETURN l_ENTITY_NAME;
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (
                123,
                'ENTITY_NAME',
                'Error @ENTITY_NAME outermost exception ' || SQLERRM);
            RETURN NULL;
    END ENTITY_NAME;

    PROCEDURE CREATE_DATA_MANAGEMENT (p_req_num VARCHAR2)
    AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_COMPANY_NAME               VARCHAR2 (240);
        l_ADDRESS_LINE1              VARCHAR2 (50);
        l_ADDRESS_LINE2              VARCHAR2 (50);
        l_CITY                       VARCHAR2 (20);
        l_STATE_PROVINCE             VARCHAR2 (20);
        l_COUNTRY                    VARCHAR2 (20);
        l_POSTAL_CODE                VARCHAR2 (50);
        l_TELEPHONE                  VARCHAR2 (20);
        l_FAX                        VARCHAR2 (40);
        l_URL                        VARCHAR2 (240);
        l_TAX_VAT_REGI_ID            VARCHAR2 (50);
        l_PAYMENT_REMITTANCE_EMAIL   VARCHAR2 (2000);
        l_PO_COMMUNICATION_EMAIL     VARCHAR2 (2000);
        l_PAYMENT_TERMS              VARCHAR2 (40);
        l_BANK_NAME                  VARCHAR2 (240);
        l_BANK_ADDRESS_LINE_1        VARCHAR2 (40);
        l_BANK_ADDRESS_LINE_2        VARCHAR2 (40);
        l_BANK_CITY                  VARCHAR2 (40);
        l_BANK_STATE_PROVINCE        VARCHAR2 (40);
        l_BANK_COUNTRY               VARCHAR2 (40);
        l_BANK_POSTAL_CODE           VARCHAR2 (50);
        l_BANK_CODE                  VARCHAR2 (40);
        l_BANK_BRANCH_CODE           VARCHAR2 (40);
        l_ACCOUNT_TYPE               VARCHAR2 (40);
        l_ACCOUNT_NAME               VARCHAR2 (320);
        l_ACCOUNT_NUMBER             VARCHAR2 (40);
        l_CURRENCY                   VARCHAR2 (40);
        l_IBAN                       VARCHAR2 (40);
        l_SWIFT_BIC                  VARCHAR2 (40);
        l_IFSC                       VARCHAR2 (40);
        l_ACH_ABA_ROUTING            VARCHAR2 (40);
        l_CNAPS_CODE                 VARCHAR2 (40);
        l_BANK_BRANCH_NAME           VARCHAR2 (240);
        L_ROWCOUNT                   NUMBER := 0;
    BEGIN
        BEGIN
            SELECT COUNT (1)
              INTO L_ROWCOUNT
              FROM LOTC_SUPP_DATA_MANAGEMENT
             WHERE 1 = 1 AND REGI_REQUEST_NUMBER = p_req_num;
        EXCEPTION
            WHEN OTHERS
            THEN
                L_ROWCOUNT := NULL;
        END;

        WRITE_CUST_LOG (
            123,
            'CREATE_DATA_MANAGEMENT',
               'Enter into the CREATE_DATA_MANAGEMENT logic and L_ROWCOUNT is '
            || L_ROWCOUNT);

        IF L_ROWCOUNT = 0
        THEN
            BEGIN
                INSERT INTO LOTC.LOTC_SUPP_DATA_MANAGEMENT (
                                REGI_REQUEST_NUMBER,
                                COMPANY_NAME,
                                CREATED_BY,
                                CREATION_DATE,
                                ADDRESS_LINE1,
                                ADDRESS_LINE2,
                                CITY,
                                STATE_PROVINCE,
                                COUNTRY,
                                POSTAL_CODE,
                                TELEPHONE,
                                FAX,
                                URL,
                                TAX_VAT_REGI_ID,
                                PAYMENT_REMITTANCE_EMAIL,
                                PO_COMMUNICATION_EMAIL,
                                PAYMENT_TERMS,
                                BANK_NAME,
                                BANK_ADDRESS_LINE_1,
                                BANK_ADDRESS_LINE_2,
                                BANK_CITY,
                                BANK_STATE_PROVINCE,
                                BANK_COUNTRY,
                                BANK_POSTAL_CODE,
                                BANK_CODE,
                                BANK_BRANCH_CODE,
                                ACCOUNT_TYPE,
                                ACCOUNT_NAME,
                                ACCOUNT_NUMBER,
                                CURRENCY,
                                IBAN,
                                SWIFT_BIC,
                                IFSC,
                                ACH_ABA_ROUTING,
                                CNAPS_CODE,
                                ENTITY_NAME,
                                SUPPLIER_BANK_NAME,
                                SUPPLIER_BANK_COUNTRY,
                                BANK_NUMBER,
                                BRANCH_NAME,
                                BRANCH_NUMBER,
                                BIC,
                                BRANCH_TYPE,
                                SUPPLIER_ACCOUNT_TYPE,
                                ALTERNATE_ACCOUNT_NAME,
                                BANK_CHARGE_BEARER,
                                PAYMENT_METHOD,
                                PAY_GROUP,
                                SITE_CODE,
                                LIABILITY_ACCOUNT,
                                PREPAID_ACCOUNT,
                                INVOICE_TOLERANCE_FROM_GOODS,
                                INVOICE_TOLERANCE_FOR_SERVICE,
                                TAX_REPORTABLE,
                                INCOME_TAX_TYPE,
                                STATE,
                                SUPPLIER_PAYMENT_TERMS,
                                INCOME_TAX_REPORTING_SITE,
                                ROUNDING_LEVEL,
                                ALLOW_TAX_APPLICABILITY,
                                ALLOW_OFFSET_TAXES,
                                CALCULATE_TAX,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATE_LOGIN,
                                NOTE_TO_SUPPLIER,
                                NOTE_TO_APPROVER,
                                DISQUALIFY_NOTE,
                                ATTRIBUTE1,
                                ATTRIBUTE2,
                                ATTRIBUTE3,
                                ATTRIBUTE4,
                                ATTRIBUTE5,
                                ATTRIBUTE6,
                                ATTRIBUTE7,
                                ATTRIBUTE8,
                                ATTRIBUTE9,
                                ATTRIBUTE10,
                                NOTIFY_STATUS,
                                DISQUALIFY_STATUS,
                                RESUBMIT_STATUS,
                                ITEM_TYPE,
                                NOTIFY_KEY,
                                DISQUALIFY_KEY,
                                RESUBMIT_KEY,
                                SHIP_TO,
                                BILL_TO,
                                BANK_BRANCH_NAME)
                    SELECT TO_NUMBER (TRIM (p_req_num)),
                           reg.COMPANY_NAME,
                           fnd_global.user_id,
                           SYSDATE,
                           reg.ADDRESS_LINE1,
                           reg.ADDRESS_LINE2,
                           reg.CITY,
                           reg.STATE_PROVINCE,
                           reg.COUNTRY,
                           reg.POSTAL_CODE,
                           NULL,
                           NULL,
                           NULL,
                           NVL (INFO.TAX_VAT_REGI_ID,
                                INFO.CH_TAX_VAT_REGI_ID),
                           NVL (INFO.PAYMENT_REMITTANCE_EMAIL,
                                INFO.CH_PAYMENT_REMITTANCE_EMAIL),
                           NVL (INFO.PO_COMMUNICATION_EMAIL,
                                INFO.CH_PO_COMMUNICATION_EMAIL),
                           INFO.PAYMENT_TERMS,
                           (CASE
                                WHEN INFO.BANK_NAME IS NOT NULL
                                THEN
                                    INFO.BANK_NAME
                                WHEN INFO.CH_BANK_NAME IS NOT NULL
                                THEN
                                    INFO.CH_BANK_NAME
                                WHEN INFO.TW_BANK_NAME IS NOT NULL
                                THEN
                                    INFO.TW_BANK_NAME
                                ELSE
                                    NULL
                            END)
                               BANK_NAME,
                           INFO.BANK_ADDRESS_LINE_1,
                           INFO.BANK_ADDRESS_LINE_2,
                           INFO.BANK_CITY,
                           INFO.BANK_STATE_PROVINCE,
                           INFO.BANK_COUNTRY,
                           INFO.BANK_POSTAL_CODE,
					    -- NVL (INFO.BANK_CODE, JP_BANK_CODE)   Commeted the logic for Bank Code not appearing in the Notification 17-Jan-19
						   NVL (NVL (INFO.BANK_CODE, JP_BANK_CODE),TW_BANK_CODE)   --Added the logic for showing Bank Code information into the Notification 17-Jan-19
                               BANK_CODE,
                           (CASE
                                WHEN INFO.BANK_BRANCH_CODE IS NOT NULL
                                THEN
                                    INFO.BANK_BRANCH_CODE
                                WHEN INFO.TW_BRANCH_CODE IS NOT NULL
                                THEN
                                    INFO.TW_BRANCH_CODE
                                WHEN INFO.JP_BRANCH_CODE IS NOT NULL
                                THEN
                                    INFO.JP_BRANCH_CODE
                                ELSE
                                    NULL
                            END)
                               BANK_BRANCH_CODE,
                           NVL (INFO.ACCOUNT_TYPE, INFO.JP_ACCOUNT_TYPE)
                               ACCOUNT_TYPE,
                           (CASE
                                WHEN INFO.ACCOUNT_NAME IS NOT NULL
                                THEN
                                    INFO.ACCOUNT_NAME
                                WHEN INFO.CH_ACCOUNT_NAME IS NOT NULL
                                THEN
                                    INFO.CH_ACCOUNT_NAME
                                WHEN INFO.TW_ACCOUNT_NAME IS NOT NULL
                                THEN
                                    INFO.TW_ACCOUNT_NAME
                                WHEN INFO.JP_ACCOUNT_NAME IS NOT NULL
                                THEN
                                    INFO.JP_ACCOUNT_NAME
                                ELSE
                                    NULL
                            END)
                               ACCOUNT_NAME,
                           (CASE
                                WHEN INFO.ACCOUNT_NUMBER IS NOT NULL
                                THEN
                                    INFO.ACCOUNT_NUMBER
                                WHEN INFO.CH_ACCOUNT_NUMBER IS NOT NULL
                                THEN
                                    INFO.CH_ACCOUNT_NUMBER
                                WHEN INFO.TW_ACCOUNT_NUMBER IS NOT NULL
                                THEN
                                    INFO.TW_ACCOUNT_NUMBER
                                WHEN INFO.JP_ACCOUNT_NUMBER IS NOT NULL
                                THEN
                                    INFO.JP_ACCOUNT_NUMBER
                                ELSE
                                    NULL
                            END)
                               ACCOUNT_NUMBER,
                           (CASE
                                WHEN INFO.CURRENCY IS NOT NULL
                                THEN
                                    INFO.CURRENCY
                                WHEN INFO.CH_PAYMENT_CURRENCY IS NOT NULL
                                THEN
                                    INFO.CH_PAYMENT_CURRENCY
                                WHEN INFO.TW_PAYMENT_CURRENCY IS NOT NULL
                                THEN
                                    INFO.TW_PAYMENT_CURRENCY
                                WHEN INFO.JP_CURRENCY IS NOT NULL
                                THEN
                                    INFO.JP_CURRENCY
                                ELSE
                                    NULL
                            END)
                               CURRENCY,
                           INFO.IBAN,
                           INFO.SWIFT_BIC,
                           INFO.IFSC,
                           INFO.ACH_ABA_ROUTING,
                           (CASE
                                WHEN INFO.CNAPS_CODE IS NOT NULL
                                THEN
                                    INFO.CNAPS_CODE
                                WHEN INFO.CH_CNAPS_CODE_12 IS NOT NULL
                                THEN
                                    INFO.CH_CNAPS_CODE_12
                                WHEN INFO.TW_CNAPS_CODE_12 IS NOT NULL
                                THEN
                                    INFO.TW_CNAPS_CODE_12
                                ELSE
                                    NULL
                            END)
                               CNAPS_CODE,
                           onb.ENTITY_NAME_SUPP_REGI_IN,
                           NULL, --  LotcSuppDataManagement.SUPPLIER_BANK_NAME,
                           NULL, -- LotcSuppDataManagement.SUPPLIER_BANK_COUNTRY,
                           NULL,        -- LotcSuppDataManagement.BANK_NUMBER,
                           NULL,        -- LotcSuppDataManagement.BRANCH_NAME,
                           NULL,      -- LotcSuppDataManagement.BRANCH_NUMBER,
                           NULL,                -- LotcSuppDataManagement.BIC,
                           NULL,        -- LotcSuppDataManagement.BRANCH_TYPE,
                           (CASE
                                WHEN INFO.ACCOUNT_TYPE IS NOT NULL
                                THEN
                                    INFO.ACCOUNT_TYPE
                                WHEN INFO.JP_ACCOUNT_TYPE IS NOT NULL
                                THEN
                                    INFO.JP_ACCOUNT_TYPE
                                ELSE
                                    NULL
                            END)
                               SUPPLIER_ACCOUNT_TYPE,
                           NULL,
                           (SELECT lkp2.KEY5
                              FROM lfnd_lookups lkp1, lfnd_lookups lkp2
                             WHERE     1 = 1
                                   AND lkp1.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_ENTITIES'
                                   AND lkp2.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_OU_INFO'
                                   AND lkp1.KEY3 = lkp2.KEY1
                                   AND lkp1.KEY4 =
                                       onb.ENTITY_NAME_SUPP_REGI_IN)
                               BANK_CHARGE_BEARER,
                           (SELECT NVL (KEY6, KEY4)
                              FROM lfnd_lookups lkp2
                             WHERE     1 = 1
                                   AND lkp2.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_ENITY_INFO'
                                   AND KEY1 = onb.ENTITY_NAME_SUPP_REGI_IN
                                   AND KEY2 =
                                       (CASE
                                            WHEN INFO.CURRENCY IS NOT NULL
                                            THEN
                                                INFO.CURRENCY
                                            WHEN INFO.CH_PAYMENT_CURRENCY
                                                     IS NOT NULL
                                            THEN
                                                INFO.CH_PAYMENT_CURRENCY
                                            WHEN INFO.TW_PAYMENT_CURRENCY
                                                     IS NOT NULL
                                            THEN
                                                INFO.TW_PAYMENT_CURRENCY
                                            WHEN INFO.JP_CURRENCY IS NOT NULL
                                            THEN
                                                INFO.JP_CURRENCY
                                            ELSE
                                                NULL
                                        END))
                               PAYMENT_METHOD,
                           (SELECT KEY3
                              FROM lfnd_lookups lkp2
                             WHERE     1 = 1
                                   AND lkp2.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_ENITY_INFO'
                                   AND KEY1 = onb.ENTITY_NAME_SUPP_REGI_IN
                                   AND KEY2 =
                                       (CASE
                                            WHEN INFO.CURRENCY IS NOT NULL
                                            THEN
                                                INFO.CURRENCY
                                            WHEN INFO.CH_PAYMENT_CURRENCY
                                                     IS NOT NULL
                                            THEN
                                                INFO.CH_PAYMENT_CURRENCY
                                            WHEN INFO.TW_PAYMENT_CURRENCY
                                                     IS NOT NULL
                                            THEN
                                                INFO.TW_PAYMENT_CURRENCY
                                            WHEN INFO.JP_CURRENCY IS NOT NULL
                                            THEN
                                                INFO.JP_CURRENCY
                                            ELSE
                                                NULL
                                        END))
                               PAY_GROUP,
                           (SELECT    KEY1
                                   || ' '
                                   || (SELECT TERRITORY_CODE
                                         FROM fnd_territories_vl
                                        WHERE TERRITORY_SHORT_NAME =
                                              reg.COUNTRY)
                                   || ' '
                                   || (CASE
                                           WHEN INFO.CURRENCY IS NOT NULL
                                           THEN
                                               INFO.CURRENCY
                                           WHEN INFO.CH_PAYMENT_CURRENCY
                                                    IS NOT NULL
                                           THEN
                                               INFO.CH_PAYMENT_CURRENCY
                                           WHEN INFO.TW_PAYMENT_CURRENCY
                                                    IS NOT NULL
                                           THEN
                                               INFO.TW_PAYMENT_CURRENCY
                                           WHEN INFO.JP_CURRENCY IS NOT NULL
                                           THEN
                                               INFO.JP_CURRENCY
                                           ELSE
                                               NULL
                                       END)
                              FROM lfnd_lookups lkp2
                             WHERE     1 = 1
                                   AND lkp2.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_ENTITIES'
                                   AND KEY4 = onb.ENTITY_NAME_SUPP_REGI_IN)
                               SITE_CODE,
                           (SELECT KEY8
                              FROM lfnd_lookups lkp2
                             WHERE     1 = 1
                                   AND lkp2.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_ENITY_INFO'
                                   AND KEY1 = onb.ENTITY_NAME_SUPP_REGI_IN
                                   AND KEY2 =
                                       (CASE
                                            WHEN INFO.CURRENCY IS NOT NULL
                                            THEN
                                                INFO.CURRENCY
                                            WHEN INFO.CH_PAYMENT_CURRENCY
                                                     IS NOT NULL
                                            THEN
                                                INFO.CH_PAYMENT_CURRENCY
                                            WHEN INFO.TW_PAYMENT_CURRENCY
                                                     IS NOT NULL
                                            THEN
                                                INFO.TW_PAYMENT_CURRENCY
                                            WHEN INFO.JP_CURRENCY IS NOT NULL
                                            THEN
                                                INFO.JP_CURRENCY
                                            ELSE
                                                NULL
                                        END))
                               LIABILITY_ACCOUNT,
                           (SELECT KEY7
                              FROM lfnd_lookups lkp2
                             WHERE     1 = 1
                                   AND lkp2.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_ENITY_INFO'
                                   AND KEY1 = onb.ENTITY_NAME_SUPP_REGI_IN
                                   AND KEY2 =
                                       (CASE
                                            WHEN INFO.CURRENCY IS NOT NULL
                                            THEN
                                                INFO.CURRENCY
                                            WHEN INFO.CH_PAYMENT_CURRENCY
                                                     IS NOT NULL
                                            THEN
                                                INFO.CH_PAYMENT_CURRENCY
                                            WHEN INFO.TW_PAYMENT_CURRENCY
                                                     IS NOT NULL
                                            THEN
                                                INFO.TW_PAYMENT_CURRENCY
                                            WHEN INFO.JP_CURRENCY IS NOT NULL
                                            THEN
                                                INFO.JP_CURRENCY
                                            ELSE
                                                NULL
                                        END))
                               PREPAID_ACCOUNT,
                           (SELECT lkp2.KEY2
                              FROM lfnd_lookups lkp1, lfnd_lookups lkp2
                             WHERE     1 = 1
                                   AND lkp1.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_ENTITIES'
                                   AND lkp2.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_OU_INFO'
                                   AND lkp1.KEY3 = lkp2.KEY1
                                   AND lkp1.KEY4 =
                                       onb.ENTITY_NAME_SUPP_REGI_IN)
                               INVOICE_TOLERANCE_FROM_GOODS,
                           (SELECT lkp2.KEY3
                              FROM lfnd_lookups lkp1, lfnd_lookups lkp2
                             WHERE     1 = 1
                                   AND lkp1.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_ENTITIES'
                                   AND lkp2.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_OU_INFO'
                                   AND lkp1.KEY3 = lkp2.KEY1
                                   AND lkp1.KEY4 =
                                       onb.ENTITY_NAME_SUPP_REGI_IN)
                               INVOICE_TOLERANCE_FOR_SERVICE,
                           (DECODE (
                                info.US_SUPPLIER_QUALIFICATION_8,
                                'Yes', (SELECT b.key4
                                          FROM lfnd_lookups a, lfnd_lookups b
                                         WHERE     1 = 1
                                               AND a.key3 = b.key1
                                               AND a.LOOKUP_TYPE =
                                                   'LOGI_SUPP_ONBRD_ENTITIES'
                                               AND b.LOOKUP_TYPE =
                                                   'LOGI_SUPP_ONBRD_TAX_DEFAULT'
                                               AND a.KEY4 =
                                                   onb.ENTITY_NAME_SUPP_REGI_IN
                                               AND b.key3 =
                                                   'TAX - Reportable'),
                                NULL))
                               TAX_REPORTABLE,
                           (DECODE (
                                info.US_SUPPLIER_QUALIFICATION_8,
                                'Yes', (SELECT b.key4
                                          FROM lfnd_lookups a, lfnd_lookups b
                                         WHERE     1 = 1
                                               AND a.key3 = b.key1
                                               AND a.LOOKUP_TYPE =
                                                   'LOGI_SUPP_ONBRD_ENTITIES'
                                               AND b.LOOKUP_TYPE =
                                                   'LOGI_SUPP_ONBRD_TAX_DEFAULT'
                                               AND a.KEY4 =
                                                   onb.ENTITY_NAME_SUPP_REGI_IN
                                               AND b.key3 = 'Income Tax Type'),
                                NULL))
                               INCOME_TAX_TYPE,
                           (DECODE (
                                info.US_SUPPLIER_QUALIFICATION_8,
                                'Yes', (SELECT b.key4
                                          FROM lfnd_lookups a, lfnd_lookups b
                                         WHERE     1 = 1
                                               AND a.key3 = b.key1
                                               AND a.LOOKUP_TYPE =
                                                   'LOGI_SUPP_ONBRD_ENTITIES'
                                               AND b.LOOKUP_TYPE =
                                                   'LOGI_SUPP_ONBRD_TAX_DEFAULT'
                                               AND a.KEY4 =
                                                   onb.ENTITY_NAME_SUPP_REGI_IN
                                               AND b.key3 = 'State'),
                                NULL))
                               STATE,
                           onb.PAYMENT_TERM_SUPPLIER,
                           (DECODE (
                                info.US_SUPPLIER_QUALIFICATION_8,
                                'Yes', (SELECT b.key4
                                          FROM lfnd_lookups a, lfnd_lookups b
                                         WHERE     1 = 1
                                               AND a.key3 = b.key1
                                               AND a.LOOKUP_TYPE =
                                                   'LOGI_SUPP_ONBRD_ENTITIES'
                                               AND b.LOOKUP_TYPE =
                                                   'LOGI_SUPP_ONBRD_TAX_DEFAULT'
                                               AND a.KEY4 =
                                                   onb.ENTITY_NAME_SUPP_REGI_IN
                                               AND b.key3 =
                                                   'Income Tax Reporting Site'),
                                NULL))
                               INCOME_TAX_REPORTING_SITE,
                           (SELECT b.key4
                              FROM lfnd_lookups a, lfnd_lookups b
                             WHERE     1 = 1
                                   AND a.key3 = b.key1
                                   AND a.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_ENTITIES'
                                   AND b.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_TAX_DEFAULT'
                                   AND a.KEY4 = onb.ENTITY_NAME_SUPP_REGI_IN
                                   AND b.key3 = 'Rounding Level')
                               ROUNDING_LEVEL,
                           (SELECT b.key4
                              FROM lfnd_lookups a, lfnd_lookups b
                             WHERE     1 = 1
                                   AND a.key3 = b.key1
                                   AND a.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_ENTITIES'
                                   AND b.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_TAX_DEFAULT'
                                   AND a.KEY4 = onb.ENTITY_NAME_SUPP_REGI_IN
                                   AND b.key3 = 'Allow Tax Applicability')
                               ALLOW_TAX_APPLICABILITY,
                           (SELECT b.key4
                              FROM lfnd_lookups a, lfnd_lookups b
                             WHERE     1 = 1
                                   AND a.key3 = b.key1
                                   AND a.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_ENTITIES'
                                   AND b.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_TAX_DEFAULT'
                                   AND a.KEY4 = onb.ENTITY_NAME_SUPP_REGI_IN
                                   AND b.key3 = 'Allow offset Taxes')
                               ALLOW_OFFSET_TAXES,
                           (SELECT b.key4
                              FROM lfnd_lookups a, lfnd_lookups b
                             WHERE     1 = 1
                                   AND a.key3 = b.key1
                                   AND a.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_ENTITIES'
                                   AND b.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_TAX_DEFAULT'
                                   AND a.KEY4 = onb.ENTITY_NAME_SUPP_REGI_IN
                                   AND b.key3 = 'Calculate Tax')
                               CALCULATE_TAX,
                           fnd_global.user_id,
                           SYSDATE,
                           fnd_global.login_id,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           'LSUONBDR',
                           NULL,
                           NULL,
                           NULL,
                           (SELECT KEY9
                              FROM lfnd_lookups lkp2
                             WHERE     1 = 1
                                   AND lkp2.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_ENITY_INFO'
                                   AND KEY1 = onb.ENTITY_NAME_SUPP_REGI_IN
                                   AND KEY2 =
                                       (CASE
                                            WHEN INFO.CURRENCY IS NOT NULL
                                            THEN
                                                INFO.CURRENCY
                                            WHEN INFO.CH_PAYMENT_CURRENCY
                                                     IS NOT NULL
                                            THEN
                                                INFO.CH_PAYMENT_CURRENCY
                                            WHEN INFO.TW_PAYMENT_CURRENCY
                                                     IS NOT NULL
                                            THEN
                                                INFO.TW_PAYMENT_CURRENCY
                                            WHEN INFO.JP_CURRENCY IS NOT NULL
                                            THEN
                                                INFO.JP_CURRENCY
                                            ELSE
                                                NULL
                                        END))
                               SHIP_TO,
                           (SELECT KEY10
                              FROM lfnd_lookups lkp2
                             WHERE     1 = 1
                                   AND lkp2.LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_ENITY_INFO'
                                   AND KEY1 = onb.ENTITY_NAME_SUPP_REGI_IN
                                   AND KEY2 =
                                       (CASE
                                            WHEN INFO.CURRENCY IS NOT NULL
                                            THEN
                                                INFO.CURRENCY
                                            WHEN INFO.CH_PAYMENT_CURRENCY
                                                     IS NOT NULL
                                            THEN
                                                INFO.CH_PAYMENT_CURRENCY
                                            WHEN INFO.TW_PAYMENT_CURRENCY
                                                     IS NOT NULL
                                            THEN
                                                INFO.TW_PAYMENT_CURRENCY
                                            WHEN INFO.JP_CURRENCY IS NOT NULL
                                            THEN
                                                INFO.JP_CURRENCY
                                            ELSE
                                                NULL
                                        END))
                               BILL_TO,
                           NVL (CH_BRANCH_NAME, TW_BRANCH_NAME)
                               BANK_BRANCH_NAME
                      FROM LOTC.LOTC_PROSPECTIVE_SUPPLIER_REG  reg,
                           LOTC.LOTC_PROS_SUPP_REG_ADD_INFO    info,
                           LOTC.LOTC_SUPP_ONBOARD_REQUEST      onb
                     WHERE     1 = 1
                           AND reg.REGI_REQUEST_NUMBER =
                               info.REGI_REQUEST_NUMBER
                           AND info.REGI_REQUEST_NUMBER =
                               onb.REGI_REQUEST_NUMBER
                           AND reg.REGI_REQUEST_NUMBER =
                               TO_NUMBER (TRIM (p_req_num));
            /*                        AND NOT EXISTS
                                           (SELECT 1
                                              FROM LOTC.LOTC_SUPP_DATA_MANAGEMENT SDM1
                                             WHERE SDM1.REGI_REQUEST_NUMBER =
                                                   reg.REGI_REQUEST_NUMBER); */
            EXCEPTION
                WHEN OTHERS
                THEN
                    WRITE_CUST_LOG (
                        123,
                        'CREATE_DATA_MANAGEMENT',
                        'Error @CREATE_DATA_MANAGEMENT inserting ' || SQLERRM);
                    WRITE_CUST_LOG (123,
                                    'CREATE_DATA_MANAGEMENT',
                                    DBMS_UTILITY.format_error_backtrace);
                    WRITE_CUST_LOG (123,
                                    'CREATE_DATA_MANAGEMENT',
                                    DBMS_UTILITY.format_error_stack);
            END;
        END IF;

        IF L_ROWCOUNT = 1
        THEN
            l_COMPANY_NAME := NULL;
            l_ADDRESS_LINE1 := NULL;
            l_ADDRESS_LINE2 := NULL;
            l_CITY := NULL;
            l_STATE_PROVINCE := NULL;
            l_COUNTRY := NULL;
            l_POSTAL_CODE := NULL;
            l_TELEPHONE := NULL;
            l_FAX := NULL;
            l_URL := NULL;
            l_TAX_VAT_REGI_ID := NULL;
            l_PAYMENT_REMITTANCE_EMAIL := NULL;
            l_PO_COMMUNICATION_EMAIL := NULL;
            l_PAYMENT_TERMS := NULL;
            l_BANK_NAME := NULL;
            l_BANK_ADDRESS_LINE_1 := NULL;
            l_BANK_ADDRESS_LINE_2 := NULL;
            l_BANK_CITY := NULL;
            l_BANK_STATE_PROVINCE := NULL;
            l_BANK_COUNTRY := NULL;
            l_BANK_POSTAL_CODE := NULL;
            l_BANK_CODE := NULL;
            l_BANK_BRANCH_CODE := NULL;
            l_ACCOUNT_TYPE := NULL;
            l_ACCOUNT_NAME := NULL;
            l_ACCOUNT_NUMBER := NULL;
            l_CURRENCY := NULL;
            l_IBAN := NULL;
            l_SWIFT_BIC := NULL;
            l_IFSC := NULL;
            l_ACH_ABA_ROUTING := NULL;
            l_CNAPS_CODE := NULL;
            l_BANK_BRANCH_NAME := NULL;

            BEGIN
                SELECT reg.COMPANY_NAME,
                       reg.ADDRESS_LINE1,
                       reg.ADDRESS_LINE2,
                       reg.CITY,
                       reg.STATE_PROVINCE,
                       reg.COUNTRY,
                       reg.POSTAL_CODE,
                       NULL,
                       NULL,
                       NULL,
                       NVL (INFO.TAX_VAT_REGI_ID, INFO.CH_TAX_VAT_REGI_ID),
                       NVL (INFO.PAYMENT_REMITTANCE_EMAIL,
                            INFO.CH_PAYMENT_REMITTANCE_EMAIL),
                       NVL (INFO.PO_COMMUNICATION_EMAIL,
                            INFO.CH_PO_COMMUNICATION_EMAIL),
                       INFO.PAYMENT_TERMS,
                       (CASE
                            WHEN INFO.BANK_NAME IS NOT NULL
                            THEN
                                INFO.BANK_NAME
                            WHEN INFO.CH_BANK_NAME IS NOT NULL
                            THEN
                                INFO.CH_BANK_NAME
                            WHEN INFO.TW_BANK_NAME IS NOT NULL
                            THEN
                                INFO.TW_BANK_NAME
                            ELSE
                                NULL
                        END)
                           BANK_NAME,
                       INFO.BANK_ADDRESS_LINE_1,
                       INFO.BANK_ADDRESS_LINE_2,
                       INFO.BANK_CITY,
                       INFO.BANK_STATE_PROVINCE,
                       INFO.BANK_COUNTRY,
                       INFO.BANK_POSTAL_CODE,
                      -- NVL (INFO.BANK_CODE, JP_BANK_CODE)   Commeted the logic for Bank Code not appearing in the Notification   17-Jan-19
					  NVL (NVL (INFO.BANK_CODE, JP_BANK_CODE),TW_BANK_CODE)   --Added the logic for showing Bank Code information into the Notification  17-Jan-19
                           BANK_CODE,
                       (CASE
                            WHEN INFO.BANK_BRANCH_CODE IS NOT NULL
                            THEN
                                INFO.BANK_BRANCH_CODE
                            WHEN INFO.TW_BRANCH_CODE IS NOT NULL
                            THEN
                                INFO.TW_BRANCH_CODE
                            WHEN INFO.JP_BRANCH_CODE IS NOT NULL
                            THEN
                                INFO.JP_BRANCH_CODE
                            ELSE
                                NULL
                        END)
                           BANK_BRANCH_CODE,
                       NVL (INFO.ACCOUNT_TYPE, INFO.JP_ACCOUNT_TYPE)
                           ACCOUNT_TYPE,
                       (CASE
                            WHEN INFO.ACCOUNT_NAME IS NOT NULL
                            THEN
                                INFO.ACCOUNT_NAME
                            WHEN INFO.CH_ACCOUNT_NAME IS NOT NULL
                            THEN
                                INFO.CH_ACCOUNT_NAME
                            WHEN INFO.TW_ACCOUNT_NAME IS NOT NULL
                            THEN
                                INFO.TW_ACCOUNT_NAME
                            WHEN INFO.JP_ACCOUNT_NAME IS NOT NULL
                            THEN
                                INFO.JP_ACCOUNT_NAME
                            ELSE
                                NULL
                        END)
                           ACCOUNT_NAME,
                       (CASE
                            WHEN INFO.ACCOUNT_NUMBER IS NOT NULL
                            THEN
                                INFO.ACCOUNT_NUMBER
                            WHEN INFO.CH_ACCOUNT_NUMBER IS NOT NULL
                            THEN
                                INFO.CH_ACCOUNT_NUMBER
                            WHEN INFO.TW_ACCOUNT_NUMBER IS NOT NULL
                            THEN
                                INFO.TW_ACCOUNT_NUMBER
                            WHEN INFO.JP_ACCOUNT_NUMBER IS NOT NULL
                            THEN
                                INFO.JP_ACCOUNT_NUMBER
                            ELSE
                                NULL
                        END)
                           ACCOUNT_NUMBER,
                       (CASE
                            WHEN INFO.CURRENCY IS NOT NULL
                            THEN
                                INFO.CURRENCY
                            WHEN INFO.CH_PAYMENT_CURRENCY IS NOT NULL
                            THEN
                                INFO.CH_PAYMENT_CURRENCY
                            WHEN INFO.TW_PAYMENT_CURRENCY IS NOT NULL
                            THEN
                                INFO.TW_PAYMENT_CURRENCY
                            WHEN INFO.JP_CURRENCY IS NOT NULL
                            THEN
                                INFO.JP_CURRENCY
                            ELSE
                                NULL
                        END)
                           CURRENCY,
                       INFO.IBAN,
                       INFO.SWIFT_BIC,
                       INFO.IFSC,
                       INFO.ACH_ABA_ROUTING,
                       (CASE
                            WHEN INFO.CNAPS_CODE IS NOT NULL
                            THEN
                                INFO.CNAPS_CODE
                            WHEN INFO.CH_CNAPS_CODE_12 IS NOT NULL
                            THEN
                                INFO.CH_CNAPS_CODE_12
                            WHEN INFO.TW_CNAPS_CODE_12 IS NOT NULL
                            THEN
                                INFO.TW_CNAPS_CODE_12
                            ELSE
                                NULL
                        END)
                           CNAPS_CODE,
                       NVL (CH_BRANCH_NAME, TW_BRANCH_NAME)
                           BANK_BRANCH_NAME
                  INTO l_COMPANY_NAME,
                       l_ADDRESS_LINE1,
                       l_ADDRESS_LINE2,
                       l_CITY,
                       l_STATE_PROVINCE,
                       l_COUNTRY,
                       l_POSTAL_CODE,
                       l_TELEPHONE,
                       l_FAX,
                       l_URL,
                       l_TAX_VAT_REGI_ID,
                       l_PAYMENT_REMITTANCE_EMAIL,
                       l_PO_COMMUNICATION_EMAIL,
                       l_PAYMENT_TERMS,
                       l_BANK_NAME,
                       l_BANK_ADDRESS_LINE_1,
                       l_BANK_ADDRESS_LINE_2,
                       l_BANK_CITY,
                       l_BANK_STATE_PROVINCE,
                       l_BANK_COUNTRY,
                       l_BANK_POSTAL_CODE,
                       l_BANK_CODE,
                       l_BANK_BRANCH_CODE,
                       l_ACCOUNT_TYPE,
                       l_ACCOUNT_NAME,
                       l_ACCOUNT_NUMBER,
                       l_CURRENCY,
                       l_IBAN,
                       l_SWIFT_BIC,
                       l_IFSC,
                       l_ACH_ABA_ROUTING,
                       l_CNAPS_CODE,
                       l_BANK_BRANCH_NAME
                  FROM LOTC.LOTC_PROSPECTIVE_SUPPLIER_REG  reg,
                       LOTC.LOTC_PROS_SUPP_REG_ADD_INFO    info,
                       LOTC.LOTC_SUPP_ONBOARD_REQUEST      onb
                 WHERE     1 = 1
                       AND reg.REGI_REQUEST_NUMBER = info.REGI_REQUEST_NUMBER
                       AND info.REGI_REQUEST_NUMBER = onb.REGI_REQUEST_NUMBER
                       AND reg.REGI_REQUEST_NUMBER =
                           TO_NUMBER (TRIM (p_req_num));
            EXCEPTION
                WHEN OTHERS
                THEN
                    WRITE_CUST_LOG (
                        123,
                        'CREATE_DATA_MANAGEMENT',
                        'Error in Retriving the information ' || SQLERRM);
            END;

            UPDATE LOTC_SUPP_DATA_MANAGEMENT
               SET COMPANY_NAME = l_COMPANY_NAME,
                   ADDRESS_LINE1 = l_ADDRESS_LINE1,
                   ADDRESS_LINE2 = l_ADDRESS_LINE2,
                   CITY = l_CITY,
                   STATE_PROVINCE = l_STATE_PROVINCE,
                   COUNTRY = l_COUNTRY,
                   POSTAL_CODE = l_POSTAL_CODE,
                   TELEPHONE = l_TELEPHONE,
                   FAX = l_FAX,
                   URL = l_URL,
                   TAX_VAT_REGI_ID = l_TAX_VAT_REGI_ID,
                   PAYMENT_REMITTANCE_EMAIL = l_PAYMENT_REMITTANCE_EMAIL,
                   PO_COMMUNICATION_EMAIL = l_PO_COMMUNICATION_EMAIL,
                   PAYMENT_TERMS = l_PAYMENT_TERMS,
                   BANK_NAME = l_BANK_NAME,
                   BANK_ADDRESS_LINE_1 = l_BANK_ADDRESS_LINE_1,
                   BANK_ADDRESS_LINE_2 = l_BANK_ADDRESS_LINE_2,
                   BANK_CITY = l_BANK_CITY,
                   BANK_STATE_PROVINCE = l_BANK_STATE_PROVINCE,
                   BANK_COUNTRY = l_BANK_COUNTRY,
                   BANK_POSTAL_CODE = l_BANK_POSTAL_CODE,
                   BANK_CODE = l_BANK_CODE,
                   BANK_BRANCH_CODE = l_BANK_BRANCH_CODE,
                   ACCOUNT_TYPE = l_ACCOUNT_TYPE,
                   ACCOUNT_NAME = l_ACCOUNT_NAME,
                   ACCOUNT_NUMBER = l_ACCOUNT_NUMBER,
                   CURRENCY = l_CURRENCY,
                   IBAN = l_IBAN,
                   SWIFT_BIC = l_SWIFT_BIC,
                   IFSC = l_IFSC,
                   ACH_ABA_ROUTING = l_ACH_ABA_ROUTING,
                   CNAPS_CODE = l_CNAPS_CODE,
                   BANK_BRANCH_NAME = l_BANK_BRANCH_NAME
             WHERE REGI_REQUEST_NUMBER = p_req_num;
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (
                123,
                'CREATE_DATA_MANAGEMENT',
                   'Error @CREATE_DATA_MANAGEMENT outermost exception '
                || SQLERRM);

            WRITE_CUST_LOG (123,
                            'CREATE_DATA_MANAGEMENT',
                            DBMS_UTILITY.format_error_backtrace);
            WRITE_CUST_LOG (123,
                            'CREATE_DATA_MANAGEMENT',
                            DBMS_UTILITY.format_error_stack);
    END CREATE_DATA_MANAGEMENT;

    PROCEDURE REJECT_ATT_VALUES (itemtype    IN     VARCHAR2,
                                 itemkey     IN     VARCHAR2,
                                 actid       IN     NUMBER,
                                 funcmode    IN     VARCHAR2,
                                 resultout   IN OUT VARCHAR2)
    AS
        vCommands                        VARCHAR2 (4000);
        l_Responder                      VARCHAR2 (100);
        l_Responder_Name                 VARCHAR2 (100);
        l_Responder_Mailid               VARCHAR2 (100);
        vRoleCount                       NUMBER;
        l_transaction_type               VARCHAR2 (30) := 'LOGI_SUPP_ONBRD_REG';
        l_application_Id                 NUMBER := 60007;

        l_next_approver                  AME_UTIL.approverRecord;
        l_request_number                 NUMBER;
        l_approver_id                    NUMBER (15) := NULL;
        l_approver_name                  VARCHAR2 (150);
        l_approver_name_display          VARCHAR2 (150);
        l_callingProgram                 VARCHAR2 (150)
                                             := 'LogiSupplieronBoardingApproval';
        l_nextapproversout               ame_util.approverstable2;
        l_itemindexesout                 ame_util.idlist;
        l_itemclassesout                 ame_util.stringlist;
        l_itemidsout                     ame_util.stringlist;
        l_itemsourcesout                 ame_util.longstringlist;
        l_approvalprocesscompleteynout   VARCHAR2 (100);
        l_approver_count                 NUMBER;
        l_transaction_id                 VARCHAR2 (30);
        l_ExpirationDate                 DATE := SYSDATE + 1000;
        l_AdHocRoleName                  VARCHAR2 (500);
        l_AdHocRoleDesc                  VARCHAR2 (500);
        l_customer_name                  VARCHAR2 (240);
        l_dm_approver                    VARCHAR2 (240);
        l_notification_sequence          NUMBER;
        l_user_name                      VARCHAR2 (240);
        l_email_address                  VARCHAR2 (240);
        l_dm_role_name                   VARCHAR2 (240);
        l_App_user_name                  VARCHAR2 (100);
        l_App_user_name2                 VARCHAR2 (100);
        l_App_user_name3                 VARCHAR2 (100);
        l_App_user_name4                 VARCHAR2 (100);
        l_App_user_name5                 VARCHAR2 (100);
        l_nid                            NUMBER;
        l_gid                            NUMBER;
        l_result                         VARCHAR2 (100);
        l_ame_status                     VARCHAR2 (20);
        l_original_approver_name         VARCHAR2 (240);
        l_forwardeein                    ame_util.approverrecord2;
        l_user_name1                     VARCHAR2 (50);
        l_role_name1                     VARCHAR2 (320) := NULL;
        l_ENTITY_NAME_SUPP_REGI_IN       VARCHAR2 (240);
        l_REQUESTOR_NAME                 VARCHAR2 (240);
        l_EMAIL_ADDRESS1                 VARCHAR2 (240);
    BEGIN
        UPDATE LOTC.LOTC_SUPP_ONBOARD_REQUEST req
           SET REGISTRATION_STATUS = 'Rejected by Reviewer'
         WHERE req.REGI_REQUEST_NUMBER =
               (SELECT REGI_REQUEST_NUMBER
                  FROM LOTC.LOTC_PROSPECTIVE_SUPPLIER_REG
                 WHERE ITEM_TYPE = itemtype AND ITEM_KEY = itemkey);


        UPDATE LOTC_PROS_SUPP_REG_ADD_INFO
           SET SUBMITTED = NULL
         WHERE REGI_REQUEST_NUMBER =
               (SELECT REGI_REQUEST_NUMBER
                  FROM LOTC.LOTC_PROSPECTIVE_SUPPLIER_REG
                 WHERE ITEM_TYPE = itemtype AND ITEM_KEY = itemkey);

        UPDATE LOTC.LOTC_PROSPECTIVE_SUPPLIER_REG
           SET SUBMITTED = NULL
         WHERE ITEM_TYPE = itemtype AND ITEM_KEY = itemkey;

        BEGIN
            SELECT ENTITY_NAME_SUPP_REGI_IN,
                   REQUESTOR_NAME,
                   (SELECT EMAIL_ADDRESS
                      FROM PER_ALL_PEOPLE_F
                     WHERE     FULL_NAME = REQUESTOR_NAME
                           AND SYSDATE BETWEEN EFFECTIVE_START_DATE
                                           AND NVL (EFFECTIVE_END_DATE,
                                                    SYSDATE)
                           AND ROWNUM = 1)
                       EMAIL_ADDRESS
              INTO l_ENTITY_NAME_SUPP_REGI_IN,
                   l_REQUESTOR_NAME,
                   l_EMAIL_ADDRESS1
              FROM LOTC_SUPP_ONBOARD_REQUEST req
             WHERE req.REGI_REQUEST_NUMBER =
                   (SELECT REGI_REQUEST_NUMBER
                      FROM LOTC.LOTC_PROSPECTIVE_SUPPLIER_REG
                     WHERE ITEM_TYPE = itemtype AND ITEM_KEY = itemkey);
        EXCEPTION
            WHEN OTHERS
            THEN
                write_cust_log (
                    123,
                    itemkey,
                    'Error in Entity information Derivation ' || SQLERRM);
                l_ENTITY_NAME_SUPP_REGI_IN := NULL;
                l_REQUESTOR_NAME := NULL;
                l_EMAIL_ADDRESS := NULL;
        END;

        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'ENTITY_NAME_SUPP_REGI_IN',
                                   avalue     => l_ENTITY_NAME_SUPP_REGI_IN);

        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'REQUESTOR_NAME',
                                   avalue     => l_REQUESTOR_NAME);

        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'EMAIL_ADDRESS',
                                   avalue     => l_EMAIL_ADDRESS1);

        BEGIN
            l_Responder := NULL;

            SELECT wn.RECIPIENT_ROLE,
                   (SELECT PAPF.FULL_NAME
                      FROM PER_ALL_PEOPLE_F PAPF, FND_USER FNDU
                     WHERE     1 = 1
                           AND PAPF.PERSON_ID = FNDU.EMPLOYEE_ID
                           AND FNDU.USER_NAME = wn.RECIPIENT_ROLE
                           AND ROWNUM = 1),
                   (SELECT PAPF.EMAIL_ADDRESS
                      FROM PER_ALL_PEOPLE_F PAPF, FND_USER FNDU
                     WHERE     1 = 1
                           AND PAPF.PERSON_ID = FNDU.EMPLOYEE_ID
                           AND FNDU.USER_NAME = wn.RECIPIENT_ROLE
                           AND ROWNUM = 1)
              INTO l_Responder, l_Responder_Name, l_Responder_Mailid
              FROM wf_notifications wn
             WHERE     1 = 1
                   AND NOTIFICATION_ID =
                       (SELECT MAX (NOTIFICATION_ID)
                          FROM wf_notifications
                         WHERE     1 = 1
                               AND MESSAGE_TYPE = itemtype
                               AND item_key = itemkey
                               AND RESPONDER IS NOT NULL
                               AND STATUS = 'CLOSED');
        EXCEPTION
            WHEN OTHERS
            THEN
                l_Responder := NULL;
        END;

        WRITE_CUST_LOG (
            itemkey,
            'LOGI_SUPP_ONBRD_PKG.REJECT_ATT_VALUES',
               l_Responder
            || '  $  '
            || l_Responder_Name
            || '  $  '
            || l_Responder_Mailid);

        SELECT COUNT (1)
          INTO vRoleCount
          FROM apps.wf_roles
         WHERE NAME = l_Responder_Mailid;

        IF vRoleCount = 0
        THEN
            wf_directory.createadhocrole (
                role_name                 => l_Responder_Mailid,
                role_display_name         => l_Responder_Name,
                role_description          => l_Responder_Name,
                notification_preference   => 'MAILHTML',
                email_address             => l_Responder_Mailid,
                status                    => 'ACTIVE',
                expiration_date           => NULL);
        END IF;

        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#FROM_ROLE',
                                   avalue     => l_Responder_Mailid);

        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#WFM_FROM',
                                   avalue     => l_Responder_Name);

        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#WFM_REPLYTO',
                                   avalue     => l_Responder_Mailid);


        l_transaction_type := 'LOGI_PROS_SUPP_REG';
        l_application_id := 60007;
        l_transaction_id := itemKey;
        l_approver_name := l_Responder;

        -- ReAssign Approving the request start from here
        l_approver_count :=
            wf_engine.GetItemAttrNumber (itemtype   => itemtype,
                                         itemkey    => itemkey,
                                         aname      => 'LOGI_APPROVER_COUNT');


        BEGIN
            SELECT CASE
                       WHEN l_approver_count = 0
                       THEN
                           'LOGI_PROS_SUPP_REG_ROLE_' || itemkey
                       ELSE
                              'LOGI_PROS_SUPP_REG_ROLE_'
                           || itemkey
                           || '_'
                           || l_approver_count
                   END
              INTO l_role_name1
              FROM DUAL;

            write_cust_log (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.REJECT_ATT_VALUES',
                            'l_role_name1   is  --> ' || l_role_name1);


            SELECT USER_NAME
              INTO l_user_name1
              FROM WF_USER_ROLES
             WHERE role_name = l_role_name1 AND USER_NAME = l_approver_name;
        EXCEPTION
            WHEN OTHERS
            THEN
                BEGIN
                    SELECT USER_NAME
                      INTO l_approver_name
                      FROM WF_USER_ROLES
                     WHERE role_name = l_role_name1 AND ROWNUM = 1;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        write_cust_log (
                            itemkey,
                            'LOGI_SUPP_ONBRD_PKG.REJECT_ATT_VALUES',
                               'l_approver_name derivation issue     --> '
                            || SQLERRM);
                END;
        END;

        -- ReAssign Approving the request end from here



        IF (funcmode = 'RUN')
        THEN
            l_ame_status := ame_util.rejectstatus;
            ame_api2.updateapprovalstatus2 (
                applicationidin     => l_application_id,
                transactiontypein   => l_transaction_type,
                transactionidin     => l_transaction_id,
                approvalstatusin    => l_ame_status,
                approvernamein      => l_approver_name);

            write_cust_log (
                itemkey,
                'LOGI_SUPP_ONBRD_PKG.REJECT_ATT_VALUES',
                   'RUN  l_approver_name update status    --> '
                || l_approver_name
                || '     '
                || l_ame_status);
        ELSIF (funcmode = 'TRANSFER')
        THEN
            l_forwardeein.name := wf_engine.context_new_role;
            l_original_approver_name := wf_engine.context_original_recipient;

            write_cust_log (
                itemkey,
                'LOGI_SUPP_ONBRD_PKG.REJECT_ATT_VALUES',
                   'TRANSFER    l_forwardeein.name    --> '
                || l_forwardeein.name);
            write_cust_log (
                itemkey,
                'LOGI_SUPP_ONBRD_PKG.REJECT_ATT_VALUES',
                   'TRANSFER    l_original_approver_name    --> '
                || l_original_approver_name);


            ame_api2.updateapprovalstatus2 (
                applicationidin     => l_application_id,
                transactiontypein   => l_transaction_type,
                transactionidin     => l_transaction_id,
                approvalstatusin    => 'FORWARD',
                approvernamein      => l_original_approver_name,
                forwardeein         => l_forwardeein);
            write_cust_log (
                itemkey,
                'LOGI_SUPP_ONBRD_PKG.REJECT_ATT_VALUES',
                   'TRANSFER  l_approver_name update status    --> '
                || l_original_approver_name
                || '     '
                || 'FORWARD');
        END IF;

        COMMIT;

        BEGIN
            /*             SELECT SUBSTR (TEXT_VALUE, 1, 3999)
                          INTO vCommands
                          FROM WF_NOTIFICATION_ATTRIBUTES
                         WHERE     NOTIFICATION_ID =
                                   (SELECT MAX (NOTIFICATION_ID)
                                      FROM WF_NOTIFICATIONS nft
                                     WHERE     1 = 1
                                           AND ITEM_KEY = itemkey
                                           AND MESSAGE_TYPE = 'LSUONBDR')
                               AND Name = 'PRN_COMMENTS'; */

            vCommands := ' ';

            FOR i
                IN (SELECT SUBSTR (TEXT_VALUE, 1, 3999) TEXT_VALUE
                      FROM WF_NOTIFICATION_ATTRIBUTES
                     WHERE     NOTIFICATION_ID IN
                                   (SELECT NOTIFICATION_ID
                                      FROM WF_NOTIFICATIONS nft
                                     WHERE     1 = 1
                                           AND GROUP_ID =
                                               (SELECT MAX (GROUP_ID)
                                                  FROM WF_NOTIFICATIONS nft
                                                 WHERE     1 = 1
                                                       AND ITEM_KEY = itemkey
                                                       AND MESSAGE_TYPE =
                                                           'LSUONBDR'))
                           AND Name = 'PRN_COMMENTS')
            LOOP
                vCommands := vCommands || '' || i.TEXT_VALUE;
            END LOOP;

            WF_ENGINE.SetItemAttrText (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'REJECT_COMMAND',
                                       avalue     => vCommands);
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.REJECT_ATT_VALUES',
                    'Error in vCommands Derivation  --> ' || SQLERRM);
        END;

        BEGIN
            l_dm_role_name := 'LOGI_DATA_MANAGEMENT_TEAM_' || itemkey;

            WRITE_CUST_LOG (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.REJECT_ATT_VALUES',
                            'l_dm_role_name  --> ' || l_dm_role_name);

            vRoleCount := 0;

            SELECT COUNT (1)
              INTO vRoleCount
              FROM apps.wf_roles
             WHERE NAME = l_dm_role_name;

            IF vRoleCount = 0
            THEN
                WF_DIRECTORY.CreateAdHocRole (l_dm_role_name,
                                              l_dm_role_name,
                                              NULL,
                                              NULL,
                                              NULL,
                                              'MAILHTML',
                                              NULL,
                                              NULL,
                                              NULL,
                                              'ACTIVE',
                                              l_ExpirationDate);
            END IF;


            FOR DM_USER
                IN (SELECT USER_NAME, EMAIL_ADDRESS
                      FROM (SELECT ROWNUM
                                       ROW_NUM,
                                   KEY4
                                       USER_NAME,
                                   (SELECT EMAIL_ADDRESS
                                      FROM per_all_people_f
                                     WHERE full_name = KEY3 AND ROWNUM = 1)
                                       EMAIL_ADDRESS
                              FROM lfnd_lookups a
                             WHERE     LOOKUP_TYPE =
                                       'LOGI_SUPP_ONBRD_TEAM_MEMBERS'
                                   AND KEY1 =
                                       (SELECT KEY2
                                          FROM lfnd_lookups a
                                         WHERE     LOOKUP_TYPE =
                                                   'LOGI_SUPP_ONBRD_ENTITIES'
                                               AND KEY4 =
                                                   (SELECT NVL (
                                                               (SELECT ENTITY_NAME
                                                                  FROM LOTC.LOTC_SUPP_DATA_MANAGEMENT
                                                                 WHERE REGI_REQUEST_NUMBER =
                                                                       REQ.REGI_REQUEST_NUMBER),
                                                               REQ.ENTITY_NAME_SUPP_REGI_IN)
                                                      FROM APPS.LOTC_SUPP_ONBOARD_REQUEST
                                                           REQ,
                                                           APPS.LOTC_PROSPECTIVE_SUPPLIER_REG
                                                           PREG
                                                     WHERE     REQ.REGI_REQUEST_NUMBER =
                                                               PREG.REGI_REQUEST_NUMBER
                                                           AND PREG.ITEM_TYPE =
                                                               itemtype
                                                           AND PREG.ITEM_KEY =
                                                               itemkey))))
            LOOP
                WF_DIRECTORY.AddUsersToAdHocRole (l_dm_role_name,
                                                  DM_USER.USER_NAME);
            END LOOP;

            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'DATA_MGR_ROLE',
                                       avalue     => l_dm_role_name);
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.REJECT_ATT_VALUES',
                       'DM Team Derivation Isuue  --> '
                    || DBMS_UTILITY.format_error_backtrace
                    || '   and format_error_stack      '
                    || DBMS_UTILITY.format_error_stack);
        END;

        resultout := 'Success';
    EXCEPTION
        WHEN OTHERS
        THEN
            resultout := 'Success';
            WRITE_CUST_LOG (
                itemkey,
                'LOGI_SUPP_ONBRD_PKG.REJECT_ATT_VALUES',
                   'Outter Most exception  --> '
                || DBMS_UTILITY.format_error_backtrace
                || '   and format_error_stack      '
                || DBMS_UTILITY.format_error_stack);
    END REJECT_ATT_VALUES;



    PROCEDURE START_DISQUALIFY_WF (pItemKey VARCHAR2)
    AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        vItemType     VARCHAR2 (30) := 'LSUONBDR';
        vProcess      VARCHAR2 (50) := 'LOGI_DISQUALIFY_SUPPLIER';
        vForm         VARCHAR2 (50);
        vsqlerrm      VARCHAR2 (110);
        vDocumment    CLOB;
        vPrimaryKey   NUMBER;
    BEGIN
        Wf_Engine.createProcess (ItemType   => vItemType,
                                 ItemKey    => pItemKey,
                                 process    => vProcess);

        Wf_Engine.StartProcess (itemType => vItemType, itemKey => pItemKey);

        UPDATE LOTC.LOTC_SUPP_DATA_MANAGEMENT
           SET RESUBMIT_STATUS = 'Y',
               NOTIFY_STATUS = 'Y',
               DISQUALIFY_KEY = 'Y'
         WHERE DISQUALIFY_KEY = pItemKey AND ITEM_TYPE = 'LSUONBDR';

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            vsqlerrm := SUBSTR (SQLERRM, 1, 100);
            COMMIT;
    END start_Disqualify_wf;


    PROCEDURE START_NOTIFY_WF (pItemKey VARCHAR2)
    AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        vItemType         VARCHAR2 (30) := 'LSUONBDR';
        vProcess          VARCHAR2 (50) := 'LOGI_NOTIFY_SUPPLIER';
        vForm             VARCHAR2 (50);
        vsqlerrm          VARCHAR2 (110);
        vDocumment        CLOB;
        vPrimaryKey       NUMBER;
        vNotifyCommands   VARCHAR2 (4000);
    BEGIN
        Wf_Engine.createProcess (ItemType   => vItemType,
                                 ItemKey    => pItemKey,
                                 process    => vProcess);

        Wf_Engine.StartProcess (itemType => vItemType, itemKey => pItemKey);
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            vsqlerrm := SUBSTR (SQLERRM, 1, 100);
            COMMIT;
    END START_NOTIFY_WF;



    PROCEDURE DATA_MAN_NOTIFY_SUPPLIER (itemtype    IN     VARCHAR2,
                                        itemkey     IN     VARCHAR2,
                                        actid       IN     NUMBER,
                                        funcmode    IN     VARCHAR2,
                                        resultout   IN OUT VARCHAR2)
    AS
        vSuppProsRequestPage   VARCHAR2 (1000);
        vSupplierName          VARCHAR2 (240);
        vRequestorName         VARCHAR2 (100);
        vRequestorUserName     VARCHAR2 (100);
        vSupplierMailId        VARCHAR2 (2000);
        vApproveBody           VARCHAR2 (4000);
        vRejectBody            VARCHAR2 (4000);
        vRequestNumber         NUMBER;
        vRoleCount             NUMBER;
        vNotifyCommands        VARCHAR2 (4000);
    BEGIN
        BEGIN
            WRITE_CUST_LOG (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.Data_Man_Notify_Supplier',
                            'Entered into Data_Man_Notify_Supplier logic');

            SELECT REGI_REQUEST_NUMBER
              INTO vRequestNumber
              FROM LOTC_SUPP_DATA_MANAGEMENT
             WHERE NOTIFY_KEY = itemkey AND ITEM_TYPE = 'LSUONBDR';


            SELECT SUPPLIER_NAME, REQUESTOR_NAME, CONTACT_PERSON_MAIL_ID
              INTO vSupplierName, vRequestorName, vSupplierMailId
              FROM LOTC_SUPP_ONBOARD_REQUEST
             WHERE REGI_REQUEST_NUMBER = vRequestNumber;

            SELECT USER_NAME
              INTO vRequestorUserName
              FROM PER_ALL_PEOPLE_F PAPF, FND_USER FNDU
             WHERE     1 = 1
                   AND PAPF.PERSON_ID = FNDU.EMPLOYEE_ID
                   AND PAPF.FULL_NAME = vRequestorName
                   AND ROWNUM = 1;

            UPDATE LOTC_PROSPECTIVE_SUPPLIER_REG
               SET SUBMITTED = NULL
             WHERE REGI_REQUEST_NUMBER = vRequestNumber;

            UPDATE LOTC_PROS_SUPP_REG_ADD_INFO
               SET SUBMITTED = NULL
             WHERE REGI_REQUEST_NUMBER = vRequestNumber;


            UPDATE LOTC.LOTC_SUPP_ONBOARD_REQUEST
               SET REGISTRATION_STATUS = 'Supplier to provide details'
             WHERE REGI_REQUEST_NUMBER = vRequestNumber;



            Wf_Engine.SetItemAttrText (itemtype,
                                       itemkey,
                                       'SUPPLIER_NAME',
                                       vSupplierName);

            Wf_Engine.SetItemAttrText (itemtype,
                                       itemkey,
                                       'REQUESTER_NAME',
                                       vRequestorUserName);

            vSuppProsRequestPage :=
                FND_RUN_FUNCTION.get_run_function_url (
                    p_function_id =>
                        fnd_function.get_function_id ('LOGI_SUPP_ONBRD_PROS'),
                    p_resp_appl_id =>
                        NULL,
                    p_resp_id =>
                        NULL,
                    p_security_group_id =>
                        0,
                    p_parameters =>
                           'RequestNumber1='
                        || vRequestNumber
                        || '&'
                        || 'NotifyMode=Yes',
                    p_override_agent =>
                        NULL,
                    p_org_id =>
                        NULL,
                    p_lang_code =>
                        NULL,
                    p_encryptParameters =>
                        TRUE);
            /*     01-NOv-18        vSuppProsRequestPage :=
                            REPLACE (vSuppProsRequestPage,
                                     pos_url_pkg.get_internal_url,
                                     pos_url_pkg.get_external_url); */

            vSuppProsRequestPage :=
                REPLACE (vSuppProsRequestPage,
                         fnd_profile.VALUE ('APPS_SERVLET_AGENT') || '/',
                         pos_url_pkg.get_external_url || 'OA_HTML/');

            wf_engine.setitemattrtext (
                itemtype   => itemtype,
                itemkey    => itemkey,
                aname      => 'LOGI_SUPP_ONBDR_PROS_PAGE',
                avalue     => vSuppProsRequestPage);


            SELECT COUNT (1)
              INTO vRoleCount
              FROM apps.wf_roles
             WHERE NAME = vSupplierMailId;

            IF vRoleCount = 0
            THEN
                wf_directory.createadhocrole (
                    role_name                 => vSupplierMailId,
                    role_display_name         => vSupplierMailId,
                    role_description          => vSupplierName,
                    notification_preference   => 'MAILHTML',
                    email_address             => vSupplierMailId,
                    status                    => 'ACTIVE',
                    expiration_date           => NULL);
            END IF;

            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => '#FROM_ROLE',
                                       avalue     => vSupplierMailId);
            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => '#WFM_FROM',
                                       avalue     => vSupplierMailId);
            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => '#WFM_REPLYTO',
                                       avalue     => vSupplierMailId);

            BEGIN
                SELECT NOTE_TO_SUPPLIER
                  INTO vNotifyCommands
                  FROM LOTC_SUPP_DATA_MANAGEMENT
                 WHERE ITEM_TYPE = 'LSUONBDR' AND NOTIFY_KEY = itemkey;
            EXCEPTION
                WHEN OTHERS
                THEN
                    WRITE_CUST_LOG (
                        itemkey,
                        'LOGI_SUPP_ONBRD_PKG.start_Notify_wf',
                           'Error in start_Notify_wf comments derivation -->'
                        || SQLERRM);
                    vNotifyCommands := NULL;
            END;

            WRITE_CUST_LOG (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.start_Notify_wf',
                            'vNotifyCommands -->' || vNotifyCommands);

            Wf_Engine.SetItemAttrText (itemtype,
                                       itemkey,
                                       'NOTIFY_COMMENTS',
                                       vNotifyCommands);

            resultout := 'COMPLETE:' || 'Y';
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.Data_Man_Notify_Supplier',
                       'vSupplierName,vRequestorName,vSupplierMailId  --> '
                    || SQLERRM);
                resultout := 'COMPLETE:' || 'N';
        END;
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.Data_Man_Notify_Supplier',
                            'Outter Most exception  --> ' || SQLERRM);
    END DATA_MAN_NOTIFY_SUPPLIER;

    PROCEDURE DATA_MAN_DISQUALIFY_SUPPLIER (itemtype    IN     VARCHAR2,
                                            itemkey     IN     VARCHAR2,
                                            actid       IN     NUMBER,
                                            funcmode    IN     VARCHAR2,
                                            resultout   IN OUT VARCHAR2)
    AS
        vSuppProsRequestPage   VARCHAR2 (1000);
        vSupplierName          VARCHAR2 (240);
        vRequestorName         VARCHAR2 (100);
        vRequestorUserName     VARCHAR2 (100);
        vSupplierMailId        VARCHAR2 (2000);
        vApproveBody           VARCHAR2 (4000);
        vRejectBody            VARCHAR2 (4000);
        vRequestNumber         NUMBER;
        vRoleCount             NUMBER;
        vDisqualifyNote        VARCHAR2 (4000);
        vNoteToSupplier        VARCHAR2 (4000);
        vDisqualifyNote1       VARCHAR2 (4000);
        vDisqualifyNoteReq     VARCHAR2 (4000);
    BEGIN
        BEGIN
            SELECT REGI_REQUEST_NUMBER
              INTO vRequestNumber
              FROM LOTC_SUPP_DATA_MANAGEMENT
             WHERE DISQUALIFY_KEY = itemkey AND ITEM_TYPE = 'LSUONBDR';


            SELECT SUPPLIER_NAME, REQUESTOR_NAME, CONTACT_PERSON_MAIL_ID
              INTO vSupplierName, vRequestorName, vSupplierMailId
              FROM LOTC_SUPP_ONBOARD_REQUEST
             WHERE REGI_REQUEST_NUMBER = vRequestNumber;

            SELECT USER_NAME
              INTO vRequestorUserName
              FROM PER_ALL_PEOPLE_F PAPF, FND_USER FNDU
             WHERE     1 = 1
                   AND PAPF.PERSON_ID = FNDU.EMPLOYEE_ID
                   AND PAPF.FULL_NAME = vRequestorName
                   AND ROWNUM = 1;


            Wf_Engine.SetItemAttrText (itemtype,
                                       itemkey,
                                       'SUPPLIER_NAME',
                                       vSupplierName);

            Wf_Engine.SetItemAttrText (itemtype,
                                       itemkey,
                                       'REQUESTER_NAME',
                                       vRequestorUserName);

            SELECT COUNT (1)
              INTO vRoleCount
              FROM apps.wf_roles
             WHERE NAME = vSupplierMailId;

            IF vRoleCount = 0
            THEN
                wf_directory.createadhocrole (
                    role_name                 => vSupplierMailId,
                    role_display_name         => vSupplierMailId,
                    role_description          => vSupplierName,
                    notification_preference   => 'MAILHTML',
                    email_address             => vSupplierMailId,
                    status                    => 'ACTIVE',
                    expiration_date           => NULL);
            END IF;

            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => '#FROM_ROLE',
                                       avalue     => vSupplierMailId);
            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => '#WFM_FROM',
                                       avalue     => vSupplierMailId);
            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => '#WFM_REPLYTO',
                                       avalue     => vSupplierMailId);



            UPDATE LOTC_SUPP_ONBOARD_REQUEST
               SET REGISTRATION_STATUS = 'Disqualified, Closed'
             WHERE REGI_REQUEST_NUMBER = vRequestNumber;


            BEGIN
                SELECT NOTE_TO_SUPPLIER
                  INTO vNoteToSupplier
                  FROM LOTC_SUPP_DATA_MANAGEMENT
                 WHERE REGI_REQUEST_NUMBER = vRequestNumber;
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;


            BEGIN
                SELECT DISQUALIFY_NOTE
                  INTO vDisqualifyNote1
                  FROM LOTC_SUPP_DATA_MANAGEMENT
                 WHERE REGI_REQUEST_NUMBER = vRequestNumber;
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;



            vDisqualifyNote :=
                   'Dear Supplier,

We regret to inform you that your company was not approved as a Logitech supplier per comment below.

Comment:  '
                || vNoteToSupplier
                || '

If you have questions or concerns, please contact:  Global_Procurement_Team@logitech.com

Thank you,
Global Procurement Department';


            vDisqualifyNoteReq :=
                   'Dear Requestor,'
                || vSupplierName
                || ' registration request has been Disqualified  per comment below

Comments : '
                || vDisqualifyNote1
                || '

If you have questions or concerns, please contact: Global_Procurement_Team@logitech.com

Thank you,
Global Procurement Department';

            wf_engine.setitemattrtext (
                itemtype   => itemtype,
                itemkey    => itemkey,
                aname      => 'LOGI_SOB_DISQUALIFY_NOTE',
                avalue     => vDisqualifyNote);


            wf_engine.setitemattrtext (
                itemtype   => itemtype,
                itemkey    => itemkey,
                aname      => 'REQUESTOR_NOTIFY_NOTIFICATION',
                avalue     => vDisqualifyNoteReq);

            resultout := 'COMPLETE:' || 'Y';
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.Data_Man_Disqualify_Supplier',
                       'vSupplierName,vRequestorName,vSupplierMailId  --> '
                    || SQLERRM);
                resultout := 'COMPLETE:' || 'N';
        END;
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (
                itemkey,
                'LOGI_SUPP_ONBRD_PKG.Data_Man_Disqualify_Supplier',
                'Outter Most exception  --> ' || SQLERRM);
    END DATA_MAN_DISQUALIFY_SUPPLIER;



    PROCEDURE DATA_MANAGEMENT_ACCESS (P_REG_REQ_NUMBER   IN     VARCHAR2,
                                      P_USER_NAME        IN     VARCHAR2,
                                      P_STATUS              OUT VARCHAR2)
    AS
        DMUser         VARCHAR2 (30) := NULL;
        ItemType       VARCHAR2 (30);
        ItemKey        VARCHAR2 (30);
        DMActiveUser   NUMBER := 0;
    BEGIN
        WRITE_CUST_LOG (
            itemkey,
            'DATA_MANAGEMENT_ACCESS',
               'P_REG_REQ_NUMBER '
            || P_REG_REQ_NUMBER
            || '   P_USER_NAME  '
            || P_USER_NAME);

        BEGIN
            SELECT DISTINCT lkp1.KEY4
              INTO DMUser
              FROM lfnd_lookups lkp1
             WHERE     lkp1.LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_TEAM_MEMBERS'
                   AND lkp1.KEY4 = P_USER_NAME;
        EXCEPTION
            WHEN OTHERS
            THEN
                DMUser := NULL;
        END;

        BEGIN
            SELECT ITEM_TYPE, ITEM_KEY
              INTO ItemType, ItemKey
              FROM LOTC_PROSPECTIVE_SUPPLIER_REG
             WHERE REGI_REQUEST_NUMBER = P_REG_REQ_NUMBER;

            SELECT COUNT (1)
              INTO DMActiveUser
              FROM WF_NOTIFICATIONS
             WHERE     MESSAGE_TYPE = ItemType
                   AND ITEM_KEY = ItemKey
                   AND STATUS = 'OPEN'
                   AND RECIPIENT_ROLE = DMUser;
        EXCEPTION
            WHEN OTHERS
            THEN
                DMActiveUser := 0;
        END;

        IF DMUser IS NOT NULL AND DMActiveUser != 0
        THEN
            P_STATUS := 'Y';
        ELSE
            P_STATUS := 'N';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            P_STATUS := 'N';
    END DATA_MANAGEMENT_ACCESS;

    --------------------------------------------------------Work flow Logics Started ------------------------------------------

    PROCEDURE START_WF (pItemKey VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        vItemType            VARCHAR2 (30) := 'LSUONBDR';
        vProcess             VARCHAR2 (50) := 'LOGI_SUPP_ONBDR_APP_PROCESS';
        vForm                VARCHAR2 (50);
        vsqlerrm             VARCHAR2 (110);
        vDocumment           CLOB;
        vPrimaryKey          NUMBER;
        vRequestNumber       NUMBER;
        vRequestorName       VARCHAR2 (240);
        vRequestorMailId     VARCHAR2 (240);
        vRequestorUserName   VARCHAR2 (240);
        vRoleCount           NUMBER;
    BEGIN
        Wf_Engine.createProcess (ItemType   => vItemType,
                                 ItemKey    => pItemKey,
                                 process    => vProcess);

        BEGIN
            SELECT REGI_REQUEST_ID, REGI_REQUEST_NUMBER, REQUESTOR_NAME
              INTO vPrimaryKey, vRequestNumber, vRequestorName
              FROM LOTC_SUPP_ONBOARD_REQUEST
             WHERE ITEM_TYPE = vItemType AND ITEM_KEY = pItemKey;

            Wf_Engine.setitemattrdocument (
                vItemType,
                pItemKey,
                'EXCEL_ATTACHEMENT',
                   'FND:entity=LOTC_SUPPONBORD&pk1name=LOTC_SUPPONBORD&pk1value='
                || vPrimaryKey);
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    pItemKey,
                    'LOGI_SUPP_ONBRD_PKG.DERIVE_APPROVERS',
                    'vPrimaryKey derivation issue -->' || SQLERRM);
        END;

        Wf_Engine.SetItemAttrText (vItemType,
                                   pItemKey,
                                   'REQUEST_NUMBER',
                                   vRequestNumber);

        Wf_Engine.StartProcess (itemType => vItemType, itemKey => pItemKey);
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            vsqlerrm := SUBSTR (SQLERRM, 1, 100);
            COMMIT;
    END START_WF;

    PROCEDURE DERIVE_APPROVERS (itemtype   IN            VARCHAR2,
                                itemkey    IN            VARCHAR2,
                                actid      IN            NUMBER,
                                funcmode   IN            VARCHAR2,
                                result        OUT NOCOPY VARCHAR2)
    AS
        l_next_approver                  AME_UTIL.approverRecord;
        l_request_number                 NUMBER;
        l_transaction_type               VARCHAR2 (30) := 'LOGI_SUPP_ONBRD_REG';
        l_application_Id                 NUMBER := 60007;
        l_approver_id                    NUMBER (15) := NULL;
        l_approver_name                  VARCHAR2 (150);
        l_approver_name_display          VARCHAR2 (150);
        l_callingProgram                 VARCHAR2 (150)
                                             := 'LogiSupplieronBoardingApproval';
        l_nextapproversout               ame_util.approverstable2;
        l_itemindexesout                 ame_util.idlist;
        l_itemclassesout                 ame_util.stringlist;
        l_itemidsout                     ame_util.stringlist;
        l_itemsourcesout                 ame_util.longstringlist;
        l_approvalprocesscompleteynout   VARCHAR2 (100);
        l_approver_count                 NUMBER;
        l_transaction_id                 NUMBER;
        vRequestorMailId                 VARCHAR2 (240);
        vRequestorName                   VARCHAR2 (240);
        vRequestorUserName               VARCHAR2 (240);
        vRequestorUserName1              VARCHAR2 (240);
        vRoleCount                       NUMBER;
        l_Approver1                      VARCHAR2 (100);
        l_Approver2                      VARCHAR2 (100);
        l_Approver3                      VARCHAR2 (100);
        l_Approver4                      VARCHAR2 (100);
        l_Approver5                      VARCHAR2 (100);
        l_Approver6                      VARCHAR2 (100);
        l_Approver7                      VARCHAR2 (100);
        l_Approver8                      VARCHAR2 (100);
        l_Approver9                      VARCHAR2 (100);
        l_Approver10                     VARCHAR2 (100);
        l_ExpirationDate                 DATE := SYSDATE + 1000;
        l_AdHocRoleName                  VARCHAR2 (500);
        l_AdHocRoleDesc                  VARCHAR2 (500);
        l_customer_name                  VARCHAR2 (240);
    BEGIN
        l_approver_count :=
            wf_engine.GetItemAttrNumber (itemtype   => itemtype,
                                         itemkey    => itemkey,
                                         aname      => 'LOGI_APPROVER_COUNT');

        IF l_approver_count <> 0
        THEN
            result := 'COMPLETE:' || 'Y';
            GOTO skip_logic;
        END IF;

        BEGIN
            SELECT REGI_REQUEST_NUMBER, REQUESTOR_NAME
              INTO l_request_number, vRequestorName
              FROM LOTC.LOTC_SUPP_ONBOARD_REQUEST
             WHERE 1 = 1 AND ITEM_KEY = itemkey AND ITEM_TYPE = itemtype;
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.DERIVE_APPROVERS',
                    'REGI_REQUEST_NUMBER derivation issue -->' || SQLERRM);
        END;


        SELECT PAPF.FULL_NAME, FNDU.USER_NAME,                       --rvemula
                                               PAPF.EMAIL_ADDRESS
          INTO vRequestorUserName, vRequestorUserName1, vRequestorMailId
          FROM PER_ALL_PEOPLE_F PAPF, FND_USER FNDU
         WHERE     1 = 1
               AND PAPF.PERSON_ID = FNDU.EMPLOYEE_ID
               AND PAPF.FULL_NAME = vRequestorName
               AND ROWNUM = 1;

        SELECT COUNT (1)
          INTO vRoleCount
          FROM apps.wf_roles
         WHERE NAME = vRequestorMailId;

        IF vRoleCount = 0
        THEN
            wf_directory.createadhocrole (
                role_name                 => vRequestorMailId,
                role_display_name         => vRequestorUserName,
                role_description          => vRequestorUserName,
                notification_preference   => 'MAILHTML',
                email_address             => vRequestorMailId,
                status                    => 'ACTIVE',
                expiration_date           => NULL);
        END IF;

        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#FROM_ROLE',
                                   avalue     => vRequestorUserName1); --vRequestorUserName);--vRequestorMailId);  --rvemula
        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#WFM_FROM',
                                   avalue     => vRequestorUserName); --vRequestorMailId);--vRequestorUserName);   --rvemula
        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#WFM_REPLYTO',
                                   avalue     => vRequestorMailId);



        Ame_Api2.getnextapprovers1 (
            applicationidin                => l_application_Id,
            transactiontypein              => l_transaction_type,
            transactionidin                => itemkey,
            flagapproversasnotifiedin      => ame_util.booleantrue,
            approvalprocesscompleteynout   => l_approvalprocesscompleteynout,
            nextapproversout               => l_nextapproversout,
            itemindexesout                 => l_itemindexesout,
            itemclassesout                 => l_itemclassesout,
            itemidsout                     => l_itemidsout,
            itemsourcesout                 => l_itemsourcesout);

        FOR i IN l_nextApproversOut.FIRST .. l_nextApproversOut.LAST
        LOOP
            IF i = 1
            THEN
                l_Approver1 := l_nextApproversOut (i).name;
                l_AdHocRoleDesc := l_Approver1;
                wf_engine.setitemattrtext (itemtype   => itemtype,
                                           itemkey    => itemkey,
                                           aname      => 'LOGI_APPROVER_NAME',
                                           avalue     => l_Approver1);
            ELSIF i = 2
            THEN
                l_Approver2 := l_nextApproversOut (i).name;
                l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver2;
            ELSIF i = 3
            THEN
                l_Approver3 := l_nextApproversOut (i).name;
                l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver3;
            ELSIF i = 4
            THEN
                l_Approver4 := l_nextApproversOut (i).name;
                l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver4;
            ELSIF i = 5
            THEN
                l_Approver5 := l_nextApproversOut (i).name;
                l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver5;
            ELSIF i = 6
            THEN
                l_Approver6 := l_nextApproversOut (i).name;
                l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver6;
            ELSIF i = 7
            THEN
                l_Approver7 := l_nextApproversOut (i).name;
                l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver7;
            ELSIF i = 8
            THEN
                l_Approver8 := l_nextApproversOut (i).name;
                l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver8;
            ELSIF i = 9
            THEN
                l_Approver9 := l_nextApproversOut (i).name;
                l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver9;
            ELSE
                l_Approver10 := l_nextApproversOut (i).name;
                l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver10;
            END IF;
        END LOOP;

        l_AdHocRoleName := 'LOGI_SUPP_ONBDR_REG_ROLE_' || itemkey;

        IF l_Approver1 IS NOT NULL
        THEN
            WF_DIRECTORY.CreateAdHocRole (l_AdHocRoleName,
                                          l_AdHocRoleDesc,
                                          NULL,
                                          NULL,
                                          NULL,
                                          'MAILHTML',
                                          NULL,
                                          NULL,
                                          NULL,
                                          'ACTIVE',
                                          l_ExpirationDate);

            Wf_Engine.SetItemAttrText (itemtype,
                                       ItemKey,
                                       'CATEGORY_MGR_ROLE',
                                       l_AdHocRoleName);

            WRITE_CUST_LOG (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.DERIVE_APPROVERS',
                            'l_AdHocRoleName  --> ' || l_AdHocRoleName);


            IF l_Approver1 IS NOT NULL
            THEN
                WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                  l_Approver1);
                WRITE_CUST_LOG (itemkey,
                                'LOGI_SUPP_ONBRD_PKG.DERIVE_APPROVERS',
                                'l_Approver1  --> ' || l_Approver1);
            END IF;

            IF l_Approver2 IS NOT NULL
            THEN
                WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                  l_Approver2);
                WRITE_CUST_LOG (itemkey,
                                'LOGI_SUPP_ONBRD_PKG.DERIVE_APPROVERS',
                                'l_Approver2  --> ' || l_Approver2);
            END IF;

            IF l_Approver3 IS NOT NULL
            THEN
                WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                  l_Approver3);
                WRITE_CUST_LOG (itemkey,
                                'LOGI_SUPP_ONBRD_PKG.DERIVE_APPROVERS',
                                'l_Approver3  --> ' || l_Approver3);
            END IF;

            IF l_Approver4 IS NOT NULL
            THEN
                WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                  l_Approver4);
            END IF;

            IF l_Approver5 IS NOT NULL
            THEN
                WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                  l_Approver5);
            END IF;

            IF l_Approver6 IS NOT NULL
            THEN
                WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                  l_Approver6);
            END IF;

            IF l_Approver7 IS NOT NULL
            THEN
                WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                  l_Approver7);
            END IF;

            IF l_Approver8 IS NOT NULL
            THEN
                WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                  l_Approver8);
            END IF;

            IF l_Approver9 IS NOT NULL
            THEN
                WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                  l_Approver9);
            END IF;

            IF l_Approver10 IS NOT NULL
            THEN
                WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                  l_Approver10);
            END IF;


            WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype,
                                         itemkey    => itemkey,
                                         aname      => 'REQUEST_NUMBER',
                                         avalue     => l_request_number);

            result := 'COMPLETE:' || 'Y';
        ELSE
            result := 'COMPLETE:' || 'N';
        END IF;

       <<skip_logic>>
        NULL;
    EXCEPTION
        WHEN OTHERS
        THEN
            result := 'COMPLETE:' || 'N';
            WRITE_CUST_LOG (
                itemkey,
                'LOGI_SUPP_ONBRD_PKG.DERIVE_APPROVERS',
                'DERIVE_APPROVERS outter most exception  --> ' || SQLERRM);
            WF_CORE.Context (
                l_transaction_type,
                l_callingProgram,
                itemtype,
                itemkey,
                TO_CHAR (actid),
                   'Error in LOGI_SUPP_ONBRD_PKG.DERIVE_APPROVERS -->'
                || SQLERRM);
    END DERIVE_APPROVERS;

    PROCEDURE POPULATE_WF_ATTR (itemtype    IN     VARCHAR2,
                                itemkey     IN     VARCHAR2,
                                actid       IN     NUMBER,
                                funcmode    IN     VARCHAR2,
                                resultout   IN OUT VARCHAR2)
    IS
        vSupplierName           VARCHAR2 (240);
        vRequestorName          VARCHAR2 (100);
        vRequestorUserName      VARCHAR2 (100);
        vRequestorMailId        VARCHAR2 (100);
        vSupplierMailId         VARCHAR2 (2000);
        vApproveBody            VARCHAR2 (4000);
        vRejectBody             VARCHAR2 (4000);
        vRequestNumber          NUMBER;
        vSuppOnbdrSearchPage    VARCHAR2 (1000);
        vSuppOnbdrRequestPage   VARCHAR2 (1000);
        vSuppProsRequestPage    VARCHAR2 (1000);
        vRoleCount              NUMBER;
        vFromAddress            VARCHAR2 (240);
        vApproverCount          NUMBER;
    BEGIN
        vApproverCount :=
            wf_engine.GetItemAttrNumber (itemtype   => itemtype,
                                         itemkey    => itemkey,
                                         aname      => 'LOGI_APPROVER_COUNT');

        IF vApproverCount <> 0
        THEN
            resultout := 'Success';
            GOTO skip_logic;
        END IF;

        BEGIN
            SELECT SUPPLIER_NAME,
                   REQUESTOR_NAME,
                   CONTACT_PERSON_MAIL_ID,
                   REGI_REQUEST_NUMBER
              INTO vSupplierName,
                   vRequestorName,
                   vSupplierMailId,
                   vRequestNumber
              FROM LOTC_SUPP_ONBOARD_REQUEST
             WHERE ITEM_TYPE = itemtype AND ITEM_KEY = itemkey;

            SELECT FNDU.USER_NAME, PAPF.EMAIL_ADDRESS
              INTO vRequestorUserName, vRequestorMailId
              FROM PER_ALL_PEOPLE_F PAPF, FND_USER FNDU
             WHERE     1 = 1
                   AND PAPF.PERSON_ID = FNDU.EMPLOYEE_ID
                   AND PAPF.FULL_NAME = vRequestorName
                   AND ROWNUM = 1;

            Wf_Engine.SetItemAttrText (itemtype,
                                       itemkey,
                                       'SUPPLIER_NAME',
                                       vSupplierName);

            Wf_Engine.SetItemAttrText (itemtype,
                                       itemkey,
                                       'REQUESTER_NAME',
                                       vRequestorUserName);

            SELECT COUNT (1)
              INTO vRoleCount
              FROM apps.wf_roles
             WHERE NAME = vRequestorMailId;

            IF vRoleCount = 0
            THEN
                wf_directory.createadhocrole (
                    role_name                 => vRequestorMailId,
                    role_display_name         => vRequestorUserName,
                    role_description          => vRequestorUserName,
                    notification_preference   => 'MAILHTML',
                    email_address             => vRequestorMailId,
                    status                    => 'ACTIVE',
                    expiration_date           => NULL);
            END IF;

            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'REQUESTER_ROLE',
                                       avalue     => vRequestorMailId);

            vSuppOnbdrSearchPage :=
                FND_RUN_FUNCTION.get_run_function_url (
                    p_function_id =>
                        fnd_function.get_function_id (
                            'LOGI_SUPP_ONBRD_SEARCH'),
                    p_resp_appl_id =>
                        NULL,
                    p_resp_id =>
                        NULL,
                    p_security_group_id =>
                        0,
                    p_parameters =>
                        NULL,
                    p_override_agent =>
                        NULL,
                    p_org_id =>
                        NULL,
                    p_lang_code =>
                        NULL,
                    p_encryptParameters =>
                        TRUE);
            /*  01-NOv-18 vSuppOnbdrSearchPage :=
                 REPLACE (vSuppOnbdrSearchPage,
                          pos_url_pkg.get_internal_url,
                          pos_url_pkg.get_external_url); */
            vSuppOnbdrSearchPage :=
                REPLACE (vSuppOnbdrSearchPage,
                         fnd_profile.VALUE ('APPS_SERVLET_AGENT') || '/',
                         pos_url_pkg.get_external_url || 'OA_HTML/');
            wf_engine.setitemattrtext (
                itemtype   => itemtype,
                itemkey    => itemkey,
                aname      => 'LOGI_SUPP_ONBDR_SEARCH_PAGE',
                avalue     => vSuppOnbdrSearchPage);


            vSuppOnbdrRequestPage :=
                FND_RUN_FUNCTION.get_run_function_url (
                    p_function_id =>
                        fnd_function.get_function_id (
                            'LOGI_SUPP_ONBRD_REQUEST'),
                    p_resp_appl_id =>
                        NULL,
                    p_resp_id =>
                        NULL,
                    p_security_group_id =>
                        0,
                    p_parameters =>
                           'RequestNumber1='
                        || vRequestNumber
                        || '&'
                        || 'mode=UPDATE',
                    p_override_agent =>
                        NULL,
                    p_org_id =>
                        NULL,
                    p_lang_code =>
                        NULL,
                    p_encryptParameters =>
                        TRUE);
            /* 01-NOv-18 vSuppOnbdrRequestPage :=
                  REPLACE (vSuppOnbdrRequestPage,
                           pos_url_pkg.get_internal_url,
                           pos_url_pkg.get_external_url); */

            vSuppOnbdrRequestPage :=
                REPLACE (vSuppOnbdrRequestPage,
                         fnd_profile.VALUE ('APPS_SERVLET_AGENT') || '/',
                         pos_url_pkg.get_external_url || 'OA_HTML/');
            wf_engine.setitemattrtext (
                itemtype   => itemtype,
                itemkey    => itemkey,
                aname      => 'LOGI_SUPP_ONBDR_REGI_PAGE',
                avalue     => vSuppOnbdrRequestPage);


            vSuppProsRequestPage :=
                FND_RUN_FUNCTION.get_run_function_url (
                    p_function_id =>
                        fnd_function.get_function_id ('LOGI_SUPP_ONBRD_PROS'),
                    p_resp_appl_id =>
                        NULL,
                    p_resp_id =>
                        NULL,
                    p_security_group_id =>
                        0,
                    p_parameters =>
                           'RequestNumber1='
                        || vRequestNumber
                        || '&'
                        || 'NotifyMode=Yes',
                    p_override_agent =>
                        NULL,
                    p_org_id =>
                        NULL,
                    p_lang_code =>
                        NULL,
                    p_encryptParameters =>
                        TRUE);
            /* 01-NOv-18 vSuppProsRequestPage :=
                 REPLACE (vSuppProsRequestPage,
                          pos_url_pkg.get_internal_url,
                          pos_url_pkg.get_external_url); */

            vSuppProsRequestPage :=
                REPLACE (vSuppProsRequestPage,
                         fnd_profile.VALUE ('APPS_SERVLET_AGENT') || '/',
                         pos_url_pkg.get_external_url || 'OA_HTML/');
            wf_engine.setitemattrtext (
                itemtype   => itemtype,
                itemkey    => itemkey,
                aname      => 'LOGI_SUPP_ONBDR_PROS_PAGE',
                avalue     => vSuppProsRequestPage);


            SELECT COUNT (1)
              INTO vRoleCount
              FROM apps.wf_roles
             WHERE NAME = vSupplierMailId;

            IF vRoleCount = 0
            THEN
                wf_directory.createadhocrole (
                    role_name                 => vSupplierMailId,
                    role_display_name         => vSupplierName,
                    role_description          => vSupplierName,
                    notification_preference   => 'MAILHTML',
                    email_address             => vSupplierMailId,
                    status                    => 'ACTIVE',
                    expiration_date           => NULL);
            END IF;

            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'SUPPLIER_ROLE',
                                       avalue     => vSupplierMailId);
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.POPULATE_WF_ATTR',
                       'vSupplierName,vRequestorName,vSupplierMailId  --> '
                    || SQLERRM);
        END;

       <<skip_logic>>
        NULL;
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.POPULATE_WF_ATTR',
                            'outter most exception  --> ' || SQLERRM);
    END POPULATE_WF_ATTR;


    PROCEDURE REJECT_FROM_ADDRESS (itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   resultout   IN OUT VARCHAR2)
    AS
        l_transaction_type               VARCHAR2 (30) := 'LOGI_SUPP_ONBRD_REG';
        l_application_Id                 NUMBER := 60007;
        l_approver_id                    NUMBER (15) := NULL;
        l_approver_name                  VARCHAR2 (150);
        l_approver_name_display          VARCHAR2 (150);
        l_nextapproversout               ame_util.approverstable2;
        l_itemindexesout                 ame_util.idlist;
        l_itemclassesout                 ame_util.stringlist;
        l_itemidsout                     ame_util.stringlist;
        l_itemsourcesout                 ame_util.longstringlist;
        l_approvalprocesscompleteynout   VARCHAR2 (100);
        l_approver_count                 NUMBER;
        vFromAddress                     VARCHAR2 (100);
        l_Responder                      VARCHAR2 (100);
        l_Responder_Name                 VARCHAR2 (100);
        l_Responder_Mailid               VARCHAR2 (100);
        vRoleCount                       NUMBER;
        l_App_user_name                  VARCHAR2 (100);
        vCommands                        VARCHAR2 (4000);
    BEGIN
        BEGIN
            l_Responder := NULL;

            SELECT wn.TO_USER,
                   (SELECT PAPF.FULL_NAME
                      FROM PER_ALL_PEOPLE_F PAPF, FND_USER FNDU
                     WHERE     1 = 1
                           AND PAPF.PERSON_ID = FNDU.EMPLOYEE_ID
                           AND (   FNDU.USER_NAME = wn.TO_USER
                                OR PAPF.FULL_NAME = wn.TO_USER)
                           AND ROWNUM = 1),
                   (SELECT PAPF.EMAIL_ADDRESS
                      FROM PER_ALL_PEOPLE_F PAPF, FND_USER FNDU
                     WHERE     1 = 1
                           AND PAPF.PERSON_ID = FNDU.EMPLOYEE_ID
                           AND (   FNDU.USER_NAME = wn.TO_USER
                                OR PAPF.FULL_NAME = wn.TO_USER)
                           AND ROWNUM = 1)
              INTO l_Responder, l_Responder_Name, l_Responder_Mailid
              FROM wf_notifications wn
             WHERE     1 = 1
                   AND NOTIFICATION_ID =
                       (SELECT MAX (NOTIFICATION_ID)
                          FROM wf_notifications
                         WHERE     1 = 1
                               AND MESSAGE_TYPE = itemtype
                               AND item_key = itemkey
                               AND RESPONDER IS NOT NULL
                               AND STATUS = 'CLOSED');
        EXCEPTION
            WHEN OTHERS
            THEN
                l_Responder := NULL;
        END;

        WRITE_CUST_LOG (
            itemkey,
            'L_RESPONDER',
               l_Responder
            || '  $  '
            || l_Responder_Name
            || '  $  '
            || l_Responder_Mailid);

        SELECT COUNT (1)
          INTO vRoleCount
          FROM apps.wf_roles
         WHERE NAME = l_Responder_Mailid;

        IF vRoleCount = 0
        THEN
            wf_directory.createadhocrole (
                role_name                 => l_Responder_Mailid,
                role_display_name         => l_Responder_Name,
                role_description          => l_Responder_Name,
                notification_preference   => 'MAILHTML',
                email_address             => l_Responder_Mailid,
                status                    => 'ACTIVE',
                expiration_date           => NULL);
        END IF;

        WRITE_CUST_LOG (itemkey,
                        '2',
                        'l_Responder_Mailid -->' || l_Responder_Mailid);

        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#FROM_ROLE',
                                   avalue     => l_Responder_Mailid);

        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#WFM_FROM',
                                   avalue     => l_Responder_Name);

        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#WFM_REPLYTO',
                                   avalue     => l_Responder_Mailid);

        BEGIN
            ame_api2.updateApprovalStatus2 (
                applicationIdIn     => l_application_Id,
                transactionIdIn     => itemkey,
                approvalStatusIn    => ame_util.rejectStatus,
                approverNameIn      => l_Responder,
                transactionTypeIn   => l_transaction_type);
        EXCEPTION
            WHEN OTHERS
            THEN
                BEGIN
                    SELECT USER_NAME
                      INTO l_Responder
                      FROM WF_USER_ROLES
                     WHERE     role_name =
                               'LOGI_SUPP_ONBDR_REG_ROLE_' || itemkey
                           AND ROWNUM = 1;

                    WRITE_CUST_LOG (
                        itemkey,
                        'REJECT_FROM_ADDRESS',
                           '1 Error in  updating the approver in the list '
                        || SQLERRM
                        || '  and the current responder is  -->'
                        || l_Responder);
                    ame_api2.updateApprovalStatus2 (
                        applicationIdIn     => l_application_Id,
                        transactionIdIn     => itemkey,
                        approvalStatusIn    => ame_util.rejectStatus,
                        approverNameIn      => l_Responder,
                        transactionTypeIn   => l_transaction_type);
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        WRITE_CUST_LOG (
                            itemkey,
                            'REJECT_FROM_ADDRESS',
                               '2 Error in  updating the approver in the list '
                            || SQLERRM
                            || '  and the current responder is  -->'
                            || l_Responder);
                END;
        END;

        UPDATE LOTC_SUPP_ONBOARD_REQUEST
           SET REGISTRATION_STATUS = 'Rejected'
         WHERE ITEM_TYPE = itemtype AND ITEM_KEY = itemkey;

        BEGIN
            /*             SELECT SUBSTR (TEXT_VALUE, 1, 3999)
                          INTO vCommands
                          FROM WF_NOTIFICATION_ATTRIBUTES
                         WHERE     NOTIFICATION_ID =
                                   (SELECT MAX (NOTIFICATION_ID)
                                      FROM WF_NOTIFICATIONS nft
                                     WHERE     1 = 1
                                           AND ITEM_KEY = itemkey
                                           AND MESSAGE_TYPE = 'LSUONBDR')
                               AND Name = 'PRN_COMMENTS'; */

            vCommands := ' ';

            FOR i
                IN (SELECT SUBSTR (TEXT_VALUE, 1, 3999) TEXT_VALUE
                      FROM WF_NOTIFICATION_ATTRIBUTES
                     WHERE     NOTIFICATION_ID IN
                                   (SELECT NOTIFICATION_ID
                                      FROM WF_NOTIFICATIONS nft
                                     WHERE     1 = 1
                                           AND GROUP_ID =
                                               (SELECT MAX (GROUP_ID)
                                                  FROM WF_NOTIFICATIONS nft
                                                 WHERE     1 = 1
                                                       AND ITEM_KEY = itemkey
                                                       AND MESSAGE_TYPE =
                                                           'LSUONBDR'))
                           AND Name = 'PRN_COMMENTS')
            LOOP
                vCommands := vCommands || '' || i.TEXT_VALUE;
            END LOOP;

            WF_ENGINE.SetItemAttrText (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'REJECT_COMMAND',
                                       avalue     => vCommands);
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    itemkey,
                    'REJECT_FROM_ADDRESS',
                    'Error in vCommands Derivation  --> ' || SQLERRM);
        END;

        resultout := 'Success';
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (itemkey,
                            'REJECT_FROM_ADDRESS',
                            'Error @REJECT_FROM_ADDRESS -->' || SQLERRM);
            resultout := 'Success';
    END REJECT_FROM_ADDRESS;


    PROCEDURE APPROVE_NOTIFICATION (itemtype    IN     VARCHAR2,
                                    itemkey     IN     VARCHAR2,
                                    actid       IN     NUMBER,
                                    funcmode    IN     VARCHAR2,
                                    resultout   IN OUT VARCHAR2)
    AS
        l_transaction_type               VARCHAR2 (30) := 'LOGI_SUPP_ONBRD_REG';
        l_application_Id                 NUMBER := 60007;
        l_approver_id                    NUMBER (15) := NULL;
        l_approver_name                  VARCHAR2 (150);
        l_approver_name_display          VARCHAR2 (150);
        l_nextapproversout               ame_util.approverstable2;
        l_itemindexesout                 ame_util.idlist;
        l_itemclassesout                 ame_util.stringlist;
        l_itemidsout                     ame_util.stringlist;
        l_itemsourcesout                 ame_util.longstringlist;
        l_approvalprocesscompleteynout   VARCHAR2 (100);
        l_approver_count                 NUMBER;
        vFromAddress                     VARCHAR2 (100);
        l_Responder                      VARCHAR2 (100);
        l_Responder_Name                 VARCHAR2 (100);
        l_Responder_Mailid               VARCHAR2 (100);
        vRoleCount                       NUMBER;
        l_App_user_name                  VARCHAR2 (100);
        l_Approver1                      VARCHAR2 (100);
        l_Approver2                      VARCHAR2 (100);
        l_Approver3                      VARCHAR2 (100);
        l_Approver4                      VARCHAR2 (100);
        l_Approver5                      VARCHAR2 (100);
        l_Approver6                      VARCHAR2 (100);
        l_Approver7                      VARCHAR2 (100);
        l_Approver8                      VARCHAR2 (100);
        l_Approver9                      VARCHAR2 (100);
        l_Approver10                     VARCHAR2 (100);
        l_ExpirationDate                 DATE := SYSDATE + 1000;
        l_AdHocRoleName                  VARCHAR2 (500);
        l_AdHocRoleDesc                  VARCHAR2 (500);
    BEGIN
        BEGIN
            l_Responder := NULL;

            SELECT wn.TO_USER,
                   (SELECT PAPF.FULL_NAME
                      FROM PER_ALL_PEOPLE_F PAPF, FND_USER FNDU
                     WHERE     1 = 1
                           AND PAPF.PERSON_ID = FNDU.EMPLOYEE_ID
                           AND (   FNDU.USER_NAME = wn.TO_USER
                                OR PAPF.FULL_NAME = wn.TO_USER)
                           AND ROWNUM = 1),
                   (SELECT PAPF.EMAIL_ADDRESS
                      FROM PER_ALL_PEOPLE_F PAPF, FND_USER FNDU
                     WHERE     1 = 1
                           AND PAPF.PERSON_ID = FNDU.EMPLOYEE_ID
                           AND (   FNDU.USER_NAME = wn.TO_USER
                                OR PAPF.FULL_NAME = wn.TO_USER)
                           AND ROWNUM = 1)
              INTO l_Responder, l_Responder_Name, l_Responder_Mailid
              FROM wf_notifications wn
             WHERE     1 = 1
                   AND NOTIFICATION_ID =
                       (SELECT MAX (NOTIFICATION_ID)
                          FROM wf_notifications
                         WHERE     1 = 1
                               AND MESSAGE_TYPE = itemtype
                               AND item_key = itemkey
                               AND RESPONDER IS NOT NULL
                               AND STATUS = 'CLOSED');
        EXCEPTION
            WHEN OTHERS
            THEN
                l_Responder := NULL;
        END;

        WRITE_CUST_LOG (
            itemkey,
            'APPROVE_NOTIFICATION',
               'L_RESPONDER'
            || l_Responder
            || '  $  '
            || l_Responder_Name
            || '  $  '
            || l_Responder_Mailid);

        SELECT COUNT (1)
          INTO vRoleCount
          FROM apps.wf_roles
         WHERE NAME = l_Responder_Mailid;

        IF vRoleCount = 0
        THEN
            wf_directory.createadhocrole (
                role_name                 => l_Responder_Mailid,
                role_display_name         => l_Responder_Name,
                role_description          => l_Responder_Name,
                notification_preference   => 'MAILHTML',
                email_address             => l_Responder_Mailid,
                status                    => 'ACTIVE',
                expiration_date           => NULL);
        END IF;

        WRITE_CUST_LOG (itemkey,
                        'APPROVE_NOTIFICATION',
                        'l_Responder_Mailid -->' || l_Responder_Mailid);

        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#FROM_ROLE',
                                   avalue     => l_Responder_Mailid);

        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#WFM_FROM',
                                   avalue     => l_Responder_Name);

        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#WFM_REPLYTO',
                                   avalue     => l_Responder_Mailid);

        BEGIN
            l_App_user_name :=
                wf_engine.GetItemAttrText (itemtype   => itemtype,
                                           itemkey    => itemkey,
                                           aname      => 'LOGI_APPROVER_NAME');

            WRITE_CUST_LOG (itemkey,
                            'APPROVE_NOTIFICATION',
                            'l_App_user_name  -->' || l_App_user_name);

            IF l_Responder != l_App_user_name
            THEN
                ame_api2.updateApprovalStatus2 (
                    applicationIdIn     => l_application_Id,
                    transactionIdIn     => itemkey,
                    approvalStatusIn    => ame_util.approvedStatus,
                    approverNameIn      => l_App_user_name,
                    transactionTypeIn   => l_transaction_type);
            ELSE
                ame_api2.updateApprovalStatus2 (
                    applicationIdIn     => l_application_Id,
                    transactionIdIn     => itemkey,
                    approvalStatusIn    => ame_util.approvedStatus,
                    approverNameIn      => l_Responder,
                    transactionTypeIn   => l_transaction_type);
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    itemkey,
                    'APPROVE_NOTIFICATION',
                    'Entered into when others exception' || SQLERRM);
        END;

        COMMIT;

        BEGIN
            Ame_Api2.getnextapprovers1 (applicationidin =>
                                            l_application_Id,
                                        transactiontypein =>
                                            l_transaction_type,
                                        transactionidin =>
                                            itemkey,
                                        flagapproversasnotifiedin =>
                                            ame_util.booleantrue,
                                        approvalprocesscompleteynout =>
                                            l_approvalprocesscompleteynout,
                                        nextapproversout =>
                                            l_nextapproversout,
                                        itemindexesout =>
                                            l_itemindexesout,
                                        itemclassesout =>
                                            l_itemclassesout,
                                        itemidsout =>
                                            l_itemidsout,
                                        itemsourcesout =>
                                            l_itemsourcesout);

            FOR i IN l_nextApproversOut.FIRST .. l_nextApproversOut.LAST
            LOOP
                IF i = 1
                THEN
                    l_Approver1 := l_nextApproversOut (i).name;
                    l_AdHocRoleDesc := l_Approver1;
                    wf_engine.setitemattrtext (
                        itemtype   => itemtype,
                        itemkey    => itemkey,
                        aname      => 'LOGI_APPROVER_NAME',
                        avalue     => l_Approver1);
                ELSIF i = 2
                THEN
                    l_Approver2 := l_nextApproversOut (i).name;
                    l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver2;
                ELSIF i = 3
                THEN
                    l_Approver3 := l_nextApproversOut (i).name;
                    l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver3;
                ELSIF i = 4
                THEN
                    l_Approver4 := l_nextApproversOut (i).name;
                    l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver4;
                ELSIF i = 5
                THEN
                    l_Approver5 := l_nextApproversOut (i).name;
                    l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver5;
                ELSIF i = 6
                THEN
                    l_Approver6 := l_nextApproversOut (i).name;
                    l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver6;
                ELSIF i = 7
                THEN
                    l_Approver7 := l_nextApproversOut (i).name;
                    l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver7;
                ELSIF i = 8
                THEN
                    l_Approver8 := l_nextApproversOut (i).name;
                    l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver8;
                ELSIF i = 9
                THEN
                    l_Approver9 := l_nextApproversOut (i).name;
                    l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver9;
                ELSE
                    l_Approver10 := l_nextApproversOut (i).name;
                    l_AdHocRoleDesc := l_AdHocRoleDesc || ',' || l_Approver10;
                END IF;
            END LOOP;

            l_AdHocRoleName := 'LOGI_SUPP_ONBDR_REG_ROLE_' || itemkey;

            IF l_Approver1 IS NOT NULL
            THEN
                WF_DIRECTORY.CreateAdHocRole (l_AdHocRoleName,
                                              l_AdHocRoleDesc,
                                              NULL,
                                              NULL,
                                              NULL,
                                              'MAILHTML',
                                              NULL,
                                              NULL,
                                              NULL,
                                              'ACTIVE',
                                              l_ExpirationDate);

                Wf_Engine.SetItemAttrText (itemtype,
                                           ItemKey,
                                           'CATEGORY_MGR_ROLE',
                                           l_AdHocRoleName);

                IF l_Approver1 IS NOT NULL
                THEN
                    WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                      l_Approver1);
                END IF;

                IF l_Approver2 IS NOT NULL
                THEN
                    WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                      l_Approver2);
                END IF;

                IF l_Approver3 IS NOT NULL
                THEN
                    WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                      l_Approver3);
                END IF;

                IF l_Approver4 IS NOT NULL
                THEN
                    WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                      l_Approver4);
                END IF;

                IF l_Approver5 IS NOT NULL
                THEN
                    WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                      l_Approver5);
                END IF;

                IF l_Approver6 IS NOT NULL
                THEN
                    WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                      l_Approver6);
                END IF;

                IF l_Approver7 IS NOT NULL
                THEN
                    WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                      l_Approver7);
                END IF;

                IF l_Approver8 IS NOT NULL
                THEN
                    WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                      l_Approver8);
                END IF;

                IF l_Approver9 IS NOT NULL
                THEN
                    WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                      l_Approver9);
                END IF;

                IF l_Approver10 IS NOT NULL
                THEN
                    WF_DIRECTORY.AddUsersToAdHocRole (l_AdHocRoleName,
                                                      l_Approver10);
                END IF;

                resultout := 'COMPLETE:' || 'Y';
            ELSE
                resultout := 'COMPLETE:' || 'N';
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (itemkey,
                                'LOGI_SUPP_ONBRD_PKG.Approve_notification',
                                'Approver found exception  --> ' || SQLERRM);
                resultout := 'COMPLETE:' || 'N';
        END;
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.Approve_notification',
                            'Outter Most exception  --> ' || SQLERRM);
            resultout := 'COMPLETE:' || 'N';
    END APPROVE_NOTIFICATION;

    PROCEDURE NOTIFY_VENDOR (itemtype    IN     VARCHAR2,
                             itemkey     IN     VARCHAR2,
                             actid       IN     NUMBER,
                             funcmode    IN     VARCHAR2,
                             resultout   IN OUT VARCHAR2)
    IS
        vSupplierExist   NUMBER := 0;
    BEGIN
        SELECT COUNT (1)
          INTO vSupplierExist
          FROM LOTC_SUPP_ONBOARD_REQUEST req, LFND_LOOKUPS lkup
         WHERE     1 = 1
               AND req.SUPPLIER_TYPE = lkup.KEY3
               AND lkup.LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_FRM_VALUES'
               AND lkup.KEY2 = 'Supplier Type'
               AND lkup.KEY6 = 'Y'
               AND req.ITEM_TYPE = itemtype
               AND req.ITEM_KEY = itemkey;

        UPDATE LOTC_SUPP_ONBOARD_REQUEST
           SET REGISTRATION_STATUS = 'Supplier to provide details' --'Approved'
         WHERE ITEM_TYPE = itemtype AND ITEM_KEY = itemkey;

        IF vSupplierExist = 1
        THEN
            resultout := 'COMPLETE:' || 'Y';
        ELSE
            resultout := 'COMPLETE:' || 'N';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            resultout := 'COMPLETE:' || 'N';
            WRITE_CUST_LOG (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.VENDOR_TYPE',
                            'outter most exception  --> ' || SQLERRM);
    END NOTIFY_VENDOR;


    PROCEDURE REJECT_NOTIFICATION (itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   resultout   IN OUT VARCHAR2)
    AS
    BEGIN
        UPDATE LOTC_SUPP_ONBOARD_REQUEST
           SET REGISTRATION_STATUS = 'Rejected'
         WHERE ITEM_TYPE = itemtype AND ITEM_KEY = itemkey;
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.Reject_notification',
                            'Outter Most exception  --> ' || SQLERRM);
    END REJECT_NOTIFICATION;



    PROCEDURE START_WF1 (pItemKey VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        vItemType            VARCHAR2 (30) := 'LSUONBDR';
        vProcess             VARCHAR2 (50) := 'LOGI_PROS_SUPPLIER_REGI_REQST';
        vForm                VARCHAR2 (50);
        vsqlerrm             VARCHAR2 (110);
        vDocumment           CLOB;
        vPrimaryKey          NUMBER;
        vRequestNumber       NUMBER;
        vRequestorName       VARCHAR2 (240);
        vRequestorMailId     VARCHAR2 (240);
        vRequestorUserName   VARCHAR2 (240);
        vRoleCount           NUMBER;
        vCheck               NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO vCheck
          FROM LOTC_PROSPECTIVE_SUPPLIER_REG
         WHERE ITEM_KEY = pItemKey;

        IF vCheck = 0
        THEN
            RETURN;
        END IF;

        Wf_Engine.createProcess (ItemType   => vItemType,
                                 ItemKey    => pItemKey,
                                 process    => vProcess);

        BEGIN
            SELECT REGI_REQUEST_ID,
                   REGI_REQUEST_NUMBER,
                   SUBSTR (COMPANY_NAME, 1, 40)
              INTO vPrimaryKey, vRequestNumber, vRequestorName
              FROM LOTC_PROSPECTIVE_SUPPLIER_REG
             WHERE ITEM_TYPE = vItemType AND ITEM_KEY = pItemKey;

            Wf_Engine.setitemattrdocument (
                vItemType,
                pItemKey,
                'EXCEL_ATTACHEMENT',
                   'FND:entity=LOTC_PROSUPREG&pk1name=LOTC_PROSUPREG&pk1value='
                || vPrimaryKey);
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    pItemKey,
                    'START_WF1',
                    'vPrimaryKey derivation issue -->' || SQLERRM);
                WRITE_CUST_LOG (pItemKey,
                                'LOGI_SUPP_ONBRD_PKG.START_WF1',
                                'vItemType -->' || vItemType);
                WRITE_CUST_LOG (pItemKey,
                                'LOGI_SUPP_ONBRD_PKG.START_WF1',
                                'pItemKey -->' || pItemKey);
        END;

        Wf_Engine.SetItemAttrText (vItemType,
                                   pItemKey,
                                   'REQUEST_NUMBER',
                                   vRequestNumber);
        Wf_Engine.SetItemAttrText (vItemType,
                                   pItemKey,
                                   'ITEM_KEY',
                                   pItemKey);
        Wf_Engine.StartProcess (itemType => vItemType, itemKey => pItemKey);


        SELECT FNDU.USER_NAME, PAPF.EMAIL_ADDRESS
          INTO vRequestorUserName, vRequestorMailId
          FROM PER_ALL_PEOPLE_F PAPF, FND_USER FNDU
         WHERE     1 = 1
               AND PAPF.PERSON_ID = FNDU.EMPLOYEE_ID
               AND PAPF.FULL_NAME = vRequestorName
               AND ROWNUM = 1;

        SELECT COUNT (1)
          INTO vRoleCount
          FROM apps.wf_roles
         WHERE NAME = vRequestorMailId;

        IF vRoleCount = 0
        THEN
            wf_directory.createadhocrole (
                role_name                 => vRequestorMailId,
                role_display_name         => vRequestorUserName,
                role_description          => vRequestorUserName,
                notification_preference   => 'MAILHTML',
                email_address             => vRequestorMailId,
                status                    => 'ACTIVE',
                expiration_date           => NULL);
        END IF;

        wf_engine.setitemattrtext (itemtype   => vItemType,
                                   itemkey    => pItemKey,
                                   aname      => 'REQUESTER_ROLE',
                                   avalue     => vRequestorMailId);
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            vsqlerrm := SUBSTR (SQLERRM, 1, 100);
            WRITE_CUST_LOG (pItemKey,
                            'LOGI_SUPP_ONBRD_PKG.START_WF1',
                            'Outter most Error  -->' || SQLERRM);
            COMMIT;
    END START_WF1;

    PROCEDURE DERIVE_APPROVERS1 (itemtype   IN            VARCHAR2,
                                 itemkey    IN            VARCHAR2,
                                 actid      IN            NUMBER,
                                 funcmode   IN            VARCHAR2,
                                 result        OUT NOCOPY VARCHAR2)
    AS
        l_request_number                 NUMBER;
        l_transaction_type               VARCHAR2 (30) := 'LOGI_PROS_SUPP_REG';
        l_application_Id                 NUMBER := 60007;
        l_approver_id                    NUMBER (15) := NULL;
        l_approver_name                  VARCHAR2 (150);
        l_approver_name_display          VARCHAR2 (150);
        l_itemindexesout                 ame_util.idlist;
        l_itemclassesout                 ame_util.stringlist;
        l_itemidsout                     ame_util.stringlist;
        l_itemsourcesout                 ame_util.longstringlist;
        l_approvalprocesscompleteynout   VARCHAR2 (100);
        l_approver_count                 NUMBER;
        l_nextApproversOut               ame_util.approversTable2;
        l_flagApproversAsNotifiedIn      VARCHAR2 (1);
        l_ExpirationDate                 DATE := SYSDATE + 1000;
        l_AdHocRoleName                  VARCHAR2 (500);
        l_AdHocRoleDesc                  VARCHAR2 (500);
        l_customer_name                  VARCHAR2 (240);
        vRequestorName                   VARCHAR2 (240);
        vRequestorUserName               VARCHAR2 (240);
        vRequestorMailId                 VARCHAR2 (2000);
        vRoleCount                       NUMBER;
        l_transaction_id                 VARCHAR2 (30);
        l_next_approver                  ame_util.approverrecord2;
        l_next_approvers                 ame_util.approverstable2;
        l_next_approvers_count           NUMBER;
        l_approver_index                 NUMBER;
        l_is_approval_complete           VARCHAR2 (1);
        l_role_users                     wf_directory.usertable;
        l_role_name                      VARCHAR2 (320) := NULL;
        l_role_display_name              VARCHAR2 (360);
        l_all_approvers                  ame_util.approverstable;

        CURSOR c1 (
            p_user_name    VARCHAR2)
        IS
            SELECT papf.full_name
              FROM fnd_user fu, per_all_people_f papf
             WHERE     fu.employee_id = papf.person_id
                   AND fu.user_name = p_user_name
                   AND SYSDATE BETWEEN papf.EFFECTIVE_START_DATE
                                   AND NVL (papf.EFFECTIVE_end_DATE,
                                            SYSDATE + 1)
                   AND SYSDATE BETWEEN fu.start_date
                                   AND NVL (fu.end_date, SYSDATE + 1);
    BEGIN
        l_approver_count :=
            wf_engine.GetItemAttrNumber (itemtype   => itemtype,
                                         itemkey    => itemkey,
                                         aname      => 'LOGI_APPROVER_COUNT');

        IF l_approver_count <> 0
        THEN
            result := 'COMPLETE:' || 'Y';
            GOTO skip_logic;
        END IF;

        BEGIN
            SELECT REGI_REQUEST_NUMBER, COMPANY_NAME, CONTACT_EMAIL
              INTO l_request_number, vRequestorUserName, vRequestorMailId
              FROM LOTC.LOTC_PROSPECTIVE_SUPPLIER_REG
             WHERE 1 = 1 AND ITEM_KEY = itemkey AND ITEM_TYPE = itemtype;
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.DERIVE_APPROVERS1',
                    'REGI_REQUEST_NUMBER derivation issue -->' || SQLERRM);
        END;

        UPDATE LOTC.LOTC_SUPP_ONBOARD_REQUEST
           SET REGISTRATION_STATUS = 'Pending Reviewer Approval'
         WHERE REGI_REQUEST_NUMBER = l_request_number;


        BEGIN
            UPDATE LOTC.LOTC_SUPP_DATA_MANAGEMENT
               SET RESUBMIT_STATUS = NULL,
                   NOTIFY_STATUS = NULL,
                   DISQUALIFY_KEY = NULL
             WHERE REGI_REQUEST_NUMBER = l_request_number;
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.DERIVE_APPROVERS1',
                    ' LOTC_SUPP_DATA_MANAGEMENT update issue -->' || SQLERRM);
        END;

        SELECT COUNT (1)
          INTO vRoleCount
          FROM apps.wf_roles
         WHERE NAME = vRequestorMailId;

        IF vRoleCount = 0
        THEN
            wf_directory.createadhocrole (
                role_name                 => vRequestorMailId,
                role_display_name         => vRequestorUserName,
                role_description          => vRequestorUserName,
                notification_preference   => 'MAILHTML',
                email_address             => vRequestorMailId,
                status                    => 'ACTIVE',
                expiration_date           => NULL);
        END IF;

        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#FROM_ROLE',
                                   avalue     => vRequestorMailId);
        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#WFM_FROM',
                                   avalue     => vRequestorUserName);
        wf_engine.setitemattrtext (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => '#WFM_REPLYTO',
                                   avalue     => vRequestorMailId);

        l_transaction_id := itemkey;
        l_transaction_type := 'LOGI_PROS_SUPP_REG';
        l_application_Id := 60007;

        IF (funcmode = 'RUN')
        THEN
            ame_api2.getNextApprovers4 (
                applicationIdIn                => l_application_id,
                transactionTypeIn              => l_transaction_type,
                transactionIdIn                => l_transaction_id,
                flagApproversAsNotifiedIn      => ame_util.booleanTrue,
                approvalProcessCompleteYNOut   => l_is_approval_complete,
                nextApproversOut               => l_next_approvers);

            l_next_approvers_count := l_next_approvers.COUNT;

            IF (l_is_approval_complete = ame_util.booleanTrue)
            THEN
                result := 'COMPLETE:' || 'APPROVAL_COMPLETE';
            ELSIF (l_next_approvers.COUNT = 0)
            THEN
                ame_api2.getPendingApprovers (
                    applicationIdIn                => l_application_id,
                    transactionTypeIn              => l_transaction_type,
                    transactionIdIn                => l_transaction_id,
                    approvalProcessCompleteYNOut   => l_is_approval_complete,
                    approversOut                   => l_next_approvers);
            END IF;

            l_next_approvers_count := l_next_approvers.COUNT;

            IF (l_next_approvers_count = 0)
            THEN
                result := 'COMPLETE:' || 'NO_NEXT_APPROVER';
            END IF;

            IF (l_next_approvers_count > 0)
            THEN
                result := 'COMPLETE:' || 'VALID_APPROVER';
            END IF;

            /*      IF (l_next_approvers_count = 1)
                 THEN
                     l_next_approver :=
                         l_next_approvers (l_next_approvers.FIRST ());
                     wf_engine.SetItemAttrText (itemtype   => itemType,
                                                itemkey    => itemkey,
                                                aname      => 'APPROVER_USER_NAME',
                                                avalue     => l_next_approver.name);

                     wf_engine.SetItemAttrText (
                         itemtype   => itemType,
                         itemkey    => itemkey,
                         aname      => 'APPROVER_DISPLAY_NAME',
                         avalue     => l_next_approver.display_name);

                     FOR crec IN c1 (l_next_approver.name)
                     LOOP
                         l_role_display_name := crec.full_name;
                     END LOOP;


                     result := 'COMPLETE:' || 'VALID_APPROVER';
                 END IF; */

            l_role_name := 'LOGI_PROS_SUPP_REG_ROLE_' || itemkey;
            l_approver_index := l_next_approvers.FIRST ();

            WHILE (l_approver_index IS NOT NULL)
            LOOP
                l_role_users (l_approver_index) :=
                    l_next_approvers (l_approver_index).name;

                write_cust_log (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.DERIVE_APPROVERS1',
                       'l_next_approvers   --> '
                    || l_next_approvers (l_approver_index).name);

                l_approver_index := l_next_approvers.NEXT (l_approver_index);
            END LOOP;

            wf_directory.CreateAdHocRole2 (
                role_name                 => l_role_name,
                role_display_name         => l_role_display_name,
                language                  => NULL,
                territory                 => NULL,
                role_description          => l_role_display_name,
                notification_preference   => NULL,
                role_users                => l_role_users,
                email_address             => NULL,
                fax                       => NULL,
                status                    => 'ACTIVE',
                expiration_date           => NULL,
                parent_orig_system        => NULL,
                parent_orig_system_id     => NULL,
                owner_tag                 => NULL);

            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'CATEGORY_MGR_ROLE',
                                       avalue     => l_role_name);

            write_cust_log (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.DERIVE_APPROVERS1',
                            'l_role_name   --> ' || l_role_name);
        END IF;

        WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'REQUEST_NUMBER',
                                     avalue     => l_request_number);

        IF L_ROLE_NAME IS NOT NULL
        THEN
            result := 'COMPLETE:' || 'Y';
        ELSE
            result := 'COMPLETE:' || 'N';
        END IF;

       <<skip_logic>>
        NULL;
    EXCEPTION
        WHEN OTHERS
        THEN
            result := 'COMPLETE:' || 'N';
            WRITE_CUST_LOG (
                itemkey,
                'LOGI_SUPP_ONBRD_PKG.DERIVE_APPROVERS',
                'DERIVE_APPROVERS outter most exception  --> ' || SQLERRM);
    END DERIVE_APPROVERS1;


    PROCEDURE POPULATE_WF_ATTR1 (itemtype    IN     VARCHAR2,
                                 itemkey     IN     VARCHAR2,
                                 actid       IN     NUMBER,
                                 funcmode    IN     VARCHAR2,
                                 resultout   IN OUT VARCHAR2)
    IS
        vSupplierName             VARCHAR2 (240);
        vRequestorName            VARCHAR2 (100);
        vRequestorUserName        VARCHAR2 (100);
        vRequestorMailId          VARCHAR2 (100);
        vSupplierMailId           VARCHAR2 (2000);
        vApproveBody              VARCHAR2 (4000);
        vRejectBody               VARCHAR2 (4000);
        vRequestNumber            NUMBER;
        vSuppOnbdrSearchPage      VARCHAR2 (1000);
        vSuppOnbdrRequestPage     VARCHAR2 (1000);
        vSuppProsRequestPage      VARCHAR2 (1000);
        vSuppDataManagementPage   VARCHAR2 (1000);
        vRoleCount                NUMBER;
        vApproverCount            NUMBER;
    BEGIN
        vApproverCount :=
            wf_engine.GetItemAttrNumber (itemtype   => itemtype,
                                         itemkey    => itemkey,
                                         aname      => 'LOGI_APPROVER_COUNT');

        IF vApproverCount <> 0
        THEN
            resultout := 'Success';
            GOTO skip_logic;
        END IF;

        BEGIN
            SELECT REQUESTOR_NAME, REGI_REQUEST_NUMBER
              INTO vRequestorName, vRequestNumber
              FROM LOTC_SUPP_ONBOARD_REQUEST
             WHERE REGI_REQUEST_NUMBER =
                   (SELECT REGI_REQUEST_NUMBER
                      FROM LOTC.LOTC_PROSPECTIVE_SUPPLIER_REG
                     WHERE ITEM_TYPE = itemtype AND ITEM_KEY = itemkey);

            SELECT FNDU.USER_NAME, PAPF.EMAIL_ADDRESS
              INTO vRequestorUserName, vRequestorMailId
              FROM PER_ALL_PEOPLE_F PAPF, FND_USER FNDU
             WHERE     1 = 1
                   AND PAPF.PERSON_ID = FNDU.EMPLOYEE_ID
                   AND PAPF.FULL_NAME = vRequestorName
                   AND ROWNUM = 1;


            SELECT COMPANY_NAME, CONTACT_EMAIL
              INTO vSupplierName, vSupplierMailId
              FROM LOTC.LOTC_PROSPECTIVE_SUPPLIER_REG
             WHERE REGI_REQUEST_NUMBER = vRequestNumber;

            Wf_Engine.SetItemAttrText (itemtype,
                                       itemkey,
                                       'SUPPLIER_NAME',
                                       vSupplierName);

            Wf_Engine.SetItemAttrText (itemtype,
                                       itemkey,
                                       'REQUESTER_NAME',
                                       vRequestorUserName);

            SELECT COUNT (1)
              INTO vRoleCount
              FROM apps.wf_roles
             WHERE NAME = vRequestorMailId;

            IF vRoleCount = 0
            THEN
                wf_directory.createadhocrole (
                    role_name                 => vRequestorMailId,
                    role_display_name         => vRequestorUserName,
                    role_description          => vRequestorUserName,
                    notification_preference   => 'MAILHTML',
                    email_address             => vRequestorMailId,
                    status                    => 'ACTIVE',
                    expiration_date           => NULL);
            END IF;

            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'REQUESTER_ROLE',
                                       avalue     => vRequestorMailId);

            vSuppOnbdrSearchPage :=
                FND_RUN_FUNCTION.get_run_function_url (
                    p_function_id =>
                        fnd_function.get_function_id (
                            'LOGI_SUPP_ONBRD_SEARCH'),
                    p_resp_appl_id =>
                        NULL,
                    p_resp_id =>
                        NULL,
                    p_security_group_id =>
                        0,
                    p_parameters =>
                        NULL,
                    p_override_agent =>
                        NULL,
                    p_org_id =>
                        NULL,
                    p_lang_code =>
                        NULL,
                    p_encryptParameters =>
                        TRUE);
            /* 01-NOv-18 vSuppOnbdrSearchPage :=
                REPLACE (vSuppOnbdrSearchPage,
                         pos_url_pkg.get_internal_url,
                         pos_url_pkg.get_external_url); */
            vSuppOnbdrSearchPage :=
                REPLACE (vSuppOnbdrSearchPage,
                         fnd_profile.VALUE ('APPS_SERVLET_AGENT') || '/',
                         pos_url_pkg.get_external_url || 'OA_HTML/');
            wf_engine.setitemattrtext (
                itemtype   => itemtype,
                itemkey    => itemkey,
                aname      => 'LOGI_SUPP_ONBDR_SEARCH_PAGE',
                avalue     => vSuppOnbdrSearchPage);


            vSuppOnbdrRequestPage :=
                FND_RUN_FUNCTION.get_run_function_url (
                    p_function_id =>
                        fnd_function.get_function_id (
                            'LOGI_SUPP_ONBRD_REQUEST'),
                    p_resp_appl_id =>
                        NULL,
                    p_resp_id =>
                        NULL,
                    p_security_group_id =>
                        0,
                    p_parameters =>
                           'RequestNumber1='
                        || vRequestNumber
                        || '&'
                        || 'mode=UPDATE',
                    p_override_agent =>
                        NULL,
                    p_org_id =>
                        NULL,
                    p_lang_code =>
                        NULL,
                    p_encryptParameters =>
                        TRUE);
            /*  01-NOv-18 vSuppOnbdrRequestPage :=
                  REPLACE (vSuppOnbdrRequestPage,
                           pos_url_pkg.get_internal_url,
                           pos_url_pkg.get_external_url); */
            vSuppOnbdrRequestPage :=
                REPLACE (vSuppOnbdrRequestPage,
                         fnd_profile.VALUE ('APPS_SERVLET_AGENT') || '/',
                         pos_url_pkg.get_external_url || 'OA_HTML/');
            wf_engine.setitemattrtext (
                itemtype   => itemtype,
                itemkey    => itemkey,
                aname      => 'LOGI_SUPP_ONBDR_REGI_PAGE',
                avalue     => vSuppOnbdrRequestPage);


            vSuppProsRequestPage :=
                FND_RUN_FUNCTION.get_run_function_url (
                    p_function_id =>
                        fnd_function.get_function_id ('LOGI_SUPP_ONBRD_PROS'),
                    p_resp_appl_id =>
                        NULL,
                    p_resp_id =>
                        NULL,
                    p_security_group_id =>
                        0,
                    p_parameters =>
                           'RequestNumber1='
                        || vRequestNumber
                        || '&'
                        || 'NotifyMode=Yes',
                    p_override_agent =>
                        NULL,
                    p_org_id =>
                        NULL,
                    p_lang_code =>
                        NULL,
                    p_encryptParameters =>
                        TRUE);
            /* 01-NOv-18 vSuppProsRequestPage :=
                REPLACE (vSuppProsRequestPage,
                         pos_url_pkg.get_internal_url,
                         pos_url_pkg.get_external_url); */
            vSuppProsRequestPage :=
                REPLACE (vSuppProsRequestPage,
                         fnd_profile.VALUE ('APPS_SERVLET_AGENT') || '/',
                         pos_url_pkg.get_external_url || 'OA_HTML/');
            wf_engine.setitemattrtext (
                itemtype   => itemtype,
                itemkey    => itemkey,
                aname      => 'LOGI_SUPP_ONBDR_PROS_PAGE',
                avalue     => vSuppProsRequestPage);

            vSuppDataManagementPage :=
                FND_RUN_FUNCTION.get_run_function_url (
                    p_function_id =>
                        fnd_function.get_function_id (
                            'LOGI_SUPP_ONBRD_DATA_MAN'),
                    p_resp_appl_id =>
                        NULL,
                    p_resp_id =>
                        NULL,
                    p_security_group_id =>
                        0,
                    p_parameters =>
                        'RequestNumber1=' || vRequestNumber,
                    p_override_agent =>
                        NULL,
                    p_org_id =>
                        NULL,
                    p_lang_code =>
                        NULL,
                    p_encryptParameters =>
                        TRUE);
            /* 01-NOv-18 vSuppDataManagementPage :=
                REPLACE (vSuppDataManagementPage,
                         pos_url_pkg.get_internal_url,
                         pos_url_pkg.get_external_url); */
            vSuppDataManagementPage :=
                REPLACE (vSuppDataManagementPage,
                         fnd_profile.VALUE ('APPS_SERVLET_AGENT') || '/',
                         pos_url_pkg.get_external_url || 'OA_HTML/');
            wf_engine.setitemattrtext (
                itemtype   => itemtype,
                itemkey    => itemkey,
                aname      => 'LOGI_SUPP_DATA_MANAG_PAGE',
                avalue     => vSuppDataManagementPage);

            SELECT COUNT (1)
              INTO vRoleCount
              FROM apps.wf_roles
             WHERE NAME = vSupplierMailId;

            IF vRoleCount = 0
            THEN
                wf_directory.createadhocrole (
                    role_name                 => vSupplierMailId,
                    role_display_name         => vSupplierName,
                    role_description          => vSupplierName,
                    notification_preference   => 'MAILHTML',
                    email_address             => vSupplierMailId,
                    status                    => 'ACTIVE',
                    expiration_date           => NULL);
            END IF;

            vApproveBody :=
                '
Dear Supplier,

         On behalf of Logitech we would like to inform you that your information has been reviewed and approved. We welcome you as a new Logitech supplier!
We would like to remind you that a contract and a Purchase Order must be in place before any work is started.
Please engage with your Logitech contact to confirm all steps are completed and to ask any questions regarding the process.

Sincerely,
Logitech Global Procurement
Global_Procurement_Team@logitech.com';


            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'APPROVE_NOTI_BODY',
                                       avalue     => vApproveBody);

            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'SUPPLIER_ROLE',
                                       avalue     => vSupplierMailId);
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.POPULATE_WF_ATTR1',
                       'vSupplierName,vRequestorName,vSupplierMailId  --> '
                    || SQLERRM);
        END;

        resultout := 'Success';

       <<skip_logic>>
        NULL;
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.POPULATE_WF_ATTR1',
                            'outter most exception  --> ' || SQLERRM);
    END POPULATE_WF_ATTR1;

    PROCEDURE APPROVE_NOTIFICATION1 (itemtype    IN     VARCHAR2,
                                     itemkey     IN     VARCHAR2,
                                     actid       IN     NUMBER,
                                     funcmode    IN     VARCHAR2,
                                     resultout   IN OUT VARCHAR2)
    AS
        l_transaction_type               VARCHAR2 (30) := 'LOGI_PROS_SUPP_REG';
        l_application_Id                 NUMBER := 60007;
        l_request_number                 NUMBER;
        l_approver_id                    NUMBER (15) := NULL;
        l_approver_name                  VARCHAR2 (150);
        l_approver_name_display          VARCHAR2 (150);
        l_nextapproversout               ame_util.approverstable2;
        l_itemindexesout                 ame_util.idlist;
        l_itemclassesout                 ame_util.stringlist;
        l_itemidsout                     ame_util.stringlist;
        l_itemsourcesout                 ame_util.longstringlist;
        l_approvalprocesscompleteynout   VARCHAR2 (100);
        l_approver_count                 NUMBER;
        l_ExpirationDate                 DATE := SYSDATE + 1000;
        l_AdHocRoleName                  VARCHAR2 (500) := NULL;
        l_AdHocRoleDesc                  VARCHAR2 (500) := NULL;
        l_Responder                      VARCHAR2 (50);
        l_Responder_Name                 VARCHAR2 (240);
        l_Responder_Mailid               VARCHAR2 (100);
        vRoleCount                       NUMBER;
        l_transaction_id                 VARCHAR2 (30);
        l_next_approver                  ame_util.approverrecord2;
        l_next_approvers                 ame_util.approverstable2;
        l_next_approvers_count           NUMBER;
        l_approver_index                 NUMBER;
        l_is_approval_complete           VARCHAR2 (1);
        l_role_users                     wf_directory.usertable;
        l_role_name                      VARCHAR2 (320) := NULL;
        l_role_display_name              VARCHAR2 (360);
        l_all_approvers                  ame_util.approverstable;
        l_nid                            NUMBER;
        l_gid                            NUMBER;
        l_result                         VARCHAR2 (100);
        l_ame_status                     VARCHAR2 (20);
        l_original_approver_name         VARCHAR2 (240);
        l_forwardeein                    ame_util.approverrecord2;
        l_user_name                      VARCHAR2 (50);
        l_role_name1                     VARCHAR2 (320) := NULL;

        CURSOR c1 (
            p_user_name    VARCHAR2)
        IS
            SELECT papf.full_name
              FROM fnd_user fu, per_all_people_f papf
             WHERE     fu.employee_id = papf.person_id
                   AND fu.user_name = p_user_name
                   AND SYSDATE BETWEEN papf.EFFECTIVE_START_DATE
                                   AND NVL (papf.EFFECTIVE_end_DATE,
                                            SYSDATE + 1)
                   AND SYSDATE BETWEEN fu.start_date
                                   AND NVL (fu.end_date, SYSDATE + 1);
    BEGIN
        BEGIN
            BEGIN
                wf_engine.setitemattrtext (itemtype   => itemtype,
                                           itemkey    => itemkey,
                                           aname      => 'PRN_COMMENTS',
                                           avalue     => NULL);
                l_Responder := NULL;

                SELECT wn.RECIPIENT_ROLE,
                       (SELECT PAPF.FULL_NAME
                          FROM PER_ALL_PEOPLE_F PAPF, FND_USER FNDU
                         WHERE     1 = 1
                               AND PAPF.PERSON_ID = FNDU.EMPLOYEE_ID
                               AND FNDU.USER_NAME = wn.RECIPIENT_ROLE
                               AND ROWNUM = 1),
                       (SELECT PAPF.EMAIL_ADDRESS
                          FROM PER_ALL_PEOPLE_F PAPF, FND_USER FNDU
                         WHERE     1 = 1
                               AND PAPF.PERSON_ID = FNDU.EMPLOYEE_ID
                               AND FNDU.USER_NAME = wn.RECIPIENT_ROLE
                               AND ROWNUM = 1)
                  INTO l_Responder, l_Responder_Name, l_Responder_Mailid
                  FROM wf_notifications wn
                 WHERE     1 = 1
                       AND NOTIFICATION_ID =
                           (SELECT MAX (NOTIFICATION_ID)
                              FROM wf_notifications
                             WHERE     1 = 1
                                   AND MESSAGE_TYPE = itemtype
                                   AND item_key = itemkey
                                   AND RESPONDER IS NOT NULL
                                   AND STATUS = 'CLOSED');
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_Responder := NULL;
            END;

            WRITE_CUST_LOG (
                itemkey,
                'LOGI_SUPP_ONBRD_PKG.APPROVE_NOTIFICATION1',
                   l_Responder
                || '  $  '
                || l_Responder_Name
                || '  $  '
                || l_Responder_Mailid);

            SELECT COUNT (1)
              INTO vRoleCount
              FROM apps.wf_roles
             WHERE NAME = l_Responder_Mailid;

            IF vRoleCount = 0
            THEN
                wf_directory.createadhocrole (
                    role_name                 => l_Responder_Mailid,
                    role_display_name         => l_Responder_Name,
                    role_description          => l_Responder_Name,
                    notification_preference   => 'MAILHTML',
                    email_address             => l_Responder_Mailid,
                    status                    => 'ACTIVE',
                    expiration_date           => NULL);
            END IF;

            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => '#FROM_ROLE',
                                       avalue     => l_Responder_Mailid);

            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => '#WFM_FROM',
                                       avalue     => l_Responder_Name);

            wf_engine.setitemattrtext (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => '#WFM_REPLYTO',
                                       avalue     => l_Responder_Mailid);

            SELECT REGI_REQUEST_NUMBER
              INTO l_request_number
              FROM LOTC_PROSPECTIVE_SUPPLIER_REG
             WHERE ITEM_TYPE = itemtype AND ITEM_KEY = itemkey;


            l_transaction_type := 'LOGI_PROS_SUPP_REG';
            l_application_id := 60007;
            l_transaction_id := itemKey;
            l_approver_name := l_Responder;


            -- ReAssign Approving the request start from here
            l_approver_count :=
                wf_engine.GetItemAttrNumber (
                    itemtype   => itemtype,
                    itemkey    => itemkey,
                    aname      => 'LOGI_APPROVER_COUNT');


            BEGIN
                SELECT CASE
                           WHEN l_approver_count = 0
                           THEN
                               'LOGI_PROS_SUPP_REG_ROLE_' || itemkey
                           ELSE
                                  'LOGI_PROS_SUPP_REG_ROLE_'
                               || itemkey
                               || '_'
                               || l_approver_count
                       END
                  INTO l_role_name1
                  FROM DUAL;

                write_cust_log (itemkey,
                                'LOGI_SUPP_ONBRD_PKG.APPROVE_NOTIFICATION1',
                                'l_role_name1   is  --> ' || l_role_name1);

                SELECT USER_NAME
                  INTO l_user_name
                  FROM WF_USER_ROLES
                 WHERE     role_name = l_role_name1
                       AND USER_NAME = l_approver_name;
            EXCEPTION
                WHEN OTHERS
                THEN
                    BEGIN
                        SELECT USER_NAME
                          INTO l_approver_name
                          FROM WF_USER_ROLES
                         WHERE role_name = l_role_name1 AND ROWNUM = 1;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            write_cust_log (
                                itemkey,
                                'LOGI_SUPP_ONBRD_PKG.APPROVE_NOTIFICATION1',
                                   'l_approver_name derivation issue     --> '
                                || SQLERRM);
                    END;
            END;

            -- ReAssign Approving the request end from here

            IF (funcmode = 'RUN')
            THEN
                l_forwardeein.name := wf_engine.context_new_role;
                l_original_approver_name :=
                    wf_engine.context_original_recipient;

                /*    write_cust_log (
                       123,
                       'LOGI_SUPP_ONBRD_PKG.APPROVE_NOTIFICATION1',
                       'RUN    l_forwardeein.name    --> ' || l_forwardeein.name);
                   write_cust_log (
                       123,
                       'LOGI_SUPP_ONBRD_PKG.APPROVE_NOTIFICATION1',
                          'RUN    l_original_approver_name    --> '
                       || l_original_approver_name);


                   write_cust_log (123,
                                   'LOGI_SUPP_ONBRD_PKG.APPROVE_NOTIFICATION1',
                                   'l_gid    --> ' || wf_engine.context_nid); */

                l_ame_status := ame_util.approvedstatus;

                ame_api2.updateapprovalstatus2 (
                    applicationidin     => l_application_id,
                    transactiontypein   => l_transaction_type,
                    transactionidin     => l_transaction_id,
                    approvalstatusin    => l_ame_status,
                    approvernamein      => l_approver_name);

                write_cust_log (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.APPROVE_NOTIFICATION1',
                       'l_approver_name update status    --> '
                    || l_approver_name
                    || '     '
                    || l_ame_status);
            ELSIF (funcmode = 'TRANSFER')
            THEN
                l_forwardeein.name := wf_engine.context_new_role;
                l_original_approver_name :=
                    wf_engine.context_original_recipient;

                write_cust_log (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.APPROVE_NOTIFICATION1',
                       'TRANSFER    l_forwardeein.name    --> '
                    || l_forwardeein.name);
                write_cust_log (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.APPROVE_NOTIFICATION1',
                       'TRANSFER    l_original_approver_name    --> '
                    || l_original_approver_name);


                ame_api2.updateapprovalstatus2 (
                    applicationidin     => l_application_id,
                    transactiontypein   => l_transaction_type,
                    transactionidin     => l_transaction_id,
                    approvalstatusin    => 'FORWARD',
                    approvernamein      => l_original_approver_name,
                    forwardeein         => l_forwardeein);

                write_cust_log (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.APPROVE_NOTIFICATION1',
                       'TRANSFER    l_approver_name update status    --> '
                    || l_original_approver_name
                    || '     '
                    || 'FORWARD');
            END IF;

            IF (funcmode = 'RUN')
            THEN
                l_transaction_type := 'LOGI_PROS_SUPP_REG';
                l_application_Id := 60007;


                ame_api2.getNextApprovers4 (
                    applicationIdIn                => l_application_id,
                    transactionTypeIn              => l_transaction_type,
                    transactionIdIn                => l_transaction_id,
                    flagApproversAsNotifiedIn      => ame_util.booleanTrue,
                    approvalProcessCompleteYNOut   => l_is_approval_complete,
                    nextApproversOut               => l_next_approvers);

                l_next_approvers_count := l_next_approvers.COUNT;

                IF (l_is_approval_complete = ame_util.booleanTrue)
                THEN
                    resultout := 'COMPLETE:' || 'APPROVAL_COMPLETE';
                ELSIF (l_next_approvers.COUNT = 0)
                THEN
                    ame_api2.getPendingApprovers (
                        applicationIdIn =>
                            l_application_id,
                        transactionTypeIn =>
                            l_transaction_type,
                        transactionIdIn =>
                            l_transaction_id,
                        approvalProcessCompleteYNOut =>
                            l_is_approval_complete,
                        approversOut =>
                            l_next_approvers);
                END IF;

                l_next_approvers_count := l_next_approvers.COUNT;

                IF (l_next_approvers_count = 0)
                THEN
                    resultout := 'COMPLETE:' || 'NO_NEXT_APPROVER';
                END IF;

                IF (l_next_approvers_count > 0)
                THEN
                    resultout := 'COMPLETE:' || 'VALID_APPROVER';
                END IF;

                /*     IF (l_next_approvers_count = 1)
                    THEN
                        l_next_approver :=
                            l_next_approvers (l_next_approvers.FIRST ());
                        wf_engine.SetItemAttrText (
                            itemtype   => itemType,
                            itemkey    => itemkey,
                            aname      => 'APPROVER_USER_NAME',
                            avalue     => l_next_approver.name);

                        wf_engine.SetItemAttrText (
                            itemtype   => itemType,
                            itemkey    => itemkey,
                            aname      => 'APPROVER_DISPLAY_NAME',
                            avalue     => l_next_approver.display_name);

                        FOR crec IN c1 (l_next_approver.name)
                        LOOP
                            l_role_display_name := crec.full_name;
                        END LOOP;


                        resultout := 'COMPLETE:' || 'VALID_APPROVER';
                    END IF; */

                l_approver_count :=
                    wf_engine.GetItemAttrNumber (
                        itemtype   => itemtype,
                        itemkey    => itemkey,
                        aname      => 'LOGI_APPROVER_COUNT');


                l_role_name :=
                       'LOGI_PROS_SUPP_REG_ROLE_'
                    || itemkey
                    || '_'
                    || TO_CHAR (NVL (l_approver_count, 0) + 1);

                l_approver_index := l_next_approvers.FIRST ();

                WHILE (l_approver_index IS NOT NULL)
                LOOP
                    l_role_users (l_approver_index) :=
                        l_next_approvers (l_approver_index).name;

                    write_cust_log (
                        itemkey,
                        'LOGI_SUPP_ONBRD_PKG.APPROVE_NOTIFICATION1',
                           'l_next_approvers   --> '
                        || l_next_approvers (l_approver_index).name);
                    l_approver_index :=
                        l_next_approvers.NEXT (l_approver_index);
                END LOOP;

                wf_directory.CreateAdHocRole2 (
                    role_name                 => l_role_name,
                    role_display_name         => l_role_display_name,
                    language                  => NULL,
                    territory                 => NULL,
                    role_description          => l_role_display_name,
                    notification_preference   => NULL,
                    role_users                => l_role_users,
                    email_address             => NULL,
                    fax                       => NULL,
                    status                    => 'ACTIVE',
                    expiration_date           => NULL,
                    parent_orig_system        => NULL,
                    parent_orig_system_id     => NULL,
                    owner_tag                 => NULL);

                wf_engine.setitemattrtext (itemtype   => itemtype,
                                           itemkey    => itemkey,
                                           aname      => 'CATEGORY_MGR_ROLE',
                                           avalue     => l_role_name);
            END IF;

            WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype,
                                         itemkey    => itemkey,
                                         aname      => 'REQUEST_NUMBER',
                                         avalue     => l_request_number);

            IF l_role_name IS NOT NULL AND resultout LIKE '%VALID_APPROVER%'
            THEN
                l_approver_count := l_approver_count + 1;

                WF_ENGINE.SetItemAttrNumber (
                    itemtype   => itemtype,
                    itemkey    => itemkey,
                    aname      => 'LOGI_APPROVER_COUNT',
                    avalue     => l_approver_count);

                resultout := 'COMPLETE:' || 'Y';
            ELSE
                resultout := 'COMPLETE:' || 'N';
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.APPROVE_NOTIFICATION1',
                       'Approver found exception  --> '
                    || SQLERRM
                    || ' DBMS_UTILTY -->'
                    || DBMS_UTILITY.format_error_backtrace
                    || ' DBMS_UTILTY -->'
                    || DBMS_UTILITY.format_error_stack);
                resultout := 'COMPLETE:' || 'N';
        END;
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.APPROVE_NOTIFICATION1',
                            'Outter Most exception  --> ' || SQLERRM);
            resultout := 'COMPLETE:' || 'N';
    END APPROVE_NOTIFICATION1;


    PROCEDURE NOTIFY_VENDOR1 (itemtype    IN     VARCHAR2,
                              itemkey     IN     VARCHAR2,
                              actid       IN     NUMBER,
                              funcmode    IN     VARCHAR2,
                              resultout   IN OUT VARCHAR2)
    IS
        vSupplierExist   NUMBER := 0;
    BEGIN
        SELECT COUNT (1)
          INTO vSupplierExist
          FROM LOTC_SUPP_ONBOARD_REQUEST req, LFND_LOOKUPS lkup
         WHERE     1 = 1
               AND req.SUPPLIER_TYPE = lkup.KEY3
               AND lkup.LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_FRM_VALUES'
               AND lkup.KEY2 = 'Supplier Type'
               AND lkup.KEY6 = 'Y'
               AND req.REGI_REQUEST_NUMBER =
                   (SELECT REGI_REQUEST_NUMBER
                      FROM LOTC.LOTC_PROSPECTIVE_SUPPLIER_REG
                     WHERE ITEM_TYPE = itemtype AND ITEM_KEY = itemkey);

        WRITE_CUST_LOG (itemkey,
                        'LOGI_SUPP_ONBRD_PKG.Notify_Vendor1',
                        'vSupplierExist  --> ' || vSupplierExist);

        UPDATE LOTC.LOTC_SUPP_ONBOARD_REQUEST req
           SET REGISTRATION_STATUS = 'Approved by Reviewer'
         WHERE req.REGI_REQUEST_NUMBER =
               (SELECT REGI_REQUEST_NUMBER
                  FROM LOTC.LOTC_PROSPECTIVE_SUPPLIER_REG
                 WHERE ITEM_TYPE = itemtype AND ITEM_KEY = itemkey);

        IF vSupplierExist = 1
        THEN
            WRITE_CUST_LOG (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.Notify_Vendor1',
                            'vSupplierExist  --> Y');
            resultout := 'COMPLETE:' || 'Y';
        ELSE
            resultout := 'COMPLETE:' || 'N';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            resultout := 'COMPLETE:' || 'N';
            WRITE_CUST_LOG (itemkey,
                            'LOGI_SUPP_ONBRD_PKG.VENDOR_TYPE',
                            'outter most exception  --> ' || SQLERRM);
    END NOTIFY_VENDOR1;


    PROCEDURE CREATE_SUPPLIER (itemtype    IN     VARCHAR2,
                               itemkey     IN     VARCHAR2,
                               actid       IN     NUMBER,
                               funcmode    IN     VARCHAR2,
                               resultout   IN OUT VARCHAR2)
    AS
        vRegRegNumber         NUMBER;
        vOrgId                NUMBER;
        vRequestId            NUMBER;
        l_return              BOOLEAN;
        l_phase               VARCHAR2 (30);
        l_status              VARCHAR2 (30);
        l_dev_phase           VARCHAR2 (30);
        l_dev_status          VARCHAR2 (30);
        l_message             VARCHAR2 (1000);
        l_error_count         NUMBER := 0;
        l_emp_full_name       VARCHAR2 (240);
        l_isOcrmSupp          NUMBER := 0;
        l_region              VARCHAR2 (20);
        l_ocrm_role_name      VARCHAR2 (50);
        vRoleCount            NUMBER;
        l_ExpirationDate      DATE := SYSDATE + 1000;
        l_dm_approver         NUMBER;
        l_user_name           VARCHAR2 (100); -- rvemula added as part of  ITSM-3721
        l_responsibility_id   NUMBER;   -- rvemula added as part of  ITSM-3721
        l_application_id      NUMBER;   -- rvemula added as part of  ITSM-3721
    BEGIN
        BEGIN
            SELECT REGI_REQUEST_NUMBER
              INTO vRegRegNumber
              FROM LOTC_PROSPECTIVE_SUPPLIER_REG
             WHERE 1 = 1 AND ITEM_KEY = itemkey AND ITEM_TYPE = itemtype;

            SELECT ORGANIZATION_ID
              INTO vOrgId
              FROM LFND_LOOKUPS               LKP,
                   LOTC_SUPP_ONBOARD_REQUEST  REQ,
                   HR_OPERATING_UNITS         HR
             WHERE     1 = 1
                   AND LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_ENTITIES'
                   AND KEY4 = ENTITY_NAME_SUPP_REGI_IN
                   AND KEY3 = HR.NAME
                   AND req.REGI_REQUEST_NUMBER = vRegRegNumber;
        EXCEPTION
            WHEN OTHERS
            THEN
                vRegRegNumber := 0;
                vOrgId := 0;
        END;


        UPDATE LOTC.LOTC_SUPP_ONBOARD_REQUEST req
           SET REGISTRATION_STATUS = 'Completed, Closed'
         WHERE req.REGI_REQUEST_NUMBER = vRegRegNumber;

        WRITE_CUST_LOG (itemkey, 'CREATE_SUPPLIER', 'itemkey:' || itemkey);

        WRITE_CUST_LOG (itemkey, 'CREATE_SUPPLIER', 'itemtype:' || itemtype);

        WRITE_CUST_LOG (itemkey,
                        'CREATE_SUPPLIER',
                        'vRegRegNumber:' || vRegRegNumber);
        WRITE_CUST_LOG (itemkey, 'CREATE_SUPPLIER', 'vOrgId:' || vOrgId);

        IF vRegRegNumber <> 0
        THEN
            mo_global.init ('SQLAP');
            mo_global.set_org_context (vOrgId, NULL, 'SQLAP');
            mo_global.set_policy_context ('S', vOrgId);
            fnd_request.set_org_id (vOrgId);

            SELECT ll.KEY2
              INTO l_region
              FROM lfnd_lookups ll, LOTC_SUPP_DATA_MANAGEMENT Data
             WHERE     ll.LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_ENTITIES'
                   AND ll.KEY4 = data.ENTITY_NAME
                   AND data.REGI_REQUEST_NUMBER = vRegRegNumber;


            BEGIN
                l_dm_approver := NULL;
                l_user_name := NULL;

                SELECT fu.USER_ID, fu.user_name -- rvemula added as part of  ITSM-3721
                  INTO l_dm_approver, l_user_name -- rvemula added as part of  ITSM-3721
                  FROM fnd_user fu, per_all_people_f ppf
                 WHERE     fu.employee_id = ppf.person_id
                       AND fu.user_name =
                           (SELECT RECIPIENT_ROLE
                              FROM wf_notifications wn
                             WHERE     MESSAGE_TYPE = itemtype
                                   AND ITEM_KEY = itemkey
                                   AND STATUS = 'CLOSED'
                                   AND EXISTS
                                           (SELECT 1
                                              FROM lfnd_lookups
                                             WHERE     lookup_type =
                                                       'LOGI_SUPP_ONBRD_TEAM_MEMBERS'
                                                   AND KEY1 = l_region
                                                   AND KEY4 =
                                                       wn.RECIPIENT_ROLE));
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_dm_approver := NULL;
                    WRITE_CUST_LOG (
                        itemkey,
                        'CREATE_SUPPLIER',
                           'l_dm_approver issue itemkey is --> '
                        || itemkey
                        || '  and error is    '
                        || SQLERRM);
            END;

            --start rvemula added as part of  ITSM-3721
            BEGIN
                l_responsibility_id := NULL;

                SELECT RESPONSIBILITY_ID, APPLICATION_ID
                  INTO l_responsibility_id, l_application_id
                  FROM fnd_responsibility_tl
                 WHERE RESPONSIBILITY_NAME =
                       (SELECT KEY5
                          FROM lfnd_lookups
                         WHERE     lookup_type =
                                   'LOGI_SUPP_ONBRD_TEAM_MEMBERS'
                               AND KEY1 = l_region
                               AND KEY4 = l_user_name);
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_responsibility_id := 51330;
                    WRITE_CUST_LOG (
                        itemkey,
                        'CREATE_SUPPLIER',
                           'l_responsibility_id issue itemkey is --> '
                        || itemkey
                        || '  and error is    '
                        || SQLERRM);
            END;

            -- end rvemula added as part of  ITSM-3721
            WRITE_CUST_LOG (
                itemkey,
                'CREATE_SUPPLIER',
                   'l_responsibility_id is  --> '
                || l_responsibility_id
                || ' l_dm_approver is  --> '
                || l_dm_approver
                || '  and    l_application_id  --> '
                || l_application_id);

                -- rvemula added apps_initialize as part of  ITSM-3721
            apps.fnd_global.apps_initialize (
                NVL (l_dm_approver, fnd_global.user_id),
                l_responsibility_id,                                  --20639,
                l_application_id);

            vRequestId :=
                FND_REQUEST.SUBMIT_REQUEST (
                    application   => 'LOTC',
                    program       => 'LOTCSUPONBOARDING',
                    start_time    => NULL,
                    sub_request   => FALSE,
                    argument1     => vRegRegNumber,
                    argument2     => l_region);
            COMMIT;

            WRITE_CUST_LOG (
                itemkey,
                'CREATE_SUPPLIER',
                'Request Not Submitted due to "' || fnd_message.get || '".');

            WRITE_CUST_LOG (itemkey,
                            'CREATE_SUPPLIER',
                            'Concurrent Program Request ID:' || vRequestId);

            IF vRequestId IS NOT NULL
            THEN
                LOOP
                    l_return :=
                        fnd_concurrent.wait_for_request (vRequestId,
                                                         10,
                                                         500,
                                                         l_phase,
                                                         l_status,
                                                         l_dev_phase,
                                                         l_dev_status,
                                                         l_message);
                    l_return :=
                        fnd_concurrent.get_request_status (vRequestId,
                                                           NULL,
                                                           NULL,
                                                           l_phase,
                                                           l_status,
                                                           l_dev_phase,
                                                           l_dev_status,
                                                           l_message);

                    IF (NVL (l_dev_phase, 'ERROR') = 'COMPLETE')
                    THEN
                        EXIT;
                    END IF;
                END LOOP;
            END IF;
        END IF;

        SELECT COUNT (1)
          INTO l_isOcrmSupp
          FROM LOTC_SUPP_ONBOARD_REQUEST
         WHERE     REGI_REQUEST_NUMBER = vRegRegNumber
               AND OCRM_SUPPLIER_TYPE IS NOT NULL;

        SELECT ll.KEY2
          INTO l_region
          FROM lfnd_lookups ll, LOTC_SUPP_DATA_MANAGEMENT Data
         WHERE     ll.LOOKUP_TYPE = 'LOGI_SUPP_ONBRD_ENTITIES'
               AND ll.KEY4 = data.ENTITY_NAME
               AND data.REGI_REQUEST_NUMBER = vRegRegNumber;

        IF l_isOcrmSupp = 1
        THEN
            BEGIN
                l_ocrm_role_name :=
                    'LOGI_OCRM_TEAM_' || l_region || '_' || itemkey;

                WRITE_CUST_LOG (
                    itemkey,
                    'LOGI_SUPP_ONBRD_PKG.CREATE_SUPPLIER',
                    'l_ocrm_role_name   --> ' || l_ocrm_role_name);

                vRoleCount := 0;

                SELECT COUNT (1)
                  INTO vRoleCount
                  FROM apps.wf_roles
                 WHERE NAME = l_ocrm_role_name;

                IF vRoleCount = 0
                THEN
                    WF_DIRECTORY.CreateAdHocRole (l_ocrm_role_name,
                                                  l_ocrm_role_name,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  'MAILHTML',
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  'ACTIVE',
                                                  l_ExpirationDate);
                END IF;

                FOR DM_USER
                    IN (SELECT KEY3, KEY2
                          FROM lfnd_lookups
                         WHERE     LOOKUP_TYPE =
                                   'LOGI_SUPP_ONBRD_OCRM_EMAIL_ADD'
                               AND KEY1 = l_region)
                LOOP
                    WF_DIRECTORY.AddUsersToAdHocRole (l_ocrm_role_name,
                                                      DM_USER.KEY3);
                END LOOP;

                wf_engine.setitemattrtext (itemtype   => itemtype,
                                           itemkey    => itemkey,
                                           aname      => 'OCRM_ROLE',
                                           avalue     => l_ocrm_role_name);
            EXCEPTION
                WHEN OTHERS
                THEN
                    WRITE_CUST_LOG (
                        itemkey,
                        'LOGI_SUPP_ONBRD_PKG.CREATE_SUPPLIER',
                           'OCRM Team Derivation Isuue  --> '
                        || DBMS_UTILITY.format_error_backtrace
                        || '   and format_error_stack      '
                        || DBMS_UTILITY.format_error_stack);
            END;

            resultout := 'COMPLETE:' || 'Y';
        ELSE
            resultout := 'COMPLETE:' || 'N';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            resultout := 'COMPLETE:' || 'N';
            WRITE_CUST_LOG (itemkey,
                            'CREATE_SUPPLIER',
                            'Error @ CREATE_SUPPLIER --> ' || SQLERRM);
    END CREATE_SUPPLIER;

    PROCEDURE UPDATE_OCRM_INFO (itemtype    IN     VARCHAR2,
                                itemkey     IN     VARCHAR2,
                                actid       IN     NUMBER,
                                funcmode    IN     VARCHAR2,
                                resultout   IN OUT VARCHAR2)
    IS
        vRegRegNumber       NUMBER;
        vCompanyName        VARCHAR2 (240);
        vOcrmSupplierType   VARCHAR2 (5);
        vVendorId           NUMBER;
    BEGIN
        SELECT REGI_REQUEST_NUMBER, COMPANY_NAME
          INTO vRegRegNumber, vCompanyName
          FROM LOTC_PROSPECTIVE_SUPPLIER_REG
         WHERE 1 = 1 AND ITEM_KEY = itemkey AND ITEM_TYPE = itemtype;

        SELECT OCRM_SUPPLIER_TYPE
          INTO vOcrmSupplierType
          FROM LOTC_SUPP_ONBOARD_REQUEST
         WHERE REGI_REQUEST_NUMBER = vRegRegNumber;

        UPDATE HZ_PARTIES
           SET ATTRIBUTE1 = vOcrmSupplierType
         WHERE PARTY_NAME = vCompanyName;

        SELECT VENDOR_ID
          INTO vVendorId
          FROM po_vendors pv
         WHERE 1 = 1 AND VENDOR_NAME = vCompanyName;


        UPDATE po_vendor_sites_All
           SET ATTRIBUTE14 =
                   DECODE (vOcrmSupplierType,
                           'T1', 'T1 and AP',
                           vOcrmSupplierType)
         WHERE VENDOR_ID = vVendorId;

        WRITE_CUST_LOG (
            itemkey,
            'UPDATE_OCRM_INFO',
               ' vRegRegNumber  ,  vCompanyName , vVendorId  and vOcrmSupplierType '
            || vRegRegNumber
            || ' - '
            || vCompanyName
            || ' - '
            || vVendorId
            || ' - '
            || vOcrmSupplierType);

        WRITE_CUST_LOG (
            itemkey,
            'UPDATE_OCRM_INFO',
               'UPDATE_OCRM_INFO updated Succesfully to the customer --> '
            || vCompanyName
            || ' and the OCRM Type is '
            || vOcrmSupplierType
            || '   number of records updated is '
            || SQL%ROWCOUNT);

        COMMIT;

        resultout := 'Success';
    EXCEPTION
        WHEN OTHERS
        THEN
            WRITE_CUST_LOG (itemkey,
                            'UPDATE_OCRM_INFO',
                            'Error @ UPDATE_OCRM_INFO --> ' || SQLERRM);
            resultout := 'Success';
    END UPDATE_OCRM_INFO;

    FUNCTION PENDING_WITH (P_REG_REQ_NUM    NUMBER,
                           P_ITEM_KEY       VARCHAR2,
                           P_PLACE          VARCHAR2)
        RETURN VARCHAR2
    AS
        L_Approvers_name   VARCHAR2 (300);
        L_Item_Key         VARCHAR2 (50);
        L_Item_TYPE        VARCHAR2 (50) := 'LSUONBDR';
    BEGIN
        IF P_PLACE = 'PSRR'
        THEN
            FOR i
                IN --            (SELECT DISTINCT '(' || wc.TO_USER || ')' TO_USER
                --                  FROM wf_notifications note, WF_COMMENTS wc
                                            --                 WHERE     1 = 1
             --                       AND wc.NOTIFICATION_ID = note.NOTIFICATION_ID
                            --                       AND (note.MESSAGE_TYPE) =
                           --                           (SELECT pros.ITEM_TYPE
--                              FROM LOTC_PROSPECTIVE_SUPPLIER_REG pros
--                             WHERE pros.REGI_REQUEST_NUMBER = P_REG_REQ_NUM)
                                --                       AND (note.ITEM_KEY) =
                            --                           (SELECT pros.ITEM_KEY
--                              FROM LOTC_PROSPECTIVE_SUPPLIER_REG pros
--                             WHERE pros.REGI_REQUEST_NUMBER = P_REG_REQ_NUM)
                                 --                       AND STATUS = 'OPEN')
             (SELECT DISTINCT '(' || TO_USER || ')' TO_USER
                FROM wf_notifications
               WHERE     MESSAGE_TYPE = L_Item_TYPE
                     AND ITEM_KEY =
                         (SELECT pros.ITEM_KEY
                            FROM LOTC_PROSPECTIVE_SUPPLIER_REG pros
                           WHERE pros.REGI_REQUEST_NUMBER = P_REG_REQ_NUM)
                     AND MORE_INFO_ROLE IS NULL
                     AND STATUS = 'OPEN'
              UNION ALL
              SELECT DISTINCT '(' || display_name || ')' TO_USER
                FROM wf_notifications wn, WF_Roles wf
               WHERE     Wn.more_info_role = wf.name
                     AND wn.MESSAGE_TYPE = L_Item_TYPE
                     AND wn.ITEM_KEY =
                         (SELECT pros.ITEM_KEY
                            FROM LOTC_PROSPECTIVE_SUPPLIER_REG pros
                           WHERE pros.REGI_REQUEST_NUMBER = P_REG_REQ_NUM)
                     AND wn.MORE_INFO_ROLE IS NOT NULL
                     AND wn.STATUS = 'OPEN')
            LOOP
                IF L_Approvers_name IS NULL
                THEN
                    L_Approvers_name := i.to_user;
                ELSIF L_Approvers_name IS NOT NULL
                THEN
                    L_Approvers_name := L_Approvers_name || ',' || i.to_user;
                END IF;
            END LOOP;
        ELSIF P_PLACE = 'SOBR'
        THEN
            BEGIN
                --                SELECT CASE
                --                           WHEN (SELECT TO_USER
                --                                               FROM wf_notifications
                --                                              WHERE     MESSAGE_TYPE =
                --                                                        L_Item_TYPE
                --                                                    AND ITEM_KEY = P_ITEM_KEY
                --                                                    AND MORE_INFO_ROLE
                --                                                            IS NULL
                --                                                    AND STATUS = 'OPEN'
                --                                                    AND ROWNUM = 1)
                --                                    IS NOT NULL and (SELECT TO_USER
                --                                               FROM wf_notifications
                --                                              WHERE     MESSAGE_TYPE =
                --                                                        L_Item_TYPE
                --                                                    AND ITEM_KEY = P_ITEM_KEY
                --                                                    AND MORE_INFO_ROLE
                --                                                            IS NULL
                --                                                    AND STATUS = 'OPEN'
                --                                                    AND ROWNUM = 1) not like '%,%'
                --                           THEN
                --                               (SELECT FULL_NAME
                --                                   FROM fnd_user fu, per_all_people_f ppf
                --                                  WHERE     fu.employee_id = ppf.person_id
                --                                        AND USER_NAME =(SELECT TO_USER
                --                                              FROM wf_notifications
                --                                             WHERE     MESSAGE_TYPE =
                --                                                       L_Item_TYPE
                --                                                   AND ITEM_KEY = P_ITEM_KEY
                --                                                   AND MORE_INFO_ROLE IS NULL
                --                                                   AND STATUS = 'OPEN'
                --                                                   AND ROWNUM = 1))
                --                            WHEN  (SELECT TO_USER
                --                                               FROM wf_notifications
                --                                              WHERE     MESSAGE_TYPE =
                --                                                        L_Item_TYPE
                --                                                    AND ITEM_KEY = P_ITEM_KEY
                --                                                    AND MORE_INFO_ROLE
                --                                                            IS NULL
                --                                                    AND STATUS = 'OPEN'
                --                                                    AND ROWNUM = 1)
                --                                    IS NOT NULL and (SELECT TO_USER
                --                                               FROM wf_notifications
                --                                              WHERE     MESSAGE_TYPE =
                --                                                        L_Item_TYPE
                --                                                    AND ITEM_KEY = P_ITEM_KEY
                --                                                    AND MORE_INFO_ROLE
                --                                                            IS NULL
                --                                                    AND STATUS = 'OPEN'
                --                                                    AND ROWNUM = 1) like '%,%'
                --                           THEN
                --                               ((SELECT TO_USER
                --                                              FROM wf_notifications
                --                                             WHERE     MESSAGE_TYPE =
                --                                                       L_Item_TYPE
                --                                                   AND ITEM_KEY = P_ITEM_KEY
                --                                                   AND MORE_INFO_ROLE IS NULL
                --                                                   AND STATUS = 'OPEN'
                --                                                   AND ROWNUM = 1))
                --WHEN (SELECT TO_USER
                --                                               FROM wf_notifications
                --                                              WHERE     MESSAGE_TYPE =
                --                                                        L_Item_TYPE
                --                                                    AND ITEM_KEY = P_ITEM_KEY
                --                                                    AND STATUS = 'OPEN'
                --                                                    AND ROWNUM = 1)
                --                                    IS NOT NULL and (SELECT TO_USER
                --                                               FROM wf_notifications
                --                                              WHERE     MESSAGE_TYPE =
                --                                                        L_Item_TYPE
                --                                                    AND ITEM_KEY = P_ITEM_KEY
                --                                                    AND STATUS = 'OPEN'
                --                                                    AND ROWNUM = 1) not like '%,%'
                --                           THEN
                --                               (SELECT FULL_NAME
                --                                   FROM fnd_user fu, per_all_people_f ppf
                --                                  WHERE     fu.employee_id = ppf.person_id
                --                                        AND USER_NAME =(SELECT TO_USER
                --                                              FROM wf_notifications
                --                                             WHERE     MESSAGE_TYPE =
                --                                                       L_Item_TYPE
                --                                                   AND ITEM_KEY = P_ITEM_KEY
                --                                                   AND STATUS = 'OPEN'
                --                                                   AND ROWNUM = 1))
                --                            WHEN  (SELECT TO_USER
                --                                               FROM wf_notifications
                --                                              WHERE     MESSAGE_TYPE =
                --                                                        L_Item_TYPE
                --                                                    AND ITEM_KEY = P_ITEM_KEY
                --                                                    AND STATUS = 'OPEN'
                --                                                    AND ROWNUM = 1)
                --                                    IS NOT NULL and (SELECT TO_USER
                --                                               FROM wf_notifications
                --                                              WHERE     MESSAGE_TYPE =
                --                                                        L_Item_TYPE
                --                                                    AND ITEM_KEY = P_ITEM_KEY
                --                                                    AND MORE_INFO_ROLE
                --                                                            IS NULL
                --                                                    AND STATUS = 'OPEN'
                --                                                    AND ROWNUM = 1) like '%,%'
                --                           THEN
                --                               ((SELECT TO_USER
                --                                              FROM wf_notifications
                --                                             WHERE     MESSAGE_TYPE =
                --                                                       L_Item_TYPE
                --                                                   AND ITEM_KEY = P_ITEM_KEY
                --                                                   AND STATUS = 'OPEN'
                --                                                   AND ROWNUM = 1))
                ----                           WHEN (SELECT FULL_NAME
                ----                                   FROM fnd_user fu, per_all_people_f ppf
                ----                                  WHERE     fu.employee_id = ppf.person_id
                ----                                        AND USER_NAME =
                ----                                            (SELECT TO_USER
                ----                                               FROM wf_notifications
                ----                                              WHERE     MESSAGE_TYPE =
                ----                                                        L_Item_TYPE
                ----                                                    AND ITEM_KEY = P_ITEM_KEY
                ----                                                    AND MORE_INFO_ROLE
                ----                                                            IS NULL
                ----                                                    AND STATUS = 'OPEN'
                ----                                                    AND ROWNUM = 1))
                ----                                    IS NOT NULL
                ----                           THEN
                ----                               (SELECT FULL_NAME
                ----                                  FROM fnd_user fu, per_all_people_f ppf
                ----                                 WHERE     fu.employee_id = ppf.person_id
                ----                                       AND USER_NAME =
                ----                                           (SELECT TO_USER
                ----                                              FROM wf_notifications
                ----                                             WHERE     MESSAGE_TYPE =
                ----                                                       L_Item_TYPE
                ----                                                   AND ITEM_KEY = P_ITEM_KEY
                ----                                                   AND MORE_INFO_ROLE IS NULL
                ----                                                   AND STATUS = 'OPEN'
                ----                                                   AND ROWNUM = 1))
                ----                           WHEN (SELECT FULL_NAME
                ----                                   FROM fnd_user fu, per_all_people_f ppf
                ----                                  WHERE     fu.employee_id = ppf.person_id
                ----                                        AND USER_NAME =
                ----                                            (SELECT display_name
                ----                                               FROM wf_notifications  wn,
                ----                                                    WF_Roles          wf
                ----                                              WHERE     Wn.more_info_role =
                ----                                                        wf.name
                ----                                                    AND wn.MESSAGE_TYPE =
                ----                                                        L_Item_TYPE
                ----                                                    AND wn.ITEM_KEY =
                ----                                                        P_ITEM_KEY
                ----                                                    AND wn.MORE_INFO_ROLE
                ----                                                            IS NOT NULL
                ----                                                    AND wn.STATUS = 'OPEN'
                ----                                                    AND ROWNUM = 1))
                ----                                    IS NULL
                ----                           THEN
                ----                               (SELECT display_name
                ----                                  FROM wf_notifications wn, WF_Roles wf
                ----                                 WHERE     Wn.more_info_role = wf.name
                ----                                       AND wn.MESSAGE_TYPE = L_Item_TYPE
                ----                                       AND wn.ITEM_KEY = P_ITEM_KEY
                ----                                       AND wn.MORE_INFO_ROLE IS NOT NULL
                ----                                       AND wn.STATUS = 'OPEN'
                ----                                       AND ROWNUM = 1)
                --                           ELSE
                --                               (SELECT FULL_NAME
                --                                  FROM fnd_user fu, per_all_people_f ppf
                --                                 WHERE     fu.employee_id = ppf.person_id
                --                                       AND USER_NAME =
                --                                           (SELECT TO_USER
                --                                              FROM wf_notifications
                --                                             WHERE     MESSAGE_TYPE =
                --                                                       L_Item_TYPE
                --                                                   AND ITEM_KEY = P_ITEM_KEY
                --                                                   AND MORE_INFO_ROLE IS NULL
                --                                                   AND STATUS = 'OPEN'
                --                                                   AND ROWNUM = 1))
                --                       END
                --                  INTO L_Approvers_name
                --                  FROM DUAL;



                SELECT CASE
                           WHEN MORE_INFO_ROLE IS NOT NULL
                           THEN
                               (SELECT FULL_NAME
                                  FROM FND_USER FU, PER_ALL_PEOPLE_F PPF
                                 WHERE     FU.employee_id = ppf.person_id
                                       AND fu.USER_NAME = MORE_INFO_ROLE
                                       AND ROWNUM = 1)
                           WHEN TO_USER IS NOT NULL AND TO_USER LIKE '%,%'
                           THEN
                               TO_USER
                           WHEN     TO_USER IS NOT NULL
                                AND TO_USER NOT LIKE '%,%'
                           THEN
                               (SELECT FULL_NAME
                                  FROM FND_USER FU, PER_ALL_PEOPLE_F PPF
                                 WHERE     FU.employee_id = ppf.person_id
                                       AND fu.USER_NAME = TO_USER
                                       AND ROWNUM = 1)
                           ELSE
                               NULL
                       END
                  INTO L_Approvers_name
                  FROM wf_notifications
                 WHERE MESSAGE_TYPE = L_Item_TYPE AND ITEM_KEY = P_ITEM_KEY;
            EXCEPTION
                WHEN OTHERS
                THEN
                    L_Approvers_name := NULL;
            END;
        ELSE
            L_Approvers_name := NULL;
        END IF;

        RETURN L_Approvers_name;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END PENDING_WITH;

    PROCEDURE WRITE_CUST_LOG (RECORD_ID    IN VARCHAR2,
                              P_LOG_TYPE   IN VARCHAR2,
                              P_LOG_TEXT   IN VARCHAR2)
    AS
        L_SEQ_ID          NUMBER;
        L_OVERFLOW_FLAG   VARCHAR2 (30);
        L_ERROR_MSG       VARCHAR2 (4000);

        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        BEGIN
            SELECT LOTC.LOTC_SUP_ONBDR_CUST_LOG_S.NEXTVAL
              INTO L_SEQ_ID
              FROM DUAL;
        EXCEPTION
            WHEN OTHERS
            THEN
                L_SEQ_ID := -1;
        END;

        BEGIN
            IF (LENGTH (P_LOG_TEXT) > 3990)
            THEN
                L_OVERFLOW_FLAG := '..';
            END IF;

            L_ERROR_MSG := SUBSTR (P_LOG_TEXT, 1, 3990) || L_OVERFLOW_FLAG;

            INSERT INTO LOTC.LOTC_SUP_ONBDR_CUST_LOG (RECORD_ID,
                                                      LOG_TYPE,
                                                      SEQ,
                                                      LOG_TEXT,
                                                      USER_ID,
                                                      CREATION_DATE)
                 VALUES (RECORD_ID,
                         P_LOG_TYPE,
                         L_SEQ_ID,
                         L_ERROR_MSG,
                         FND_GLOBAL.USER_ID,
                         SYSDATE);

            COMMIT;
        EXCEPTION
            WHEN OTHERS
            THEN
                L_ERROR_MSG := 'Error in Logging' || SQLERRM;

                INSERT INTO LOTC.LOTC_SUP_ONBDR_CUST_LOG (RECORD_ID,
                                                          LOG_TYPE,
                                                          SEQ,
                                                          LOG_TEXT,
                                                          USER_ID,
                                                          CREATION_DATE)
                     VALUES (RECORD_ID,
                             'LOTC_SUP_ONBDR_CUST_LOG',
                             L_SEQ_ID,
                             L_ERROR_MSG,
                             FND_GLOBAL.USER_ID,
                             SYSDATE);

                COMMIT;
        END;
    END WRITE_CUST_LOG;
/*     PROCEDURE CHECK_VENDOR_TYPE (P_REQ_NUM   IN     VARCHAR2,
                                 P_USER_ID   IN     VARCHAR2,
                                 P_RETURN       OUT VARCHAR2)
    AS
        vValidUser   VARCHAR2 (1) := 'N';
        vSubmitted   VARCHAR2 (1) := NULL;
    BEGIN
        BEGIN
            SELECT SUBMITTED
              INTO vSubmitted
              FROM LOTC_PROSPECTIVE_SUPPLIER_REG
             WHERE REGI_REQUEST_NUMBER = p_req_num;
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    123,
                    'CHECK_VENDOR_TYPE',
                       'p_req_num  -->'
                    || p_req_num
                    || '   P_USER_ID  --> '
                    || P_USER_ID
                    || '   Error submit validation --> '
                    || SQLERRM);
                vSubmitted := NULL;
        END;

        IF P_USER_ID = 6 AND vSubmitted IS NULL
        THEN
            P_RETURN := 'Y';
        ELSIF P_USER_ID != 6 AND vSubmitted IS NULL
        THEN
            BEGIN
                SELECT 'Y'
                  INTO vValidUser
                  FROM LOTC.LOTC_SUPP_ONBOARD_REQUEST  OBDR,
                       PER_ALL_PEOPLE_F                PPF,
                       FND_USER                        FU
                 WHERE     1 = 1
                       AND REGI_REQUEST_NUMBER = p_req_num
                       AND USER_ID = p_user_id
                       AND SUPPLIER_TYPE IN
                               ('Charity', 'Government Organization')
                       AND ppf.PERSON_ID = fu.EMPLOYEE_ID
                       AND SYSDATE BETWEEN ppf.EFFECTIVE_START_DATE
                                       AND NVL (ppf.EFFECTIVE_END_DATE,
                                                SYSDATE)
                       AND ROWNUM = 1;

                P_RETURN := vValidUser;
            EXCEPTION
                WHEN OTHERS
                THEN
                    WRITE_CUST_LOG (
                        123,
                        'CHECK_VENDOR_TYPE',
                           'p_req_num  -->'
                        || p_req_num
                        || '   P_USER_ID  --> '
                        || P_USER_ID
                        || '   Error in user validation --> '
                        || SQLERRM);
                    P_RETURN := 'N';
            END;
        ELSE
            P_RETURN := 'N';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            P_RETURN := 'N';
            WRITE_CUST_LOG (
                123,
                'CHECK_VENDOR_TYPE',
                   'p_req_num  -->'
                || p_req_num
                || '   P_USER_ID  --> '
                || P_USER_ID
                || '  outter most exception  --> '
                || SQLERRM);
    END CHECK_VENDOR_TYPE; */
END LOGI_SUPP_ONBRD_PKG;
/
