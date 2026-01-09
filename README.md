# 📊 SISTEM DE GESTIUNE A SECȚIILOR DE POLIȚIE - BAZĂ DE DATE

## 📋 Cuprins

1. [Descriere Generală](#descriere-generală)
2. [Arhitectura Bazei de Date](#arhitectura-bazei-de-date)
3. [Diagrame](#diagrame)
4. [Schema Bazei de Date](#schema-bazei-de-date)
5. [Funcționalități Implementate](#funcționalități-implementate)
6. [Instalare și Configurare](#instalare-și-configurare)
7. [Utilizare](#utilizare)
8. [Cerințe Proiect](#cerințe-proiect)
9. [Tehnologii Folosite](#tehnologii-folosite)
10. [Autor](#autor)

---

## 📖 Descriere Generală

Sistemul de Management a Secțiilor de Poliție este o bază de date complexă Oracle 19c concepută pentru gestionarea eficientă a cazurilor criminale, probelor, suspecților și resurselor umane ale unei instituții polițienești moderne.

### 🎯 Obiective Principale

- **Gestionarea cazurilor criminale** - Tracking complet de la raportare la rezolvare
- **Management probe** - Evidență probe fizice, lanț de custodie, rezultate analize
- **Tracking suspecți și victime** - Bază de date centralizată cu relații complexe
- **Optimizare resurse** - Asignare automată cazuri la departamente specializate
- **Audit și securitate** - Trasabilitate completă modificări date și structură
- **Raportare executivă** - Analiză performanță și predictii

---

## 🏗️ Arhitectura Bazei de Date

### Structură Organizațională
```
POLIȚIA ROMÂNĂ
    ├── SECȚII DE POLIȚIE
    │   ├── DEPARTAMENTE (cu specializări)
    │   │   └── OFIȚERI
    │   └── CAZURI
    │       ├── PROBE
    │       ├── SUSPECȚI
    │       └── VICTIME
    └── SPECIALIZĂRI (Omoruri, Furturi, Cyber, etc.)
```

### Entități Principale

**10 Tabele:**
- **8 Tabele Neasociative:** SECTIE_POLITIE, SPECIALIZARE, DEPARTAMENT, OFITER, CAZ, PROBA, SUSPECT, VICTIMA
- **2 Tabele Asociative:** CAZ_SUSPECT, CAZ_VICTIMA

---

## 📊 Diagrame

### Diagramă ER (Entity-Relationship)

![Diagrama ER](path/to/diagrama_ERD.png)

*Diagrama ER prezintă relațiile dintre entitățile sistemului și cardinalitățile acestora.*

### Diagramă Conceptuală (Model Relațional)

![Diagrama Conceptuală](path/to/diagrama_conceptuala.png)

*Diagrama conceptuală prezintă structura detaliată a tabelelor cu toate atributele, tipurile de date și constrângerile.*
---

## 🗃️ Schema Bazei de Date

### 1. SECTIE_POLITIE - Reprezintă unitățile polițienești la nivel de secție (ex: Secția 1 Poliție București)

### 2. SPECIALIZARE - Tipurile de specializări disponibile (Omoruri - OMO, Furturi - FURT, Cyber - CYB, etc.)

### 3. DEPARTAMENT - Departamente specializate în cadrul secțiilor (ex: Departament Omoruri - Secția 1)

### 4. OFITER -  Ofițerii de poliție alocați departamentelor, cu ierarhie (supervizor)

### 5. CAZ - Cazurile criminale gestionate de sistem

### 6. PROBA - Probele colectate pentru cazuri (ADN, amprentă, documente, etc.)

### 7. SUSPECT - Bază de date suspecți (poate fi partajată între cazuri)

### 8. VICTIMA - Bază de date victime

### 9. CAZ_SUSPECT (Tabelă Asociativă) - Relația Many-to-Many între cazuri și suspecți

### 10. CAZ_VICTIMA (Tabelă Asociativă) - Relația Many-to-Many între cazuri și victime

---

## ⚙️ Funcționalități Implementate

### 🔹 Cerința 6: Procedură cu Colecții Oracle

**Procedură:** `generator_raport(p_id_sectie, p_perioada_zile)`

**Colecții folosite:**
1. **INDEX-BY TABLE** - Stocare temporară statistici departamente
2. **NESTED TABLE** - Listă cazuri active
3. **VARRAY** - Top 5 ofițeri cu cele mai multe cazuri

**Output:** Raport complet performanță secție cu statistici detaliate

---

### 🔹 Cerința 7: Cursoare (Explicit + Parametrizat)

**Procedură:** `raport_ierarhie_ofiteri(p_id_sectie)`

**Cursoare implementate:**
- **Cursor EXPLICIT** - Parcurge departamente din secție
- **Cursor PARAMETRIZAT DEPENDENT** - Pentru fiecare departament, preia ofițerii
```sql
BEGIN
    raport_ierarhie_ofiteri(1);
END;
```

**Demonstrează:** Relația de dependență între cursoare (cursor parametrizat primește valori din cursor părinte)

---

### 🔹 Cerința 9: Procedură cu 5+ Tabele și Excepții Proprii

**Procedură:** `transfera_caz_departament(p_id_caz, p_id_dept_destinatie)`

**Tabele folosite:**
1. CAZ
2. DEPARTAMENT
3. SECTIE_POLITIE
4. CAZ_SUSPECT
5. PROBA

**Excepții personalizate:**
- `ex_caz_netransferabil` - Status caz nu permite transfer
- `ex_conflict_sectie` - Departamente din secții diferite
- `ex_departament_supraincarcat` - Departament destinație plin
```sql
BEGIN
    transfera_caz_departament(5, 3);
END;
```

---

### 🔹 Cerința 10: Trigger LMD Nivel COMANDĂ

**Trigger:** `trg_audit_cazuri`

**Caracteristici:**
- **Nivel:** STATEMENT (comandă)
- **Eveniment:** AFTER INSERT OR UPDATE OR DELETE ON CAZ
- **Execuții:** O SINGURĂ DATĂ per comandă SQL (nu per rând!)

**Tabelă audit:** `audit_cazuri`
```sql
-- Se activează o singură dată pentru toate cele 3 INSERT-uri
INSERT ALL
    INTO CAZ (...) VALUES (...)
    INTO CAZ (...) VALUES (...)
    INTO CAZ (...) VALUES (...)
SELECT * FROM DUAL;
```

**Beneficii:** Eficiență mare pentru operații în masă (bulk operations)

---

### 🔹 Cerința 11: Trigger LMD Nivel LINIE

**Trigger:** `trg_audit_probe_linie`

**Caracteristici:**
- **Nivel:** ROW (linie) - `FOR EACH ROW`
- **Eveniment:** AFTER INSERT OR UPDATE OR DELETE ON PROBA
- **Execuții:** Pentru FIECARE rând afectat
- **Acces:** `:OLD` și `:NEW` values

**Tabelă audit:** `audit_probe_detaliat`
```sql
-- Trigger se execută de 3 ori (câte o dată pentru fiecare probă)
INSERT INTO PROBA (...) VALUES (...); -- Execuție 1
INSERT INTO PROBA (...) VALUES (...); -- Execuție 2
INSERT INTO PROBA (...) VALUES (...); -- Execuție 3
```

**Înregistrează:**
- Valori VECHI (`:OLD`) vs. NOI (`:NEW`)
- Ce câmp specific s-a modificat
- Istoric complet modificări per probă

---

### 🔹 Cerința 12: Trigger LDD (DDL)

**Trigger:** `trg_ddl_protectie_politie`

**Caracteristici:**
- **Nivel:** SCHEMA
- **Eveniment:** AFTER DDL (CREATE, ALTER, DROP, TRUNCATE)
- **Protecție:** Blochează DROP/TRUNCATE pe 10 tabele critice

**Tabele protejate:**
- SECTIE_POLITIE, DEPARTAMENT, OFITER, CAZ, PROBA
- SUSPECT, VICTIMA, CAZ_SUSPECT, CAZ_VICTIMA, SPECIALIZARE

**Tabelă audit:** `audit_ddl_politie`
```sql
-- ✅ PERMIS
CREATE TABLE test_tabel (...);
ALTER TABLE test_tabel ADD (coloana VARCHAR2(50));

-- ❌ BLOCAT
DROP TABLE CAZ;  -- Eroare: Tabel critic protejat!
TRUNCATE TABLE PROBA;  -- Eroare: Operație interzisă!
```

**Procedură autonomă:** `proc_audit_ddl_politie` (cu PRAGMA AUTONOMOUS_TRANSACTION)

---

### 🔹 Cerința 13: Pachet cu Tipuri Complexe

**Pachet:** `package_investigatii`

#### Tipuri de Date Complexe

**1. `tip_informatii_departament` (OBJECT TYPE)**
```sql
TYPE tip_informatii_departament AS OBJECT (
    id_departament NUMBER,
    nume_departament VARCHAR2(150),
    specializare VARCHAR2(100),
    nr_ofiteri NUMBER,
    nr_cazuri_active NUMBER,
    scor_potrivire NUMBER
);
```

**2. `tip_caz_analiza` (OBJECT TYPE)**
```sql
TYPE tip_caz_analiza AS OBJECT (
    id_caz NUMBER,
    numar_caz VARCHAR2(50),
    scor_progres NUMBER,
    nr_probe NUMBER,
    nr_suspecti NUMBER,
    nivel_urgenta VARCHAR2(20),
    recomandari VARCHAR2(1000)
);
```

**3. `tip_lista_departament` (NESTED TABLE)**
```sql
TYPE tip_lista_departament AS TABLE OF tip_informatii_departament;
```

#### Funcții (5)

**F1:** `calculeaza_scor_potrivire(p_id_departament, p_numar_caz)` → NUMBER
- Calculează scor 0-100 bazat pe:
  - **Specializare (50p):** Potrivire cod din număr caz (ex: `2024/OMO/001` → `OMO`)
  - **Capacitate (30p):** Număr cazuri active (0-3 cazuri = 30p, 7-8 = 5p)
  - **Experiență (20p):** Număr ofițeri × 5 puncte

**F2:** `gaseste_departament_optim(p_numar_caz, p_id_sectie)` → tip_informatii_departament
- Returnează departamentul cu scorul cel mai mare
- **Returnează obiect complet**, nu doar ID

**F3:** `calculeaza_progres_investigatie(p_id_caz)` → NUMBER
- Scor 0-100 bazat pe:
  - Probe analizate (40p)
  - Suspecți identificați (35p)
  - Status caz (25p)

**F4:** `analizeaza_investigatie_detaliat(p_id_caz)` → tip_caz_analiza
- Returnează **obiect complet** cu analiză investigație
- Include recomandări automate

**F5:** `obtine_lista_departamente(p_numar_caz, p_id_sectie)` → tip_lista_departament
- Returnează **colecție** cu TOATE departamentele și scorurile lor

#### Proceduri (4)

**P1:** `asigneaza_caz_automat(p_id_caz)`
- Asignează automat cazul la departamentul optim
- Folosește `tip_informatii_departament` intern

**P2:** `analizeaza_investigatie(p_id_caz)`
- Afișează analiză completă
- Folosește `tip_caz_analiza` intern

**P3:** `compara_departamente(p_numar_caz, p_id_sectie)`
- Afișează TOATE departamentele cu scoruri comparative
- Folosește `tip_lista_departament` (colecția)

**P4:** `raport_departamente(p_id_sectie)`
- Raport performanță cu statistici

#### Exemplu Utilizare
```sql
-- Asignare automată caz nou
BEGIN
    package_investigatii.asigneaza_caz_automat(15);
END;

-- Analiză investigație
BEGIN
    package_investigatii.analizeaza_investigatie(15);
END;

-- Comparație departamente pentru un caz
BEGIN
    package_investigatii.compara_departamente('2024/OMO/047', 1);
END;

-- Obținere departament optim ca obiect
DECLARE
    v_dept tip_informatii_departament;
BEGIN
    v_dept := package_investigatii.gaseste_departament_optim('2024/OMO/047', 1);
    
    DBMS_OUTPUT.PUT_LINE('Departament: ' || v_dept.nume_departament);
    DBMS_OUTPUT.PUT_LINE('Scor: ' || v_dept.scor_potrivire || '/100');
END;
```

---

## 🚀 Instalare și Configurare

### Prerequisite

- Oracle Database 19c Enterprise Edition Release 19.0.0.0.0
- SQL*Plus sau Oracle SQL Developer
- Utilizator cu privilegii: CREATE TABLE, CREATE PROCEDURE, CREATE TRIGGER, CREATE TYPE

---

## 💻 Utilizare

### Scenarii Comune

#### 1. Adăugare Caz Nou
```sql
INSERT INTO CAZ (
    id_departament, numar_caz, tip_caz, prioritate_caz, status_caz,
    data_incidentului, data_raportare, data_deschidere_caz,
    oras, tara
) VALUES (
    1, '2024/OMO/150', 'Omor', 'critica', 'activ',
    SYSTIMESTAMP, SYSTIMESTAMP, SYSDATE,
    'Bucuresti', 'Romania'
);
```

#### 2. Asignare Automată la Departament Optim
```sql
BEGIN
    package_investigatii.asigneaza_caz_automat(150);
END;
```

#### 3. Adăugare Probe
```sql
INSERT INTO PROBA (
    id_caz, numar_evidenta, tip_proba, categorie_proba,
    data_colectare, conditie_proba, status_analiza
) VALUES (
    150, 'PROBA-2024-1523', 'ADN', 'biologica',
    SYSDATE, 'buna', 'in asteptare'
);
```

#### 4. Asociere Suspect
```sql
INSERT INTO CAZ_SUSPECT (
    id_caz, id_suspect, status_suspect, nivel_suspiciune,
    motiv_suspiciune, data_adaugare
) VALUES (
    150, 45, 'sub investigatie', 'ridicat',
    'Gasit la scena crimei', SYSDATE
);
```

#### 5. Analiză Progres Investigație
```sql
BEGIN
    package_investigatii.analizeaza_investigatie(150);
END;
```

#### 6. Raport Performanță Secție
```sql
BEGIN
    generator_raport(1, 30);  -- Ultimele 30 zile
END;
```

#### 7. Transfer Caz între Departamente
```sql
BEGIN
    transfera_caz_departament(150, 5);
END;
```

---

## 📋 Cerințe Proiect

### ✅ Cerințe Implementate

| # | Cerință | Status | Fișier |
|---|---------|--------|--------|
| 6 | Procedură cu 3 tipuri colecții Oracle | ✅ | `scripts/cerinta6.sql` |
| 7 | Cursoare (explicit + parametrizat dependent) | ✅ | `scripts/cerinta7.sql` |
| 8 | Excepții personalizate | ✅ | `scripts/cerinta8.sql` |
| 9 | Procedură 5+ tabele + excepții proprii | ✅ | `scripts/cerinta9.sql` |
| 10 | Trigger LMD nivel COMANDĂ | ✅ | `scripts/cerinta10.sql` |
| 11 | Trigger LMD nivel LINIE | ✅ | `scripts/cerinta11.sql` |
| 12 | Trigger LDD (DDL) | ✅ | `scripts/cerinta12.sql` |
| 13 | Pachet cu tipuri complexe (2+ tipuri, 2+ funcții, 2+ proceduri) | ✅ | `scripts/cerinta13.sql` |

---

## 🛠️ Tehnologii Folosite

- **Bază de date:** Oracle Database 19c Enterprise Edition Release 19.0.0.0.0
- **Limbaj:** PL/SQL
- **IDE:** DataGrip 2024.3.5

---

## 📂 Structura Proiect
```
police-project-work/
├── README.md                                          
├── diagrams/
│   ├── diagrama_ERD.png                              # diagrama ERD
│   └── diagrama_conceptuala.png                      # diagrama conceptuala
├── scripts/
│   ├── create_tabel.sql                              # schema bazei de date
│   ├── insert_tabel.sql                              # date de test
│   ├── cerinta6.sql                  
│   ├── cerinta7.sql                   
│   ├── cerinta8.sql                  
│   ├── cerinta9.sql         
│   ├── cerinta10.sql           
│   ├── cerinta11.sql              
│   ├── cerinta12.sql                
│   └── cerinta13.sql                    
├── docs/
│   ├── SGBD - Cerinte Proiect 2025-2026.pdf          # cerinte proiect
│   ├── SGBD_Proiect_Dragunoi_Miruna.docx             # implementare proiect
└──└── Cod_Text_Proiect_SGBD_Dragunoi_Miruna.txt     # codul proiectului in formate text
```

---

## 🎓 Concepte Demonstrate

### 1. Normalizare Bază de Date
- **Formă normală 3 (3NF)** - Eliminare dependențe tranzitive
- **Relații Many-to-Many** - Tabele asociative CAZ_SUSPECT, CAZ_VICTIMA
- **Relații ierarhice** - OFITER cu supervizor (self-join)

### 2. Integritate Referențială
- **Chei primare** - Identity columns
- **Chei externe** - cu ON DELETE CASCADE pentru integritate
- **Constrângeri CHECK** - validare valori (status, prioritate, etc.)
- **Constrângeri UNIQUE** - numere evidență unice

### 3. Optimizare
- **Indexuri** - pe chei externe și coloane frecvent căutate
- **Trigger-e nivel comandă** - eficiență pentru bulk operations
- **Colecții** - procesare în memorie pentru performanță
- **Cursoare parametrizate** - reutilizare și eficiență

### 4. Securitate și Audit
- **Trigger-e LDD** - protecție structură bază de date
- **Trigger-e LMD** - audit modificări date
- **Tabele audit** - trasabilitate completă
- **Excepții personalizate** - validări business logic

### 5. Modularitate și Reutilizare
- **Pachete** - encapsulare logică de business
- **Tipuri complexe** - abstractizare date
- **Proceduri** - reutilizare cod
- **Funcții** - calcule reutilizabile

---

## 📞 Contact și Suport

**Autor:** Drăgunoi Miruna
**GitHub:** [@miruna-github](https://github.com/mirunadragunoi-github)  
**Universitate:** Universitatea din București, Facultatea de Matematică și Informatică
**An:** 2024-2025  
**Disciplina:** Sisteme de gestiune a bazelor de date

---

## 📄 Licență

Acest proiect este dezvoltat în scop educațional pentru cursul de Baze de Date.

---

## 🎯 Concluzii

Acest proiect demonstrează implementarea unui sistem de management investigații polițienești complet funcțional folosind Oracle Database 19c. Sistemul implementează concepte avansate de baze de date (normalizare, integritate referențială, trigger-e, pachete, tipuri complexe) și oferă o soluție robustă pentru gestionarea cazurilor criminale.

**Puncte forte:**
- Arhitectură bine structurată și normalizată
- Audit complet și trasabilitate
- Automatizare procese (asignare cazuri, analiză progres)
- Extensibilitate și modularitate
- Securitate la nivel de date și structură

**Lecții învățate:**
- Importanța planificării schemei înainte de implementare
- Utilitatea trigger-elor pentru audit și validări
- Puterea pachetelor pentru encapsulare logică
- Necesitatea testării extensive

---

*Realizat cu ❤️ pentru cursul de Sisteme de gestiune a bazelor de date*
