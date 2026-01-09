-- CERINTA 9 PROIECT

-- 9.Formulați în limbaj natural o problemă pe care să o rezolvați folosind un subprogram stocat independent de tip
-- procedură care să aibă minim 2 parametri și să utilizeze într-o singură comandă SQL 5 dintre tabelele create.
-- Definiți minim 2 excepții proprii, altele decât cele predefinite la nivel de sistem. Apelați subprogramul astfel
-- încât să evidențiați toate cazurile definite și tratate.


-- Cerinta in limbaj natural:
-- Departamentul de coordonare al sectiilor de politie trebuie sa transfere un caz de la un departament la altul
-- (de exemplu, cand un caz devine prea complex si trebuie preluat de un departament specializat). Sistemul trebuie
-- sa valideze urmatoarele aspecte:
-- 1) Ambele departamente (departamentul de sursa si departamentul de destinatie) trebuie sa existe in sistem
-- 2) departamentele intre care este transferat cazul trebuie sa fie din aceeasi sectie de politie (cazurile nu pot
-- fi transferate intre alte sectii de politie, ci doar la nivel de sectie intre departamente interioare)
-- 3) cazul care urmeaza sa fie transferat trebuie sa existe si sa fie in disponibilitate de a fi transferat (sa fie
-- inca activ)
-- 4) departamentul de destinatie sa nu fie deja supraincarcat, in aceasta situatie nu se pot transfera alte cazuri la
-- el (fiecare departament sa aiba un maxim de 10 cazuri active).

-- Dupa aceste validari, sistemul va transfera cazul la departamentul de destinatie, va actualiza statusul cazului si
-- va afisa un rezultat complet al istoricului cazului ce implica: ambele departamente, cazul respectiv, sectia din
-- care face parte, suspectii, victimele si probele.

-- IMPLEMENTARE!!!
CREATE OR REPLACE PROCEDURE transfer_caz_departament(
    p_id_caz IN NUMBER,
    p_id_dept_destinatie IN NUMBER
) AS
    -- exceptii personalizate
    ex_departament_supraincarcat EXCEPTION;
    ex_conflict_sectie EXCEPTION;
    ex_caz_netransferabil EXCEPTION;

    -- variabilele pentru departamentul sursa
    v_id_dept_sursa NUMBER;
    v_nume_dept_sursa VARCHAR2(150);
    v_id_sectie_sursa NUMBER;

    -- declarare variabile
    v_numar_caz VARCHAR2(50);
    v_tip_caz VARCHAR2(100);
    v_status_caz VARCHAR2(30);
    v_prioritate VARCHAR2(20);
    v_data_incident DATE;

    v_nume_dept_dest VARCHAR2(150);
    v_cod_dept_dest VARCHAR2(30);

    v_nume_sectie VARCHAR2(100);
    v_id_sectie_dest NUMBER;

    v_nr_suspecti NUMBER;
    v_nr_probe NUMBER;
    v_nr_cazuri_dest NUMBER;

    v_caz_exista NUMBER;
    v_dept_exista NUMBER;

BEGIN
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('*********** TRANSFER CAZ LA DEPARTAMENT NOU ***********');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Parametri:');
    DBMS_OUTPUT.PUT_LINE('  -->> ID Caz: ' || p_id_caz);
    DBMS_OUTPUT.PUT_LINE('  -->> ID Departament destinatie: ' || p_id_dept_destinatie);
    DBMS_OUTPUT.PUT_LINE('');

    -- validare 1: verificam daca acel caz exista
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(' ** PASUL 1: Validare existenta caz **');

    BEGIN
        SELECT COUNT(*) INTO v_caz_exista
        FROM CAZ WHERE id_caz = p_id_caz;

        IF v_caz_exista = 0 THEN
            RAISE NO_DATA_FOUND;
        END IF;

        DBMS_OUTPUT.PUT_LINE(' VALIDAT -> Cazul cu ID ' || p_id_caz || ' exista');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(' !!! EROARE: Cazul nu exista!');
            RAISE_APPLICATION_ERROR(-20001,
                'Cazul cu ID ' || p_id_caz || ' nu exista!');
    END;

    -- validare 2: verificam daca departamentul de destinatie exista
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(' ** PASUL 2: Validare departament destinatie **');

    BEGIN
        SELECT COUNT(*) INTO v_dept_exista
        FROM DEPARTAMENT WHERE id_departament = p_id_dept_destinatie;

        IF v_dept_exista = 0 THEN
            RAISE NO_DATA_FOUND;
        END IF;

        DBMS_OUTPUT.PUT_LINE(' VALIDAT -> Departamentul destinatie exista');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(' !!!! EROARE: Departamentul nu exista!');
            RAISE_APPLICATION_ERROR(-20002,
                'Departamentul cu ID ' || p_id_dept_destinatie || ' nu exista!');
    END;

    -- trebuie sa fac preluarea departamentului sursa
    SELECT d.id_departament, d.nume_departament, d.id_sectie
    INTO v_id_dept_sursa, v_nume_dept_sursa, v_id_sectie_sursa
    FROM CAZ c
    INNER JOIN DEPARTAMENT d ON c.id_departament = d.id_departament
    WHERE c.id_caz = p_id_caz;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(' *** PASUL 3: PRELUARE DATE ***');

    BEGIN
        SELECT
            -- datele din tabela CAZ
            c.numar_caz,
            c.tip_caz,
            c.status_caz,
            c.prioritate_caz,
            c.data_incidentului,
            -- datele din tabela DEPARTAMENT --- cel de destinatie
            d.nume_departament AS dept_dest,
            d.cod_departament AS cod_dest,
            -- datele din tabla SECTIE_POLITIE
            s.nume_sectie,
            s.id_sectie,
            -- datele din tabela CAZ_SUSPECT
            COUNT(DISTINCT cs.id_suspect) AS nr_suspecti,
            -- datele din tabela PROBA
            COUNT(DISTINCT p.id_proba) AS nr_probe
        INTO
            v_numar_caz, v_tip_caz, v_status_caz, v_prioritate, v_data_incident,
            v_nume_dept_dest, v_cod_dept_dest,
            v_nume_sectie, v_id_sectie_dest,
            v_nr_suspecti,
            v_nr_probe
        FROM CAZ c
        INNER JOIN DEPARTAMENT d
            ON d.id_departament = p_id_dept_destinatie
        INNER JOIN SECTIE_POLITIE s
            ON d.id_sectie = s.id_sectie
        LEFT JOIN CAZ_SUSPECT cs
            ON c.id_caz = cs.id_caz
        LEFT JOIN PROBA p
            ON c.id_caz = p.id_caz
        WHERE c.id_caz = p_id_caz
        GROUP BY
            c.numar_caz, c.tip_caz, c.status_caz, c.prioritate_caz, c.data_incidentului,
            d.nume_departament, d.cod_departament,
            s.nume_sectie, s.id_sectie;

    DBMS_OUTPUT.PUT_LINE(' Validat: Datele s-au preluat cu succes!');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(' !!! EROARE la preluare date!');
            RAISE_APPLICATION_ERROR(-20003, 'Eroare la preluare informatii!');
    END;

    -- afisez informatiile preluate
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE(' ^^ INFORMATII PRELUATE: ^^');
    DBMS_OUTPUT.PUT_LINE('  --- Caz:');
    DBMS_OUTPUT.PUT_LINE('      -->> Numar: ' || v_numar_caz);
    DBMS_OUTPUT.PUT_LINE('      -->> Tip: ' || v_tip_caz);
    DBMS_OUTPUT.PUT_LINE('      -->> Status: ' || v_status_caz);
    DBMS_OUTPUT.PUT_LINE('      -->> Prioritate: ' || v_prioritate);
    DBMS_OUTPUT.PUT_LINE('      -->> Data incident: ' || TO_CHAR(v_data_incident, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('      -->> Suspecti: ' || v_nr_suspecti);
    DBMS_OUTPUT.PUT_LINE('      -->> Probe: ' || v_nr_probe);
    DBMS_OUTPUT.PUT_LINE('  --- Departament SURSA:');
    DBMS_OUTPUT.PUT_LINE('      -->> Nume: ' || v_nume_dept_sursa);
    DBMS_OUTPUT.PUT_LINE('      -->> ID Sectie: ' || v_id_sectie_sursa);
    DBMS_OUTPUT.PUT_LINE('  --- Departament DESTINATIE:');
    DBMS_OUTPUT.PUT_LINE('      -->> Nume: ' || v_nume_dept_dest);
    DBMS_OUTPUT.PUT_LINE('      -->> Cod: ' || v_cod_dept_dest);
    DBMS_OUTPUT.PUT_LINE('  --- Sectie:');
    DBMS_OUTPUT.PUT_LINE('      -->> Nume: ' || v_nume_sectie);
    DBMS_OUTPUT.PUT_LINE('      -->> ID: ' || v_id_sectie_dest);

    -- calculez nr de cazuri din departamentul de destinatie
    SELECT COUNT(*) INTO v_nr_cazuri_dest
    FROM CAZ
    WHERE id_departament = p_id_dept_destinatie
      AND status_caz IN ('activ', 'in asteptare');

    DBMS_OUTPUT.PUT_LINE('  - Cazuri active: ' || v_nr_cazuri_dest);

    -- validari personalizate
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.PUT_LINE(' *** PASUL 4: Validari personalizate ***');

    -- exceptie personalizata: transfer in acelasi departament!!
    IF v_id_dept_sursa = p_id_dept_destinatie THEN
        DBMS_OUTPUT.PUT_LINE(' !!! EROARE: Cazul este deja in acest departament!');
        RAISE_APPLICATION_ERROR(-20004,
            ' !!! Cazul este deja in departamentul specificat!');
    END IF;
    DBMS_OUTPUT.PUT_LINE(' VALIDAT -> Departamente diferite');

    -- exceptie personalizata: verificare pentru status caz sa poata fi in continuare validat
    IF v_status_caz NOT IN ('activ', 'in asteptare', 'suspendat') THEN
        DBMS_OUTPUT.PUT_LINE(' !!! EXCEPȚIE: Caz netransferabil!');
        DBMS_OUTPUT.PUT_LINE('  --->> Status: ' || v_status_caz);
        RAISE ex_caz_netransferabil;
    END IF;
    DBMS_OUTPUT.PUT_LINE(' VALIDAT -> Status: Transferabil');

    -- exceptie personalizata: conflict de sectie ! sa am aceeasi sectie la departamente
    IF v_id_sectie_sursa != v_id_sectie_dest THEN
        DBMS_OUTPUT.PUT_LINE(' !!!! EXCEPTIE: Conflict de sectie!');
        DBMS_OUTPUT.PUT_LINE('  --->> Sursa: Sectia ' || v_id_sectie_sursa);
        DBMS_OUTPUT.PUT_LINE('  --->> Destinatie: Sectia ' || v_id_sectie_dest);
        RAISE ex_conflict_sectie;
    END IF;
    DBMS_OUTPUT.PUT_LINE(' VALIDAT -> Aceeasi sectie');

    -- exceptie personalizata: verificarea supraincarcarii unui departament
    IF v_nr_cazuri_dest >= 10 THEN
        DBMS_OUTPUT.PUT_LINE('!!! EXCEPȚIE: Departament supraincarcat!');
        DBMS_OUTPUT.PUT_LINE('  -->> Cazuri: ' || v_nr_cazuri_dest || ' / 10');
        RAISE ex_departament_supraincarcat;
    END IF;
    DBMS_OUTPUT.PUT_LINE(' VALIDAT -> Capacitate OK (' || v_nr_cazuri_dest || ' / 10)');

    -- executie efectiva transfer
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(' *** PASUL 5: Executie transfer ***');

    UPDATE CAZ
    SET id_departament = p_id_dept_destinatie,
        status_caz = 'activ'
    WHERE id_caz = p_id_caz;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(' VERIFICARE --->>> Transfer executat cu succes!');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE(' - REZUMAT:');
    DBMS_OUTPUT.PUT_LINE('  --->>> Caz: ' || v_numar_caz || ' (' || v_tip_caz || ')');
    DBMS_OUTPUT.PUT_LINE('  --->>> DE LA: ' || v_nume_dept_sursa);
    DBMS_OUTPUT.PUT_LINE('  --->>> CATRE: ' || v_nume_dept_dest);
    DBMS_OUTPUT.PUT_LINE('  --->>> Sectie: ' || v_nume_sectie);
    DBMS_OUTPUT.PUT_LINE('  --->>> Elemente transferate:');
    DBMS_OUTPUT.PUT_LINE('         - Suspecti: ' || v_nr_suspecti);
    DBMS_OUTPUT.PUT_LINE('         - Probe: ' || v_nr_probe);
    DBMS_OUTPUT.PUT_LINE('  --->>> Noi cazuri dept. destinatie: ' || (v_nr_cazuri_dest + 1) || ' / 10');
    DBMS_OUTPUT.PUT_LINE('');

EXCEPTION
    WHEN ex_caz_netransferabil THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE(' !!! EROARE: CAZ NETRANSFERABIL !!!');
        DBMS_OUTPUT.PUT_LINE('Status "' || v_status_caz || '" nu permite transfer.');
        DBMS_OUTPUT.PUT_LINE('Statusuri valide: activ, in asteptare, suspendat');
        RAISE_APPLICATION_ERROR(-20103,
            'Cazul are status "' || v_status_caz || '" - netransferabil!');

    WHEN ex_conflict_sectie THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE(' !!! EROARE: CONFLICT DE SECTIE !!!');
        DBMS_OUTPUT.PUT_LINE('Transfer inter-sectii necesita aprobare superioara!');
        RAISE_APPLICATION_ERROR(-20102, 'Conflict sectie!');

    WHEN ex_departament_supraincarcat THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE(' !!! EROARE: CAZ NETRANSFERABIL !!!');
        DBMS_OUTPUT.PUT_LINE('Departamentul are ' || v_nr_cazuri_dest || ' cazuri active.');
        DBMS_OUTPUT.PUT_LINE('Limita: 10 cazuri per departament');
        RAISE_APPLICATION_ERROR(-20101,
            'Departament supraincarcat: ' || v_nr_cazuri_dest || ' / 10 cazuri!');

    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('!!! EROARE: Date negasite!');
        RAISE;

    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('!!! EROARE: ' || SQLERRM);
        RAISE;
END transfer_caz_departament;

-- teste
-- caz 1 -> transfer cu succes
BEGIN
    transfer_caz_departament(p_id_caz => 1, p_id_dept_destinatie => 2);
END;

-- caz 2 -> pt caz indexistent
BEGIN
    transfer_caz_departament(p_id_caz => 9999, p_id_dept_destinatie => 2);
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;

-- caz 3 -> pt departament inexistent
BEGIN
    transfer_caz_departament(p_id_caz => 1, p_id_dept_destinatie => 9999);
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;

-- caz 4 -> pt conflictul de sectie
BEGIN
    transfer_caz_departament(p_id_caz => 1, p_id_dept_destinatie => 4);
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;

-- caz 5 -> daca cazul este din acelasi departament
BEGIN
    transfer_caz_departament(p_id_caz => 1, p_id_dept_destinatie => 1);
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;

-- caz 6 -> daca cazul nu este in disponibilitate de a fi transferat
BEGIN
    transfer_caz_departament(p_id_caz => 3, p_id_dept_destinatie => 1);
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;

