-- CERINTA 10 PROIECT

-- 10. Definiți un trigger de tip LMD la nivel de comandă. Declanșați trigger-ul.

-- trigger la nivel de comanda!!! se executa o singura data per comanda
-- audiez toate critice pe tabelul CAZ

-- IMPLEMENTARE!!
-- creez o tabla pentru a salva audit ul pentru cazuri
CREATE TABLE audit_cazuri (
    id_audit NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tip_operatie VARCHAR2(10) NOT NULL, -- pt INSERT/UPDATE/DELETE
    nume_tabel VARCHAR2(50) DEFAULT 'CAZ',
    utilizator VARCHAR2(100),
    data_operatie TIMESTAMP DEFAULT SYSTIMESTAMP,
    detalii_operatie VARCHAR2(500),
    CONSTRAINT ck_tip_operatie CHECK (tip_operatie IN ('INSERT', 'UPDATE', 'DELETE'))
);

-- trigger ul efectiv la nivel de comanda
CREATE OR REPLACE TRIGGER trigger_audit_cazuri
    AFTER INSERT OR UPDATE OR DELETE ON CAZ
DECLARE
    v_tip_operatie VARCHAR2(10);
    v_detalii VARCHAR2(500);
    v_user VARCHAR2(100);
BEGIN
    -- determin tipul de operatie
    IF INSERTING THEN
        v_tip_operatie := 'INSERT';
        v_detalii := 'Cazuri noi adaugate in sistem';
    ELSIF UPDATING THEN
        v_tip_operatie := 'UPDATE';
        v_detalii := 'Cazuri existente modificate';
    ELSIF DELETING THEN
        v_tip_operatie := 'DELETE';
        v_detalii := 'Cazuri sterse din sistem';
    END IF;

    -- preluez informatiile legale de utilizator
    v_user := USER;  -- utilizatorul curent

    -- inregistrez in tabela de audit
    INSERT INTO audit_cazuri (
        tip_operatie,
        utilizator,
        detalii_operatie
    ) VALUES (v_tip_operatie,v_user,v_detalii);

    -- afisez un mesaj
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE(' **** REZULTATE TRIGGER **** ');
    DBMS_OUTPUT.PUT_LINE('  -->> Operatie: ' || v_tip_operatie);
    DBMS_OUTPUT.PUT_LINE('  -->> Utilizator: ' || v_user);
    DBMS_OUTPUT.PUT_LINE('  -->> Data: ' || TO_CHAR(SYSTIMESTAMP, 'DD-MON-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('  -->> Tabel: CAZ');
    DBMS_OUTPUT.PUT_LINE('  -->> Status: Inregistrat in audit');
    DBMS_OUTPUT.PUT_LINE('');

EXCEPTION
    WHEN OTHERS THEN
        -- nu opresc operatia principala daca audit ul esueaza
        -- nu fac nici RAISE ca sa nu blochez operatia principala
        DBMS_OUTPUT.PUT_LINE('ATENTIE: Eroare la inregistrare audit: ' || SQLERRM);
END trigger_audit_cazuri;

-- verific trigger ul creat
SELECT trigger_name, trigger_type, triggering_event, table_name, status
FROM user_triggers
WHERE trigger_name = 'TRIGGER_AUDIT_CAZURI';

-- teste pentru trigger!!!
-- test 1: caz de inserare a unui caz
INSERT INTO CAZ (
    id_departament, numar_caz, tip_caz, prioritate_caz, status_caz,
    data_incidentului, data_raportare, data_deschidere_caz, oras, tara
) VALUES (
    1, 'TRG-TEST-001', 'Test Trigger Insert Simple', 'medie', 'activ',
    SYSTIMESTAMP, SYSTIMESTAMP, SYSDATE, 'Bucuresti', 'Romania'
);

-- verific auditul
SELECT id_audit, tip_operatie, utilizator,
       TO_CHAR(data_operatie, 'DD-MON-YYYY HH24:MI:SS') AS data,
       detalii_operatie
FROM audit_cazuri
ORDER BY id_audit DESC
FETCH FIRST 1 ROW ONLY;

-- test 2: caz de inserare multipla, pt a demonstra ca triggerul se activeaza o singura data pt toata comanda
INSERT INTO CAZ (
    id_departament, numar_caz, tip_caz, prioritate_caz, status_caz,
    data_incidentului, data_raportare, data_deschidere_caz, oras, tara
)
SELECT
    1 + MOD(LEVEL, 2),
    'TRG-TEST-' || LPAD(1 + LEVEL, 3, '0'),
    'Test Trigger Insert Multiplu ' || LEVEL,
    CASE MOD(LEVEL, 3)
        WHEN 0 THEN 'medie'
        WHEN 1 THEN 'ridicata'
        ELSE 'critica'
    END,
    'activ',
    SYSTIMESTAMP - INTERVAL '1' DAY * LEVEL,
    SYSTIMESTAMP - INTERVAL '1' HOUR * LEVEL,
    SYSDATE,
    CASE MOD(LEVEL, 3)
        WHEN 0 THEN 'Bucuresti'
        WHEN 1 THEN 'Cluj-Napoca'
        ELSE 'Timisoara'
    END,
    'Romania'
FROM dual
CONNECT BY LEVEL <= 3;

-- verific auditul
SELECT id_audit, tip_operatie, utilizator,
       TO_CHAR(data_operatie, 'DD-MON-YYYY HH24:MI:SS') AS data
FROM audit_cazuri
ORDER BY id_audit DESC
FETCH FIRST 2 ROWS ONLY;

-- test 3: caz de update multiplu (trigger tot o singura data)
UPDATE CAZ
SET status_caz = 'suspendat',
    prioritate_caz = 'urgenta maxima'
WHERE numar_caz LIKE 'TRG-TEST%';

-- verificare audit
SELECT id_audit, tip_operatie, utilizator, detalii_operatie
FROM audit_cazuri
WHERE tip_operatie = 'UPDATE'
ORDER BY id_audit DESC
FETCH FIRST 1 ROW ONLY;

-- test 4: caz de delete
DELETE FROM CAZ
WHERE numar_caz LIKE 'TRG-TEST-001';

-- verificare audit
SELECT id_audit, tip_operatie, utilizator, detalii_operatie
FROM audit_cazuri
WHERE tip_operatie = 'DELETE'
ORDER BY id_audit DESC
FETCH FIRST 1 ROW ONLY;

-- test 5: caz de delete pentru linii multiple
DELETE FROM CAZ
WHERE numar_caz BETWEEN 'TRG-TEST-002' AND 'TRG-TEST-004';

-- verificare audit
SELECT id_audit, tip_operatie, utilizator,
       TO_CHAR(data_operatie, 'DD-MON-YYYY HH24:MI:SS') AS data_operatie
FROM audit_cazuri
WHERE tip_operatie = 'DELETE'
ORDER BY id_audit DESC
FETCH FIRST 2 ROWS ONLY;

-- statistici complete
SELECT
    tip_operatie,
    COUNT(*) AS numar_operatii,
    MIN(data_operatie) AS prima_operatie,
    MAX(data_operatie) AS ultima_operatie,
    utilizator
FROM audit_cazuri
GROUP BY tip_operatie, utilizator
ORDER BY ultima_operatie DESC;

-- istoric complet operatii de la audit
SELECT
    id_audit,
    tip_operatie,
    TO_CHAR(data_operatie, 'DD-MON-YYYY HH24:MI:SS') AS data_operatie,
    utilizator,
    detalii_operatie
FROM audit_cazuri
ORDER BY data_operatie DESC;

COMMIT;