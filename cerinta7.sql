-- CERINTA 7 PROIECT

-- 7. Formulați în limbaj natural o problemă pe care să o rezolvați folosind un subprogram stocat independent care
-- să utilizeze 2 tipuri diferite de cursoare studiate, unul dintre acestea fiind cursor parametrizat, dependent
-- de celălalt cursor. Apelați subprogramul.


-- Cerinta in limbaj natural:
-- Departamentul de resurse umane trebuie sa genereze un raport detaliat despre structura organizationala si
-- activitatea fiecarui departament dintr-o sectie. Pentru fiecare departament, sistemul va afisa informatii
-- generale, apoi va lista toti ofiterii din acel departament impreuna cu informatii despre cazurile care sunt
-- gestionate de departamentul respectiv.
--
-- Raportul trebuie sa permita filtrarea dupa sectie si sa se afiseze pentru fiecare departament urmatoarele
-- informatii:
-- 1) Informatii despre departament (nume, cod, serviciu, numar total de ofiteri, numar total de cazuri)
-- 2) Pentru fiecare ofiter din departament:
--    - date personale (nume, pozitie, vechime)
--    - informatii despre supervizor (daca exista)
-- 3) Statistici despre cazurile departamentului (activ, inchis, in investigare)
--
-- Acest raport ajuta conducerea sa identifice rapid departamentele supraincarcate si distribuția resurselor umane.


-- Descriere:
-- o sa avem nevoie sa implementam 2 tipuri de cursoare:
-- 1) un cursor explicit (neparametrizat) ->> pt departamente - parcurge toate departamentele din sectie si nu este
--    influentat (nu depinde de nimic)
-- 2) un cursor parametrizat -->> pt ofiteri - parcurge ofiterii din departamentul curent si depinde de primul cursor
--    deoarece primeste id_departament ca paramentru

-- IMPLEMENTARE!!

CREATE OR REPLACE PROCEDURE raport_departamente_ofiteri(
    p_id_sectie IN NUMBER
) AS
    -- variabilele
    v_nume_sectie VARCHAR2(100);
    v_total_departamente NUMBER := 0;
    v_total_ofiteri NUMBER := 0;
    v_total_cazuri NUMBER := 0;
    v_nume_specializare VARCHAR2(100);
    v_nr_cazuri_dept NUMBER;
    v_nr_cazuri_active NUMBER;
    v_nr_cazuri_inchise NUMBER;

    -- CURSORUL 1 - explicit pt departamentele din sectie
    CURSOR c_departamente IS
        SELECT
            d.id_departament,
            d.nume_departament,
            d.cod_departament,
            d.locatie_cladire,
            d.numar_telefon,
            d.id_specializare,
            COUNT(DISTINCT o.id_ofiter) AS nr_ofiteri,
            COUNT(DISTINCT c.id_caz) AS nr_cazuri
        FROM DEPARTAMENT d
        LEFT JOIN OFITER o ON d.id_departament = o.id_departament
        LEFT JOIN CAZ c ON d.id_departament = c.id_departament
        WHERE d.id_sectie = p_id_sectie
        GROUP BY d.id_departament, d.nume_departament, d.cod_departament,
                 d.locatie_cladire, d.numar_telefon, d.id_specializare
        ORDER BY d.nume_departament;

    -- CURSOR 2 - parametrizat, depinde de cursor 1, pt ofiterii din departamentul curent
    -- primeste id_departament din cursorul 1
    CURSOR c_ofiteri(p_id_departament NUMBER) IS
        SELECT
            o.id_ofiter,
            o.cod_ofiter,
            o.nume,
            o.prenume,
            o.pozitie,
            o.data_angajare,
            ROUND(MONTHS_BETWEEN(SYSDATE, o.data_angajare) / 12, 1) AS vechime_ani,
            o.id_supervizor,
            s.nume AS nume_supervizor,
            s.prenume AS prenume_supervizor,
            s.pozitie AS pozitie_supervizor
        FROM OFITER o
        LEFT JOIN OFITER s ON o.id_supervizor = s.id_ofiter
        WHERE o.id_departament = p_id_departament
        ORDER BY o.pozitie DESC, o.nume;

    -- variabile pentru cursoare
    rec_dept c_departamente%ROWTYPE;
    rec_ofiter c_ofiteri%ROWTYPE;

BEGIN
    -- verificare si obtinere nume sectie
    BEGIN
        SELECT nume_sectie INTO v_nume_sectie
        FROM SECTIE_POLITIE
        WHERE id_sectie = p_id_sectie;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,
                'Sectia cu ID ' || p_id_sectie || ' nu exista!');
    END;

    -- raport
    DBMS_OUTPUT.PUT_LINE('***** RAPORT STRUCTURA DEPARTAMENTE SI OFITERI  ******');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Sectia: ' || v_nume_sectie);
    DBMS_OUTPUT.PUT_LINE('Data raport: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI'));
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('');

    -- deschid cursorul 1 pt departamente
    OPEN c_departamente;

    LOOP
        -- iau departamentul curent
        FETCH c_departamente INTO rec_dept;
        EXIT WHEN c_departamente%NOTFOUND;

        v_total_departamente := v_total_departamente + 1;
        v_total_ofiteri := v_total_ofiteri + rec_dept.nr_ofiteri;
        v_total_cazuri := v_total_cazuri + rec_dept.nr_cazuri;

        -- obtin nume specializare
        BEGIN
            SELECT nume_specializare INTO v_nume_specializare
            FROM SPECIALIZARE
            WHERE id_specializare = rec_dept.id_specializare;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_nume_specializare := 'N/A';
        END;

        -- statistici cazuri
        BEGIN
            SELECT
                COUNT(CASE WHEN status_caz = 'activ' THEN 1 END),
                COUNT(CASE WHEN status_caz = 'rezolvat' THEN 1 END)
            INTO v_nr_cazuri_active, v_nr_cazuri_inchise
            FROM CAZ
            WHERE id_departament = rec_dept.id_departament;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_nr_cazuri_active := 0;
                v_nr_cazuri_inchise := 0;
        END;

        -- informatii departament
        DBMS_OUTPUT.PUT_LINE('  DEPARTAMENT -> ' || v_total_departamente);
        DBMS_OUTPUT.PUT_LINE('  --->>> Nume: ' || rec_dept.nume_departament);
        DBMS_OUTPUT.PUT_LINE('  --->>> Cod: ' || rec_dept.cod_departament);
        DBMS_OUTPUT.PUT_LINE('  --->>> Specializare: ' || v_nume_specializare);
        DBMS_OUTPUT.PUT_LINE('  --->>> Locatie: ' || NVL(rec_dept.locatie_cladire, 'N/A'));
        DBMS_OUTPUT.PUT_LINE('  --->>> Telefon: ' || NVL(rec_dept.numar_telefon, 'N/A'));
        DBMS_OUTPUT.PUT_LINE('  ─────────────────────────────────────────────');
        DBMS_OUTPUT.PUT_LINE('  Statistici: ');
        DBMS_OUTPUT.PUT_LINE('     -->> Total ofiteri: ' || rec_dept.nr_ofiteri);
        DBMS_OUTPUT.PUT_LINE('     -->> Total cazuri: ' || rec_dept.nr_cazuri);
        DBMS_OUTPUT.PUT_LINE('     -->> Cazuri active: ' || v_nr_cazuri_active);
        DBMS_OUTPUT.PUT_LINE('     -->> Cazuri inchise: ' || v_nr_cazuri_inchise);
        DBMS_OUTPUT.PUT_LINE('  ─────────────────────────────────────────────');

        -- verific supraincarcarea departamentului
        IF rec_dept.nr_cazuri > 20 THEN
            DBMS_OUTPUT.PUT_LINE(' !!!!  ATENTIE: Departament cu volum mare de cazuri !!!');
        END IF;

        IF rec_dept.nr_ofiteri > 0 THEN
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('  LISTA OFITERI:');
            DBMS_OUTPUT.PUT_LINE('');

            -- deschid cursorul 2 parametrizat -> trimit id_departament din cursorul 1
            OPEN c_ofiteri(rec_dept.id_departament);

            LOOP
                -- preiau ofiterul curent
                FETCH c_ofiteri INTO rec_ofiter;
                EXIT WHEN c_ofiteri%NOTFOUND;

                -- informatii ofiter
                DBMS_OUTPUT.PUT_LINE('     * Ofiter: ' || rec_ofiter.nume || ' ' || rec_ofiter.prenume);
                DBMS_OUTPUT.PUT_LINE('     --->> Cod: ' || rec_ofiter.cod_ofiter);
                DBMS_OUTPUT.PUT_LINE('     --->> Pozitie: ' || rec_ofiter.pozitie);
                DBMS_OUTPUT.PUT_LINE('     --->> Data angajare: ' ||
                                   TO_CHAR(rec_ofiter.data_angajare, 'DD-MON-YYYY'));
                DBMS_OUTPUT.PUT_LINE('     --->> Vechime: ' || rec_ofiter.vechime_ani || ' ani');

                -- informatii supervizor
                IF rec_ofiter.id_supervizor IS NOT NULL THEN
                    DBMS_OUTPUT.PUT_LINE('     --->> Supervizor: ' || rec_ofiter.nume_supervizor || ' ' ||
                                       rec_ofiter.prenume_supervizor ||
                                       ' (' || rec_ofiter.pozitie_supervizor || ')');
                ELSE
                    DBMS_OUTPUT.PUT_LINE('     !!! Supervizor: Nu are supervizor (pozitie de conducere)');
                END IF;

                -- avertizare pt vechime
                IF rec_ofiter.vechime_ani < 1 THEN
                    DBMS_OUTPUT.PUT_LINE('     ** Ofiter nou - necesita training');
                ELSIF rec_ofiter.vechime_ani > 15 THEN
                    DBMS_OUTPUT.PUT_LINE('     ** Ofiter senior - experienta vasta');
                END IF;

                DBMS_OUTPUT.PUT_LINE('');

            END LOOP;

            -- inchid cursorul parametrizat
            CLOSE c_ofiteri;

        ELSE
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('  Departamentul nu are ofiteri asignati');
        END IF;

        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('');

    END LOOP;

    -- inchid cursorul explicit pt departamente
    CLOSE c_departamente;

EXCEPTION
    WHEN OTHERS THEN
        -- inchid cursoarele in caz de eroare
        IF c_departamente%ISOPEN THEN
            CLOSE c_departamente;
        END IF;
        IF c_ofiteri%ISOPEN THEN
            CLOSE c_ofiteri;
        END IF;

        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE(' EROARE: ' || SQLERRM);
        RAISE;
END raport_departamente_ofiteri;


-- apelare procedura!!

BEGIN
    raport_departamente_ofiteri(1);
END;

