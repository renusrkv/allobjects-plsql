CREATE TABLE XX_CUST_LOG
(
    RECORD_ID NUMBER,
    LOG_TYPE VARCHAR2 (100 BYTE),
    SEQ NUMBER,
    LOG_TEXT VARCHAR2 (4000 BYTE),
    USER_ID NUMBER,
    CREATION_DATE DATE
)
/

SHOW ERROR;

CREATE INDEX XX_CUST_LOG_I1
    ON XX_CUST_LOG (RECORD_ID)
    LOGGING
/

SHOW ERROR;


CREATE SEQUENCE XX_CUST_LOG_S MINVALUE 1
                                     MAXVALUE 999999999999999999999999999
                                     START WITH 1
                                     INCREMENT BY 1
                                     CACHE 20
/
SHOW ERROR;

CREATE OR REPLACE SYNONYM APPS.XX_CUST_LOG FOR XX_CUST_LOG
/
SHOW ERROR;

CREATE OR REPLACE SYNONYM APPS.XX_CUST_LOG_S FOR XX_CUST_LOG_S
/
SHOW ERROR;

CREATE OR REPLACE PACKAGE apps.XX_CUST_LOG_PKG
AS
    PROCEDURE WRITE_CUST_LOG (RECORD_ID    IN NUMBER,
                              p_log_type   IN VARCHAR2,
                              p_log_text   IN VARCHAR2);

    PROCEDURE clear_log;
END XX_CUST_LOG_PKG;
/

SHOW ERROR;



CREATE OR REPLACE PACKAGE BODY apps.XX_CUST_LOG_PKG
AS
    PROCEDURE WRITE_CUST_LOG (RECORD_ID    IN NUMBER,
                              P_LOG_TYPE   IN VARCHAR2,
                              P_LOG_TEXT   IN VARCHAR2)
    AS
        L_SEQ_ID          NUMBER;
        L_OVERFLOW_FLAG   VARCHAR2 (30);
        L_ERROR_MSG       VARCHAR2 (4000);
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        BEGIN
            SELECT XX_CUST_LOG_S.NEXTVAL INTO L_SEQ_ID FROM DUAL;
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

            INSERT INTO XX_CUST_LOG (RECORD_ID,
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

                INSERT INTO XX_CUST_LOG (RECORD_ID,
                                                LOG_TYPE,
                                                SEQ,
                                                LOG_TEXT,
                                                USER_ID,
                                                CREATION_DATE)
                     VALUES (RECORD_ID,
                             'XX_CUST_LOG',
                             L_SEQ_ID,
                             L_ERROR_MSG,
                             FND_GLOBAL.USER_ID,
                             SYSDATE);

                COMMIT;
        END;
    END WRITE_CUST_LOG;

    PROCEDURE CLEAR_LOG
    IS
    BEGIN
        BEGIN
            DELETE FROM XX_CUST_LOG
                  WHERE CREATION_DATE < TRUNC (SYSDATE) - 90;

            COMMIT;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;
    END;
END XX_CUST_LOG_PKG;
/

SHOW ERROR;
