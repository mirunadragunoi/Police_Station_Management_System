-- CERINTA 5 PROIECT

-- INSERT PENTRU FIECARE TABEL

-- INSERT PENTRU TABELA SECTIE_POLITIE

INSERT INTO SECTIE_POLITIE (nume_sectie, cod_sectie, numar_telefon, email, oras, tara)
VALUES ('Sectia 1 Bucuresti', 'SEC-01-B', '021-313-2001', 'sectia1buc@politia.ro', 'Bucuresti', 'Romania');

INSERT INTO SECTIE_POLITIE (nume_sectie, cod_sectie, numar_telefon, email, oras, tara)
VALUES ('Sectia 2 Bucuresti', 'SEC-02-B', '021-313-2002', 'sectia2buc@politia.ro', 'Bucuresti', 'Romania');

INSERT INTO SECTIE_POLITIE (nume_sectie, cod_sectie, numar_telefon, email, oras, tara)
VALUES ('Sectia 3 Cluj-Napoca', 'SEC-03-CJ', '0264-595-001', 'sectia3cluj@politia.ro', 'Cluj-Napoca', 'Romania');

INSERT INTO SECTIE_POLITIE (nume_sectie, cod_sectie, numar_telefon, email, oras, tara)
VALUES ('Sectia 4 Timisoara', 'SEC-04-TM', '0256-220-001', 'sectia4tim@politia.ro', 'Timisoara', 'Romania');

INSERT INTO SECTIE_POLITIE (nume_sectie, cod_sectie, numar_telefon, email, oras, tara)
VALUES ('Sectia 5 Iasi', 'SEC-05-IS', '0232-213-001', 'sectia5iasi@politia.ro', 'Iasi', 'Romania');

INSERT INTO SECTIE_POLITIE (nume_sectie, cod_sectie, numar_telefon, email, oras, tara)
VALUES ('Sectia 6 Constanta', 'SEC-06-CT', '0241-664-001', 'sectia6ct@politia.ro', 'Constanta', 'Romania');

INSERT INTO SECTIE_POLITIE (nume_sectie, cod_sectie, numar_telefon, email, oras, tara)
VALUES ('Sectia 7 Brasov', 'SEC-07-BV', '0268-407-001', 'sectia7brasov@politia.ro', 'Brasov', 'Romania');

INSERT INTO SECTIE_POLITIE (nume_sectie, cod_sectie, numar_telefon, email, oras, tara)
VALUES ('Sectia 8 Craiova', 'SEC-08-CRV', '0251-408-001', 'sectia8craiova@politia.ro', 'Craiova', 'Romania');

COMMIT;

-- INSERT PENTRU TABELA SPECIALIZARE

INSERT INTO SPECIALIZARE (nume_specializare, cod_specializare, nivel_urgenta, risc_ocupational)
VALUES ('Investigare Omoruri', 'OMO', 'critic', 'ridicat');

INSERT INTO SPECIALIZARE (nume_specializare, cod_specializare, nivel_urgenta, risc_ocupational)
VALUES ('Antidrog', 'ANTI', 'ridicat', 'ridicat');

INSERT INTO SPECIALIZARE (nume_specializare, cod_specializare, nivel_urgenta, risc_ocupational)
VALUES ('Persoane Disparute', 'PERS', 'ridicat', 'mediu');

INSERT INTO SPECIALIZARE (nume_specializare, cod_specializare, nivel_urgenta, risc_ocupational)
VALUES ('Crima Organizata', 'CRIM', 'critic', 'ridicat');

INSERT INTO SPECIALIZARE (nume_specializare, cod_specializare, nivel_urgenta, risc_ocupational)
VALUES ('Furt si Talharie', 'FURT', 'mediu', 'mediu');

INSERT INTO SPECIALIZARE (nume_specializare, cod_specializare, nivel_urgenta, risc_ocupational)
VALUES ('Crime Cibernetice', 'CYBER', 'ridicat', 'scazut');

INSERT INTO SPECIALIZARE (nume_specializare, cod_specializare, nivel_urgenta, risc_ocupational)
VALUES ('Violenta Domestica', 'VIOL', 'ridicat', 'ridicat');

INSERT INTO SPECIALIZARE (nume_specializare, cod_specializare, nivel_urgenta, risc_ocupational)
VALUES ('Frauda Financiara', 'FRAUD', 'mediu', 'scazut');

COMMIT;

-- INSERT PENTRU TABELA DEPARTAMENT

INSERT INTO DEPARTAMENT (id_sectie, id_specializare, nume_departament, cod_departament, locatie_cladire, numar_telefon)
VALUES (1, 1, 'Departament Omoruri - Sectia 1 Bucuresti', 'SEC-01-B-OMO', 'Etaj 3', '021-313-2101');

INSERT INTO DEPARTAMENT (id_sectie, id_specializare, nume_departament, cod_departament, locatie_cladire, numar_telefon)
VALUES (1, 2, 'Departament Antidrog - Sectia 1 Bucuresti', 'SEC-01-B-ANTI', 'Etaj 2', '021-313-2102');

INSERT INTO DEPARTAMENT (id_sectie, id_specializare, nume_departament, cod_departament, locatie_cladire, numar_telefon)
VALUES (2, 1, 'Departament Omoruri - Sectia 2 Bucuresti', 'SEC-02-B-OMO', 'Etaj 4', '021-313-2201');

INSERT INTO DEPARTAMENT (id_sectie, id_specializare, nume_departament, cod_departament, locatie_cladire, numar_telefon)
VALUES (3, 3, 'Departament Persoane Disparute - Sectia 3 Cluj', 'SEC-03-CJ-PERS', 'Parter', '0264-595-301');

INSERT INTO DEPARTAMENT (id_sectie, id_specializare, nume_departament, cod_departament, locatie_cladire, numar_telefon)
VALUES (4, 4, 'Departament Crima Organizata - Sectia 4 Timisoara', 'SEC-04-TM-CRIM', 'Etaj 5', '0256-220-401');

INSERT INTO DEPARTAMENT (id_sectie, id_specializare, nume_departament, cod_departament, locatie_cladire, numar_telefon)
VALUES (5, 5, 'Departament Furt - Sectia 5 Iasi', 'SEC-05-IS-FURT', 'Etaj 1', '0232-213-501');

INSERT INTO DEPARTAMENT (id_sectie, id_specializare, nume_departament, cod_departament, locatie_cladire, numar_telefon)
VALUES (6, 6, 'Departament Crime Cibernetice - Sectia 6 Constanta', 'SEC-06-CT-CYBER', 'Etaj 2', '0241-664-601');

INSERT INTO DEPARTAMENT (id_sectie, id_specializare, nume_departament, cod_departament, locatie_cladire, numar_telefon)
VALUES (7, 7, 'Departament Violenta Domestica - Sectia 7 Brasov', 'SEC-07-BV-VIOL', 'Parter', '0268-407-701');

COMMIT;

-- INSERT PENTRU TABELA OFITER

-- sefi de departament (fara supervizor)
INSERT INTO OFITER (id_departament, id_supervizor, cod_ofiter, nume, prenume, pozitie, data_angajare, data_nastere)
VALUES (1, NULL, 'OF-2020-001', 'Popescu', 'Ion', 'Comisar sef', TO_DATE('2015-03-15', 'YYYY-MM-DD'), TO_DATE('1975-06-20', 'YYYY-MM-DD'));

INSERT INTO OFITER (id_departament, id_supervizor, cod_ofiter, nume, prenume, pozitie, data_angajare, data_nastere)
VALUES (2, NULL, 'OF-2020-002', 'Ionescu', 'Maria', 'Comisar', TO_DATE('2016-07-01', 'YYYY-MM-DD'), TO_DATE('1980-03-12', 'YYYY-MM-DD'));

INSERT INTO OFITER (id_departament, id_supervizor, cod_ofiter, nume, prenume, pozitie, data_angajare, data_nastere)
VALUES (3, NULL, 'OF-2020-003', 'Georgescu', 'Andrei', 'Comisar sef', TO_DATE('2014-01-10', 'YYYY-MM-DD'), TO_DATE('1978-11-05', 'YYYY-MM-DD'));

-- ofiteri subordonati
INSERT INTO OFITER (id_departament, id_supervizor, cod_ofiter, nume, prenume, pozitie, data_angajare, data_nastere)
VALUES (1, 1, 'OF-2021-004', 'Vasilescu', 'Elena', 'Inspector sef', TO_DATE('2018-05-20', 'YYYY-MM-DD'), TO_DATE('1985-09-18', 'YYYY-MM-DD'));

INSERT INTO OFITER (id_departament, id_supervizor, cod_ofiter, nume, prenume, pozitie, data_angajare, data_nastere)
VALUES (1, 1, 'OF-2022-005', 'Dumitrescu', 'Mihai', 'Inspector', TO_DATE('2020-02-14', 'YYYY-MM-DD'), TO_DATE('1990-04-25', 'YYYY-MM-DD'));

INSERT INTO OFITER (id_departament, id_supervizor, cod_ofiter, nume, prenume, pozitie, data_angajare, data_nastere)
VALUES (2, 2, 'OF-2022-006', 'Stan', 'Alexandra', 'Subinspector', TO_DATE('2021-08-01', 'YYYY-MM-DD'), TO_DATE('1992-07-30', 'YYYY-MM-DD'));

INSERT INTO OFITER (id_departament, id_supervizor, cod_ofiter, nume, prenume, pozitie, data_angajare, data_nastere)
VALUES (3, 3, 'OF-2023-007', 'Popa', 'Cristian', 'Inspector', TO_DATE('2022-11-15', 'YYYY-MM-DD'), TO_DATE('1988-12-10', 'YYYY-MM-DD'));

INSERT INTO OFITER (id_departament, id_supervizor, cod_ofiter, nume, prenume, pozitie, data_angajare, data_nastere)
VALUES (2, 2, 'OF-2019-008', 'Munteanu', 'Daniel', 'Comisar', TO_DATE('2013-06-01', 'YYYY-MM-DD'), TO_DATE('1977-02-28', 'YYYY-MM-DD'));

COMMIT;

-- INSERT PENTRU TABELA CAZ
INSERT INTO CAZ (id_departament, numar_caz, tip_caz, prioritate_caz, status_caz, data_incidentului, data_raportare, data_deschidere_caz, data_inchidere_caz, oras, tara)
VALUES (1, '2024/OMO/001', 'Omor', 'critica', 'activ',
        TO_TIMESTAMP('2024-11-15 22:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_TIMESTAMP('2024-11-15 23:15:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2024-11-16', 'YYYY-MM-DD'), NULL, 'Bucuresti', 'Romania');

INSERT INTO CAZ (id_departament, numar_caz, tip_caz, prioritate_caz, status_caz, data_incidentului, data_raportare, data_deschidere_caz, data_inchidere_caz, oras, tara)
VALUES (2, '2024/ANTI/045', 'Trafic de droguri', 'ridicata', 'activ',
        TO_TIMESTAMP('2024-12-01 14:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_TIMESTAMP('2024-12-01 18:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2024-12-02', 'YYYY-MM-DD'), NULL, 'Bucuresti', 'Romania');

INSERT INTO CAZ (id_departament, numar_caz, tip_caz, prioritate_caz, status_caz, data_incidentului, data_raportare, data_deschidere_caz, data_inchidere_caz, oras, tara)
VALUES (3, '2024/OMO/012', 'Tentativa de omor', 'critica', 'rezolvat',
        TO_TIMESTAMP('2024-10-20 19:45:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_TIMESTAMP('2024-10-20 20:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2024-10-21', 'YYYY-MM-DD'), TO_DATE('2024-12-10', 'YYYY-MM-DD'), 'Bucuresti', 'Romania');

INSERT INTO CAZ (id_departament, numar_caz, tip_caz, prioritate_caz, status_caz, data_incidentului, data_raportare, data_deschidere_caz, data_inchidere_caz, oras, tara)
VALUES (4, '2024/PERS/078', 'Persoana disparuta', 'ridicata', 'activ',
        TO_TIMESTAMP('2024-12-20 10:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_TIMESTAMP('2024-12-20 16:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2024-12-20', 'YYYY-MM-DD'), NULL, 'Cluj-Napoca', 'Romania');

INSERT INTO CAZ (id_departament, numar_caz, tip_caz, prioritate_caz, status_caz, data_incidentului, data_raportare, data_deschidere_caz, data_inchidere_caz, oras, tara)
VALUES (5, '2024/CRIM/023', 'Crima organizata - extorcare', 'critica', 'activ',
        TO_TIMESTAMP('2024-11-05 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_TIMESTAMP('2024-11-05 12:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2024-11-06', 'YYYY-MM-DD'), NULL, 'Timisoara', 'Romania');

INSERT INTO CAZ (id_departament, numar_caz, tip_caz, prioritate_caz, status_caz, data_incidentului, data_raportare, data_deschidere_caz, data_inchidere_caz, oras, tara)
VALUES (6, '2024/FURT/156', 'Furt cu efractie', 'medie', 'suspendat',
        TO_TIMESTAMP('2024-09-15 03:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_TIMESTAMP('2024-09-15 08:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2024-09-15', 'YYYY-MM-DD'), NULL, 'Iasi', 'Romania');

INSERT INTO CAZ (id_departament, numar_caz, tip_caz, prioritate_caz, status_caz, data_incidentului, data_raportare, data_deschidere_caz, data_inchidere_caz, oras, tara)
VALUES (7, '2024/CYBER/089', 'Frauda online', 'ridicata', 'activ',
        TO_TIMESTAMP('2024-12-10 12:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_TIMESTAMP('2024-12-11 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2024-12-11', 'YYYY-MM-DD'), NULL, 'Constanta', 'Romania');

INSERT INTO CAZ (id_departament, numar_caz, tip_caz, prioritate_caz, status_caz, data_incidentului, data_raportare, data_deschidere_caz, data_inchidere_caz, oras, tara)
VALUES (8, '2024/VIOL/034', 'Violenta domestica', 'ridicata', 'trimis in judecata',
        TO_TIMESTAMP('2024-11-28 20:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_TIMESTAMP('2024-11-28 21:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2024-11-29', 'YYYY-MM-DD'), TO_DATE('2024-12-20', 'YYYY-MM-DD'), 'Brasov', 'Romania');

COMMIT;

-- INSERT PENTRU TABELA SUSPECT

INSERT INTO SUSPECT (nume, prenume, data_nasterii, gen, numar_telefon, nivel_pericol, armat, amprenta)
VALUES ('Radu', 'Bogdan', TO_DATE('1985-05-10', 'YYYY-MM-DD'), 'masculin', '0721123456', 'extrem', 'D', 'AMP-2024-001');

INSERT INTO SUSPECT (nume, prenume, data_nasterii, gen, numar_telefon, nivel_pericol, armat, amprenta)
VALUES ('Marinescu', 'Victor', TO_DATE('1990-08-22', 'YYYY-MM-DD'), 'masculin', '0732234567', 'ridicat', 'N', 'AMP-2024-002');

INSERT INTO SUSPECT (nume, prenume, data_nasterii, gen, numar_telefon, nivel_pericol, armat, amprenta)
VALUES ('Constantinescu', 'Adrian', TO_DATE('1982-12-05', 'YYYY-MM-DD'), 'masculin', NULL, 'ridicat', 'D', 'AMP-2024-003');

INSERT INTO SUSPECT (nume, prenume, data_nasterii, gen, numar_telefon, nivel_pericol, armat, amprenta)
VALUES ('Ion', 'Gabriel', TO_DATE('1995-03-18', 'YYYY-MM-DD'), 'masculin', '0745345678', 'mediu', 'N', 'AMP-2024-004');

INSERT INTO SUSPECT (nume, prenume, data_nasterii, gen, numar_telefon, nivel_pericol, armat, amprenta)
VALUES ('Stoica', 'Florin', TO_DATE('1988-07-14', 'YYYY-MM-DD'), 'masculin', '0756456789', 'scazut', 'N', NULL);

INSERT INTO SUSPECT (nume, prenume, data_nasterii, gen, numar_telefon, nivel_pericol, armat, amprenta)
VALUES ('Nicolae', 'Marian', TO_DATE('1992-11-30', 'YYYY-MM-DD'), 'masculin', '0767567890', 'ridicat', 'N', 'AMP-2024-006');

INSERT INTO SUSPECT (nume, prenume, data_nasterii, gen, numar_telefon, nivel_pericol, armat, amprenta)
VALUES ('Andreescu', 'Viorel', TO_DATE('1980-01-25', 'YYYY-MM-DD'), 'masculin', NULL, 'extrem', 'D', 'AMP-2024-007');

INSERT INTO SUSPECT (nume, prenume, data_nasterii, gen, numar_telefon, nivel_pericol, armat, amprenta)
VALUES ('Tudor', 'Gheorghe', TO_DATE('1998-09-08', 'YYYY-MM-DD'), 'masculin', '0778678901', 'mediu', 'N', 'AMP-2024-008');

COMMIT;

-- INSERT PENTRU TABELA VICTIMA
INSERT INTO VICTIMA (nume, prenume, genul, data_nastere, inaltime, greutate, culoarea_ochilor, culoarea_parului, numar_telefon, email, oras, tara)
VALUES ('Matei', 'Ana', 'feminin', TO_DATE('1990-04-12', 'YYYY-MM-DD'), 165, 55.5, 'caprui', 'saten', '0721111222', 'ana.matei@email.com', 'Bucuresti', 'Romania');

INSERT INTO VICTIMA (nume, prenume, genul, data_nastere, inaltime, greutate, culoarea_ochilor, culoarea_parului, numar_telefon, email, oras, tara)
VALUES ('Popescu', 'Elena', 'feminin', TO_DATE('1985-08-20', 'YYYY-MM-DD'), 170, 62.0, 'albastri', 'blond', '0732222333', 'elena.popescu@email.com', 'Cluj-Napoca', 'Romania');

INSERT INTO VICTIMA (nume, prenume, genul, data_nastere, inaltime, greutate, culoarea_ochilor, culoarea_parului, numar_telefon, email, oras, tara)
VALUES ('Ionescu', 'Mihaela', 'feminin', TO_DATE('1992-06-15', 'YYYY-MM-DD'), 168, 58.0, 'verzi', 'negru', '0743333444', 'mihaela.ion@email.com', 'Timisoara', 'Romania');

INSERT INTO VICTIMA (nume, prenume, genul, data_nastere, inaltime, greutate, culoarea_ochilor, culoarea_parului, numar_telefon, email, oras, tara)
VALUES ('Georgescu', 'Maria', 'feminin', TO_DATE('1988-12-03', 'YYYY-MM-DD'), 160, 52.0, 'caprui', 'roscat', '0754444555', NULL, 'Iasi', 'Romania');

INSERT INTO VICTIMA (nume, prenume, genul, data_nastere, inaltime, greutate, culoarea_ochilor, culoarea_parului, numar_telefon, email, oras, tara)
VALUES ('Stan', 'Ioana', 'feminin', TO_DATE('1995-02-28', 'YYYY-MM-DD'), 172, 65.0, 'albastri', 'saten', '0765555666', 'ioana.stan@email.com', 'Constanta', 'Romania');

INSERT INTO VICTIMA (nume, prenume, genul, data_nastere, inaltime, greutate, culoarea_ochilor, culoarea_parului, numar_telefon, email, oras, tara)
VALUES ('Popa', 'Andreea', 'feminin', TO_DATE('1993-10-10', 'YYYY-MM-DD'), 166, 60.0, 'verzi', 'blond', NULL, 'andreea.popa@email.com', 'Brasov', 'Romania');

INSERT INTO VICTIMA (nume, prenume, genul, data_nastere, inaltime, greutate, culoarea_ochilor, culoarea_parului, numar_telefon, email, oras, tara)
VALUES ('Dumitru', 'Cristina', 'feminin', TO_DATE('1987-07-22', 'YYYY-MM-DD'), 163, 56.0, 'caprui', 'negru', '0776666777', NULL, 'Craiova', 'Romania');

INSERT INTO VICTIMA (nume, prenume, genul, data_nastere, inaltime, greutate, culoarea_ochilor, culoarea_parului, numar_telefon, email, oras, tara)
VALUES ('Vasilescu', 'Diana', 'feminin', TO_DATE('1991-05-18', 'YYYY-MM-DD'), 169, 61.5, 'albastri', 'saten', '0787777888', 'diana.v@email.com', 'Bucuresti', 'Romania');

COMMIT;


-- INSERT PENTRU TABELA PROBA
INSERT INTO PROBA (id_caz, numar_evidenta, tip_proba, categorie_proba, data_colectare, conditie_proba, status_analiza, rezultat_analiza, proba_judecata)
VALUES (1, 'PROB-2024-OMO-001-A', 'biologica', 'ADN',
        TO_TIMESTAMP('2024-11-16 01:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        'intacta', 'analizata', 'ADN corespunde suspectului ID 1', 'D');

INSERT INTO PROBA (id_caz, numar_evidenta, tip_proba, categorie_proba, data_colectare, conditie_proba, status_analiza, rezultat_analiza, proba_judecata)
VALUES (1, 'PROB-2024-OMO-001-B', 'balistica', 'Glont',
        TO_TIMESTAMP('2024-11-16 02:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        'intacta', 'analizata', 'Calibru 9mm, compatibil cu arma gasita', 'D');

INSERT INTO PROBA (id_caz, numar_evidenta, tip_proba, categorie_proba, data_colectare, conditie_proba, status_analiza, rezultat_analiza, proba_judecata)
VALUES (1, 'PROB-2024-OMO-001-C', 'fizica', 'Amprenta digitala',
        TO_TIMESTAMP('2024-11-16 00:45:00', 'YYYY-MM-DD HH24:MI:SS'),
        'perfect conservata', 'rezultate disponibile', '12 puncte de corespondenta cu suspectul', 'D');

INSERT INTO PROBA (id_caz, numar_evidenta, tip_proba, categorie_proba, data_colectare, conditie_proba, status_analiza, rezultat_analiza, proba_judecata)
VALUES (2, 'PROB-2024-ANTI-045-A', 'fizica', 'Substanta narcotica',
        TO_TIMESTAMP('2024-12-02 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        'intacta', 'analizata', 'Cocaina puritate 85%, greutate 2.5kg', 'D');

INSERT INTO PROBA (id_caz, numar_evidenta, tip_proba, categorie_proba, data_colectare, conditie_proba, status_analiza, rezultat_analiza, proba_judecata)
VALUES (3, 'PROB-2024-OMO-012-A', 'biologica', 'Sange',
        TO_TIMESTAMP('2024-10-21 08:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        'intacta', 'analizata', 'Grup sangvin A+, ADN victima confirmat', 'D');

INSERT INTO PROBA (id_caz, numar_evidenta, tip_proba, categorie_proba, data_colectare, conditie_proba, status_analiza, rezultat_analiza, proba_judecata)
VALUES (5, 'PROB-2024-CRIM-023-A', 'documentara', 'Inregistrare audio',
        TO_TIMESTAMP('2024-11-06 14:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        'intacta', 'analizata', 'Voce identificata - suspect principal', 'D');

INSERT INTO PROBA (id_caz, numar_evidenta, tip_proba, categorie_proba, data_colectare, conditie_proba, status_analiza, rezultat_analiza, proba_judecata)
VALUES (7, 'PROB-2024-CYBER-089-A', 'digitala', 'Hard disk',
        TO_TIMESTAMP('2024-12-11 15:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        'intacta', 'in analiza', NULL, 'N');

INSERT INTO PROBA (id_caz, numar_evidenta, tip_proba, categorie_proba, data_colectare, conditie_proba, status_analiza, rezultat_analiza, proba_judecata)
VALUES (8, 'PROB-2024-VIOL-034-A', 'fizica', 'Fotografie leziuni',
        TO_TIMESTAMP('2024-11-28 22:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        'perfect conservata', 'analizata', 'Vanataipe consistente cu declaratiile victimei', 'D');

COMMIT;

-- INSERT PENTRU TABELA CAZ_SUSPECT
INSERT INTO CAZ_SUSPECT (id_caz, id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare, data_adaugare)
VALUES (1, 1, 'arestat', 'principal suspect', 'Fara alibi credibil', 'ADN gasit la fata locului, amprente pe arma',
        TO_TIMESTAMP('2024-11-17 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-11-16', 'YYYY-MM-DD'));

INSERT INTO CAZ_SUSPECT (id_caz, id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare, data_adaugare)
VALUES (1, 2, 'sub investigatie', 'mediu', 'Pretinde ca era acasa, neverificat', 'Martor ocular raporteaza asemanare fizica',
        TO_TIMESTAMP('2024-11-18 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-11-17', 'YYYY-MM-DD'));

INSERT INTO CAZ_SUSPECT (id_caz, id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare, data_adaugare)
VALUES (2, 3, 'retinut', 'foarte ridicat', 'Fara alibi', 'Prins in flagrant cu substante narcotice',
        TO_TIMESTAMP('2024-12-02 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-12-02', 'YYYY-MM-DD'));

INSERT INTO CAZ_SUSPECT (id_caz, id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare, data_adaugare)
VALUES (2, 4, 'sub investigatie', 'ridicat', 'La serviciu, verificat partial', 'Conexiuni cu suspectul principal, transferuri bancare suspecte',
        NULL, TO_DATE('2024-12-03', 'YYYY-MM-DD'));

INSERT INTO CAZ_SUSPECT (id_caz, id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare, data_adaugare)
VALUES (3, 2, 'condamnat', 'principal suspect', 'Contrazis de probe video', 'Amprenta pe arma crimei, marturie victima',
        TO_TIMESTAMP('2024-10-22 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-10-21', 'YYYY-MM-DD'));

INSERT INTO CAZ_SUSPECT (id_caz, id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare, data_adaugare)
VALUES (5, 1, 'sub investigatie', 'foarte ridicat', NULL, 'Legaturi cu retea de crima organizata, interceptari telefonice',
        NULL, TO_DATE('2024-11-08', 'YYYY-MM-DD'));

INSERT INTO CAZ_SUSPECT (id_caz, id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare, data_adaugare)
VALUES (5, 6, 'retinut', 'ridicat', 'Pretinde ca era in alt oras, neverificat', 'Recunoscut de victima, interceptari',
        TO_TIMESTAMP('2024-11-10 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-11-09', 'YYYY-MM-DD'));

INSERT INTO CAZ_SUSPECT (id_caz, id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare, data_adaugare)
VALUES (5, 7, 'arestat', 'principal suspect', 'Fara alibi', 'Lider de grup, identificat in inregistrari audio',
        TO_TIMESTAMP('2024-11-11 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-11-10', 'YYYY-MM-DD'));

INSERT INTO CAZ_SUSPECT (id_caz, id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare, data_adaugare)
VALUES (6, 5, 'eliberat', 'scazut', 'Alibi verificat si confirmat de 3 martori', 'Asemanare fizica cu descrierea initiala',
        TO_TIMESTAMP('2024-09-16 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-09-15', 'YYYY-MM-DD'));

INSERT INTO CAZ_SUSPECT (id_caz, id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare, data_adaugare)
VALUES (7, 4, 'sub investigatie', 'ridicat', NULL, 'Adresa IP trasata, activitate suspicioasa online',
        NULL, TO_DATE('2024-12-12', 'YYYY-MM-DD'));

INSERT INTO CAZ_SUSPECT (id_caz, id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare, data_adaugare)
VALUES (7, 8, 'sub investigatie', 'mediu', 'Verificare in curs', 'Cont bancar conectat la tranzactii frauduloase',
        NULL, TO_DATE('2024-12-13', 'YYYY-MM-DD'));

INSERT INTO CAZ_SUSPECT (id_caz, id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare, data_adaugare)
VALUES (8, 6, 'acuzat formal', 'principal suspect', 'Fara alibi credibil', 'Marturii multiple victime, istoric violenta',
        TO_TIMESTAMP('2024-11-29 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-11-29', 'YYYY-MM-DD'));

INSERT INTO CAZ_SUSPECT (id_caz, id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare, data_adaugare)
VALUES (3, 7, 'sub investigatie', 'mediu', 'Alibi partial verificat', 'Prezent in zona la ora incidentului, relatie anterioara cu victima',
        TO_TIMESTAMP('2024-10-23 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-10-22', 'YYYY-MM-DD'));

COMMIT;

-- INSERT PENTRU TABELA CAZ_VICTIMA
INSERT INTO CAZ_VICTIMA (id_caz, id_victima, rol_victima, status_victima, nivel_ranire)
VALUES (1, 1, 'victima directa', 'decedata', 'deces');

INSERT INTO CAZ_VICTIMA (id_caz, id_victima, rol_victima, status_victima, nivel_ranire)
VALUES (1, 2, 'martor victimizat', 'in viata - traumatizata', 'usoara');

INSERT INTO CAZ_VICTIMA (id_caz, id_victima, rol_victima, status_victima, nivel_ranire)
VALUES (2, 3, 'victima secundara', 'in viata - recuperare', 'niciuna');

INSERT INTO CAZ_VICTIMA (id_caz, id_victima, rol_victima, status_victima, nivel_ranire)
VALUES (3, 4, 'victima directa', 'in viata - recuperare', 'grava');

INSERT INTO CAZ_VICTIMA (id_caz, id_victima, rol_victima, status_victima, nivel_ranire)
VALUES (3, 8, 'martor victimizat', 'in viata - traumatizata', 'usoara');

INSERT INTO CAZ_VICTIMA (id_caz, id_victima, rol_victima, status_victima, nivel_ranire)
VALUES (4, 5, 'victima directa', 'disparuta', 'niciuna');

INSERT INTO CAZ_VICTIMA (id_caz, id_victima, rol_victima, status_victima, nivel_ranire)
VALUES (5, 6, 'victima directa', 'in protectie', 'medie');

INSERT INTO CAZ_VICTIMA (id_caz, id_victima, rol_victima, status_victima, nivel_ranire)
VALUES (5, 7, 'victima secundara', 'in protectie', 'usoara');

INSERT INTO CAZ_VICTIMA (id_caz, id_victima, rol_victima, status_victima, nivel_ranire)
VALUES (5, 3, 'victima secundara', 'relocata', 'niciuna');

INSERT INTO CAZ_VICTIMA (id_caz, id_victima, rol_victima, status_victima, nivel_ranire)
VALUES (6, 2, 'victima directa', 'in viata - recuperare', 'niciuna');

INSERT INTO CAZ_VICTIMA (id_caz, id_victima, rol_victima, status_victima, nivel_ranire)
VALUES (7, 4, 'victima directa', 'in viata - traumatizata', 'niciuna');

INSERT INTO CAZ_VICTIMA (id_caz, id_victima, rol_victima, status_victima, nivel_ranire)
VALUES (8, 6, 'victima directa', 'spitalizata', 'grava');

INSERT INTO CAZ_VICTIMA (id_caz, id_victima, rol_victima, status_victima, nivel_ranire)
VALUES (8, 1, 'ruda victima indirecta', 'in viata - traumatizata', 'niciuna');

COMMIT;