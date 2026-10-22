# Stand ENSDF-Prüfung

Auftrag: `Auftrag-ENSDF.md`. Nichts gepusht.

## S0 Daten und Format — erledigt (2026-10-22 17:20), keine Code-Änderung

### Daten
- **Quelle**: NNDC, Archivseite https://www.nndc.bnl.gov/ensdfarchivals/. Die Dateiliste kommt aus
  `distributions/files.json`; dort ist `latest` = `ensdf_261001.zip` (Jahr 2026).
  Download-URL: `https://www.nndc.bnl.gov/ensdfarchivals/distributions/dist26/ensdf_261001.zip`.
- Laut Seite: DOI 10.18139/nndc.ensdf/1845010, „Last modified 2026/09/01“, 20,118 Datensätze,
  3,445 Nuklide, 300 Massenketten (Angaben der Webseite, nicht nachgezählt).
- HTTP `Last-Modified` des Zips: Fri, 02 Oct 2026 10:02:58 GMT. Heruntergeladen am 2026-10-22 17:13 CEST.
- `~/ensdf/raw/ensdf_261001.zip`: 42,479,053 Bytes,
  sha256 2546aefea0190587fdf4d7ceba30eea032e44b1a070b1c3b1ff804e57e913799.
  Die Kopie der Dateiliste liegt in `~/ensdf/raw/files.json`.
- Entpackt nach `~/ensdf/data_261001/`: **300 Dateien** `ensdf.001` … `ensdf.300` (eine je Massenzahl),
  **254 MB**.

### Formathandbuch
- `~/ensdf/manual/ensdf-manual.pdf` von https://www.nndc.bnl.gov/ensdf/ensdf-manual.pdf
  (verlinkt auf der ENSDF-Seite), 686,034 Bytes, 112 Seiten,
  sha256 3400f0ae84d24f252f5bed4e6f0227304df9a4608aceb1d67e609db12605a0e9.
- Laut Titelseite: J. K. Tuli, „Evaluated Nuclear Structure Data File – A Manual for Preparation of
  Data Sets“, BNL-NCS-51655-01/02-Rev, February 2001, NNDC, BNL.
- Text liegt als `manual/m.txt` vor (pdftotext). Seite 46 (V.19/V.20) zusätzlich als Bild gelesen,
  weil die Formeln im Text verstümmelt waren.

### Spalten laut Handbuch (Abschnitt in Klammern)
Alle Records haben 80 Spalten.
- Gemeinsam: 1–5 NUCID (Massenzahl 1–3 rechtsbündig, Element 4–5) (V.1). Spalte 6 ist leer für den
  ersten Record; jedes andere Zeichen außer `1` markiert eine Fortsetzung. 7 leer bzw. `C`/`D` bei
  Kommentaren. 8 = Record-Typ. 9 leer.
- **Level `L`** (III.B.9): 10–19 E in keV, nie leer (V.18) · 20–21 DE (V.11) · **22–39 J = Jπ**
  (V.20) · 40–49 T · 50–55 DT · 56–64 L · 65–74 S · 75–76 DS · 77 C · 78–79 MS · 80 Q (`?` =
  fragliches Niveau, `S` = Separationsenergie oder erwartet, aber nicht beobachtet).
- **Gamma `G`** (III.B.14): steht hinter dem Level, von dem der Übergang ausgeht; unplatzierte
  Gammas stehen vor dem ersten Level. 10–19 E in keV, nie leer · 20–21 DE · 22–29 RI · 30–31 DRI ·
  **32–41 M = Multipolarität** (V.19) · **42–49 MR = Mischungsverhältnis δ** (V.10; Vorzeichen nur
  angegeben, wenn bekannt) · **50–55 DMR** (V.12, auch asymmetrisch `+x-y`) · 56–62 CC · 63–64 DCC ·
  65–74 TI · 75–76 DTI · 77 C (`*`, `&`, `@` = mehrfach platziert) · 78 COIN · 80 Q (`?` =
  unsichere Platzierung, `S` = erwartet, nicht beobachtet).
- **Fortsetzung** (IV.B): 1–5 NUCID, 6 ≠ `1`, 7 leer, 8 RTYPE, ab Spalte 10 Einträge
  `<quant><op><value>`, getrennt durch `$`. Operatoren: `=, <, >, <=, >=, EQ, AP, LT, LE, GT, GE`.
- **`FL=`** (IV.C.2, Gamma): „Final level energy. It must be either identical to a level energy in
  the data set optionally followed by a `?` … or a `?` (if the final level is not known)“.
- **Energie** (V.18): NUM, auch `NUM+X` oder `X+NUM` (unbekannter Offset, Buchstaben X, Y, Z, …),
  `SN+NUM`, `SP+NUM` oder nur ein Buchstabe. Klammern bedeuten „abgeleitet“.
- **Unsicherheit** (V.11): eine Ganzzahl in Einheiten der letzten Stelle(n) oder `LT, GT, LE, GE,
  AP, CA, SY`.
- **Multipolarität** (V.19): `Mult`, `Mult+Mult`, `Mult,Mult`, `NOT Mult`. Dabei ist Mult = E_L
  oder M_L′ (Einzelziffern, L ≥ 0, L′ ≥ 1), `M+E`, `E+M`, `D` oder `Q`. Runde Klammern = „probable“,
  eckige = „assumed or derived“.
- **Jπ** (V.20): `JPI`, `JPI OR JPI` (auch `,`), `JPI AND JPI` (auch `&`), `OP JPI` (OP = AP, LE,
  GE; π gilt, J ist OP J), `NOT JPI`, `JPI TO JPI` (auch `:`, Bereichsregeln a–c), `NATURAL` /
  `UNNATURAL`, `A` oder `A+JPI` (A = J, K, L, …, unbekannter Offset). Klammern = schwache
  Argumente; `(3,4)-` heißt J = (3) oder (4) und π = −. Eckige Klammern = angenommener Wert.
- **Rückstoß**: Das Handbuch erwähnt die Rückstoßkorrektur nicht (nur „recoil distance measurement“
  als Methode). Laut Auftrag gilt dann: keine Korrektur, sondern Toleranz (S3).

### Stichprobe aus den Daten (nur Zählung, kein Code)
- Die Spalten passen, z. B. `178HF  L 93.1803   102+` und `178HF  G 93.1803   10   100    E2`.
- Record-Kennungen in den Spalten 6–9: `  G ` 793,431 · `  L ` 568,228 · Kommentare ` cL `/` cG `
  (kleines `c`, im Handbuch steht `C`/`D`) · Fortsetzungen `X L ` (XREF), `S G ` (maschinell),
  `2 L `, `2 G `. Insgesamt gibt es 34,853 Zeilen mit `FL=`.
- Das M-Feld ist in 560,329 Gammas leer. Häufig sind E2, M1+E2, Q, M1, D, E1, (E2), D+Q, [E2], …
  **In den Daten, aber nicht im Handbuch von 2001**: `M1(+E2)` (5,588), `D(+Q)` (2,809),
  `E1(+M2)`, `E2(+M1)`, `(M1(+E2))`, dreiteilig `E0+M1+E2` (355) und `D,E2`.
  → S2 braucht dafür eine Regel; die Bedeutung von `(+E2)` steht nicht im Handbuch.
- Das J-Feld hat 11,422 verschiedene Werte, ist uneinheitlich bündig und in 170,996 Leveln leer.

### Befunde für S1, Entscheidung durch Daniel
1. In `SelectionRules.lean` (fork/pr/projection-selection, feb886e4) ist
   `IsAllowedMultipole twoIi twoIf πi πf t l := 1 ≤ l ∧ TriangleRule (2l) twoIi twoIf ∧ πf = t.parity l * πi`.
   Es verbindet **Drehimpuls und Parität**. Das Lemma aus dem Auftrag („verletzt ⇔
   ¬IsAllowedMultipole“) trennt A (Drehimpuls) und A′ (nur Parität) also nicht. Vorschlag: zwei
   Urteile in `checkTransition`: `angular` ⇔ ¬(1 ≤ l ∧ TriangleRule …) und `parityOnly`
   (TriangleRule gilt, Parität nicht), dazu je ein Lemma. Die Gesamtaussage
   `violation ⇔ ¬IsAllowedMultipole` bleibt.
2. In PR 08 ist die Parität `ℤ` (±1), im Auftrag `ℤˣ` für `SpinParity`. Vorschlag: `ℤˣ` im Werkzeug,
   beim Aufruf von `IsAllowedMultipole` nach `ℤ` umwandeln, sonst passt `decide` in den Zertifikaten
   nicht direkt.
3. `IsAllowedMultipole` verlangt `1 ≤ l`. Damit wäre E0 immer „verletzt“; E0 gehört aber nach C.
   Das ist so auch im Auftrag vorgesehen, nur festgehalten.
4. Notationen wie `M1(+E2)` stehen nicht im Handbuch von 2001. Vorschlag: wie `M1+E2` behandeln
   (beide Anteile prüfen) und als eigene Unterart zählen. Optional ließe sich das neuere
   `evalcorner/pdfs/ensdf-procedures.pdf` laden, das auf der ENSDF-Seite verlinkt ist (noch nicht
   gelesen).

### Nächster Schritt
S1: Branch `ensdf-check` von `fork/pr/projection-selection`, Datei `Tools/EnsdfCheck/Rules.lean`.
Wasserstoff-Stand: #1909 noch nicht gemergt (origin/master = 8d676858), also kein Rebase fällig.

## S1 Kern in Lean — erledigt (2026-10-22 17:35), Branch `ensdf-check` (lokal, nicht gepusht)
Branch von `fork/pr/projection-selection` (ae59f621; Basis 8a6ce260). Commit **ensdf-check S1**.
`lakefile.toml`: neue `[[lean_lib]] EnsdfCheck` mit `srcDir = "Tools"`. Das `lean_exe` folgt in S4,
damit S1 ohne Linken baut. `PhyslibAlpha.lean` und PR 08 sind unverändert.

`Tools/EnsdfCheck/Rules.lean` (Namespace `EnsdfCheck`):
- Datentypen:
  - `SpinParity` mit `twoJ : ℕ` und `parity : ℤˣ`.
  - `Firmness` mit firm / tentative `( )` / assumed `[ ]` / list / unknown. `assumed` ist
    zusätzlich zum Auftrag dazugekommen (eckige Klammern).
  - `Component` = `typed t l` (Eλ/Mλ, `t : MultipoleType` aus PR 08) oder `untyped l` (D = 1,
    Q = 2), und `Multipolarity := List Component`. Damit gehen auch Mischungen wie `E0+M1+E2`.
- `Verdict`, nach Schwere geordnet: `allowed` < `untypedOk` (D/Q, Dreiecksregel erfüllt, Parität
  offen) < `special` (E0) < `parityViolation` < `angularViolation`. `checkTransition` prüft jede
  Komponente und gibt das schwerste Urteil zurück.
- Berechenbar über `Bool` (`triangleB`, `multipoleParity : ℤˣ`), weil PR 08 in einer
  `noncomputable section` steht. Bewiesen äquivalent: `triangleB_iff`
  (↔ `TriangleRule`), `coe_multipoleParity` (↔ `MultipoleType.parity`).
- Bewiesene Lemmata:
  - `checkTransition_eq_violation_iff`: für einen Eλ/Mλ mit λ ≥ 1 gilt Urteil ∈ {parity, angular}
    ⇔ `¬ IsAllowedMultipole` (wie im Auftrag gefordert).
  - `checkComponent_isViolation_iff`: dasselbe je Komponente.
  - `checkTransition_isViolation_iff` und `checkTransition_eq_angular_iff`: Gemischte
    Multipolaritäten verletzen genau dann, wenn eine Komponente verletzt.
  - `not_isAllowedMultipole_of_typed_eq_angular` und `…_untyped_eq_angular`: Ein
    Drehimpuls-Urteil (Kategorie A) heißt, dass weder E noch M dieser Ordnung erlaubt sind; das
    deckt auch D/Q.
- Beispiele mit dem Hf-178-Isomer (16⁺→13⁻: E3 erlaubt, M3 Parität, E2 Drehimpuls) per `decide`.
  `#eval` läuft, der Code ist also ausführbar.
- Kein `sorry`. Axiome: propext, Quot.sound, für das Hauptlemma zusätzlich Classical.choice
  (Standard). `lake build EnsdfCheck.Rules` grün.
- Umsetzung der S0-Befunde 1–3: A und A′ sind getrennt (angular/parity), Parität ist `ℤˣ` mit
  Umwandlung, E0 ist `special`. Für Befund 4 (`M1(+E2)`) kommt die Regel in S2.
