create or replace package apps.xxesh_contract_approval_pkg as
procedure start_wf (pItemKey varchar2);
procedure derive_approvers (itemtype   IN            VARCHAR2,
							itemkey    IN            VARCHAR2,
							actid      IN            NUMBER,
							funcmode   IN            VARCHAR2,
							result        OUT NOCOPY VARCHAR2);
procedure write_cust_log (record_id    IN VARCHAR2,
						  p_log_type   IN VARCHAR2,
						  p_log_text   IN VARCHAR2);
end xxesh_contract_approval_pkg;

xxesh_contract_headers_t


    PROCEDURE START_WF (pItemKey VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        vItemType            VARCHAR2 (30) := 'ESHCOAPP';
        vProcess             VARCHAR2 (50) := 'CONTRACT_MAIN_PROCESS';
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

--        Wf_Engine.setitemattrdocument (
                -- vItemType,
                -- pItemKey,
                -- 'EXCEL_ATTACHEMENT',
                   -- 'FND:entity=  &pk1name=  &pk1value='
                -- || vPrimaryKey); 
        EXCEPTION
            WHEN OTHERS
            THEN
                WRITE_CUST_LOG (
                    pItemKey,
                    'LFTP_SUPP_ONBRD_PKG.DERIVE_APPROVERS',
                    'vPrimaryKey derivation issue -->' || SQLERRM);
        END;

        -- Wf_Engine.SetItemAttrText (vItemType,
                                   -- pItemKey,
                                   -- 'REQUEST_NUMBER',
                                   -- vRequestNumber);

        Wf_Engine.StartProcess (itemType => vItemType, itemKey => pItemKey);
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            vsqlerrm := SUBSTR (SQLERRM, 1, 100);
            COMMIT;
    END START_WF;
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
	