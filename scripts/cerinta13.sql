--  CERINTA 13 PROIECT

-- 13. Formulați în limbaj natural o problemă pe care să o rezolvați folosind un pachet care să includă tipuri de
-- date complexe și obiecte necesare unui flux de acțiuni integrate, specifice bazei de date definite (minim
-- 2 tipuri de date, minim 2 funcții, minim 2 proceduri).

-- am nevoie deci de un pachet care sa contina:
-- -- minim 2 tipuri de date
-- -- minim 2 funtii
-- -- minim 2 proceduri

-- maybe >>
-- tipuri de date: info despre departament pentru asignare caz in functie de scor
--                 analiza detaliata a cazurilor, tot cu scor calculat din probe victime si suspecti
--                 o colectie de departamente
-- functii: vreau o functie care calculeaza scorul de potrivire dintre un departament si un caz
--          functie care gaseste departamentul cel mai optim pentru cazul respectiv
--          functie care calculeaza progresul unei investigatii
--          functie care analizeaza investigatia detaliat
--          functie care obtine toata lista de departamente
-- proceduri: procedura care asigneaza automat cazul la un departamanet
--            procedura care face analiza completa a unei investigatii
--            procedura care compara departamenele si arata toate obtiunile
--            procedura care determina raportul de performanta per departamente

-- IMPLEMENTARE!!
-- imi definesc tipurile de date
-- tip de data 1 -> pentru informatii complete legate de departament
CREATE OR REPLACE TYPE tip_informatii_departament AS OBJECT (
    id_departament NUMBER,
    nume_departament VARCHAR2(150),
    specializare VARCHAR2(100),
    nr_ofiteri NUMBER,
    nr_cazuri_active NUMBER,
    scor_potrivire NUMBER
);

-- tip de data 2 ->> pt analiza completa de investigatie
CREATE OR REPLACE TYPE tip_caz_analiza AS OBJECT (
    id_caz NUMBER,
    numar_caz VARCHAR2(50),
    tip_caz VARCHAR2(100),
    scor_progres NUMBER,
    nr_probe NUMBER,
    nr_probe_analizate NUMBER,
    nr_suspecti NUMBER,
    nivel_urgenta VARCHAR2(20),
    recomandari VARCHAR2(1000)
);

-- tip de data 3 -->> o coletie de departamente
CREATE OR REPLACE TYPE tip_lista_departament AS TABLE OF tip_informatii_departament;

-- creez pachetul cu specificatiile
CREATE OR REPLACE PACKAGE package_investigatii AS
    -- exceptii personalizate
    ex_departament_supraincarcat EXCEPTION;
    ex_caz_invalid EXCEPTION;

    -- functiile
    -- functia 1 -->> calculeaza scorul de potrivire
    FUNCTION calculeaza_scor_potrivire(
        p_id_departament IN NUMBER,
        p_numar_caz IN VARCHAR2
    ) RETURN NUMBER;

    -- functia 2 -->> gaseste departamentul optim si returneaza informatiile complete
    -- pt informatiile complete o sa returnez tip_informatii_departament
    FUNCTION gaseste_departament_optim(
        p_numar_caz IN VARCHAR2,
        p_id_sectie IN NUMBER
    ) RETURN tip_informatii_departament;

    -- functia 3 -->> calculez progresul de investigatie
    FUNCTION calculeaza_progres_investigatie(
        p_id_caz IN NUMBER
    ) RETURN NUMBER;

    -- functia 4 --->> fac o analiza completa a investigatiilor cu informatiile complete
    -- pentru informatiile complete ale investigatiilor voi folosi tip_caz_analiza
    FUNCTION analizeaza_investigatie_detaliat(
        p_id_caz IN NUMBER
    ) RETURN tip_caz_analiza;

    -- functia 5 --->> trebuie sa obtin lista tuturor departamentelor cu scorurile
    -- o sa folosesc tip_lista_departament
    FUNCTION obtine_lista_departamente(
        p_numar_caz IN VARCHAR2,
        p_id_sectie IN NUMBER
    ) RETURN tip_lista_departament;

    -- proceduri!!
    -- procedura 1 -->> asignarea automata a unui caz
    PROCEDURE asigneaza_caz_automat(
        p_id_caz IN NUMBER
    );

    -- procedura 2 -->> analiza investigatiei
    PROCEDURE analizeaza_investigatie(
        p_id_caz IN NUMBER
    );

    -- procedura 3 -->> compara departamenele si mi arata toate optiunile
    PROCEDURE compara_departamente(
        p_numar_caz IN VARCHAR2,
        p_id_sectie IN NUMBER
    );

    -- procedura 4 -->> pentru rapoartele de performanta
    PROCEDURE raport_departamente(
        p_id_sectie IN NUMBER
    );

END package_investigatii;

-- corpul pachetului
CREATE OR REPLACE PACKAGE BODY package_investigatii AS

    -- functia pentru calculul scorului de potrivire
    FUNCTION calculeaza_scor_potrivire(
        p_id_departament IN NUMBER,
        p_numar_caz IN VARCHAR2
    ) RETURN NUMBER IS

        v_scor NUMBER := 0;
        v_cod_specializare VARCHAR2(30);
        v_nr_cazuri_active NUMBER;
        v_nr_ofiteri NUMBER;
        v_cod_din_caz VARCHAR2(30);

    BEGIN
        SELECT sp.cod_specializare,
               COUNT(DISTINCT o.id_ofiter),
               COUNT(DISTINCT CASE WHEN c.status_caz IN ('activ', 'in asteptare')
                     THEN c.id_caz END)
        INTO v_cod_specializare, v_nr_ofiteri, v_nr_cazuri_active
        FROM DEPARTAMENT d
        LEFT JOIN SPECIALIZARE sp ON d.id_specializare = sp.id_specializare
        LEFT JOIN OFITER o ON d.id_departament = o.id_departament
        LEFT JOIN CAZ c ON d.id_departament = c.id_departament
        WHERE d.id_departament = p_id_departament
        GROUP BY sp.cod_specializare;

        -- extrag codul specializarii din numarul cazului
        BEGIN
            v_cod_din_caz := REGEXP_SUBSTR(p_numar_caz, '[^/]+', 1, 2);
        EXCEPTION
            WHEN OTHERS THEN
                v_cod_din_caz := NULL;
        END;

        -- in functie de codul de specializare
        IF v_cod_din_caz IS NOT NULL AND v_cod_specializare IS NOT NULL THEN
            IF UPPER(v_cod_specializare) = UPPER(v_cod_din_caz) THEN
                v_scor := v_scor + 50;
            ELSIF UPPER(v_cod_specializare) LIKE UPPER(v_cod_din_caz) || '%' OR
                  UPPER(v_cod_din_caz) LIKE UPPER(v_cod_specializare) || '%' THEN
                v_scor := v_scor + 30;
            ELSE
                v_scor := v_scor + 5;
            END IF;
        ELSE
            v_scor := v_scor + 5;
        END IF;

        -- scorul pentru capacitatea departamentului
        IF v_nr_cazuri_active <= 3 THEN
            v_scor := v_scor + 30;
        ELSIF v_nr_cazuri_active <= 6 THEN
            v_scor := v_scor + 15;
        END IF;

        -- scorul pentru vechimea ofiterilor din departament
        v_scor := v_scor + LEAST(20, v_nr_ofiteri * 5);

        RETURN v_scor;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN 0;
    END calculeaza_scor_potrivire;

    -- functia ce gaseste departamentul optim pentru un caz
    FUNCTION gaseste_departament_optim(
        p_numar_caz IN VARCHAR2,
        p_id_sectie IN NUMBER
    ) RETURN tip_informatii_departament IS

        v_id_departament_optim NUMBER;
        v_scor_maxim NUMBER := 0;
        v_scor_curent NUMBER;
        v_rezultat tip_informatii_departament;

        CURSOR c_departamente IS
            SELECT id_departament
            FROM DEPARTAMENT
            WHERE id_sectie = p_id_sectie;

    BEGIN
        -- gasesc departamentul cu cel mai mare scor
        FOR rec IN c_departamente LOOP
            v_scor_curent := calculeaza_scor_potrivire(rec.id_departament, p_numar_caz);

            IF v_scor_curent > v_scor_maxim THEN
                v_scor_maxim := v_scor_curent;
                v_id_departament_optim := rec.id_departament;
            END IF;
        END LOOP;

        IF v_id_departament_optim IS NULL THEN
            RAISE ex_departament_supraincarcat;
        END IF;

        -- construiesc obiectul de tip tip_informatii_departament ce urmeaza sa l returnez
        SELECT tip_informatii_departament(
            d.id_departament,
            d.nume_departament,
            NVL(sp.nume_specializare, 'N/A'),
            COUNT(DISTINCT o.id_ofiter),
            COUNT(DISTINCT CASE WHEN c.status_caz IN ('activ', 'in asteptare')
                  THEN c.id_caz END),
            v_scor_maxim
        )
        INTO v_rezultat
        FROM DEPARTAMENT d
        LEFT JOIN SPECIALIZARE sp ON d.id_specializare = sp.id_specializare
        LEFT JOIN OFITER o ON d.id_departament = o.id_departament
        LEFT JOIN CAZ c ON d.id_departament = c.id_departament
        WHERE d.id_departament = v_id_departament_optim
        GROUP BY d.id_departament, d.nume_departament, sp.nume_specializare;

        RETURN v_rezultat;

    EXCEPTION
        WHEN ex_departament_supraincarcat THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RETURN NULL;
    END gaseste_departament_optim;

    -- functia ce calculeaza progresul unei investigatii
    FUNCTION calculeaza_progres_investigatie(
        p_id_caz IN NUMBER
    ) RETURN NUMBER IS

        v_scor NUMBER := 0;
        v_nr_probe NUMBER;
        v_nr_probe_analizate NUMBER;
        v_nr_suspecti NUMBER;
        v_status_caz VARCHAR2(30);

    BEGIN
        SELECT status_caz INTO v_status_caz
        FROM CAZ WHERE id_caz = p_id_caz;

        SELECT COUNT(*),
               COUNT(CASE WHEN status_analiza IN ('analizata', 'rezultate disponibile')
                     THEN 1 END)
        INTO v_nr_probe, v_nr_probe_analizate
        FROM PROBA WHERE id_caz = p_id_caz;

        SELECT COUNT(*) INTO v_nr_suspecti
        FROM CAZ_SUSPECT WHERE id_caz = p_id_caz;

        -- calculez scorul investigatiei
        IF v_nr_probe > 0 THEN
            v_scor := v_scor + (v_nr_probe_analizate / v_nr_probe) * 40;
        END IF;

        IF v_nr_suspecti > 0 THEN
            v_scor := v_scor + LEAST(35, v_nr_suspecti * 10);
        END IF;

        CASE v_status_caz
            WHEN 'rezolvat' THEN v_scor := 100;
            WHEN 'trimis in judecata' THEN v_scor := GREATEST(v_scor, 85);
            WHEN 'activ' THEN v_scor := v_scor + 15;
            ELSE v_scor := v_scor + 5;
        END CASE;

        RETURN LEAST(100, ROUND(v_scor));

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE ex_caz_invalid;
        WHEN OTHERS THEN
            RETURN 0;
    END calculeaza_progres_investigatie;

    -- functia de analizeaza mai detaliat investigatia
    FUNCTION analizeaza_investigatie_detaliat(
        p_id_caz IN NUMBER
    ) RETURN tip_caz_analiza IS

        v_rezultat tip_caz_analiza;
        v_numar_caz VARCHAR2(50);
        v_tip_caz VARCHAR2(100);
        v_scor_progres NUMBER;
        v_nr_probe NUMBER;
        v_nr_probe_analizate NUMBER;
        v_nr_suspecti NUMBER;
        v_nivel_urgenta VARCHAR2(20);
        v_recomandari VARCHAR2(1000) := '';

    BEGIN
        -- preluez datele despre caz
        SELECT numar_caz, tip_caz
        INTO v_numar_caz, v_tip_caz
        FROM CAZ WHERE id_caz = p_id_caz;

        -- calculez progresul
        v_scor_progres := calculeaza_progres_investigatie(p_id_caz);

        -- statistici
        SELECT COUNT(*) INTO v_nr_probe FROM PROBA WHERE id_caz = p_id_caz;
        SELECT COUNT(*) INTO v_nr_probe_analizate
        FROM PROBA WHERE id_caz = p_id_caz
          AND status_analiza IN ('analizata', 'rezultate disponibile');
        SELECT COUNT(*) INTO v_nr_suspecti FROM CAZ_SUSPECT WHERE id_caz = p_id_caz;

        -- nivelul de urgenta
        IF v_scor_progres >= 70 THEN
            v_nivel_urgenta := 'SCAZUT';
        ELSIF v_scor_progres >= 40 THEN
            v_nivel_urgenta := 'MEDIU';
        ELSE
            v_nivel_urgenta := 'RIDICAT';
        END IF;

        -- posibile recomandari
        IF v_nr_probe = 0 THEN
            v_recomandari := 'URGENT: Colectare probe! ';
        ELSIF v_nr_probe_analizate < v_nr_probe THEN
            v_recomandari := 'Analizare probe ramase. ';
        END IF;

        IF v_nr_suspecti = 0 THEN
            v_recomandari := v_recomandari || 'PRIORITATE: Identificare suspecti!';
        END IF;

        IF v_scor_progres >= 80 THEN
            v_recomandari := 'Caz aproape finalizat - pregatire dosar judecata';
        END IF;

        -- construiesc obiectul de tip tip_caz_analiza pt a l returna
        v_rezultat := tip_caz_analiza(
            p_id_caz,
            v_numar_caz,
            v_tip_caz,
            v_scor_progres,
            v_nr_probe,
            v_nr_probe_analizate,
            v_nr_suspecti,
            v_nivel_urgenta,
            v_recomandari
        );

        RETURN v_rezultat;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE ex_caz_invalid;
        WHEN OTHERS THEN
            RETURN NULL;
    END analizeaza_investigatie_detaliat;

    -- functia ce obtine lista de departamente impreuna cu scorurile
    FUNCTION obtine_lista_departamente(
        p_numar_caz IN VARCHAR2,
        p_id_sectie IN NUMBER
    ) RETURN tip_lista_departament IS

        v_lista tip_lista_departament;
        v_scor NUMBER;

    BEGIN
        -- populez colectia cu toate departamentele
        SELECT tip_informatii_departament(
            d.id_departament,
            d.nume_departament,
            NVL(sp.nume_specializare, 'N/A'),
            COUNT(DISTINCT o.id_ofiter),
            COUNT(DISTINCT CASE WHEN c.status_caz IN ('activ', 'in asteptare')
                  THEN c.id_caz END),
            0
        )
        BULK COLLECT INTO v_lista
        FROM DEPARTAMENT d
        LEFT JOIN SPECIALIZARE sp ON d.id_specializare = sp.id_specializare
        LEFT JOIN OFITER o ON d.id_departament = o.id_departament
        LEFT JOIN CAZ c ON d.id_departament = c.id_departament
        WHERE d.id_sectie = p_id_sectie
        GROUP BY d.id_departament, d.nume_departament, sp.nume_specializare
        ORDER BY d.nume_departament;

        -- calculez scorul pentru fiecare departament
        IF v_lista IS NOT NULL AND v_lista.COUNT > 0 THEN
            FOR i IN v_lista.FIRST .. v_lista.LAST LOOP
                v_scor := calculeaza_scor_potrivire(
                    v_lista(i).id_departament,
                    p_numar_caz
                );
                v_lista(i).scor_potrivire := v_scor;
            END LOOP;
        END IF;

        RETURN v_lista;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END obtine_lista_departamente;

    -- procedura pentru asignarea automata a unui caz
    PROCEDURE asigneaza_caz_automat(
        p_id_caz IN NUMBER
    ) IS
        v_numar_caz VARCHAR2(50);
        v_id_sectie NUMBER;
        v_dept_optim tip_informatii_departament;

    BEGIN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
        DBMS_OUTPUT.PUT_LINE(' *****    ASIGNARE AUTOMATA CAZ   *****');
        DBMS_OUTPUT.PUT_LINE('');

        -- preluez informatiile despre caz
        SELECT c.numar_caz, d.id_sectie
        INTO v_numar_caz, v_id_sectie
        FROM CAZ c
        INNER JOIN DEPARTAMENT d ON c.id_departament = d.id_departament
        WHERE c.id_caz = p_id_caz;

        DBMS_OUTPUT.PUT_LINE(' --->> Caz: ' || v_numar_caz);
        DBMS_OUTPUT.PUT_LINE(' --->> Secție: ' || v_id_sectie);
        DBMS_OUTPUT.PUT_LINE('');

        -- apelez functia ce returneaza tipul complet
        v_dept_optim := gaseste_departament_optim(v_numar_caz, v_id_sectie);

        IF v_dept_optim IS NULL THEN
            DBMS_OUTPUT.PUT_LINE(' !!! Nu exista departament disponibil !!!');
            RAISE ex_departament_supraincarcat;
        END IF;

        -- afisez atributele obiectului
        DBMS_OUTPUT.PUT_LINE('  *** DEPARTAMENT OPTIM GASIT:');
        DBMS_OUTPUT.PUT_LINE('  -->> Nume: ' || v_dept_optim.nume_departament);
        DBMS_OUTPUT.PUT_LINE('  -->> Specializare: ' || v_dept_optim.specializare);
        DBMS_OUTPUT.PUT_LINE('  -->> Ofiteri: ' || v_dept_optim.nr_ofiteri);
        DBMS_OUTPUT.PUT_LINE('  -->> Cazuri active: ' || v_dept_optim.nr_cazuri_active);
        DBMS_OUTPUT.PUT_LINE('  -->> SCOR POTRIVIRE: ' || v_dept_optim.scor_potrivire || '/100');
        DBMS_OUTPUT.PUT_LINE('');

        -- update caz
        UPDATE CAZ
        SET id_departament = v_dept_optim.id_departament
        WHERE id_caz = p_id_caz;

        COMMIT;

        DBMS_OUTPUT.PUT_LINE(' ** Caz asignat cu succes! **');
        DBMS_OUTPUT.PUT_LINE('');

    EXCEPTION
        WHEN ex_caz_invalid THEN
            DBMS_OUTPUT.PUT_LINE(' !!! Caz invalid !!!');
        WHEN ex_departament_supraincarcat THEN
            DBMS_OUTPUT.PUT_LINE(' !!! Toate departamentele sunt supraincarcate !!!');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE(' !!! EROARE: ' || SQLERRM);
            RAISE;
    END asigneaza_caz_automat;

    -- procedura pentru analiza investigatiei
    PROCEDURE analizeaza_investigatie(
        p_id_caz IN NUMBER
    ) IS
        v_analiza tip_caz_analiza;

    BEGIN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
        DBMS_OUTPUT.PUT_LINE(' *****      ANALIZA INVESTIGATIE     *****');
        DBMS_OUTPUT.PUT_LINE('');

        -- apelez functia care mi returneaza tipul complet
        v_analiza := analizeaza_investigatie_detaliat(p_id_caz);

        IF v_analiza IS NULL THEN
            DBMS_OUTPUT.PUT_LINE(' !!!! Cazul nu poate fi analizat !!!!');
            RETURN;
        END IF;

        -- afisez atributele obiectului
        DBMS_OUTPUT.PUT_LINE('  --->>> CAZ: ' || v_analiza.numar_caz);
        DBMS_OUTPUT.PUT_LINE('  --->>> Tip: ' || v_analiza.tip_caz);
        DBMS_OUTPUT.PUT_LINE('  --->>> STATISTICI:');
        DBMS_OUTPUT.PUT_LINE('      --->> Probe: ' || v_analiza.nr_probe_analizate || '/' ||
                            v_analiza.nr_probe || ' analizate');
        DBMS_OUTPUT.PUT_LINE('      --->> Suspecti: ' || v_analiza.nr_suspecti);
        DBMS_OUTPUT.PUT_LINE('  --->>> EVALUARE:');
        DBMS_OUTPUT.PUT_LINE('      --->> Scor progres: ' || v_analiza.scor_progres || '/100');
        DBMS_OUTPUT.PUT_LINE('      --->> Nivel urgenta: ' || v_analiza.nivel_urgenta);

        IF LENGTH(v_analiza.recomandari) > 0 THEN
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('  --->>>  RECOMANDARI: ' || v_analiza.recomandari);
        END IF;

        DBMS_OUTPUT.PUT_LINE('');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(' !!! Cazul nu exista !!!');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(' !!! EROARE: ' || SQLERRM);
    END analizeaza_investigatie;

    -- procedura pentru comparatia dintre departamente
    PROCEDURE compara_departamente(
        p_numar_caz IN VARCHAR2,
        p_id_sectie IN NUMBER
    ) IS
        v_lista tip_lista_departament;
        v_nume_sectie VARCHAR2(100);

    BEGIN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------');
        DBMS_OUTPUT.PUT_LINE(' ***** COMPARAȚIE DEPARTAMENTE *****');

        SELECT nume_sectie INTO v_nume_sectie
        FROM SECTIE_POLITIE WHERE id_sectie = p_id_sectie;

        DBMS_OUTPUT.PUT_LINE('  --->> Secție: ' || v_nume_sectie);
        DBMS_OUTPUT.PUT_LINE('  --->> Caz: ' || p_numar_caz);
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('');

        -- apelez functia care mi returneaza colectia de departamente
        v_lista := obtine_lista_departamente(p_numar_caz, p_id_sectie);

        IF v_lista IS NULL OR v_lista.COUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE(' !!!! Nu exista departamente in aceasta sectie !!!!');
            RETURN;
        END IF;

        -- parcug colectia si afisez fiecare departament
        FOR i IN v_lista.FIRST .. v_lista.LAST LOOP
            DBMS_OUTPUT.PUT_LINE(' -> DEPARTAMENT #' || i || ': ' || v_lista(i).nume_departament);
            DBMS_OUTPUT.PUT_LINE('      -->> Specializare: ' || v_lista(i).specializare);
            DBMS_OUTPUT.PUT_LINE('      -->> Ofiteri: ' || v_lista(i).nr_ofiteri);
            DBMS_OUTPUT.PUT_LINE('      -->> Cazuri active: ' || v_lista(i).nr_cazuri_active || '/10');

            DBMS_OUTPUT.PUT_LINE(' ->>>> SCOR POTRIVIRE: ' || v_lista(i).scor_potrivire || '/100');

            -- recomandari
            IF v_lista(i).scor_potrivire >= 70 THEN
                DBMS_OUTPUT.PUT_LINE('  ->>> EXCELENT - Foarte potrivit pentru acest caz');
            ELSIF v_lista(i).scor_potrivire >= 50 THEN
                DBMS_OUTPUT.PUT_LINE('  ->>> ACCEPTABIL - Poate gestiona cazul');
            ELSE
                DBMS_OUTPUT.PUT_LINE('  ->>> NEPOTRIVIT - Nu se recomanda');
            END IF;

            DBMS_OUTPUT.PUT_LINE('');
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('-----------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Total departamente analizate: ' || v_lista.COUNT);
        DBMS_OUTPUT.PUT_LINE('');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(' !!! Sectia nu exista !!!!');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(' !!! EROARE: ' || SQLERRM);
    END compara_departamente;

    -- procedura pentru raportul de performanta
    PROCEDURE raport_departamente(
        p_id_sectie IN NUMBER
    ) IS
        v_nume_sectie VARCHAR2(100);

        CURSOR c_departamente IS
            SELECT
                d.nume_departament,
                sp.nume_specializare,
                COUNT(DISTINCT o.id_ofiter) AS nr_ofiteri,
                COUNT(DISTINCT CASE WHEN c.status_caz = 'activ' THEN c.id_caz END) AS cazuri_active,
                COUNT(DISTINCT CASE WHEN c.status_caz = 'rezolvat'
                      AND c.data_inchidere_caz >= ADD_MONTHS(SYSDATE, -1) THEN c.id_caz END) AS cazuri_rezolvate
            FROM DEPARTAMENT d
            LEFT JOIN SPECIALIZARE sp ON d.id_specializare = sp.id_specializare
            LEFT JOIN OFITER o ON d.id_departament = o.id_departament
            LEFT JOIN CAZ c ON d.id_departament = c.id_departament
            WHERE d.id_sectie = p_id_sectie
            GROUP BY d.nume_departament, sp.nume_specializare
            ORDER BY d.nume_departament;

    BEGIN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
        DBMS_OUTPUT.PUT_LINE(' *****    RAPORT PERFORMANTA DEPARTAMENTE      *****');

        SELECT nume_sectie INTO v_nume_sectie
        FROM SECTIE_POLITIE WHERE id_sectie = p_id_sectie;

        DBMS_OUTPUT.PUT_LINE('  --->> Secție: ' || v_nume_sectie);
        DBMS_OUTPUT.PUT_LINE('  --->> Data: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY'));
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('');

        FOR rec IN c_departamente LOOP
            DBMS_OUTPUT.PUT_LINE(' --->> DEPARTAMENT: ' || rec.nume_departament);
            DBMS_OUTPUT.PUT_LINE('      --->> Specializare: ' || NVL(rec.nume_specializare, 'N/A'));
            DBMS_OUTPUT.PUT_LINE('      --->> Ofiteri: ' || rec.nr_ofiteri);
            DBMS_OUTPUT.PUT_LINE('      --->> Cazuri active: ' || rec.cazuri_active);
            DBMS_OUTPUT.PUT_LINE('      --->> Rezolvate luna curenta: ' || rec.cazuri_rezolvate);

            IF rec.cazuri_active > 7 THEN
                DBMS_OUTPUT.PUT_LINE('  * Status: SUPRAINCARCAT');
            ELSIF rec.cazuri_active < 2 THEN
                DBMS_OUTPUT.PUT_LINE('  * Status: Poate prelua cazuri');
            ELSE
                DBMS_OUTPUT.PUT_LINE('  * Status: Optim');
            END IF;

            DBMS_OUTPUT.PUT_LINE('');
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(' !!! Sectia nu exista !!!! ');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(' !!! EROARE: ' || SQLERRM);
    END raport_departamente;

END package_investigatii;

-- verific ca pachetul a fost facut ok
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'PACKAGE_INVESTIGATII'
ORDER BY object_type;

-- TESTE PENTRU VERIFICAREEEEE!!!!!!!!!

-- test pentru functia care gaseste departamentul optim si returneaza tip_informatii_departament
DECLARE
    v_dept tip_informatii_departament;
    v_id_sectie NUMBER;
    v_numar_caz VARCHAR2(50);
BEGIN
    -- iau niste date pentru test
    SELECT id_sectie INTO v_id_sectie
    FROM SECTIE_POLITIE WHERE ROWNUM = 1;

    SELECT numar_caz INTO v_numar_caz
    FROM CAZ WHERE ROWNUM = 1;

    DBMS_OUTPUT.PUT_LINE('  -->> Test pentru:');
    DBMS_OUTPUT.PUT_LINE('      -->> Sectie ID: ' || v_id_sectie);
    DBMS_OUTPUT.PUT_LINE('      -->> Numar caz: ' || v_numar_caz);
    DBMS_OUTPUT.PUT_LINE('');

    -- apelez functia care gaseste departamentul optim
    v_dept := package_investigatii.gaseste_departament_optim(
        v_numar_caz,
        v_id_sectie
    );

    IF v_dept IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE(' *** DEPARTAMENT GASIT ** ');
        DBMS_OUTPUT.PUT_LINE('      -->> ID: ' || v_dept.id_departament);
        DBMS_OUTPUT.PUT_LINE('      -->> Nume: ' || v_dept.nume_departament);
        DBMS_OUTPUT.PUT_LINE('      -->> Specializare: ' || v_dept.specializare);
        DBMS_OUTPUT.PUT_LINE('      -->> Ofiteri: ' || v_dept.nr_ofiteri);
        DBMS_OUTPUT.PUT_LINE('      -->> Cazuri active: ' || v_dept.nr_cazuri_active);
        DBMS_OUTPUT.PUT_LINE(' *** Scor potrivire: ' || v_dept.scor_potrivire || '/100');
    ELSE
        DBMS_OUTPUT.PUT_LINE(' !!! Nu s-a gasit departament disponibil !!!');
    END IF;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE(' SUCCES >>> Test finalizat cu succes');
    DBMS_OUTPUT.PUT_LINE('');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE(' !!! Nu exista date pentru test !!!');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' !!! EROARE: ' || SQLERRM);
END;


-- testam analiza detaliata a unei investigatii ce returneaza un obiect de tip tip_caz_analiza
DECLARE
    v_analiza tip_caz_analiza;
    v_id_caz NUMBER;
BEGIN
    -- iau un caz pentru test
    SELECT id_caz INTO v_id_caz
    FROM CAZ WHERE ROWNUM = 1;

    DBMS_OUTPUT.PUT_LINE(' --->> Test pentru caz ID: ' || v_id_caz);
    DBMS_OUTPUT.PUT_LINE('');

    -- apelez functia de analiza a unei investigatii
    v_analiza := package_investigatii.analizeaza_investigatie_detaliat(v_id_caz);

    IF v_analiza IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE(' ***  ANALIZA COMPLETA  ***');
        DBMS_OUTPUT.PUT_LINE('      -->> ID Caz: ' || v_analiza.id_caz);
        DBMS_OUTPUT.PUT_LINE('      -->> Numar caz: ' || v_analiza.numar_caz);
        DBMS_OUTPUT.PUT_LINE('      -->> Tip caz: ' || v_analiza.tip_caz);
        DBMS_OUTPUT.PUT_LINE('  ** Scor progres: ' || v_analiza.scor_progres || '/100');
        DBMS_OUTPUT.PUT_LINE('      -->> Probe: ' || v_analiza.nr_probe_analizate || '/' || v_analiza.nr_probe);
        DBMS_OUTPUT.PUT_LINE('      -->> Suspecti: ' || v_analiza.nr_suspecti);
        DBMS_OUTPUT.PUT_LINE('      -->> Nivel urgenta: ' || v_analiza.nivel_urgenta);

        IF LENGTH(v_analiza.recomandari) > 0 THEN
            DBMS_OUTPUT.PUT_LINE('  -->> Recomandari: ' || v_analiza.recomandari);
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE(' !!! Nu s-a putut analiza cazul !!!');
    END IF;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE(' SUCCES >>> Test finalizat cu succes');
    DBMS_OUTPUT.PUT_LINE('');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE(' !!! Nu exista cazuri pentru test !!!');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' !!! EROARE: ' || SQLERRM);
END;

-- test pentru obtinerea listei tuturor departamentelor ce returneaza colectie
DECLARE
    v_lista tip_lista_departament;
    v_id_sectie NUMBER;
    v_numar_caz VARCHAR2(50);
BEGIN
    SELECT id_sectie INTO v_id_sectie
    FROM SECTIE_POLITIE WHERE ROWNUM = 1;

    SELECT numar_caz INTO v_numar_caz
    FROM CAZ WHERE ROWNUM = 1;

    DBMS_OUTPUT.PUT_LINE(' --->> Test pentru:');
    DBMS_OUTPUT.PUT_LINE('      -->> Sectie: ' || v_id_sectie);
    DBMS_OUTPUT.PUT_LINE('      -->> Caz: ' || v_numar_caz);
    DBMS_OUTPUT.PUT_LINE('');

    -- apelez functia ce mi returneaza lista departamentelor
    v_lista := package_investigatii.obtine_lista_departamente(
        v_numar_caz,
        v_id_sectie
    );

    IF v_lista IS NOT NULL AND v_lista.COUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE(' **  LISTA DEPARTAMENTE **');
        DBMS_OUTPUT.PUT_LINE(' -->> Total departamente: ' || v_lista.COUNT);
        DBMS_OUTPUT.PUT_LINE('');

        -- parcurg colectia si afisez
        FOR i IN v_lista.FIRST .. v_lista.LAST LOOP
            DBMS_OUTPUT.PUT_LINE('  [' || i || '] ' || v_lista(i).nume_departament);
            DBMS_OUTPUT.PUT_LINE('      -> Scor: ' || v_lista(i).scor_potrivire || '/100');
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE(' !!! Nu exista departamente !!!');
    END IF;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE(' SUCCESS >>> Test finalizat cu succes');
    DBMS_OUTPUT.PUT_LINE('');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE(' !!! Nu exista date pentru test !!!');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' !!! EROARE >> ' || SQLERRM);
END;

-- testam asignarea automata a unui caz
DECLARE
    v_id_caz NUMBER;
BEGIN
    -- iau un caz activ
    SELECT id_caz INTO v_id_caz
    FROM CAZ
    WHERE status_caz IN ('activ', 'in așteptare')
      AND ROWNUM = 1;

    DBMS_OUTPUT.PUT_LINE(' -->> Test pentru caz ID: ' || v_id_caz);

    -- asignez efectiv cazul
    package_investigatii.asigneaza_caz_automat(v_id_caz);

    DBMS_OUTPUT.PUT_LINE(' SUCCESS >>> Test finalizat cu succes');
    DBMS_OUTPUT.PUT_LINE('');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE(' !!! Nu exista cazuri active pentru test !!!');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' !!! EROARE: ' || SQLERRM);
END;

-- testam analiza investigatiei
DECLARE
    v_id_caz NUMBER;
BEGIN
    SELECT id_caz INTO v_id_caz
    FROM CAZ WHERE ROWNUM = 1;

    DBMS_OUTPUT.PUT_LINE('Test pentru caz ID: ' || v_id_caz);
    DBMS_OUTPUT.PUT_LINE('');

    -- analizam efectiv investigatia
    package_investigatii.analizeaza_investigatie(v_id_caz);

    DBMS_OUTPUT.PUT_LINE(' SUCCESS >>> Test finalizat cu succes');
    DBMS_OUTPUT.PUT_LINE('');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE(' !!! Nu exista cazuri pentru test !!!');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' !!! EROARE: ' || SQLERRM);
END;


-- testez procedura de comparatie intre departamente
DECLARE
    v_id_sectie NUMBER;
    v_numar_caz VARCHAR2(50);
BEGIN
    SELECT id_sectie INTO v_id_sectie
    FROM SECTIE_POLITIE WHERE ROWNUM = 1;

    SELECT numar_caz INTO v_numar_caz
    FROM CAZ WHERE ROWNUM = 1;

    DBMS_OUTPUT.PUT_LINE(' --->> Test pentru:');
    DBMS_OUTPUT.PUT_LINE('  -->> Sectie: ' || v_id_sectie);
    DBMS_OUTPUT.PUT_LINE('  -->> Caz: ' || v_numar_caz);
    DBMS_OUTPUT.PUT_LINE('');

    -- compar efectiv
    package_investigatii.compara_departamente(v_numar_caz, v_id_sectie);

    DBMS_OUTPUT.PUT_LINE(' SUCCESS >>> Test finalizat cu succes');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE(' !!! Nu exista date pentru test !!!');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' !!! EROARE: ' || SQLERRM);
END;

-- tastam raportul de performanta pentru o sectie
DECLARE
    v_id_sectie NUMBER;
BEGIN
    SELECT id_sectie INTO v_id_sectie
    FROM SECTIE_POLITIE WHERE ROWNUM = 1;

    package_investigatii.raport_departamente(v_id_sectie);

    DBMS_OUTPUT.PUT_LINE(' SUCCES >>> Test finalizat cu succes');
    DBMS_OUTPUT.PUT_LINE('');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE(' !!! Nu exista secții pentru test !!!');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' !!! EROARE: ' || SQLERRM);
END;

-- testam efectiv exceptiile
-- pt departament inexistent
DECLARE
    v_scor NUMBER;
BEGIN
    v_scor := package_investigatii.calculeaza_scor_potrivire(99999, '2024/OMO/001');
    DBMS_OUTPUT.PUT_LINE(' SUCCESS >>> Scor pentru departament inexistent: ' || v_scor);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' !!! Exceptie: ' || SQLERRM);
END;

-- TEST COMPLET!!!! -- scenariu complet pentru intrarea unui caz in sistem, pana la raportele de performanta finale
DECLARE
    v_id_caz_nou NUMBER;
    v_id_sectie NUMBER;
    v_id_departament NUMBER;
    v_numar_caz_nou VARCHAR2(50);
    v_dept tip_informatii_departament;
BEGIN
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(' ******* TEST COMPLET -->> de la intrarea unui nou caz in sistem pana la rapoartele finale ****** ');

    -- iau datele de test
    SELECT id_sectie INTO v_id_sectie
    FROM SECTIE_POLITIE WHERE ROWNUM = 1;

    SELECT id_departament INTO v_id_departament
    FROM DEPARTAMENT WHERE id_sectie = v_id_sectie AND ROWNUM = 1;

    -- pas 1 -->> creez un caz nou
    DBMS_OUTPUT.PUT_LINE(' >>> PASUL 1: Creare caz nou');

    INSERT INTO CAZ (
        id_departament, numar_caz, tip_caz, prioritate_caz, status_caz,
        data_incidentului, data_raportare, data_deschidere_caz, oras, tara
    ) VALUES (
        v_id_departament,
        '2026/OMO/3007',
        'Omor', 'critica', 'activ',
        SYSTIMESTAMP, SYSTIMESTAMP, SYSDATE,
        'Bucuresti', 'Romania'
    ) RETURNING id_caz INTO v_id_caz_nou;
    v_numar_caz_nou := '2026/OMO/3007';

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('  SUCCESS >>> Caz creat cu ID: ' || v_id_caz_nou);

    -- pas 2 -->> compar departamenele
    DBMS_OUTPUT.PUT_LINE(' >>> PASUL 2: Analiza departamente disponibile');

    package_investigatii.compara_departamente(
        v_numar_caz_nou,
        v_id_sectie
    );

    -- pas 3 -->> asignarea automata a cazului la departamentul optim
    DBMS_OUTPUT.PUT_LINE(' >>> PASUL 3: Asignare automata a cazului la departamentul optim');
    package_investigatii.asigneaza_caz_automat(v_id_caz_nou);

    -- pasul 4 ->> adaug probele la caz
    DBMS_OUTPUT.PUT_LINE(' >>> PASUL 4: Adaugare probe la caz');

    INSERT INTO PROBA (
        id_caz, numar_evidenta, tip_proba, categorie_proba,
        data_colectare, conditie_proba, status_analiza, rezultat_analiza, proba_judecata
    ) VALUES (
        v_id_caz_nou, 'PROBA-TEST-001', 'biologica', 'ADN',
        SYSDATE, 'intacta', 'in asteptare', 'TEST', 'N'
    );

    INSERT INTO PROBA (
        id_caz, numar_evidenta, tip_proba, categorie_proba,
        data_colectare, conditie_proba, status_analiza, rezultat_analiza, proba_judecata
    ) VALUES (
        v_id_caz_nou, 'PROBA-TEST-002', 'biologica', 'amprenta',
        SYSDATE, 'descompusa', 'analizata', 'TEST', 'N'
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('  SUCCESS >>> 2 probe adaugate');

    -- pas 5 -->> adaug suspect
    DBMS_OUTPUT.PUT_LINE(' >>> PASUL 5: Adaugare suspect');

    BEGIN
        DECLARE
            v_id_suspect NUMBER;
        BEGIN
            SELECT id_suspect INTO v_id_suspect
            FROM SUSPECT WHERE ROWNUM = 1;

            INSERT INTO CAZ_SUSPECT (
                id_caz, id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare, data_adaugare
            ) VALUES (
                v_id_caz_nou, v_id_suspect, 'retinut', 'ridicat',
                      'TEST', 'TEST', SYSDATE, SYSDATE
            );

            COMMIT;
            DBMS_OUTPUT.PUT_LINE('  SUCCESS >>> Suspect adaugat');
        END;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('  !!! Nu exista suspecti in baza de date pentru test !!!');
    END;

    -- pas 6 --->> analizez investigatia
    DBMS_OUTPUT.PUT_LINE(' >>> PASUL 6: Analiza completa investigatie');
    package_investigatii.analizeaza_investigatie(v_id_caz_nou);

    -- pas 7 -->> raport per departamente
    DBMS_OUTPUT.PUT_LINE(' >>> PASUL 7: Raport performanta dupa adaugare caz');
    package_investigatii.raport_departamente(v_id_sectie);

    -- curat datele adaugate
    DELETE FROM CAZ_SUSPECT WHERE id_caz = v_id_caz_nou;
    DELETE FROM PROBA WHERE id_caz = v_id_caz_nou;
    DELETE FROM CAZ WHERE id_caz = v_id_caz_nou;
    COMMIT;


    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(' SUCCESS >>> SCENARIU COMPLET FINALIZAT CU SUCCES ');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE(' !!! EROARE: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Rollback efectuat');
END;