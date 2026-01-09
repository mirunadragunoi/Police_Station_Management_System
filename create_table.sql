-- CERINTA 4 PROIECT

-- CREAREA TABELELOR

-- SECTIE_POLITIE (#id_secție (PK), nume_secție, cod_secție, numar_telefon, email, oras, tara)

CREATE TABLE SECTIE_POLITIE(
    id_sectie NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nume_sectie VARCHAR2(100) NOT NULL,
    cod_sectie VARCHAR2(50) UNIQUE NOT NULL,
    numar_telefon VARCHAR2(20),
    email VARCHAR2(50),
    oras VARCHAR2(100) NOT NULL,
    tara VARCHAR2(100) DEFAULT 'Romania' NOT NULL,

    -- constrangeri pt numarul de telefon si pt email
    CONSTRAINT chk_sectie_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_sectie_telefon CHECK (numar_telefon IS NULL OR REGEXP_LIKE(numar_telefon, '^[0-9+() -]+$'))
);

-- SPECIALIZARE (#id_specializare (PK), nume_specializare, cod_specializare, nivel_urgenta, risc_ocupational)

CREATE TABLE SPECIALIZARE(
    id_specializare NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nume_specializare VARCHAR2(100) NOT NULL,
    cod_specializare VARCHAR2(50) UNIQUE NOT NULL,
    nivel_urgenta VARCHAR2(20) DEFAULT 'scazut' NOT NULL,
    risc_ocupational VARCHAR2(20) DEFAULT 'minim' NOT NULL,

    -- constrangeri pt nivelul de urgenta si riscul ocupational
    CONSTRAINT chk_nivel_urgenta CHECK (nivel_urgenta in ('scazut', 'mediu', 'ridicat', 'critic')),
    CONSTRAINT chk_risc_ocupational CHECK (risc_ocupational IN ('minim', 'scazut', 'mediu', 'ridicat'))
);

-- DEPARTAMENT (#id_departament (PK), #id_sectie (FK), #id_specializare (FK), nume_departament, cod_departament,
-- locatie_cladire, numar_telefon)

CREATE TABLE DEPARTAMENT(
    id_departament NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_sectie NUMBER NOT NULL,
    id_specializare NUMBER NOT NULL,
    nume_departament VARCHAR2(150) NOT NULL,
    cod_departament VARCHAR2(50) UNIQUE NOT NULL,
    locatie_cladire VARCHAR2(100),
    numar_telefon VARCHAR2(20),

    -- cheile externe
    CONSTRAINT fk_departament_sectie FOREIGN KEY (id_sectie)
        REFERENCES SECTIE_POLITIE(id_sectie) ON DELETE CASCADE,
    CONSTRAINT fk_departament_specializare FOREIGN KEY (id_specializare)
        REFERENCES SPECIALIZARE(id_specializare) ON DELETE CASCADE,

    -- constrangeri numar de telefon
    CONSTRAINT chk_departament_telefon CHECK (numar_telefon IS NULL OR REGEXP_LIKE(numar_telefon, '^[0-9+() -]+$'))
);

-- OFITER (#id_ofiter (PK), cod_ofiter, nume, prenume, pozitie, #id_departament (FK), #id_supervizor (FK),
-- data_angajare, data_nastere)

CREATE TABLE OFITER(
    id_ofiter NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_departament NUMBER NOT NULL,
    id_supervizor NUMBER,
    cod_ofiter VARCHAR2(50) UNIQUE NOT NULL,
    nume VARCHAR2(50) NOT NULL,
    prenume VARCHAR2(50) NOT NULL,
    pozitie VARCHAR2(50) NOT NULL,
    data_angajare DATE DEFAULT SYSDATE NOT NULL,
    data_nastere DATE NOT NULL,

    -- cheile externe
    CONSTRAINT fk_ofiter_departament FOREIGN KEY (id_departament)
        REFERENCES DEPARTAMENT(id_departament) ON DELETE CASCADE,
    CONSTRAINT fk_ofiter_supervizor FOREIGN KEY (id_supervizor)
        REFERENCES OFITER(id_ofiter) ON DELETE SET NULL,

    -- constrangerile pt
    -- 1) pozitia pt ofiter
    CONSTRAINT chk_ofiter_pozitie CHECK (pozitie IN (
        'Agent', 'Agent sef', 'Subinspector', 'Inspector',
        'Inspector sef', 'Comisar', 'Comisar sef'
    ))
);

COMMIT;

-- trebuie sa creez un trigger pentru a avea grija ca la insert si update pe tabela OFITER, sa verific ca id_supervizor
-- sa fie diferit de id_ofiter (un ofiter nu se poate superviza singur) + sa verific ca un ofiter are varsta legala

-- !!! nu pot face constrangere cu check direct din create table deoarece:
--     - cand folosesc GENERATED ALWAYS AS IDENTITY PRIMARY KEY, id_ofiter este generat dupa ce constrangerile cu
--     check sunt evaluate
--     - folosind trigger ul -> acesta se executa dupa ce id_ofiter a fost generat, dar inainte ca inregistrarea sa
--     fie salvata in baza de date
--     - nu pot folosi SYSDATE direct in constrangerile cu check

CREATE OR REPLACE TRIGGER trigger_ofiter
BEFORE INSERT OR UPDATE ON OFITER
FOR EACH ROW
DECLARE
    v_varsta NUMBER;
BEGIN
    -- validare varsta
    v_varsta := MONTHS_BETWEEN(SYSDATE, :NEW.data_nastere) / 12;
    IF v_varsta < 18 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Varsta minima trebuie sa fie de 18 ani!');
    END IF;

    -- validare pentru supervizor
    IF :NEW.id_supervizor IS NOT NULL AND :NEW.id_ofiter = :NEW.id_supervizor THEN
        RAISE_APPLICATION_ERROR(-20001, 'Un ofiter nu poate fi propriul sau supervizor');
    END IF;
END;

-- CAZ (#id_caz (PK), #id_departament (FK), numar_caz, tip_caz, prioritate_caz, status_caz, data_incidentului,
-- data_raportare, data_deschidere_caz, data_inchidere_caz, oras, tara)

CREATE TABLE CAZ(
    id_caz NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_departament NUMBER NOT NULL,
    numar_caz VARCHAR2(50) UNIQUE NOT NULL,
    tip_caz VARCHAR2(100) NOT NULL,
    prioritate_caz VARCHAR2(20) DEFAULT 'medie' NOT NULL,
    status_caz VARCHAR2(30) DEFAULT 'activ' NOT NULL,
    data_incidentului TIMESTAMP NOT NULL,
    data_raportare TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    data_deschidere_caz DATE DEFAULT SYSDATE NOT NULL,
    data_inchidere_caz DATE,
    oras VARCHAR2(100) NOT NULL,
    tara VARCHAR2(100) DEFAULT 'Romania' NOT NULL,

    -- cheie externa
    CONSTRAINT fk_caz_departament FOREIGN KEY (id_departament)
        REFERENCES DEPARTAMENT(id_departament) ON DELETE CASCADE,

    -- constrangeri
    -- prioritatea cazului
    CONSTRAINT chk_caz_prioritate CHECK (prioritate_caz IN ('scazuta', 'medie', 'ridicata', 'critica', 'urgenta maxima')),
    -- statusul cazului predefinit
    CONSTRAINT chk_caz_status CHECK (status_caz IN (
        'activ', 'suspendat', 'in asteptare', 'rezolvat',
        'inchis - nesolutionat', 'trimis in judecata'
    )),
    -- data raportarii trebuie sa fie dupa data incidentului
    CONSTRAINT chk_caz_date CHECK (data_incidentului <= data_raportare),
    -- data inchiderii cazului sa fie dupa deschidere
    CONSTRAINT chk_caz_inchidere CHECK (data_inchidere_caz IS NULL OR data_inchidere_caz >= data_deschidere_caz)
);

-- PROBA(#id_proba (PK), #id_caz (FK), numar_evidenta, tip_proba, categorie_proba, data_colectare, conditie_proba,
-- status_analiza, rezultat_analiza, proba_judecata)

CREATE TABLE PROBA(
    id_proba NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_caz NUMBER NOT NULL,
    numar_evidenta VARCHAR2(50) UNIQUE NOT NULL,
    tip_proba VARCHAR2(50) NOT NULL,
    categorie_proba VARCHAR2(50) NOT NULL,
    data_colectare TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    conditie_proba VARCHAR2(30) DEFAULT 'intacta' NOT NULL,
    status_analiza VARCHAR2(30) DEFAULT 'nepreluata' NOT NULL,
    rezultat_analiza VARCHAR2(500),
    proba_judecata CHAR(1) DEFAULT 'N' NOT NULL,

    -- cheie externa
    CONSTRAINT fk_proba_caz FOREIGN KEY (id_caz)
        REFERENCES CAZ(id_caz) ON DELETE CASCADE,

    -- constrangeri
    CONSTRAINT chk_proba_tip CHECK (tip_proba IN (
        'biologica', 'balistica', 'digitala', 'documentara', 'fizica', 'testimoniala'
    )),
    CONSTRAINT chk_proba_conditie CHECK (conditie_proba IN (
        'intacta', 'deteriorata partial', 'contaminata', 'descompusa', 'perfect conservata'
    )),
    CONSTRAINT chk_proba_status_analiza CHECK (status_analiza IN (
        'nepreluata', 'in asteptare', 'in analiza', 'analizata',
        'rezultate disponibile', 'inadecvata pentru analiza'
    )),
    CONSTRAINT chk_proba_judecata CHECK (proba_judecata IN ('D', 'N'))
);

-- SUSPECT(#id_suspect (PK), nume, prenume, data_nasterii, gen, numar_telefon, nivel_pericol, armat, amprenta)

CREATE TABLE SUSPECT (
    id_suspect NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nume VARCHAR2(50) NOT NULL,
    prenume VARCHAR2(50) NOT NULL,
    data_nasterii DATE NOT NULL,
    gen VARCHAR2(10) NOT NULL,
    numar_telefon VARCHAR2(20),
    nivel_pericol VARCHAR2(20) DEFAULT 'mediu' NOT NULL,
    armat CHAR(1) DEFAULT 'N' NOT NULL,
    amprenta VARCHAR2(100),

    -- constrangeri
    CONSTRAINT chk_suspect_gen CHECK (gen IN ('masculin', 'feminin')),
    CONSTRAINT chk_suspect_pericol CHECK (nivel_pericol IN (
        'scazut', 'mediu', 'ridicat', 'extrem'
    )),
    CONSTRAINT chk_suspect_armat CHECK (armat IN ('D', 'N')),
    CONSTRAINT chk_suspect_telefon CHECK (numar_telefon IS NULL OR REGEXP_LIKE(numar_telefon, '^[0-9+() -]+$'))
);

-- VICTIMA(#id_victima (PK), nume, prenume, genul, data_nastere, inaltime, greutate, culoarea_ochilor,
-- culoarea_parului, numar_telefon, email, oras, tara)

CREATE TABLE VICTIMA (
    id_victima NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nume VARCHAR2(50) NOT NULL,
    prenume VARCHAR2(50) NOT NULL,
    genul VARCHAR2(10) NOT NULL,
    data_nastere DATE NOT NULL,
    inaltime NUMBER(3),
    greutate NUMBER(5,2),
    culoarea_ochilor VARCHAR2(20),
    culoarea_parului VARCHAR2(20),
    numar_telefon VARCHAR2(20),
    email VARCHAR2(100),
    oras VARCHAR2(100),
    tara VARCHAR2(100) DEFAULT 'Romania',

    -- constrangeri
    CONSTRAINT chk_victima_gen CHECK (genul IN ('masculin', 'feminin')),
    CONSTRAINT chk_victima_inaltime CHECK (inaltime BETWEEN 50 AND 250),
    CONSTRAINT chk_victima_greutate CHECK (greutate BETWEEN 2 AND 300),
    CONSTRAINT chk_victima_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_victima_telefon CHECK (numar_telefon IS NULL OR REGEXP_LIKE(numar_telefon, '^[0-9+() -]+$'))
);

-- TABELELE ASOCIATIVE

-- CAZ_SUSPECT(#id_caz, #id_suspect, status_suspect, nivel_suspiciune, alibi, motiv_suspiciune, data_interogare,
-- data_adaugare)

CREATE TABLE CAZ_SUSPECT (
    id_caz NUMBER NOT NULL,
    id_suspect NUMBER NOT NULL,
    status_suspect VARCHAR2(30) DEFAULT 'sub investigatie' NOT NULL,
    nivel_suspiciune VARCHAR2(20) DEFAULT 'mediu' NOT NULL,
    alibi VARCHAR2(500),
    motiv_suspiciune VARCHAR2(500) NOT NULL,
    data_interogare TIMESTAMP,
    data_adaugare DATE DEFAULT SYSDATE NOT NULL,

    -- cheia primara
    CONSTRAINT pk_caz_suspect PRIMARY KEY (id_caz, id_suspect),

    -- cheile straine
    CONSTRAINT fk_cazsuspect_caz FOREIGN KEY (id_caz)
        REFERENCES CAZ(id_caz) ON DELETE CASCADE,
    CONSTRAINT fk_cazsuspect_suspect FOREIGN KEY (id_suspect)
        REFERENCES SUSPECT(id_suspect) ON DELETE CASCADE,

    -- constrangeri
    CONSTRAINT chk_cazsuspect_status CHECK (status_suspect IN (
        'sub investigatie', 'retinut', 'arestat', 'eliberat',
        'acuzat formal', 'achitat', 'condamnat'
    )),
    CONSTRAINT chk_cazsuspect_nivel CHECK (nivel_suspiciune IN (
        'scazut', 'mediu', 'ridicat', 'foarte ridicat', 'principal suspect'
    ))
);

-- CAZ_VICTIMA(#id_caz, #id_victima, rol_victima, status_victima, nivel_ranire)

CREATE TABLE CAZ_VICTIMA (
    id_caz NUMBER NOT NULL,
    id_victima NUMBER NOT NULL,
    rol_victima VARCHAR2(50) DEFAULT 'victima directa' NOT NULL,
    status_victima VARCHAR2(30) DEFAULT 'in viata' NOT NULL,
    nivel_ranire VARCHAR2(20) DEFAULT 'medie' NOT NULL,

    -- cheie primara
    CONSTRAINT pk_caz_victima PRIMARY KEY (id_caz, id_victima),

    -- chei externe
    CONSTRAINT fk_cazvictima_caz FOREIGN KEY (id_caz)
        REFERENCES CAZ(id_caz) ON DELETE CASCADE,
    CONSTRAINT fk_cazvictima_victima FOREIGN KEY (id_victima)
        REFERENCES VICTIMA(id_victima) ON DELETE CASCADE,

    -- constrangeri
    CONSTRAINT chk_cazvictima_rol CHECK (rol_victima IN (
        'victima directa', 'victima secundara', 'martor victimizat',
        'ruda victima indirecta', 'supravietuitor'
    )),
    CONSTRAINT chk_cazvictima_status CHECK (status_victima IN (
        'in viata - recuperare', 'in viata - traumatizata', 'decedata',
        'disparuta', 'spitalizata', 'in protectie', 'relocata'
    )),
    CONSTRAINT chk_cazvictima_ranire CHECK (nivel_ranire IN (
        'niciuna', 'usoara', 'medie', 'grava', 'critica/fatala', 'deces'
    ))
);

COMMIT;

