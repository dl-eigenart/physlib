# Stand ENSDF Teil 2

Auftrag: `Auftrag-ENSDF-2.md` (Kopie von `~/ensdf/Auftrag-ENSDF-2.md`, Cowork-Entwurf vom
22.10.2026 19:18). Daten `ensdf_261001`. Nichts gepusht.

## T0 Bestand — erledigt (2026-10-22 19:40), nur gezählt, kein Build, keine Code-Änderung
Gezählt mit awk über alle 300 Dateien. Die Spalten folgen dem Handbuch III.B.14:
- M = Spalten 32–41, MR = 42–49, DMR = 50–55;
- Fortsetzungs-Records: Spalte 6 ist weder blank noch `1`, Spalte 7 blank, Spalte 8 `G`;
- Kommentare: Spalte 7 ∈ {c, C, d, D, t, T}.

Die Beispiele (bis zu 20 je Form) stehen in `t0-beispiele-ensdf-2.md`.

### Tabelle 1: Mischungsverhältnis δ (MR-Feld) in Gamma-Records (erste Karte, 793,431)
| Größe | Anzahl |
|---|---|
| Gammas mit MR-Feld | **35,728** |
| davon mit Vorzeichen (+/−) | 22,609 |
| davon ohne Vorzeichen (laut Handbuch III.B.14: „If no sign is given, it will be assumed to be unknown“) | 13,119 |
| DMR symmetrisch numerisch | 23,349 |
| DMR asymmetrisch `+x-y` | 7,246 |
| DMR asymmetrisch umgekehrt `-x+y` | 44 |
| DMR mit `|@` (vermutlich ∞, Bedeutung nicht nachgeschlagen) | 7 |
| DMR Grenze: LT / LE / GT / GE / AP / SY / CA | 2,202 / 820 / 570 / 179 / 458 / 2 / 1 |
| DMR leer | 850 |
| MR nicht numerisch (nur `+` oder `-`) | 15 (+3 mit Endpunkt wie `2.`, numerisch) |
| **M bei Gammas mit δ** | 26,917 gemischt `X+Y` · 8,811 gemischt mit Klammeranteil `X(+Y)` · **0 rein, 0 leer, 0 Alternativen** |
| gemischte M (`+`) ohne δ | 25,296 |

### Tabelle 2: Winkelverteilung, DCO, Polarisation
| Form | Records | Ort |
|---|---|---|
| `A2=` (Fortsetzung, G) | 10,389 | strukturiert |
| `A4=` (Fortsetzung, G) | 7,649 | strukturiert |
| `DCO…=` (Fortsetzung, G; auch `DCO(Q)`, `DCO(D)`, `DCO(1)`, `DCO(2)`) | 12,731 | strukturiert |
| `POL=` (Fortsetzung, G) | 806 | strukturiert |
| `A{-2}`/`A{-4}` im Kommentar | 29,655 | Freitext |
| `a{-2}`/`a{-4}` im Kommentar | 735 | Freitext |
| `A2` ohne Klammern im Kommentar | 1,122 | Freitext |
| „Legendre“ im Kommentar | 26 | Freitext |
| `DCO` im Kommentar | 27,688 | Freitext |
| `POL`/„polariz(s)ation“ im Kommentar | 6,514 | Freitext |
| `|g(|q)` = γ(θ) im Kommentar | 26,397 | Freitext |
| `|g|g(|q)` = γγ(θ) im Kommentar | 6,868 | Freitext |

Ein Record kann mehrere Formen enthalten; die Zahlen zählen Zeilen, nicht Gammas.

Weitere Größen auf G-Fortsetzungen (Inventar, Häufigste): LC 85,972, MC 83,205, KC 82,585 (Konversion),
FLAG 44,876, FL 34,702, %IG 17,548, BE2W 14,156, IPC 11,826, DCO 11,016, CC 10,571, A2 10,527,
EKC 9,772, BM1W 7,715, A4 7,677, BE1W 5,522.

### Tabelle 3: Belege aus den heruntergeladenen Quellen
| Frage | Beleg (Datei, Seite) |
|---|---|
| **δ-Vorzeichenkonvention** | Guidelines 2021, Anhang B „Sign Conventions for Mixing Ratios in Electromagnetic Transitions from Angular Correlations and Angular Distributions“ (M. J. Martin, 1987, rev. 2016), ab PDF-Seite 57 (gedruckt S. 52): „The two most widely used phase conventions are those proposed by Steffen [1] and by Rose and Brink [2] … relative to that of Steffen, whose convention is adopted in the following material.“ Die Formeln (1)–(6) sind dort als Bilder gesetzt und für T3/T4 noch zu lesen. Die Quellenliste des Anhangs (Becker/Steffen, Krane/Steffen, Rose/Brink, Frauenfelder/Steffen, Biedenharn/Rose) ist in der Datei enthalten; ich habe sie nicht unabhängig geprüft. |
| Vorzeichen im MR-Feld | Handbuch III.B.14: „Sign must be shown explicitly if known. If no sign is given, it will be assumed to be unknown.“; V.10: MR darf ein Vorzeichen tragen. |
| Vorzeichenwechsel | Guidelines PDF-S. 22, Punkt 11: „When changing the sign of a mixing ratio which has an asymmetric uncertainty, note that δ = A +a-b becomes δ = -A +b-a.“ |
| Form von A2, A4, DCO | Guidelines PDF-S. 22, Punkt 13, Note 1: „given in the form A2, A4, not A2/A0, A4/A0 … W(θ)=1+A2P2(cosθ)+…“; Note 2: Bei DCO muss der Charakter des Gates (D oder Q) angegeben werden. |
| Klammeranteil `M1(+E2)` | Guidelines §1.10 4e, PDF-S. 35 (aus Teil 1). |
| **Prüfprogramme laut Guidelines** | Checkliste (PDF-S. 54): „Run FMTCHK and correct all errors“, „Run PANDORA and correct any issues“. Weiter genannt: GTOL (Ausgleich der Niveauenergien, Feedings; nimmt 1 keV, wenn E ohne Unsicherheit ist), RULER (B(XL)W, Vergleich mit RUL, ρ²(E0)), BrIcc (Konversionskoeffizienten), AVETOOLS (Mittelung). **Was PANDORA prüft, steht in den Guidelines nicht.** |
| PANDORA, Prüfumfang | NNDC „ENSDF Analysis and Utility Codes“ (T. W. Burrows, `~/ensdf/codes/ensdf_codes_manual.pdf`, PDF-S. 40, gedruckt S. 37), PANDORA Version 6.6a (2001, J. K. Tuli), „physics checks“: 1. P-Karte in Zerfallsdatensätzen; 2. MS-Flag bei T½ > 0.1 s; **3. „Check consistency of spin/parity of levels with multipolarity connecting transitions.“**; 4. Transfer an gg-Target J = L±1/2; 5. log ft-Regeln; 6. α-HF-Regeln; 7. Levels in falscher Reihenfolge. |
| ConsistencyCheck | J. Chen, „Java-RULER and ConsistencyCheck“, IAEA-Codes-Meeting Dez. 2018 (`~/ensdf/codes/JunChen_…pdf`), Folie 12: „This program performs the following checks (PANDORA checks 1-5 plus some others)“, darunter **2. „consistency of gamma-ray multipolarity with change of spin and parity“**, 10. 0→0 mit Paritätswechsel, **15. „check if MULT and MR as quoted from Adopted is consistent“**, 7. BXLW gegen RUL. Folie 6: „gammas with large ΔJPI“. |

Quelldateien (sha256 und Datum in `~/ensdf/codes/*.headers`):
- `ensdf_codes_manual.pdf` (Last-Modified 22 Jul 2022, d6ffb1df…);
- `JunChen_IAEA_code_meeting_JAVA-RULER_and_ConsistencyCheck.pdf` (14 Dec 2018, fbaf7ea7…);
- `NSDD_2019_Nica_PANDORA&ENSDF_Consistency_Checking.pdf` (12 Apr 2019, 7bc4de57…; noch nicht ausgewertet).

### Was wäre wirklich neu? (Einschätzung aus den Belegen)
- **Nicht neu als Prüfung**: Jπ gegen Multipolarität (unsere A/A′) ist PANDORA-Prüfung 3 und
  ConsistencyCheck Nr. 2. Ebenso nicht neu: 0→0 (ConsistencyCheck 10), MULT/MR „as quoted from
  Adopted“ (Nr. 15, also teilweise T2-Vorzeichenvergleich), B(XL)W gegen RUL (RULER).
- **Neu an Teil 1**:
  - der formale Beweis (Kern-geprüfte Zertifikate aus dem bewiesenen Satz);
  - der datenbankweite Lauf über die aktuelle Ausgabe: Die 17 in Adopted identischen A-Fälle
    stehen trotz dieser Prüfprogramme in der Datenbank;
  - die genaue Regel für Klammeranteile.
- **Ausweislich der Belege kein bestehendes Programm** für:
  - δ gegen A2/A4 oder DCO (T4);
  - die rationalen 3j/6j mit Gleichheitsbeweis (T3);
  - „Mixed M ohne Dreieckszulässigkeit eines Anteils“ datenbankweit inkl. B/C (T2): Das deckt
    PANDORA 3 eventuell schon ab, der genaue Umfang ist nicht dokumentiert.
- **T2, erster Punkt** („δ angegeben, M rein“): kommt in den Daten **nicht vor** (0 Fälle).
  Der umgekehrte Fall „M gemischt, kein δ“ hat 25,296 Fälle und ist laut Guidelines §1.10 4c
  zulässig („If two multipolarities are given but no δ is known …“).

### Frage an Daniel (laut Auftrag)
Lohnt sich T4 (δ gegen A2/A4)? Grundlage: 10,389 strukturierte `A2=`- und 7,649 `A4=`-Records,
dazu ≈ 30,000 Freitext-Kommentare. Die Konvention (Steffen) ist belegt, die Formeln sind im
Anhang B als Bilder. Nach den vorliegenden Belegen gibt es dafür kein Prüfprogramm.
