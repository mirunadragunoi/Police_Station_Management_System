-- CERINTA 12 PROIECT

-- 12. Definiți un trigger de tip LDD. Declanșați trigger-ul.

-- trigger de tip LDD
-- OPERATII LDD --->> CREATE, ALTER, DROP, TRUNCATE

-- CERINTA IN LIMBAJ NATURAL>
-- sa se monitorizeze si audieze toate modificarile structurale, adica operatii de tip LDD
-- protectie pentru modificari stricturale pe anumite tabele

-- IMPLEMENTARE!!!
-- creez o tabela speciala pt audit
CREATE TABLE audit_operatii_ldd (
    id_audit NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    utilizator VARCHAR2(100),
    eveniment VARCHAR2(50),
    nume_obiect VARCHAR2(200),
    tip_obiect VARCHAR2(50),
    data TIMESTAMP,
    status VARCHAR2(20),
    mesaj VARCHAR2(1000)
);

-- creez niste tabele neprotejate pe test
CREATE TABLE test_tabel_1 (
    id NUMBER PRIMARY KEY,
    nume VARCHAR2(100),
    data_creare DATE DEFAULT SYSDATE
);

CREATE TABLE test_tabel_2 (
    id NUMBER PRIMARY KEY,
    descriere VARCHAR2(200),
    status VARCHAR2(20) DEFAULT 'activ'
);

-- populare cu cateva date de test
INSERT INTO test_tabel_1 VALUES (1, 'Test 1', SYSDATE);
INSERT INTO test_tabel_1 VALUES (2, 'Test 2', SYSDATE);
INSERT INTO test_tabel_2 VALUES (1, 'Descriere 1', 'activ');
INSERT INTO test_tabel_2 VALUES (2, 'Descriere 2', 'activ');
COMMIT;

-- creez o procedura pt audit
-- +++ folosesc PRAGMA AUTONOMOUS_TRANSACTION pt tranzatia independenta
CREATE OR REPLACE PROCEDURE proc_audit_operatii_ldd (
    p_eveniment VARCHAR2,
    p_obiect VARCHAR2,
    p_tip_obiect VARCHAR2,
    p_status VARCHAR2,
    p_mesaj VARCHAR2
) AS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO audit_operatii_ldd (
        utilizator,
        eveniment,
        nume_obiect,
        tip_obiect,
        data,
        status,
        mesaj
    ) VALUES (
        USER,
        p_eveniment,
        p_obiect,
        p_tip_obiect,
        SYSTIMESTAMP,
        p_status,
        p_mesaj
    );
    COMMIT;  -- commit independent

    -- afisare mesaje
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.PUT_LINE(' ****  AUDIT OPERATII LDD INREGISTRAT  *****');
    DBMS_OUTPUT.PUT_LINE('  --->> Eveniment: ' || p_eveniment);
    DBMS_OUTPUT.PUT_LINE('  --->> Obiect: ' || p_obiect);
    DBMS_OUTPUT.PUT_LINE('  --->> Status: ' || p_status);
    DBMS_OUTPUT.PUT_LINE('  --->> Mesaj: ' || p_mesaj);
    DBMS_OUTPUT.PUT_LINE('');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('EROARE la audit: ' || SQLERRM);
        RAISE;
END proc_audit_operatii_ldd;

-- creez un trigger LDD cu protectie pe tabelele critice
CREATE OR REPLACE TRIGGER trigger_ldd_protectie
    AFTER CREATE OR ALTER OR DROP OR TRUNCATE ON SCHEMA
DECLARE
    v_eveniment VARCHAR2(50);
    v_obiect VARCHAR2(200);
    v_tip_obiect VARCHAR2(50);
    v_status VARCHAR2(20);
    v_mesaj VARCHAR2(1000);
    v_blocat BOOLEAN := FALSE;

    -- fac o lista cu tabelele critice protejate care nu pot fi modificate cu DROP TRUNCATE
    TYPE t_tabele_critice IS TABLE OF VARCHAR2(100);
    v_tabele_critice t_tabele_critice := t_tabele_critice(
        'SECTIE_POLITIE',
        'SPECIALIZARE',
        'DEPARTAMENT',
        'OFITER',
        'CAZ',
        'PROBA',
        'SUSPECT',
        'VICTIMA',
        'CAZ_SUSPECT',
        'CAZ_VICTIMA'
    );

BEGIN
    -- preluez informatiile
    v_eveniment := SYS.SYSEVENT;
    v_obiect := SYS.DICTIONARY_OBJ_NAME;
    v_tip_obiect := SYS.DICTIONARY_OBJ_TYPE;

    -- verific operatiile periculoase pe tabelele critice
    IF (v_eveniment = 'DROP' OR v_eveniment = 'TRUNCATE') THEN
        -- verific daca obiectul este in lista tabelelor critice
        FOR i IN 1..v_tabele_critice.COUNT LOOP
            IF UPPER(v_obiect) = UPPER(v_tabele_critice(i)) THEN
                v_blocat := TRUE;
                v_status := 'BLOCAT';
                v_mesaj := 'SECURITATE: Operatia ' || v_eveniment ||
                          ' pe tabelul CRITIC "' || v_obiect ||
                          '" este INTERZISA!';
                EXIT;  -- opresc cautarea
            END IF;
        END LOOP;

        -- daca nu e blocat, atunci este permis si se pot efectua operatiile
        IF NOT v_blocat THEN
            v_status := 'PERMIS';
            v_mesaj := 'Operatie ' || v_eveniment || ' permisa pe obiect necritic: ' || v_obiect;
        END IF;

    ELSE
        -- CREATE SI ALTER sunt permise
        v_status := 'PERMIS';
        v_mesaj := 'Operatie DDL standard: ' || v_eveniment || ' ' ||
                   v_tip_obiect || ' ' || v_obiect;
    END IF;

    -- inregistrez in audit mereu!!!
    proc_audit_operatii_ldd(
        p_eveniment => v_eveniment,
        p_obiect => v_obiect,
        p_tip_obiect => v_tip_obiect,
        p_status => v_status,
        p_mesaj => v_mesaj
    );

    -- blochez operatia daca e marcata ca blocata
    IF v_blocat THEN
        RAISE_APPLICATION_ERROR(-20999, v_mesaj);
    END IF;

END trigger_ldd_protectie;

-- verific daca triggerul a fost creat corect
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN ('TRIGGER_LDD_PROTECTIE', 'PROC_AUDIT_OPERATII_LDD', 'AUDIT_OPERATII_LDD')
ORDER BY object_type, object_name;

-- teste!!!!
-- test 1 -->> create table -- operatie permisa si audiata
CREATE TABLE test_creare_politie (
    id NUMBER PRIMARY KEY,
    data_creare TIMESTAMP DEFAULT SYSTIMESTAMP,
    descriere VARCHAR2(100)
);

-- verific audit
SELECT eveniment, nume_obiect, status, mesaj
FROM audit_operatii_ldd
WHERE nume_obiect = 'TEST_CREARE_POLITIE';

-- test 2 --->> alter table pe tabel permis
ALTER TABLE test_tabel_1 ADD (
    data_modificare TIMESTAMP,
    status VARCHAR2(20) DEFAULT 'activ'
);

-- test 3 -->> creare index operatie permisa
CREATE INDEX idx_test_politie ON test_tabel_1(nume);

-- verific audit
SELECT eveniment, nume_obiect, tip_obiect, status
FROM audit_operatii_ldd
WHERE nume_obiect = 'IDX_TEST_POLITIE';

-- test 4 -->> truncate pe tabel neprotejat, PERMIS
TRUNCATE TABLE test_tabel_2;

-- verificare audit
SELECT eveniment, nume_obiect, status, mesaj
FROM audit_operatii_ldd
WHERE nume_obiect = 'TEST_TABEL_2';

-- test 5 -->> drop pe tabel neprotejat, deci permis
DROP TABLE test_tabel_2;

-- verificare audit
SELECT eveniment, nume_obiect, status, mesaj
FROM audit_operatii_ldd
WHERE nume_obiect = 'TEST_TABEL_2'
ORDER BY data;

-- test 6 -->> drop pe tabel protejat, caz in care operatia va fi blocata
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CAZ';
    DBMS_OUTPUT.PUT_LINE(' !!!! EROARE: Nu ar fi trebuit sa ajunga aici!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('!!!! OPERATIE BLOCATA !!!!');
        DBMS_OUTPUT.PUT_LINE('Mesaj: ' || SQLERRM);
END;

-- verificare daca operatia blocata a ajuns in audit
SELECT eveniment, nume_obiect, status, mesaj
FROM audit_operatii_ldd
WHERE nume_obiect = 'CAZ'
ORDER BY data DESC;

-- test 7 --->> truncate pe tabel protejat, caz in care operatia va fi blocata
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE PROBA';
    DBMS_OUTPUT.PUT_LINE('!!!! EROARE: Nu ar fi trebuit sa ajunga aici!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('!!!! OPERATIE BLOCATA !!!!');
        DBMS_OUTPUT.PUT_LINE('Mesaj: ' || SQLERRM);
END;

-- verificare audit
SELECT eveniment, nume_obiect, status, mesaj
FROM audit_operatii_ldd
WHERE nume_obiect = 'PROBA'
ORDER BY data DESC;

-- test 8 --->> drop pe tabel protejat
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE SUSPECT';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' !!!! BLOCAT SUSPECT: ' || SQLERRM);
END;

-- test 9 --->> truncate pe tabel protejat ---BLOCAT
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE DEPARTAMENT';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' !!!! BLOCAT DEPARTAMENT: ' || SQLERRM);
END;

-- raport final --> toate operatiile
SELECT
    id_audit,
    eveniment,
    nume_obiect,
    tip_obiect,
    utilizator,
    TO_CHAR(data, 'DD-MON-YYYY HH24:MI:SS') AS data,
    status,
    SUBSTR(mesaj, 1, 80) AS mesaj
FROM audit_operatii_ldd
ORDER BY data DESC;