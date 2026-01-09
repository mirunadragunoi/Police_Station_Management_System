-- CERINTA 11 PROIECT

-- 11. Definiți un trigger de tip LMD la nivel de linie. Declanșați trigger-ul.

-- TRIGGER LMD LA NIVEL DE LINIE!!!
-- se executa pt fiecare rand afectat
-- are acces la :OLD si :NEW

-- creez un trigger pentru tabela PROBA care sa inregistreze fiecare modificare individuala
-- vreau sa retin valorile vechi si noi ale campurilor importante, tipul operatiei, cine a facut modificarwa si cand,
-- care camp specific a fost modificat pentru cazul de update

-- IMPLEMENTARE!!

-- creez o tabela de audit pentru probe
CREATE TABLE audit_probe_detaliat (
    id_audit_proba NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_proba NUMBER,
    tip_operatie VARCHAR2(10) NOT NULL,
    camp_modificat VARCHAR2(50),
    valoare_veche VARCHAR2(500),
    valoare_noua VARCHAR2(500),
    utilizator VARCHAR2(100),
    data_modificare TIMESTAMP DEFAULT SYSTIMESTAMP,
    numar_evidenta_proba VARCHAR2(100),
    detalii VARCHAR2(500),
    CONSTRAINT ck_audit_proba_tip CHECK (tip_operatie IN ('INSERT', 'UPDATE', 'DELETE'))
);

-- implementarea triggerului la nivel de linie
CREATE OR REPLACE TRIGGER trigger_audit_probe_linie
    AFTER INSERT OR UPDATE OR DELETE ON PROBA
    FOR EACH ROW  -- trigger nivel de linie!!!!
DECLARE
    v_tip_operatie VARCHAR2(10);
    v_utilizator VARCHAR2(100);
    v_numar_evidenta VARCHAR2(100);
BEGIN
    -- determin utilizatorul
    v_utilizator := USER;

    -- determin un numar de evidenta
    IF INSERTING OR UPDATING THEN
        v_numar_evidenta := :NEW.numar_evidenta;
    ELSE
        v_numar_evidenta := :OLD.numar_evidenta;
    END IF;

    -- cazul 1 --->> INSERT pt o proba noua adaugata
    IF INSERTING THEN
        v_tip_operatie := 'INSERT';

        INSERT INTO audit_probe_detaliat (
            id_proba, tip_operatie, camp_modificat,
            valoare_veche, valoare_noua,
            utilizator, numar_evidenta_proba, detalii
        ) VALUES (
            :NEW.id_proba,
            v_tip_operatie,
            'PROBA_NOUA',
            NULL,  -- nu am o valoare veche
            'Nr: ' || :NEW.numar_evidenta || ', Tip: ' || :NEW.tip_proba,
            v_utilizator,
            v_numar_evidenta,
            'Proba noua adaugata in sistem - ' || :NEW.tip_proba
        );

        -- afisare mesaj!!
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('     TRIGGER LINIE: INSERT NOUA PROBA             ');
        DBMS_OUTPUT.PUT_LINE('  -->> ID Proba: ' || :NEW.id_proba);
        DBMS_OUTPUT.PUT_LINE('  -->> Numar evidenta: ' || :NEW.numar_evidenta);
        DBMS_OUTPUT.PUT_LINE('  -->> Tip proba: ' || :NEW.tip_proba);
        DBMS_OUTPUT.PUT_LINE('  -->> Utilizator: ' || v_utilizator);
        DBMS_OUTPUT.PUT_LINE('  *** Audit inregistrat pentru PROBA NOUA ***');
        DBMS_OUTPUT.PUT_LINE('');

    -- cazul 1 --->> UPDATE pt modificarea unei probe existente
    ELSIF UPDATING THEN
        v_tip_operatie := 'UPDATE';
        -- trebuie sa verific fiecare camp important si sa inregistrez modificarile
        -- statusul pentru analiza modificat
        IF :OLD.status_analiza != :NEW.status_analiza OR
           (:OLD.status_analiza IS NULL AND :NEW.status_analiza IS NOT NULL) OR
           (:OLD.status_analiza IS NOT NULL AND :NEW.status_analiza IS NULL) THEN

            INSERT INTO audit_probe_detaliat (
                id_proba, tip_operatie, camp_modificat,
                valoare_veche, valoare_noua,
                utilizator, numar_evidenta_proba, detalii
            ) VALUES (
                :NEW.id_proba,
                v_tip_operatie,
                'status_analiza',
                :OLD.status_analiza,
                :NEW.status_analiza,
                v_utilizator,
                v_numar_evidenta,
                'Status analiza modificat'
            );
        END IF;

        -- rezultat analiza modificat
        IF :OLD.rezultat_analiza != :NEW.rezultat_analiza OR
           (:OLD.rezultat_analiza IS NULL AND :NEW.rezultat_analiza IS NOT NULL) OR
           (:OLD.rezultat_analiza IS NOT NULL AND :NEW.rezultat_analiza IS NULL) THEN

            INSERT INTO audit_probe_detaliat (
                id_proba, tip_operatie, camp_modificat,
                valoare_veche, valoare_noua,
                utilizator, numar_evidenta_proba, detalii
            ) VALUES (
                :NEW.id_proba,
                v_tip_operatie,
                'rezultat_analiza',
                :OLD.rezultat_analiza,
                :NEW.rezultat_analiza,
                v_utilizator,
                v_numar_evidenta,
                'Rezultat analiza actualizat'
            );
        END IF;

        -- conditie proba modificata
        IF :OLD.conditie_proba != :NEW.conditie_proba OR
           (:OLD.conditie_proba IS NULL AND :NEW.conditie_proba IS NOT NULL) OR
           (:OLD.conditie_proba IS NOT NULL AND :NEW.conditie_proba IS NULL) THEN

            INSERT INTO audit_probe_detaliat (
                id_proba, tip_operatie, camp_modificat,
                valoare_veche, valoare_noua,
                utilizator, numar_evidenta_proba, detalii
            ) VALUES (
                :NEW.id_proba,
                v_tip_operatie,
                'conditie_proba',
                :OLD.conditie_proba,
                :NEW.conditie_proba,
                v_utilizator,
                v_numar_evidenta,
                'Conditie proba modificata (posibila deteriorare!)'
            );
        END IF;

        -- proba trimisa in judecata
        IF NVL(:OLD.proba_judecata, 'N') != NVL(:NEW.proba_judecata, 'N') THEN
            INSERT INTO audit_probe_detaliat (
                id_proba, tip_operatie, camp_modificat,
                valoare_veche, valoare_noua,
                utilizator, numar_evidenta_proba, detalii
            ) VALUES (
                :NEW.id_proba,
                v_tip_operatie,
                'proba_judecata',
                :OLD.proba_judecata,
                :NEW.proba_judecata,
                v_utilizator,
                v_numar_evidenta,
                CASE
                    WHEN :NEW.proba_judecata = 'D' THEN 'Proba TRIMISA in judecata'
                    ELSE 'Status judecata modificat'
                END
            );
        END IF;

        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('     TRIGGER LINIE: UPDATE PROBA             ');
        DBMS_OUTPUT.PUT_LINE('  --->> ID Proba: ' || :NEW.id_proba);
        DBMS_OUTPUT.PUT_LINE('  --->> Numar evidenta: ' || :NEW.numar_evidenta);
        DBMS_OUTPUT.PUT_LINE('  --->> Utilizator: ' || v_utilizator);
        DBMS_OUTPUT.PUT_LINE('  ***** Modificari inregistrate in audit *******');
        DBMS_OUTPUT.PUT_LINE('');

    -- cazul 3 --->> DELETE - sterg o proba
    ELSIF DELETING THEN
        v_tip_operatie := 'DELETE';

        INSERT INTO audit_probe_detaliat (
            id_proba, tip_operatie, camp_modificat,
            valoare_veche, valoare_noua,
            utilizator, numar_evidenta_proba, detalii
        ) VALUES (
            :OLD.id_proba,
            v_tip_operatie,
            'PROBA_STEARSA',
            'Nr: ' || :OLD.numar_evidenta || ', Tip: ' || :OLD.tip_proba,
            NULL,
            v_utilizator,
            v_numar_evidenta,
            'ATENTIE: Proba stearsa din sistem! Tip: ' || :OLD.tip_proba
        );

        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('     TRIGGER LINIE: UPDATE PROBA             ');
        DBMS_OUTPUT.PUT_LINE('  --->> ID Proba: ' || :OLD.id_proba);
        DBMS_OUTPUT.PUT_LINE('  --->> Numar evidenta: ' || :OLD.numar_evidenta);
        DBMS_OUTPUT.PUT_LINE('  --->> Tip proba: ' || :OLD.tip_proba);
        DBMS_OUTPUT.PUT_LINE('  --->> Utilizator: ' || v_utilizator);
        DBMS_OUTPUT.PUT_LINE('  ***  ATENTIE: Proba STEARSA din sistem! ****');
        DBMS_OUTPUT.PUT_LINE('');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- nu blochez operatia principala
        DBMS_OUTPUT.PUT_LINE('EROARE in trigger audit probe: ' || SQLERRM);
END trigger_audit_probe_linie;

-- verific daca trigger ul a fost creat cu succes
SELECT trigger_name, trigger_type, triggering_event, table_name, status
FROM user_triggers
WHERE trigger_name = 'TRIGGER_AUDIT_PROBE_LINIE';

-- teste pentru trigger

-- test 1 -> INSERT pt adaugarea de probe noi, se executa pentru fiecare proba
INSERT INTO PROBA (
    id_caz, numar_evidenta, tip_proba, categorie_proba,
    data_colectare, conditie_proba, status_analiza, proba_judecata
) VALUES (
    1, 'PROBE-TEST-001', 'fizica', 'arma',
    SYSDATE, 'intacta', 'in așteptare', 'N'
);

INSERT INTO PROBA (
    id_caz, numar_evidenta, tip_proba, categorie_proba,
    data_colectare, conditie_proba, status_analiza, proba_judecata
) VALUES (
    1, 'PROBE-TEST-002', 'biologica', 'ADN',
    SYSDATE, 'perfect conservata', 'in așteptare', 'N'
);

INSERT INTO PROBA (
    id_caz, numar_evidenta, tip_proba, categorie_proba,
    data_colectare, conditie_proba, status_analiza, proba_judecata
) VALUES (
    2, 'PROBE-TEST-003', 'balistica', 'test',
    SYSDATE, 'intacta', 'nepreluata', 'N'
);

-- verific auditul
SELECT id_audit_proba, id_proba, tip_operatie, camp_modificat,
       numar_evidenta_proba, detalii,
       TO_CHAR(data_modificare, 'HH24:MI:SS') AS ora
FROM audit_probe_detaliat
WHERE tip_operatie = 'INSERT'
ORDER BY id_audit_proba DESC
FETCH FIRST 3 ROWS ONLY;

-- test 2 -->> UPDATE pt modificarea statusului analizei probelor, se executa pt fiecare
UPDATE PROBA
SET status_analiza = 'analizata',
    rezultat_analiza = 'ADN confirmat suspect principal'
WHERE numar_evidenta = 'PROBE-TEST-001';

UPDATE PROBA
SET status_analiza = 'analizata',
    rezultat_analiza = 'Amprenta pozitiva - identificare completa'
WHERE numar_evidenta = 'PROBE-TEST-002';

-- verificare audit pt modificari
SELECT id_audit_proba, id_proba, camp_modificat,
       valoare_veche, valoare_noua, detalii
FROM audit_probe_detaliat
WHERE tip_operatie = 'UPDATE'
  AND numar_evidenta_proba LIKE 'PROBE-TEST%'
ORDER BY id_audit_proba DESC;

-- test 3 ->> UPDATE MULTIPLU - pt trimitere in judecata, se executa pentru fiecare proba trimisa in judecata
UPDATE PROBA
SET proba_judecata = 'D'
WHERE numar_evidenta LIKE 'PROBE-TEST%'
  AND status_analiza = 'analizata';

-- verificare audit
SELECT numar_evidenta, tip_proba, status_analiza, proba_judecata
FROM PROBA
WHERE numar_evidenta LIKE 'PROBE-TEST%'
ORDER BY numar_evidenta;

SELECT id_audit_proba, numar_evidenta_proba, camp_modificat,
       valoare_veche AS inainte, valoare_noua AS dupa, detalii
FROM audit_probe_detaliat
WHERE camp_modificat = 'proba_judecata'
  AND numar_evidenta_proba LIKE 'PROBE-TEST%'
ORDER BY id_audit_proba DESC;

-- test 4 -->> UPDATE pt deteriorare proba
UPDATE PROBA
SET conditie_proba = 'deteriorata partial'
WHERE numar_evidenta = 'PROBE-TEST-003';

-- verificare audit pentru deterioare proba
SELECT id_audit_proba, numar_evidenta_proba, camp_modificat,
       valoare_veche, valoare_noua, detalii,
       TO_CHAR(data_modificare, 'DD-MON-YYYY HH24:MI:SS') AS cand
FROM audit_probe_detaliat
WHERE camp_modificat = 'conditie_proba'
  AND numar_evidenta_proba = 'PROBE-TEST-003'
ORDER BY id_audit_proba DESC;

-- test 5 -->> DELETE - sterg niste probe, se executa pt fiecare proba stearsa
DELETE FROM PROBA
WHERE numar_evidenta IN ('PROBE-TEST-001', 'PROBE-TEST-002');

-- verificare audit
SELECT id_audit_proba, id_proba, numar_evidenta_proba,
       valoare_veche, detalii,
       TO_CHAR(data_modificare, 'DD-MON-YYYY HH24:MI:SS') AS data_stergere
FROM audit_probe_detaliat
WHERE tip_operatie = 'DELETE'
  AND numar_evidenta_proba LIKE 'PROBE-TEST%'
ORDER BY id_audit_proba DESC;

-- curat final datele adaugate pentru testarea cerintei
DELETE FROM PROBA WHERE numar_evidenta LIKE 'PROBE-TEST%';
COMMIT;

-- raport final
SELECT
    id_audit_proba,
    tip_operatie,
    numar_evidenta_proba,
    camp_modificat,
    valoare_veche,
    valoare_noua,
    TO_CHAR(data_modificare, 'DD-MON HH24:MI:SS') AS data_modificare,
    utilizator,
    detalii
FROM audit_probe_detaliat
ORDER BY data_modificare DESC
FETCH FIRST 20 ROWS ONLY;

-- statistici
SELECT
    tip_operatie,
    camp_modificat,
    COUNT(*) AS numar_modificari
FROM audit_probe_detaliat
GROUP BY tip_operatie, camp_modificat
ORDER BY tip_operatie, numar_modificari DESC;
