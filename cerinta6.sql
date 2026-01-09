-- CERINTA 6 PROIECT

-- Formulați în limbaj natural o problemă pe care să o rezolvați folosind un subprogram stocat independent care să
-- utilizeze toate cele 3 tipuri de colecții studiate. Apelați subprogramul.

-- coletiile ce trebuie sa le folosesc:
-- 1) tablouri indexate (index-by tables)
-- 2) tablouri imbricate (nested tables)
-- 3) vectori (varrays sau varying arrays)

-- Formularea enuntului in limbaj natural:

-- Comisarul sef trebuie sa prezinte un raport urgent conducerii legat de eficienta investigatiilor din ultima luna.
-- Sistemul automatizat va cere utilizatorului sa introduca ID-ul sectiei pentru care se doreste raportul, apoi
-- va genera urmatoarele informatii:
--
-- 1) O vedere de ansamblu asupra fiecarui departament din sectia specificata (cati ofiteri lucreaza in fiecare departament si
-- care este gradul de ocupare). Aceasta informatie trebuie sa fie disponibila instant prin acees direct.
--
-- 2) O lista completa cu toti suspectii periculosi care au fost implicati in multiple cazuri din sectia respectiva.
-- Lista poata fi modificata dinamic, adica sa se poata adauga suspecti noi daca se
-- descopera legaturi noi intre cazuri
--
-- 3) Un top 5 al celor mai complexe cazuri active din sectie, masurate prin numarul de probe colectate.



-- Descriere cerinta:
-- 1) am nevoie de acces direct, deci o sa am acces direct prin index -> index-by table
-- 2) adaugare/stergere dinamica de elemente pe masura ce investigatia evolueaza -> nested table
-- 3) exact 5 elemente -> varrays


-- IMPLEMENTARE:

-- predefinire tipuri de date!

-- structura info departament
CREATE OR REPLACE TYPE tip_info_departament AS OBJECT
(
    id_departament NUMBER,
    nume_departament VARCHAR2(150),
    cod_departament VARCHAR2(30),
    nr_ofiteri NUMBER,
    grad_ocupare VARCHAR2(20)
);

-- structura suspect periculos
CREATE OR REPLACE TYPE tip_suspect_periculos AS OBJECT
(
    id_suspect NUMBER,
    nume_complet VARCHAR2(100),
    nivel_pericol VARCHAR2(20),
    nr_cazuri_implicate NUMBER,
    este_armat VARCHAR2(3),
    ultimul_update DATE
);

-- NESTED TABLE pt lista dinamica de suspecti
CREATE OR REPLACE TYPE colectie_suspecti_periculosi AS TABLE OF tip_suspect_periculos;

-- structura pt caz complex
CREATE OR REPLACE TYPE tip_caz_complex AS OBJECT
(
    pozitie_top NUMBER,
    numar_caz VARCHAR2(50),
    tip_infractiune VARCHAR2(100),
    nr_probe_colectate NUMBER,
    nr_probe_analizate NUMBER,
    procent_analizat NUMBER,
    status VARCHAR2(30),
    prioritate VARCHAR2(20)
);

-- VARRAY pt top ul fix de 5 cazuri
CREATE OR REPLACE TYPE colectie_top_cazuri AS VARRAY(5) OF tip_caz_complex;

-- !!! PROCEDURA PRINCIPALA

CREATE OR REPLACE PROCEDURE generator_raport (
    p_id_sectie IN NUMBER,
    p_data_raport IN DATE DEFAULT SYSDATE
)
AS
    -- COLECTIE 1 ->>> index by table pt acces rapid la departamente
    TYPE tip_colectie_departamente IS TABLE OF tip_info_departament INDEX BY PLS_INTEGER;
    v_departamente tip_colectie_departamente;

    -- COLECTIE 2 ->>> nested table pt lista dinamica de suspecti
    v_suspecti_periculosi colectie_suspecti_periculosi;

    -- COLECTIE 3 ->>> varray pt top 5 cazuri complexe
    v_top_cazuri_complexe colectie_top_cazuri;

    -- variabile auxiliare
    v_nume_sectie VARCHAR2(100);
    v_cod_sectie VARCHAR2(20);
    v_total_ofiteri NUMBER := 0;
    v_index_dept PLS_INTEGER := 1;
    v_temp_grad VARCHAR2(20);

BEGIN
    -- verificare sectie
    BEGIN
        SELECT nume_sectie, cod_sectie
        INTO v_nume_sectie, v_cod_sectie
        FROM SECTIE_POLITIE
        WHERE id_sectie = p_id_sectie;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,
            'Sectia cu ID-ul ' || p_id_sectie || ' nu exista in sistem!!!');
    END;

    -- raport
    DBMS_OUTPUT.PUT_LINE('--------- RAPORT INVESTIGATII -------------');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Sectia: ' || v_nume_sectie || ' (' || v_cod_sectie || ')');
    DBMS_OUTPUT.PUT_LINE('Data raport: ' || TO_CHAR(p_data_raport, 'DD-MONTH-YYYY HH24:MI'));
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');

    -- CERINTA 1 - situatia departamentelor cu index by table
    DBMS_OUTPUT.PUT_LINE('****** Situatia departamentelor *******');

    -- populare index by table
    FOR rec_dept IN (
        SELECT
            d.id_departament,
            d.nume_departament,
            d.cod_departament,
            COUNT(o.id_ofiter) AS nr_ofiteri
        FROM DEPARTAMENT d
        LEFT JOIN OFITER o ON d.id_departament = o.id_departament
        WHERE d.id_sectie = p_id_sectie
        GROUP BY d.id_departament, d.nume_departament, d.cod_departament
        ORDER BY d.id_departament
    ) LOOP
        -- calculez gradul de ocupare bazat pe numarul de ofiteri
        IF rec_dept.nr_ofiteri <= 2 THEN
            v_temp_grad := 'SUBINCARCAT';
        ELSIF rec_dept.nr_ofiteri <= 5 THEN
            v_temp_grad := 'NORMAL';
        ELSE
            v_temp_grad := 'SUPRAINCARCAT';
        END IF;

        -- stocare in index by table
        v_departamente(v_index_dept) := tip_info_departament(
            rec_dept.id_departament,
            rec_dept.nume_departament,
            rec_dept.cod_departament,
            rec_dept.nr_ofiteri,
            v_temp_grad
        );

        v_total_ofiteri := v_total_ofiteri + rec_dept.nr_ofiteri;
        v_index_dept := v_index_dept + 1;

        END LOOP;

        -- afisez departamentele
        IF v_departamente.COUNT > 0 THEN
            FOR i IN v_departamente.FIRST .. v_departamente.LAST LOOP
                    DBMS_OUTPUT.PUT_LINE('Departament -> ' || i || ':');
                    DBMS_OUTPUT.PUT_LINE('      Nume: ' || v_departamente(i).nume_departament);
                    DBMS_OUTPUT.PUT_LINE('      Cod: ' || v_departamente(i).cod_departament);
                    DBMS_OUTPUT.PUT_LINE('      Ofiteri: ' || v_departamente(i).nr_ofiteri);
                    DBMS_OUTPUT.PUT_LINE('      Status: ' || v_departamente(i).grad_ocupare);
                    DBMS_OUTPUT.PUT_LINE('');
                END LOOP;
            DBMS_OUTPUT.PUT_LINE('--->>> TOTAL DEPARTAMENTE: ' || v_departamente.COUNT);
            DBMS_OUTPUT.PUT_LINE('--->>> TOTAL OFITERI IN SECTIE: ' || v_total_ofiteri);
            DBMS_OUTPUT.PUT_LINE('--->>> MEDIE OFITERI PER DEPARTAMENT: ' ||
                                 ROUND(v_total_ofiteri / v_departamente.COUNT, 2));

            DBMS_OUTPUT.PUT_LINE('');
        ELSE
            DBMS_OUTPUT.PUT_LINE('!!! NU EXISTA DEPARTAMENTE IN ACEASTA SECTIE!!! ');
        END IF;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE('');

    -- CERINTA 2 - suspecti periculosi cu nested table
    DBMS_OUTPUT.PUT_LINE('****** Suspecti periculosi recidivisti *******');

    -- populare nested table cu bulk collect
    BEGIN
        SELECT tip_suspect_periculos(
            s.id_suspect,
            s.nume || ' ' || s.prenume,
            s.nivel_pericol,
            COUNT(DISTINCT cs.id_caz),
            CASE WHEN s.armat = 'D' THEN 'DA' ELSE 'NU' END,
            SYSDATE
        )
        BULK COLLECT INTO v_suspecti_periculosi
        FROM SUSPECT s
        INNER JOIN CAZ_SUSPECT cs ON s.id_suspect = cs.id_suspect
        INNER JOIN CAZ c ON cs.id_caz = c.id_caz
        INNER JOIN DEPARTAMENT d ON c.id_departament = d.id_departament
        WHERE d.id_sectie = p_id_sectie
          AND s.nivel_pericol IN ('ridicat', 'extrem')
          AND cs.status_suspect NOT IN ('achitat', 'eliberat')
        GROUP BY s.id_suspect, s.nume, s.prenume, s.nivel_pericol, s.armat
        HAVING COUNT(DISTINCT cs.id_caz) >= 2
        ORDER BY s.nivel_pericol DESC, COUNT(DISTINCT cs.id_caz) DESC;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_suspecti_periculosi := colectie_suspecti_periculosi(); -- colectie goala
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Eroare la preluare suspecti: ' || SQLERRM);
            v_suspecti_periculosi := colectie_suspecti_periculosi(); -- coletie goala
    END;

    -- afisez suspectii
    IF v_suspecti_periculosi IS NOT NULL AND v_suspecti_periculosi.COUNT > 0 THEN
        FOR i IN v_suspecti_periculosi.FIRST .. v_suspecti_periculosi.LAST LOOP
            DBMS_OUTPUT.PUT_LINE('Suspect ->' || i || ' - RECIDIVIST PERICULOS');
            DBMS_OUTPUT.PUT_LINE('  --->>> Nume: ' || v_suspecti_periculosi(i).nume_complet);
            DBMS_OUTPUT.PUT_LINE('  --->>> Nivel pericol:  ' ||
                               UPPER(v_suspecti_periculosi(i).nivel_pericol));
            DBMS_OUTPUT.PUT_LINE('  --->>> Cazuri implicate: ' ||
                               v_suspecti_periculosi(i).nr_cazuri_implicate);
            DBMS_OUTPUT.PUT_LINE('  --->>> Armat: ' || v_suspecti_periculosi(i).este_armat);
            DBMS_OUTPUT.PUT_LINE('  --->>> Actualizat: ' ||
                               TO_CHAR(v_suspecti_periculosi(i).ultimul_update, 'DD-MON-YYYY'));
            DBMS_OUTPUT.PUT_LINE('');
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('---->>> Total suspecti periculosi identificati: ' ||
                           v_suspecti_periculosi.COUNT);

    ELSE
        DBMS_OUTPUT.PUT_LINE('!!! Nu exista suspecti recidivisti periculosi activi in sistem !!!');
    END IF;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE('');

    -- CERINTA 3 - top 5 cazuri complexe cu varray
    DBMS_OUTPUT.PUT_LINE('****** Topul celor 5 cazuri cele mai complexe *******');

    -- populare varray
    BEGIN
        SELECT tip_caz_complex(
            ROW_NUMBER() OVER (ORDER BY COUNT(p.id_proba) DESC, c.prioritate_caz DESC),
            c.numar_caz, c.tip_caz, COUNT(p.id_proba),
            COUNT(CASE WHEN p.status_analiza IN ('analizata', 'rezultate disponibile')
                  THEN 1 END),
            CASE
                WHEN COUNT(p.id_proba) > 0 THEN
                    ROUND(COUNT(CASE WHEN p.status_analiza IN ('analizata', 'rezultate disponibile')
                          THEN 1 END) * 100.0 / COUNT(p.id_proba), 1)
                ELSE 0
            END,
            c.status_caz, c.prioritate_caz
        )
        BULK COLLECT INTO v_top_cazuri_complexe
        FROM CAZ c
        INNER JOIN DEPARTAMENT d ON c.id_departament = d.id_departament
        LEFT JOIN PROBA p ON c.id_caz = p.id_caz
        WHERE d.id_sectie = p_id_sectie
          AND c.status_caz IN ('activ', 'in asteptare')
        GROUP BY c.id_caz, c.numar_caz, c.tip_caz, c.status_caz, c.prioritate_caz
        ORDER BY COUNT(p.id_proba) DESC, c.prioritate_caz DESC
        FETCH FIRST 5 ROWS ONLY;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_top_cazuri_complexe := colectie_top_cazuri(); -- coletie goala
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Eroare la preluare cazuri: ' || SQLERRM);
            v_top_cazuri_complexe := colectie_top_cazuri(); -- colectie goala
    END;

    -- afisare top cazuri
    IF v_top_cazuri_complexe IS NOT NULL AND v_top_cazuri_complexe.COUNT > 0 THEN
        FOR i IN v_top_cazuri_complexe.FIRST .. v_top_cazuri_complexe.LAST LOOP
            DBMS_OUTPUT.PUT_LINE('  Pozitia -> ' || v_top_cazuri_complexe(i).pozitie_top);
            DBMS_OUTPUT.PUT_LINE('  --->>> Numar caz: ' || v_top_cazuri_complexe(i).numar_caz);
            DBMS_OUTPUT.PUT_LINE('  --->>> Tip infractiune: ' || v_top_cazuri_complexe(i).tip_infractiune);
            DBMS_OUTPUT.PUT_LINE('  --->>> Probe colectate: ' ||
                               v_top_cazuri_complexe(i).nr_probe_colectate);
            DBMS_OUTPUT.PUT_LINE('  --->>> Probe analizate: ' ||
                               v_top_cazuri_complexe(i).nr_probe_analizate ||
                               ' (' || v_top_cazuri_complexe(i).procent_analizat || '%)');
            DBMS_OUTPUT.PUT_LINE('  --->>> Status: ' || v_top_cazuri_complexe(i).status);
            DBMS_OUTPUT.PUT_LINE('  --->>> Prioritate: ' || v_top_cazuri_complexe(i).prioritate);
            DBMS_OUTPUT.PUT_LINE('');
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('---->>>> Total cazuri in top: ' || v_top_cazuri_complexe.COUNT || ' / 5');
    ELSE
        DBMS_OUTPUT.PUT_LINE('!!! Nu exista cazuri active cu probe colectate.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE('');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE(' EROARE CRITICA IN GENERARE RAPORT: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('BACKTRACE: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        RAISE;
END generator_raport;

-- apelarea procedurii
BEGIN
    DBMS_OUTPUT.PUT_LINE('Initiere generare raport .........');
    generator_raport(
        p_id_sectie => &id_sectie,
        p_data_raport => SYSDATE
    );
END;

DROP TYPE colectie_top_cazuri FORCE;
DROP TYPE tip_caz_complex FORCE;
DROP TYPE colectie_suspecti_periculosi FORCE;
DROP TYPE tip_suspect_periculos FORCE;
DROP TYPE tip_info_departament FORCE;
