    FUNCTION DERIVE_VACATION_RULES (p_item_key         VARCHAR2,
                                    p_orig_approver    VARCHAR2)
        RETURN VARCHAR2
    IS
        l_vac_approver   VARCHAR2 (50);
    BEGIN
        l_vac_approver := NULL;

        SELECT ACTION_ARGUMENT
          INTO l_vac_approver
          FROM WF_ROUTING_RULES
         WHERE     role = p_orig_approver
               AND MESSAGE_TYPE = 'LSUONBDR' -- commented by rvemula as it should work for all item types  30-May-2019  -- Enable the message_type to work vacation rule for Supplier Onbaording alone ITSM-64088
               AND SYSDATE BETWEEN TRUNC (BEGIN_DATE) AND TRUNC (END_DATE);

        --rvemula ITSM-145252 below insert
        INSERT INTO LOTC_SUPP_ONBDR_VACATION_RULES (REGI_REQUEST_NUMBER,
                                                    ITEM_TYPE,
                                                    ITEM_KEY,
                                                    CREATED_BY,
                                                    CREATION_DATE,
                                                    ACTUAL_USER,
                                                    DELEGATED_TO,
                                                    LAST_UPDATED_BY,
                                                    LAST_UPDATE_DATE,
                                                    LAST_UPDATE_LOGIN)
            SELECT SUBSTR (p_item_key, 1, INSTR (p_item_key, '_', 1) - 1),
                   'LSUONBDR',
                   p_item_key,
                   (SELECT USER_ID
                      FROM fnd_user fu
                     WHERE Fu.USER_NAME = l_vac_approver AND ROWNUM = 1),
                   SYSDATE,
                   p_orig_approver,
                   l_vac_approver,
                   (SELECT USER_ID
                      FROM fnd_user fu
                     WHERE Fu.USER_NAME = l_vac_approver AND ROWNUM = 1),
                   SYSDATE,
                   fnd_global.login_id
              FROM DUAL
             WHERE     1 = 1
                   AND NOT EXISTS
                           (SELECT 1
                              FROM LOTC_SUPP_ONBDR_VACATION_RULES RL1
                             WHERE     1 = 1
                                   AND ITEM_KEY = p_item_key
                                   AND ACTUAL_USER = p_orig_approver
                                   AND DELEGATED_TO = l_vac_approver);

        RETURN l_vac_approver;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN p_orig_approver;
        WHEN OTHERS
        THEN
            --Enable the log for future reference 23-MAY-19
            WRITE_CUST_LOG (p_item_key,
                            'DERIVE_VACATION_RULES',
                            'Error is ' || SQLERRM);
            RETURN p_orig_approver;
    END DERIVE_VACATION_RULES;