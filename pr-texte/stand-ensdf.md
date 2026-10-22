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

## S2 Parser — erledigt (2026-10-22 17:45), Commit **ensdf-check S2** (lokal)
- `Tools/EnsdfCheck/Parse.lean`, **unbewiesener Code**. Er liest die Records mit den
  Spaltenpositionen aus S0:
  - L: E 10–19, DE 20–21, J 22–39, Q 80.
  - G: E 10–19, DE 20–21, M 32–41, MR 42–49, DMR 50–55, C 77, Q 80.
  - Fortsetzung mit `G` in Spalte 8 und Spalte 6 ≠ blank/`1`, darin `FL=`.
  - Kommentare (Spalte 7 nicht blank) werden übersprungen.
  - Datensätze sind durch Leerzeilen (END-Record) getrennt, die erste Zeile ist der ID-Record.
- `lean_exe ensdf-check` (root `EnsdfCheck.Main`, srcDir `Tools`) mit Modus `--parse-stats`.
  - Die exe importiert `Rules.lean` statisch, führt also genau den bewiesenen Code aus.
  - Erster Bau 22 s, Lauf über alle 300 Dateien 11,6 s.
  - Statistik: `~/ensdf/parse_stats_S2.txt`.
- **Gesamtzahlen**: 20,117 Datensätze (Webseite: 20,118), 568,228 Levels, 793,431 Gammas,
  34,700 Gammas mit `FL=`.
- **Jπ** (Levels):

  | Ergebnis | Anzahl |
  |---|---|
  | einzeln, fest | 171,955 |
  | leer | 170,996 |
  | einzeln, in Klammern | 135,528 |
  | Liste | 53,203 |
  | einzeln, ohne Parität | 18,561 |
  | nicht geprüft: Offset (`J+2`, `N`, `U`, …) | 9,638 |
  | nicht geprüft: nur Parität | 3,359 |
  | nicht geprüft: Bereich (`TO`, `:`) | 3,010 |
  | nicht geprüft: Schranke (`GE`, `LE`, …) | 1,441 |
  | nicht geprüft: Dublett (`&`) | 457 |
  | nicht geprüft: `NATURAL` | 58 |
  | nicht geprüft: `NOT` | 18 |
  | **nicht lesbar** | **4** |

  Die 4 nicht lesbaren Felder: `3/21` (087:2133), `3/2,5/25,7/2(-)` (091:1775), `(37-/2)`
  (123:8278), `1(1/2,3/2)` (185:1912).
- **Multipolarität** (Gammas):

  | Ergebnis | Anzahl |
  |---|---|
  | leer | 560,329 |
  | einzeln, fest | 108,061 |
  | in Klammern (inkl. `M1(+E2)`) | 76,457 |
  | gemischt, fest | 36,787 |
  | Alternativen mit `,` | 11,591 |
  | **nicht lesbar** | **206** |

  Alle 206 nicht lesbaren Felder enthalten `O`, z. B. `Q(+O)` oder `Q+O`.
- **Energien**: 67 Level-Energien sind nicht lesbar (`SN+X`, `SN-0.377`). Exponenten wie `1.8E+3`
  werden jetzt gelesen.
- Lesarten, die Daniel prüfen sollte:
  1. `M1(+E2)` und ähnliche Formen lese ich als `M1+E2`, wobei der Anteil in Klammern als
     „probable“ gilt (Klammerregel V.19). Das Handbuch von 2001 kennt `(+E2)` selbst nicht.
  2. `O` (wohl Oktupol) steht nicht im Handbuch → P, nicht geraten.
  3. `(1,2,3)(+)` heißt Liste mit vorläufiger Parität. `(5/2-,7/2)-` wird nur angenommen, wenn
     innere und äußere Parität gleich sind.
  4. `32/2-` und `58/2+` lese ich wörtlich nach V.20 („J = N/2“, N beliebig) als J = 16 bzw. 29;
     das sind vermutlich Tippfehler in ENSDF.
  5. Eine einzelne Großbuchstaben-Spin (`N`, `U`) gilt als Offset-Form V.20.8.

## S3 Endniveau — erledigt (2026-10-22 17:55), Commit **ensdf-check S3** (lokal)
`Tools/EnsdfCheck/Assign.lean` (unbewiesen), Funktion `placeGamma` mit Ergebnis `Placement`.
- **Mit `FL=`**: Es gilt der Level mit genau diesem Energietext (IV.C.2: „identical to a level
  energy“), ersatzweise derselbe Zahlenwert mit gleichem Offset. Ein `?` dahinter wird als
  „unsicher“ markiert; `FL=?` heißt Endniveau unbekannt.
- **Ohne `FL=`**: E_f = E_i − E_γ, nur Levels mit gleichem Offset (`+X`) und E_f < E_i.
  - Toleranz 3σ mit σ = √(σ_i² + σ_γ² + σ_f²); σ = DE in Einheiten der letzten Stelle, bei leerem
    oder nicht-numerischem DE eine Einheit der letzten Stelle.
  - Genau ein Kandidat → zugeordnet; keiner → „no match“; mehrere → „ambiguous“.
- **Keine Rückstoßkorrektur**: Das Handbuch verlangt sie nicht (S0). Folge, an einer Stichprobe
  belegt: `6LI L 3562.88` → `G 3561.75` (Ende 0+) liegt 1,13 keV daneben, genau der Rückstoß
  E_γ²/(2Mc²). Leichte Kerne mit harten Gammas landen deshalb in „no match“. Das kostet
  Abdeckung, erzeugt aber **keine** Treffer.
- Lauf `--placement-stats` in 13,7 s, Ausgabe `~/ensdf/placement_stats_S3.txt`.

  Gammas **mit Multipolarität** (232,902):

  | Ergebnis | Anzahl |
  |---|---|
  | über E_i − E_γ | 209,750 |
  | über `FL=` | 10,300 |
  | mehrdeutig | 5,848 |
  | unplatziert | 4,431 |
  | kein Treffer | 2,674 |
  | Energie nicht lesbar / Offset | 78 |
  | `FL=` nicht gefunden | 16 |
  | `FL=?` | 5 |

  Zugeordnet sind 220,050, das sind 94,5 %. Über alle 793,431 Gammas: 686,823 zugeordnet,
  67,067 unplatziert, 21,734 mehrdeutig, 16,602 kein Treffer.
- Frage an Daniel: Soll die Rückstoßkorrektur als Option kommen (gemeldet getrennt, nicht als
  Standard)? Laut Auftrag nein, deshalb nicht umgesetzt.

## S4 Lauf und Bericht — erledigt (2026-10-22 18:05), Commit **ensdf-check S4** (lokal)
- `Tools/EnsdfCheck/Classify.lean` (unbewiesen, die Urteile selbst kommen aus `checkTransition`).
  Reihenfolge der Entscheidungen:
  1. Ohne Multipolarität: nicht gezählt.
  2. M nicht lesbar → P.
  3. Zuordnung gescheitert → C.
  4. Jπ nicht lesbar → P.
  5. Jπ leer oder nicht geprüfte Form → N.
  6. E0 → C, 0→0 → C.
  7. Sonst die Regelprüfung:
     - **A**: Beide J fest, M eine Alternative ohne Klammern, Platzierung fest, und eine
       Komponente verletzt die Drehimpulsregel. Die Parität darf dabei fehlen oder in Klammern
       stehen, weil die Drehimpulsregel nicht von der Parität abhängt.
     - **A′**: wie A, dazu beide Paritäten angegeben und fest; nur die Paritätsregel verletzt.
     - **B**: nicht fest, und alle Kombinationen verletzen (Listen × Alternativen × unbekannte
       Paritäten).
     - Erlaubt, aber D/Q ohne Typ → C; sonst ok.
  - „Platzierung fest“ heißt: kein `?` an `FL=`, Spalte 80 der Gamma-Zeile weder `?` noch `S`,
    Spalte 77 nicht `*&@`, keines der beiden Levels mit `?` oder `S` in Spalte 80.
- Aufruf: `lake exe ensdf-check ~/ensdf/data_261001 ~/ensdf/bericht.md` (12 s). Daneben liegen
  `bericht.AA.tsv` (A und A′, mit Zertifikatsdaten) und `bericht.B.tsv`.
- **Ergebnis**, 233,102 Gamma-Übergänge mit Multipolarität:

  | Kategorie | Anzahl | davon |
  |---|---|---|
  | **A** | **28** | |
  | **A′** | **17** | |
  | B | 146 | 89 Drehimpuls, 55 Parität oder gemischt, 2 Parität offen |
  | C | 67,173 | 52,008 D/Q ohne Typ, aber erlaubt · 2,123 E0 · 5,845 Zuordnung mehrdeutig · 2,667 kein Endniveau · 4,431 unplatziert · 99 FL/Energie |
  | P | 206 | alle mit `O` |
  | N | 5,430 | 3,025 Jπ leer, 2,405 nicht geprüfte Form |
  | ok | 160,102 | |

- Die Trefferliste steht im Bericht. Einige Zeilen sind doppelt, weil derselbe Übergang im
  Adopted-Satz und in einem Reaktions- oder Zerfallsdatensatz steht (106Ag, 106Sn, 150Gd).
- Erste Beobachtung, noch ohne Bewertung: Viele A-Treffer sind `D` oder `D+Q` bei ΔJ = 2
  (z. B. 106Ag 11⁻→9⁻, 106Sn 17⁻→15⁻, 149Gd 17/2⁻→13/2⁻); dort verletzt der Dipolanteil die
  Dreiecksregel. Mindestens ein Treffer sieht nach Zuordnungsproblem aus: 9Be 16977.1 →
  `2.78E+3`, das große σ des Zielniveaus macht das Fenster breit. Mehr in S6.

## S5 Zertifikate — erledigt (2026-10-22 18:10), Commit **ensdf-check S5** (lokal)
- Die exe erzeugt die Datei selbst (kein Python):
  `lake exe ensdf-check ~/ensdf/data_261001 ~/ensdf/bericht.md --certificates Tools/EnsdfCheck/Certificates.lean`.
- `Tools/EnsdfCheck/Certificates.lean`: **28** `example`s, eines je A-Treffer, die Daten als
  Kommentar. Form:
  `example : ∀ (t : MultipoleType) (πi πf : ℤ), ¬ IsAllowedMultipole 2Jᵢ 2J_f πi πf t λ := fun _ _ _ h => absurd h.2.1 (by decide)`.
- **Abweichung vom Auftrag**: Statt `¬ IsAllowedMultipole … := by decide` mit festen Paritäten
  steht ein ∀ über Typ und Paritäten. Gründe:
  - Bei A darf die Parität fehlen oder in Klammern stehen.
  - Bei `D`/`Q` ist der Typ offen.
  - Die Aussage ist stärker, und `decide` prüft im Kern genau den Teil `¬ TriangleRule (2λ) 2Jᵢ 2J_f`.
  Die Datei importiert nur `SelectionRules.lean` und hängt nicht vom Werkzeugcode ab.
- `lake build EnsdfCheck.Certificates` grün, zusätzlich `lake env lean` auf die Datei.
- Gegenprobe: Ein absichtlich falsches Zertifikat (9/2→5/2, λ = 2, erlaubt) wird abgelehnt
  („`decide` proved that the proposition ¬TriangleRule (2 * 2) 9 5 is false“).

## S6 Gegenprobe — Liste für Daniel (2026-10-22 18:20)
Die ersten 10 A-Treffer in Dateireihenfolge. Daten: `ensdf_261001`; „Zeile“ = Zeile der Gamma-Zeile
in `~/ensdf/data_261001/ensdf.NNN`. Die Vermutungen stammen aus den Rohzeilen (Level, Gamma,
Kommentare direkt dahinter). **Keine Bewertung „Fehler in ENSDF“ — Daniel prüft gegen die
NNDC-Webausgabe.**

| # | Nuklid | Übergang | E_γ, M | Datensatz, Zeile | Was verletzt | Vermutung |
|---|---|---|---|---|---|---|
| 1 | ⁹Be | 6760 9/2+ → 0.0 3/2- | 6757, E2 | Adopted, 009:987 | λ=2 < ΔJ=3 | **echter Widerspruch** in den Jπ-Daten: Der Level-Kommentar nennt Jπ=(5/2-) aus ¹⁰Be(e,e'p); mit 5/2- wäre E2 erlaubt. |
| 2 | ⁹Be | 16977.1 1/2- → 2.78E+3 1/2- | 14535.1, E2 | Adopted, 009:1097 | λ=2 bei 1/2→1/2 | **Werkzeugfehler (Zuordnung)**: E_i−E_γ = 2442 keV; das passt zum 2429-keV-Level, wenn man den Rückstoß (≈12,5 keV) mitnimmt. Ohne Korrektur trifft nur das breite Niveau 2.78 MeV (σ = 120 keV). Kein ENSDF-Befund. |
| 3 | ¹⁹F | 3998.7 7/2- → 1458.7 3/2- | 2540.0, M1 | Adopted, 019:2059 | M1 bei ΔJ=2 | Tippfehler (E2?) oder echter Widerspruch; in der Folgezeile steht `BM1W=0.012`. |
| 4 | ²⁵Mg | 5116.4 1/2- → 585.0 1/2+ | 4531.4, D+Q | ²⁴Mg(d,pγ), 025:5350 | Q bei 1/2→1/2 | **Formatfall/echter Widerspruch**: „D+Q“ aus einer Winkelverteilung (A2, A4 von 1969So09) passt nicht zu den Spins. |
| 5 | ³⁰P | 3019.2 1+ → 677.01 0+ | 2342.3, M1+E2 | ³⁰S EC decay, 030:10190 | E2 bei 1→0 | **Formatfall/Tippfehler**: Eine E2-Beimischung ist bei 1→0 unmöglich. Wohl Standardangabe für die Konversionsrechnung (CC folgt). |
| 6 | ⁵³Cr | 1006.27 5/2- → 564.03 1/2- | 442.7, M1+E2 | Adopted, 053:1276 | M1 bei ΔJ=2 | Tippfehler (E2?). |
| 7 | ⁵³Cr | 7613.8 25/2(-) → 6009.1 21/2(-) | 1604.7, D | (HI,xnγ), 053:3010 | D bei ΔJ=2 | Widerspruch zwischen DCO (=0.58) und Spinzuordnung, oder Doppellinie: Es gibt eine parallele Linie 1605.0 mit `?`. |
| 8 | ⁵³Fe | 2339.24 11/2- → 0.0 7/2- | 2338.3, M1+E2 | Adopted, 053:8745 | M1 bei ΔJ=2 | Tippfehler (E2?). |
| 9 | ⁹⁰Nb | 854.32 2- → 651.19 4(+) | 203.13, E1 | Adopted, 090:11281 | E1 bei ΔJ=2 | **echter Widerspruch, in ENSDF vermerkt**: Kommentar „Inconsistent with ce measurements … M1+E2“. |
| 10 | ¹⁰²Rh | 476.6 7+ → 263.7 5+ | 213.0, D | ⁷⁰Zn(³⁶S,p3nγ), 102:5087 | D bei ΔJ=2 | **echter Widerspruch, in ENSDF vermerkt**: Kommentar „D in conflict with Jπ initial and final state“. |

In Zahlen: 1 Werkzeugfehler (#2), 2 von den Evaluatoren selbst vermerkt (#9, #10), 7 offen
(Tippfehler, Formatfall oder echter Widerspruch). Einen Parserfehler habe ich bei diesen 10 nicht
gefunden: Die Spalten (E, DE, J) stimmen auch bei rechtsbündigen Energien wie `   1006.27 5`.

### Vorschlag (nicht umgesetzt, Daniel entscheidet)
Die Zuordnung robuster machen, ohne den Rückstoß anzuwenden: Nur zuordnen, wenn
E_i − E_γ und E_i − E_γ − E_γ²/(2Mc²) denselben einzigen Kandidaten ergeben; sonst „mehrdeutig“
(C). Das verschiebt nur Fälle von A/B nach C und hätte #2 aussortiert. Laut Auftrag gibt es
ohne Vorgabe im Handbuch keine Rückstoßkorrektur, daher nur als Vorschlag.

## Zusammenfassung
- S0–S6 erledigt. Branch `ensdf-check` (lokal, **nicht gepusht**), Commits S1–S5 auf ae59f621:
  `Tools/EnsdfCheck/{Rules,Parse,Assign,Classify,Main,Certificates}.lean`, dazu der lakefile-Eintrag.
- Ergebnis: A 28, A′ 17, B 146, C 67,173, P 206, N 5,430, ok 160,102 (von 233,102).
  Lean-gestützt ist nur A (28 Kern-geprüfte Zertifikate).
- Offen für Daniel:
  - Gegenprobe der Liste oben.
  - Lesarten aus S2 (`(+E2)`, `O`, `32/2`).
  - Vorschlag Rückstoß-Robustheit.
  - Push.
  - Ob und wo veröffentlicht wird.
- Wasserstoff: #1909 bei Abschluss noch nicht gemergt, also kein Rebase fällig.

## Runde 2 nach Daniels Vorgaben (2026-10-22 18:40), Commit **ensdf-check: recoil …** (lokal)

### Belege (heruntergeladen, nicht aus dem Gedächtnis)
- **IAEA Evaluators Guidelines 2021**: `~/ensdf/guidelines/Evaluators_Guidelines_2021_V2.pdf` von
  https://www-nds.iaea.org/nsdd/docs/Evaluators_Guidelines_2021_V2.pdf.
  - 3,015,510 Bytes, 91 Seiten, HTTP Last-Modified 16 Feb 2022,
    sha256 b085ec39b33e85d7ac0e292b694cf9635486407305cf7f722121505bc0f0cd1d.
  - Laut Titelseite: M. J. Martin (ORNL/UTK), „Guidelines for Nuclear Structure Evaluators“,
    ORNL/TM-2022/1835, datiert 4/26/2021.
- **`M1(+E2)` belegt**, §1.10 Punkt 4 e) (S. 30–31): „If δ overlaps zero or infinity, the
  corresponding small multipolarity component should be in parens. Example: For mult =M1+E2 with
  δ=0.3 4, the multipolarity should be entered as M1(+E2). For δ>10, the multipolarity should be
  entered as E2(+M1)“. Der Anteil in Klammern kann also null sein; das trägt Daniels Regel
  „Verletzung nur durch Klammeranteil → B“.
- **`[D,E2]` belegt**, §1.10 Punkt 7 b): „set, for example, mult=[D,E2] (or mult=[E1,M1,E2])“,
  also Komma = Alternativen und eckige Klammer = aus dem Niveauschema. Ebenso §1.10 Punkt 4 d):
  „E1+M2+E3 or E0+M1+E2“ (mehr als zwei Anteile).
- **`O` nicht belegt**: Weder die Guidelines 2021 noch `ensdf-procedures.pdf` (NNDC evalcorner,
  `~/ensdf/guidelines/`) noch das Handbuch von 2001 definieren `O` im Multipolaritätsfeld. Eine
  Websuche fand ebenfalls keine Definition. → `O` bleibt P („nicht belegt“).
- **Atomare Masseneinheit** für den Rückstoß: NIST, CODATA 2022, u c² = 931.494 103 72(29) MeV
  (https://physics.nist.gov/cgi-bin/cuu/Value?muc2mev). Näherung M = A·u; der Massenexzess fehlt,
  der Fehler im Rückstoß liegt unter 0,01 keV.

### Änderungen
1. **Rückstoß immer**: E_f = E_i − E_γ − E_γ²/(2·A·u c²).
2. **Breite Niveaus**: Ein Level mit σ_E ≥ 10 keV oder einer Breite ≥ 10 keV (T-Feld in
   EV/KEV/MEV, V.14) zählt nie als einziger Kandidat (→ C „only a broad level matches“).
   **Die Schwelle `broadKeV = 10` habe ich gewählt; Daniel bitte bestätigen oder ändern.**
   Nur eine eindeutige Zuordnung zählt, mehrere Kandidaten → C „ambiguous“.
3. **A und A′ nach Herkunft des Endniveaus getrennt** (`FL=` / E_i − E_γ − E_R), im Bericht als
   eigene Tabellen, in `bericht.AA.tsv` als Spalte.
4. **Klammeranteile**: Festigkeit wird je Komponente geprüft. A gilt nur, wenn eine Komponente
   außerhalb der Klammern verletzt; verletzt nur der Klammeranteil (`M1(+E2)`, `D(+Q)`), dann B
   („bracketed component only“). Dasselbe gilt für A′.
5. **`32/2` nicht als 16**: neue Kategorie **S**, „2J und A haben verschiedene Parität“ (halbzahliges J
   bei geradem A oder ganzzahliges bei ungeradem A). Betroffene Übergänge werden nicht weiter
   geprüft. Der Bericht listet zusätzlich alle betroffenen Level-Records.

### Ergebnis (233,102 Übergänge), vorher → jetzt
| Kategorie | Runde 1 | Runde 2 |
|---|---|---|
| A | 28 | **29**, alle mit Endniveau aus E_i − E_γ − E_R, keiner aus `FL=` |
| A′ | 17 | **24** (3 über `FL=`, 21 über die Energiedifferenz) |
| B | 146 | 131 (19 Drehimpuls nur im Klammeranteil, 11 Parität nur im Klammeranteil, …) |
| C | 67,173 | 66,889 (152 „only a broad level“, 2,159 kein Endniveau statt 2,667, 5,857 mehrdeutig) |
| **S** | — | **3** Übergänge; 5 Level-Records |
| P | 206 | 206 |
| N | 5,430 | 5,459 |
| ok | 160,102 | 160,361 |

- Zertifikate: 29, `lake build EnsdfCheck.Certificates` grün.
- Der Zuordnungsfehler ⁹Be 16977.1 → 2.78E+3 ist weg (jetzt C).
- Neu in A sind ⁴¹Sc 3775 3/2- → 0 7/2- und ⁴⁷Ti 1549.8 3/2- → 159.3 7/2-, beide `D(+Q)` bei ΔJ = 2.
  Dort verletzt der Dipolanteil außerhalb der Klammern.
- **S, Level-Records** (alle eingeklammert oder Liste):
  - ¹⁵C 10248 `(5/2, 7,2, 9/2)` (015:249) und ⁸³Kr 2985.9 `(11/2,13,2,15/2)` (083:4392):
    offensichtlich `,` statt `/`.
  - ¹²⁷La 4587.2 `(32/2-)` (127:13068 und 127:13738).
  - ¹⁷¹Re 7377.8 `(58/2+)` (171:17693).
  - Die 3 S-Übergänge hängen an ⁸³Kr und ¹²⁷La.

### Die ersten 10 A-Treffer (Runde 2) — für Daniels Gegenprobe
| # | Nuklid | Übergang | E_γ, M | Datensatz, Zeile | Vermutung |
|---|---|---|---|---|---|
| 1 | ⁹Be | 6760 9/2+ → 0.0 3/2- | 6757, E2 | Adopted, 009:987 | echter Widerspruch in den Jπ-Daten; der Level-Kommentar nennt (5/2-) aus ¹⁰Be(e,e'p) |
| 2 | ¹⁹F | 3998.7 7/2- → 1458.7 3/2- | 2540.0, M1 | Adopted, 019:2059 | Tippfehler (E2?) oder Widerspruch; `BM1W` angegeben |
| 3 | ²⁵Mg | 5116.4 1/2- → 585.0 1/2+ | 4531.4, D+Q | ²⁴Mg(d,pγ), 025:5350 | Formatfall: D+Q aus A2/A4 passt nicht zu den Spins |
| 4 | ³⁰P | 3019.2 1+ → 677.01 0+ | 2342.3, M1+E2 | ³⁰S EC decay, 030:10190 | Formatfall/Tippfehler: E2 bei 1→0 unmöglich |
| 5 | ⁴¹Sc | 3775 3/2- → 0 7/2- | 3775, D(+Q) | ⁴⁰Ca(p,γ), 041:16170 | echter Widerspruch oder Tippfehler: D mit δ = 0.00(11) bei ΔJ = 2 (A2, A4 von 1968Yo04) |
| 6 | ⁴⁷Ti | 1549.8 3/2- → 159.3 7/2- | 1391, D(+Q) | ⁴⁴Ca(α,nγ) u. a., 047:5645 | echter Widerspruch oder falsche Platzierung; δ = −0.06(6); E_γ ohne Unsicherheit |
| 7 | ⁵³Cr | 1006.27 5/2- → 564.03 1/2- | 442.7, M1+E2 | Adopted, 053:1276 | Tippfehler (E2?) |
| 8 | ⁵³Cr | 7613.8 25/2(-) → 6009.1 21/2(-) | 1604.7, D | (HI,xnγ), 053:3010 | DCO gegen Spinzuordnung, oder Doppellinie (paralleles 1605.0 `?`) |
| 9 | ⁵³Fe | 2339.24 11/2- → 0.0 7/2- | 2338.3, M1+E2 | Adopted, 053:8745 | Tippfehler (E2?) |
| 10 | ⁹⁰Nb | 854.32 2- → 651.19 4(+) | 203.13, E1 | Adopted, 090:11281 | echter Widerspruch, in ENSDF selbst vermerkt („Inconsistent with ce measurements“) |

Keine Bewertung „Fehler in ENSDF“ ohne Daniels Prüfung. Bericht: `~/ensdf/bericht.md`
(Kopie `bericht_v2.md`), Listen `bericht.AA.tsv` und `bericht.B.tsv`.

## S6 Gegenprobe — Ergebnis von Daniel (NuDat 3, Adopted, Web 22.10.2026)
Daniels Nummern beziehen sich auf die **erste** Liste (Runde 1, Abschnitt „S6 Gegenprobe — Liste für
Daniel“). Zur Sicherheit stehen die Nuklide dabei.

| # (Runde 1) | Nuklid, Übergang | Daniels Befund |
|---|---|---|
| 1 | ⁹Be 6760 9/2+ → 0 3/2-, E2 | auch in Adopted identisch |
| 2 | ⁹Be 16977.1 → 2.78E+3, E2 | **Werkzeugfehler**; Web: 14535.1 → 2429.4 5/2- (seit Runde 2 durch Rückstoß und Regel „breite Niveaus“ in C) |
| 3 | ¹⁹F 3998.7 7/2- → 1458.7 3/2-, M1 | auch in Adopted identisch |
| 4 | ²⁵Mg 5116.4 1/2- → 585.0 1/2+, D+Q, (d,pγ) | nur Einzeldatensatz; Adopted ohne Widerspruch (Adopted **E1**) |
| 5 | ³⁰P 3019.2 1+ → 677.01 0+, M1+E2, ³⁰S EC | auch in Adopted identisch |
| 6 | ⁵³Cr 1006.27 5/2- → 564.03 1/2-, M1+E2 | auch in Adopted identisch |
| 7 | ⁵³Cr 7613.8 25/2(-) → 6009.1 21/2(-), D, (HI,xnγ) | auch in Adopted identisch (nicht nur HI) |
| 8 | ⁵³Fe 2339.24 11/2- → 0 7/2-, M1+E2 | auch in Adopted identisch |
| 9 | ⁹⁰Nb 854.32 2- → 651.19 4(+), E1 | auch in Adopted identisch |
| 10 | ¹⁰²Rh 476.6 7+ → 263.7 5+, D, (³⁶S,p3nγ) | nur Einzeldatensatz; Adopted **ohne Multipolarität**, Endniveau (5+) |

Bilanz: 7 auch in Adopted (#1, 3, 5, 6, 7, 8, 9), 2 nur im Einzeldatensatz (#4, #10),
1 Werkzeugfehler (#2).

## Runde 3 (2026-10-22 18:55), Commit **ensdf-check: compare A and A' hits with the Adopted data set** (lokal)
- **Rückstoß**: wird seit Runde 2 immer angewendet (`placeGamma`). Der neue Lauf ergibt
  unveränderte Zahlen: A 29, A′ 24, B 131, C 66,889, S 3, P 206, N 5,459, ok 160,361;
  29 Zertifikate, Build grün.
- **Neue Spalten** für alle A- und A′-Treffer: „also in Adopted“ und „Adopted contradicts“.
  Regel (`adoptedCompare` in `Main.lean`):
  - Im Adopted-Satz desselben Nuklids werden Anfangsniveau, Gamma und Endniveau über die Energie
    zugeordnet (3σ, jeweils der nächste Treffer).
  - Das Endniveau wird auf den zum Treffer passenden Adopted-Level festgelegt; dann wird das
    Adopted-Gamma genauso klassifiziert.
  - **auch in Adopted** = Adopted ist A, A′ oder B. **Adopted widerspricht** = Adopted ist erlaubt
    oder hat keine Multipolarität. Sonst „unclear“; nicht gefundene Levels oder Gammas werden
    vermerkt.
  - Erster Entwurf hatte zwei Fehlurteile (³⁰P: Adopted-B als Widerspruch; ⁵³Cr 7613.8: mehrdeutige
    Adopted-Zuordnung als Widerspruch). Beides korrigiert; danach **stimmen alle 10 mit Daniels
    NuDat-Prüfung überein**. ³⁰P steht in Adopted als B: Die Verletzung ist da, aber ein Teil ist dort
    vorläufig.
- **Bilanz der Spalten:**

  | Kategorie | ist selbst Adopted | auch in Adopted (als A bzw. A′ / als B) | Adopted widerspricht | nicht gefunden |
  |---|---|---|---|---|
  | A (29) | 12 | 4 / 2 | 10 | 1 (Level) |
  | A′ (24) | 13 | 2 / 0 | 7 | 2 (1 Level, 1 Gamma) |

  „Adopted widerspricht“ heißt in 7 von 10 A-Fällen „Adopted gibt eine erlaubte Multipolarität“
  (²⁵Mg E1, ⁴⁷Ti [E2], ¹⁰⁶Cd Q, ¹¹¹Sn E2, ¹⁴⁹Gd (Q), ¹⁶²Dy 2× E2) und sonst „Adopted ohne
  Multipolarität“ (⁴¹Sc, ¹⁰²Rh, ¹¹³Cd).
- Bericht `~/ensdf/bericht.md` (Kopie `bericht_v3.md`); `bericht.AA.tsv` hat die zwei Spalten
  zusätzlich.
- Damit stehen 18 der 29 A-Treffer auch im Adopted-Satz (12 sind selbst Adopted, 6 dort ebenfalls
  verletzt). Das sind die Kandidaten für einen etwaigen Bericht an NNDC; Entscheidung und
  Kontakt nach außen: Daniel.

## Gegenprobe aller 29 A-Records — Ergebnis von Daniel (NuDat 3, Adopted, Web 22.10.2026)
- **Auch in Adopted identisch (17):** ⁹Be 6760, ¹⁹F 3998.7, ³⁰P 3019, ⁵³Cr 1006.27, ⁵³Cr 7613.8,
  ⁵³Fe 2339.24, ⁹⁰Nb 854.32, ¹⁰⁶Ag 2441.6 (2×), ¹⁰⁶Sn 8215.7 (2×), ¹¹¹Ru 705.65, ¹¹²Cd 3531.32,
  ¹⁵⁰Gd 1207.135, ¹⁵⁰Gd 1699.9 (2×), ¹⁹⁸Au 646.411.
- **In Adopted bereinigt (11):** ²⁵Mg (Adopted E1), ⁴¹Sc (ohne M), ⁴⁷Ti ([E2]), ¹⁰²Rh (ohne M),
  ¹⁰⁶Cd (Q), ¹¹¹Sn (E2), ¹¹³Cd (ohne M), ¹⁴⁴Nd (E2), ¹⁴⁹Gd ((Q)), ¹⁶²Dy 1061 und 1324 (E2).
- **In Adopted nur vorläufig (1):** ¹⁰⁶Pd 2366 (M1+E2).

### Abgleich mit den automatischen Spalten (2026-10-22 19:05)
- Erst 28 von 29 übereinstimmend. Abweichung bei ¹⁴⁴Nd 2109.4: Das Werkzeug meldete „level not in
  Adopted“. Ursache: Adopted schreibt `2109.964`, der (n,γ)-Satz `2109.4`, beide ohne DE. Mit σ =
  eine Einheit der letzten Stelle ist das 3σ-Fenster (0,3 keV) kleiner als die Differenz (0,56 keV).
- Korrektur, **nur für den Adopted-Abgleich** (nicht für die Kategorien): Fenster max(3σ, 1 keV).
  Danach ¹⁴⁴Nd: „Adopted contradicts: M=E2, J_f=2+, allowed“.
- **Jetzt 29 von 29 übereinstimmend:**

  | Daniels Befund | Werkzeug |
  |---|---|
  | identisch (17) | 12 „Adopted itself“, 4 „yes, as A“, ³⁰P „yes, as B (angular momentum)“ |
  | nur vorläufig (¹⁰⁶Pd) | „yes, as B (angular momentum, bracketed component only)“ |
  | bereinigt (11) | 11 „Adopted contradicts“ (8 erlaubte M, 3 ohne M) |

  ³⁰P steht beim Werkzeug in Adopted als B, bei Daniel als identisch: Die Verletzung ist dieselbe,
  B kommt von einer vorläufigen Angabe in Adopted (Jπ oder Platzierung), nicht von der Multipolarität.

## Breite-Schwelle: Lauf mit 5 / 10 / 20 / 50 keV (2026-10-22 19:05)
Neue Option `--broad <keV>`. Berichte in `~/ensdf/sweep/`. Die Zertifikate wurden dabei nicht
überschrieben.

| Schwelle | A | A′ | B | C | S | P | N | ok |
|---|---|---|---|---|---|---|---|---|
| 5 keV | 29 | 24 | 130 | 67,071 | 3 | 206 | 5,448 | 160,191 |
| 10 keV | 29 | 24 | 131 | 66,889 | 3 | 206 | 5,459 | 160,361 |
| 20 keV | 29 | **26** | 131 | 66,841 | 3 | 206 | 5,465 | 160,401 |
| 50 keV | 29 | **26** | 131 | 66,805 | 3 | 206 | 5,466 | 160,436 |

- Die A-Mengen sind bei allen vier Schwellen identisch (Records verglichen, nicht nur Zahlen).
  Die A′-Mengen sind bei 5 und 10 keV identisch und ebenso bei 20 und 50 keV.
- **Die Bedingung „A und A′ bleiben gleich“ ist nicht erfüllt**: Bei 20 und 50 keV kommen zwei
  A′ hinzu, nämlich ¹¹B (γ,γ) 7.29E3 5/2+ → 5.02E3 3/2- (2264.9, M1+E2, 011:3762) und → 4.44E3 5/2-
  (2840.2, M1+E2, 011:3763). Die Endniveaus stehen dort als `5.02E3` und `4.44E3` ohne DE, also σ =
  10 keV aus der letzten Stelle; bei der 10-keV-Schwelle gelten sie damit als breit (→ C). Adopted
  widerspricht beiden (E1+M2, erlaubt).
- Deshalb habe ich die Schwelle nicht festgelegt. Der Standard bleibt vorläufig 10 keV
  (`broadKeV`). **Entscheidung: Daniel.**

Code: Commit **ensdf-check: --broad option; Adopted matching with 1 keV floor** (lokal). Der
Standardlauf ist unverändert (A 29, A′ 24, …), die 29 Zertifikate bauen.

## Rückfragen zum Adopted-Abgleich (bericht_v3), beantwortet 2026-10-22 19:20

### 1. ³⁰P 3019 → 677: Was ist in Adopted vorläufig?
Adopted-Rohzeilen, wörtlich aus `ensdf.030` (Adopted-Satz ab Zeile 6826):
```
6899:  30P   L 677.11    10 0+               93 FS     10
7033:  30P   L 3019.8     8 1+               2 FS      1
7037:  30P   G 2342.3    8    100    M1+E2                   0.00044 5            *
7038:  30P F G FLAG=A
7041:  30P  cG $B(M1)(W.u.)=0.9 {I+8-3} if M1
7042:  30P  cG $B(E2)(W.u.)=7|*10{+2} {I+6-3} exceeds RUL=100 if E2
```
- **Jπ und Multipolarität sind nicht vorläufig**: 1+, 0+, M1+E2 ohne Klammern, wie in NuDat.
- Das B kommt aus **meiner Platzierungsregel**: In der Gamma-Zeile steht in **Spalte 77 ein `*`**
  (geprüft: Spalte 77 = `*`, Zeilenlänge 80). Laut Handbuch III.B.14 heißt das „The symbol `*`
  denotes a multiply-placed γ ray“, und mehrfach platzierte Gammas zählen im Werkzeug nicht als
  fest platziert.
- ~~Ein zweites 2342-keV-Gamma gibt es im Adopted-Satz von ³⁰P aber nicht.~~ **Falsch, korrigiert
  unten** („Korrektur ³⁰P“): Das 2342.3 steht zweimal im Adopted-Satz; meine Handsuche hat den
  eingerückten zweiten Eintrag übersehen.
- Am Rande: Die Evaluatoren vermerken selbst „B(E2)(W.u.)=7×10² … exceeds RUL=100 if E2“, halten
  einen reinen E2-Anteil also für unplausibel.
- Eine Regeländerung habe ich nicht vorgenommen; ³⁰P bleibt in Adopted B, mit dem Grund oben.

### 2. „Nicht gefunden“ in bericht_v3 (1 A, 2 A′)
Neue Ausgabe im Bericht (Commit **ensdf-check: Adopted matching reports nearest level and
gamma, marks slight deviations**, lokal):
- Bei jedem Treffer stehen jetzt das nächste Adopted-Level und -Gamma mit Δ in keV und in σ.
- Δ < 1 keV, aber > 3σ zählt als zugeordnet, mit der neuen Unterkategorie **„energy deviates
  slightly (…)“**.
- Der stille 1-keV-Boden aus der letzten Runde ist dadurch ersetzt.

| Treffer | Rohzeilen des Treffers | Nächstes in Adopted | Ergebnis |
|---|---|---|---|
| **A** ¹⁴⁴Nd 2109.4 4+ → 696.49 2+, 1413.0 D+Q, (n,γ) (144:5356) | `144ND  L 2109.4      4+`, `144ND  G 1413.0     156.0     2D+Q       +0.29   6` | Level `2109.79 3` 4+ (Zeile 3285): Δ = 0,39 keV = 3,7σ; Endniveau `696.561 10` 2+ (3180): Δ = 0,071 keV = 5,0σ; Gamma `1413.40 9` E2 (3294), innerhalb 3σ | **energy deviates slightly** → zugeordnet; Adopted widerspricht (E2, erlaubt). Stimmt mit Daniels Befund „bereinigt, E2“ überein. |
| **A′** ⁴¹K 9658 3/2- → 1582.10 3/2-, 8076 E1(+M2), ⁴⁰Ar(p,γ) (041:6882) | `41K   L 9658         3/2-`, `41K   G 8076         11.2      E1(+M2)   -5     10` | Level `9626 15` 1/2-,3/2- (Zeile 4433): Δ = 32 keV = 2,1σ (9658 hat kein DE, also σ = 1 keV); **dieses Level hat in Adopted kein Gamma**; nächstes Gamma in Adopted überhaupt: 8445.5 von 9740.70, Δ = 369,5 keV | **gamma not in Adopted** (keine leichte Abweichung) |
| **A′** ⁴⁸Ti 3698.3 1- → 983.65 2+, 2714.9 M1+E2, (p,p'γ) (048:12014) | `48TI  L 3698.3    3  1-`, `48TI  G 2714.9       65     2  M1+E2    +0.9    +14-5` | Level `3699.52 8` 1(-) (Zeile 6134): Δ = 1,22 keV = 3,9σ; Gamma dort `2715.81 13` (E1) (6145): Δ = 0,91 keV = 5,5σ | Level über 1 keV → bleibt **level not in Adopted**. Aus den Rohzeilen sieht man aber: Adopted hat 1(-) und (E1), also erlaubt. Würde man das Level zuordnen, wäre es „Adopted widerspricht“. **Daniel**: 1-keV-Grenze so lassen? |

Bilanz jetzt: A — 0 „nicht gefunden“, 1 „energy deviates slightly“ (¹⁴⁴Nd). A′ — 2 „nicht gefunden“
(⁴¹K: Gamma fehlt in Adopted; ⁴⁸Ti: Level 1,22 keV daneben). Kategorienzahlen unverändert
(A 29, A′ 24, …), 29 Zertifikate bauen. Bericht `~/ensdf/bericht.md`, Kopie `bericht_v4.md`.

## Korrektur ³⁰P und Parser-Prüfung eingerückter Energien (2026-10-22 19:20)
**Daniels Klarstellung**: `*` in Spalte 77 heißt „multiply-placed“ wie im Handbuch. Alle 9
`*`-Gammas im ³⁰P-Adopted-Satz sind Mehrfachplatzierungen: 627.0 ×2, 1463.8 ×3, 2342.3 ×2, 3184 ×2.
Die Regel „`*` → nicht fest platziert → B“ bleibt.

**Meine falsche Aussage** („ein zweites 2342-keV-Gamma gibt es nicht“) kam aus einer
**Handsuche mit awk**, nicht aus dem Werkzeug: Das Muster war an Spalte 10 verankert
(`substr($0,10,6) ~ /^234/`). Der zweite Eintrag hat das Energiefeld eingerückt:
```
7037:  30P   G 2342.3    8    100    M1+E2                   0.00044 5            *
7901:  30P   G  2342.3   8     29.111  D+Q     -0.4    1                          *
```
Der Record selbst ist **nicht verschoben** (`G` in Spalte 8, `*` in Spalte 77). Nur der Inhalt von
Spalte 10–19 beginnt eine Stelle weiter rechts.

**Parser geprüft** (`/tmp/t30.lean`, ruft `parseFile`/`placeGamma` direkt auf). Alle 9 `*`-Gammas
werden richtig gelesen und platziert, z. B.
- 7037: E 2342.3, DE 8, M1+E2, von 3019.8 → 677.11;
- 7901: E ` 2342.3` → 2342.3, DE 8, D+Q, MR −0.4, von 7286.8 → 4946.3;
- 7365: ` 627.0`, (D,Q), 5573.5 → 4946.3;
- 8280/8296: ` 3184`, 7920.3/7920.4 → 4736.11.

**Datenbankweit**:
- Eingerückte Energiefelder in L/G-Records sind häufig: 165,593 Gammas und 106,137 Levels.
- Kein Gamma hat eine unlesbare Energie.
- Bei den Levels habe ich alle sonst nicht lesbaren Formen einzeln gegen den Parser geprüft.
  Gefunden habe ich **eine echte Lücke**: ein Leerzeichen vor dem Offset (`3138  +X`, `881.6 +X`).
  Behoben: Leerzeichen innerhalb des Feldes werden ignoriert. Commit **ensdf-check: ignore blanks
  inside energy fields**.
- Weiter unlesbar sind **65** Level-Energien, alle nicht im Handbuch vorgesehen:
  - `SN+X`/`SN+Y` (Offset auf Offset);
  - `SN-…` (V.18 kennt nur `SN+NUM`);
  - `0+x`, `0.0+x` (kleines `x`, nicht belegt).
- Lauf danach: A 29 und A′ 24 unverändert (dieselben Records); C 66,889 → 66,886, ok 160,361 →
  160,364. 29 Zertifikate bauen.

## Entscheidungen Daniel (2026-10-22 19:10)
- **Breite-Schwelle 10 keV festgelegt.** Begründung und die Tabelle der Läufe mit 5, 10, 20 und
  50 keV stehen als Anhang in `bericht.md`. Die exe berechnet beides selbst und vergleicht die
  A- und A′-Records gegen 10 keV:
  - A ist bei allen vier Schwellen identisch.
  - A′ kommt ab 20 keV um ¹¹B 011:3762 und 011:3763 dazu. Grund: grobe Schreibweise `5.02E3`
    bzw. `4.44E3` ohne Unsicherheit. Adopted widerspricht beiden (E1+M2, erlaubt; geprüft im
    20-keV-Lauf).
  - Verweis auf `~/ensdf/sweep/`.
  - `broadKeV`-Docstring entsprechend.
- **⁴⁸Ti: 1-keV-Grenze bleibt.** Der nächste Kandidat (3699.52, Δ = 1,22 keV = 3,9σ; Gamma 2715.81
  (E1)) steht im Bericht.
- **³⁰P**: `*` = mehrfach platziert, die Regel bleibt (siehe oben).

## Abschluss (2026-10-22 19:25)
**Stand des Werkzeugs** (Branch `ensdf-check`, lokal, **nicht gepusht**, 13 Commits auf ae59f621 =
fork/pr/projection-selection):
- `Tools/EnsdfCheck/`:
  - `Rules.lean`: bewiesen, kein `sorry`, Standardaxiome.
  - `Parse.lean`, `Assign.lean`, `Classify.lean`, `Main.lean`: unbewiesener Code.
  - `Certificates.lean`: 29 Kern-geprüfte Zertifikate.
- `lakefile.toml`: `lean_lib EnsdfCheck`, `lean_exe ensdf-check`. PR-08-Dateien und
  `PhyslibAlpha.lean` unverändert.
- Aufruf: `lake exe ensdf-check ~/ensdf/data_261001 ~/ensdf/bericht.md --certificates
  Tools/EnsdfCheck/Certificates.lean` (≈ 25 s inkl. Schwellenanhang).

**Daten und Quellen**: ENSDF `ensdf_261001` (NNDC); Handbuch BNL-NCS-51655-01/02-Rev (2001); IAEA
Evaluators Guidelines 2021 (ORNL/TM-2022/1835); CODATA 2022 u c² (NIST). Hashes und URLs stehen
oben.

**Endergebnis** (233,102 Gamma-Übergänge mit Multipolarität, Schwelle 10 keV, Rückstoß
korrigiert):

| A | A′ | B | C | S | P | N | ok |
|---|---|---|---|---|---|---|---|
| 29 | 24 | 131 | 66,886 | 3 | 206 | 5,459 | 160,364 |

- **A (Lean-gestützt)**: 29 Records, alle mit Endniveau aus der Energiedifferenz.
  - Daniels NuDat-Prüfung, vom Werkzeug nachgebildet (29/29 übereinstimmend):
    - 17 auch in Adopted identisch;
    - 11 in Adopted bereinigt;
    - 1 in Adopted nur vorläufig (¹⁰⁶Pd).
  - Kandidaten für eine Meldung sind die 17 Fälle, die auch in Adopted identisch sind. Ob gemeldet
    wird und wie, entscheidet Daniel; der Kontakt nach außen liegt nur bei ihm.
- **A′ (Parität, nur Definition in PR 08)**: 24, davon 13 selbst Adopted, 2 auch dort A′,
  7 von Adopted widersprochen, 2 nicht gefunden (⁴¹K, ⁴⁸Ti).
- **S**: 5 Level-Records, darunter 2 Tippfehler `,` statt `/` (¹⁵C, ⁸³Kr), `32/2-` (¹²⁷La) und
  `58/2+` (¹⁷¹Re).
- Bericht: `~/ensdf/bericht.md` = `bericht_final.md`. Zwischenstände: `bericht_v2.md` bis
  `bericht_v4.md`; Schwellenläufe in `~/ensdf/sweep/`.

**Offen für Daniel**: Push des Branches und der Notizen; ob und wo veröffentlicht wird
(physlib-PR, eigenes Repo, Preprint); Meldung an NNDC; Folgeauftrag 3j²/6j² (laut Auftrag
„Danach“).
