-- CERINTA 8 PROIECT

-- 8. Formulați în limbaj natural o problemă pe care să o rezolvați folosind un subprogram stocat independent de
-- tip funcție care să utilizeze într-o singură comandă SQL 3 dintre tabelele create. Tratați toate excepțiile care
-- pot apărea, incluzând excepțiile predefinite NO_DATA_FOUND și TOO_MANY_ROWS. Apelați subprogramul astfel încât să
-- evidențiați toate cazurile tratate.

-- CERINTA LIMBAJ NATURAL:
-- Conducerea secției de poliție dorește să evalueze eficiența departamentelor prin calcularea unui scor de
-- performanță. Acest scor se bazează pe trei factori: numărul de ofițeri activi (care arată capacitatea de
-- lucru), numărul de cazuri gestionate (care arată volumul de muncă) și numărul de probe colectate (care
-- arată calitatea investigațiilor). Sistemul trebuie să permită calcularea rapidă a acestui scor pentru
-- orice departament și să gestioneze corect situațiile problematice (departamente inexistente, date invalide).



-- IMPLEMENTARE FUNCTIE

CREATE OR REPLACE FUNCTION calculeaza_scor_departament(
    p_id_departament IN NUMBER
) RETURN NUMBER AS
    -- variabile pt calcul spor
    v_nr_ofiteri NUMBER := 0;
    v_nr_cazuri NUMBER := 0;
    v_nr_probe NUMBER := 0;
    v_scor_total NUMBER := 0;
    v_nume_departament VARCHAR2(100);

    -- constante pt punctaj
    c_puncte_ofiter CONSTANT NUMBER := 10;
    c_puncte_caz CONSTANT NUMBER := 5;
    c_puncte_proba CONSTANT NUMBER := 2;

    -- exceptii personalizate
    e_departament_invalid EXCEPTION;
    e_date_inconsistente EXCEPTION;

BEGIN
    -- validare input
    IF p_id_departament IS NULL THEN
        RAISE e_departament_invalid;
    END IF;

    IF p_id_departament <= 0 THEN
        RAISE e_departament_invalid;
    END IF;

    -- tabelele folosite sunt: DEPARTAMENT, OFITER, CAZ, PROBA
    BEGIN
        SELECT
            d.nume_departament,
            COUNT(DISTINCT o.id_ofiter) AS nr_ofiteri,
            COUNT(DISTINCT c.id_caz) AS nr_cazuri,
            COUNT(DISTINCT p.id_proba) AS nr_probe
        INTO
            v_nume_departament,
            v_nr_ofiteri,
            v_nr_cazuri,
            v_nr_probe
        FROM DEPARTAMENT d
        LEFT JOIN OFITER o ON d.id_departament = o.id_departament
        LEFT JOIN CAZ c ON d.id_departament = c.id_departament
        LEFT JOIN PROBA p ON c.id_caz = p.id_caz
        WHERE d.id_departament = p_id_departament
        GROUP BY d.nume_departament, d.id_departament;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- departamentul nu exista in baza de date
            DBMS_OUTPUT.PUT_LINE('   EXCEPTIE NO_DATA_FOUND:');
            DBMS_OUTPUT.PUT_LINE('   Departamentul cu ID ' || p_id_departament || ' nu exista!');
            RETURN -1;

        WHEN TOO_MANY_ROWS THEN
            -- practic imposibil datorita GROUP BY
            DBMS_OUTPUT.PUT_LINE('   EXCEPTIE TOO_MANY_ROWS:');
            DBMS_OUTPUT.PUT_LINE('   Interogarea a returnat multiple randuri pentru ID ' || p_id_departament);
            RETURN -2;
    END;

    -- verificam datele inconsistente
    IF v_nr_ofiteri < 0 OR v_nr_cazuri < 0 OR v_nr_probe < 0 THEN
        RAISE e_date_inconsistente;
    END IF;

    -- calcul efectiv scor
    v_scor_total := (v_nr_ofiteri * c_puncte_ofiter) +
                    (v_nr_cazuri * c_puncte_caz) +
                    (v_nr_probe * c_puncte_proba);

    -- afisare detalii calcul
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('   CALCUL REUSIT pentru: ' || v_nume_departament);
    DBMS_OUTPUT.PUT_LINE('   ─────────────────────────────────────');
    DBMS_OUTPUT.PUT_LINE('   * Ofiteri activi: ' || v_nr_ofiteri ||
                        ' × ' || c_puncte_ofiter || ' puncte = ' ||
                        (v_nr_ofiteri * c_puncte_ofiter) || ' puncte');
    DBMS_OUTPUT.PUT_LINE('   * Cazuri gestionate: ' || v_nr_cazuri ||
                        ' × ' || c_puncte_caz || ' puncte = ' ||
                        (v_nr_cazuri * c_puncte_caz) || ' puncte');
    DBMS_OUTPUT.PUT_LINE('   * Probe colectate: ' || v_nr_probe ||
                        ' × ' || c_puncte_proba || ' puncte = ' ||
                        (v_nr_probe * c_puncte_proba) || ' puncte');
    DBMS_OUTPUT.PUT_LINE('   ─────────────────────────────────────');
    DBMS_OUTPUT.PUT_LINE('   SCOR TOTAL: ' || v_scor_total || ' puncte');
    DBMS_OUTPUT.PUT_LINE('');

    RETURN v_scor_total;

EXCEPTION
    WHEN e_departament_invalid THEN
        DBMS_OUTPUT.PUT_LINE('   EXCEPTIE PERSONALIZATA (e_departament_invalid):');
        DBMS_OUTPUT.PUT_LINE('   ID departament invalid: ' || NVL(TO_CHAR(p_id_departament), 'NULL'));
        RETURN -3;

    WHEN e_date_inconsistente THEN
        DBMS_OUTPUT.PUT_LINE('   EXCEPTIE PERSONALIZATA (e_date_inconsistente):');
        DBMS_OUTPUT.PUT_LINE('   Date negative sau inconsistente detectate!');
        RETURN -4;

    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('   EXCEPTIE VALUE_ERROR:');
        DBMS_OUTPUT.PUT_LINE('   Eroare de conversie sau valoare invalida!');
        DBMS_OUTPUT.PUT_LINE('   Detalii: ' || SQLERRM);
        RETURN -5;

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('   EXCEPTIE GENERALA NETRATATA:');
        DBMS_OUTPUT.PUT_LINE('   Cod eroare: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('   Mesaj: ' || SQLERRM);
        RETURN -99;

END calculeaza_scor_departament;

-- tratare diferite cazuri
DECLARE
    v_scor NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('*******  TESTEEE ***********');
    DBMS_OUTPUT.PUT_LINE('');

    -- departament existent cu date - caz normal
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('TEST 1: Departament VALID cu date complete');

    v_scor := calculeaza_scor_departament(1); -- exista acest departament

    IF v_scor >= 0 THEN
        DBMS_OUTPUT.PUT_LINE('  Rezultat: Scor calculat = ' || v_scor);
    ELSE
        DBMS_OUTPUT.PUT_LINE('  Rezultat: Cod eroare = ' || v_scor);
    END IF;

    DBMS_OUTPUT.PUT_LINE('');

    -- test 2 -->> departament inexistent -- pt NO_DATA_FOUND
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('TEST 2: Departament INEXISTENT (NO_DATA_FOUND)');

    v_scor := calculeaza_scor_departament(99999);  -- ID inexistent

    IF v_scor = -1 THEN
        DBMS_OUTPUT.PUT_LINE('  Rezultat: Exceptie NO_DATA_FOUND tratata corect!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  Rezultat: Cod eroare = ' || v_scor);
    END IF;

    DBMS_OUTPUT.PUT_LINE('');

    -- test 3 -- input null
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('TEST 3: Input NULL (Validare)');

    v_scor := calculeaza_scor_departament(NULL);

    IF v_scor = -3 THEN
        DBMS_OUTPUT.PUT_LINE('  Rezultat: Input invalid tratat corect!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  Rezultat: Cod eroare = ' || v_scor);
    END IF;

    DBMS_OUTPUT.PUT_LINE('');

    -- test 4 -- input negativ!!
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('TEST 4: Input NEGATIV (Validare)');

    v_scor := calculeaza_scor_departament(-5);

    IF v_scor = -3 THEN
        DBMS_OUTPUT.PUT_LINE('  Rezultat: Input invalid tratat corect!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  Rezultat: Cod eroare = ' || v_scor);
    END IF;

    DBMS_OUTPUT.PUT_LINE('');

    -- test 5 --- departament fara ofiteri/cazuri, cu scor 0
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('TEST 5: Departament GOL (fara ofiteri/cazuri)');

    -- pt departamentele 4, 5, 6, etc nu am ofiteri
    v_scor := calculeaza_scor_departament(5);

    IF v_scor >= 0 THEN
        DBMS_OUTPUT.PUT_LINE('  Rezultat: Scor = ' || v_scor || ' (departament fara activitate)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  Rezultat: Cod eroare = ' || v_scor);
    END IF;
END;

-- afisez scorurile pt toate departamentele (utilizez subprogramul si in select)
SELECT
    d.id_departament,
    d.nume_departament,
    d.cod_departament,
    calculeaza_scor_departament(d.id_departament) AS scor_performanta
FROM DEPARTAMENT d
ORDER BY calculeaza_scor_departament(d.id_departament) DESC;