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

## Entscheidung Daniel (2026-10-22 22:17)
T4 als Pilot T4a: erst die Steffen-Formeln aus Anhang B von den Bildseiten lesen (mit Seitenzahl),
dann ≈ 200 Fälle der häufigsten Kommentarform; Anteil lesbar, Treffer, Fehlalarme. Danach anhalten.

## T4a Pilot — erledigt (2026-10-22 23:10), Numerik, kein Beweis, kein Repo-Code
Code und Ausgaben in `~/ensdf/t4a/` (`check_fk.py`, `forms.py`, `pilot_t4a.py`, `pilot_200.txt`,
`pilot_200_flip.txt`). Bildseiten in `~/ensdf/guidelines/appB/pg-58…61.png`.

### Steffen-Formeln, Guidelines 2021 Anhang B (sha256 b085ec39…), von den Bildseiten gelesen
Gedruckte Seite 53 = PDF-Seite 58, gedruckte Seite 54 = PDF-Seite 59, gedruckte Seite 55 = PDF-Seite 60.
Kaskade J₁ →γ₁ (L₁, L₁′ = L₁+1)→ J₂ →γ₂ (L₂, L₂′)→ J₃.
- (1), S. 53: W(θ) = Σ B_k(γ₁) A_k(γ₂) P_k(cos θ), nur gerade k.
- (2), S. 54: B_k(γ₁) = [F_k(L₁L₁J₁J₂) + 2δ(γ₁)(−1)^(L−L′+k) F_k(L₁L₁′J₁J₂) + δ²(γ₁) F_k(L₁′L₁′J₁J₂)] / (1+δ²(γ₁))
  (für unpolarisiertes, nicht ausgerichtetes J₁).
- (3), S. 54: A_k(γ₂) = [F_k(L₂L₂J₃J₂) + 2δ(γ₂) F_k(L₂L₂′J₃J₂) + δ²(γ₂) F_k(L₂′L₂′J₃J₂)] / (1+δ²(γ₂)).
- (4), (5), S. 54: δ(γ₁) = ⟨J₂‖π₁′L₁′‖J₁⟩/⟨J₂‖π₁L₁‖J₁⟩, δ(γ₂) = ⟨J₃‖π₂′L₂′‖J₂⟩/⟨J₃‖π₂L₂‖J₂⟩.
- S. 54: „Steffen uses emission matrix elements and the initial state always appears on the right.
  Equations (1), (2), and (3) define a unique sign for the mixing ratios.“ F₀(LL′J₂J₃) = δ_LL′,
  B₀ = A₀ = 1. Beispiel aus den Tabellen [3]: **F₂(2242) = −0.1707, F₂(2202) = −0.5976**.
- S. 54: δ_Rose-Brink = (−1)^(L−L′) δ_Steffen; R_k(LL′J_iJ_f) = (−1)^(L−L′+k) F_k(LL′J_fJ_i).
- S. 55: δ_Biedenharn-Rose(γ₁) = −δ_Steffen(γ₁).
- **Die Guidelines definieren F_k nicht**, sie verweisen nur auf Frauenfelder/Steffen [3]
  („defined and tabulated by“). Für eine Rechnung braucht man also eine zweite Quelle.

### Quelle für F_k und die Ausrichtung
A. M. Hurst, D. A. Matters, T. Kawano, *Analytic calculator for determination of γ-ray angular
distribution coefficients and tensors in aligned and partially-aligned nuclei*, arXiv:2606.12681v3
(15 Jul 2026), `~/ensdf/sources_Fk/arxiv_2606.12681.pdf` (sha256 0ceb1c78…, Last-Modified 16 Jul 2026).
Gelesen von den Seitenbildern `ax-13/14/16.png`:
- Gl. (7), S. 14: F_k(J_f L₁ L₂ J_i) = (−1)^(J_f−J_i−1) √((2L₁+1)(2L₂+1)(2J_i+1)) ⟨L₁ 1 L₂ −1|k 0⟩ W(J_i J_i L₁ L₂; k J_f).
- Gl. (8), S. 14: A_k = [B_k F_k(J_f L₁L₁ J_i) + 2δ B_k F_k(J_f L₁L₂ J_i) + δ² B_k F_k(J_f L₂L₂ J_i)]/(1+δ²);
  Gl. (9): δ = ⟨J_f‖M(L₂)‖J_i⟩/⟨J_f‖M(L₁)‖J_i⟩. Das ist dieselbe Form wie Guidelines (3)/(5).
- Gl. (20), S. 18: ρ_k(J) = √(2J+1) Σ_m (−1)^(J−m) ⟨J m J −m|k 0⟩ P_m(J), P_m = P₋ₘ; Gl. (19) α_k = ρ_k/B_k.
- S. 19: Laut den Autoren reproduziert das Programm die Tabellen von Yamazaki, Rose/Brink und
  der Mateosian/Sunyar exakt, bis auf Druckfehler in Rose/Brink (nicht unabhängig geprüft).
- **Abgleich** (`check_fk.py`, sympy 1.17.0): Gl. (7) ergibt F₂(J_f=4, 2, 2, J_i=2) = −√70/49 =
  −0.170747 und F₂(0, 2, 2, 2) = −√70/14 = −0.597614. Das stimmt mit den Guidelines-Werten auf 4 Stellen überein.
  Zuordnung: Guidelines F_k(L L′ J_andere J_ausgerichtet) ↔ Hurst F_k(J_andere L L′ J_ausgerichtet).
  **Einschränkung**: Das prüft nur L = L′. Für das Vorzeichen des Mischterms gibt es in den Guidelines kein
  Zahlenbeispiel; dafür stütze ich mich nur auf die Aussage von Hurst et al. zu den Tabellen und auf die
  Vorzeichen-Gegenprobe unten.

### Häufigste Kommentarform (`forms.py`)
Unter den A{-2}-Kommentaren (Record-Typ: 28,216 G, 447 L, Rest wenige) ist die häufigste Vorlage
`A{-2}=x {Iu}, A{-4}=y {Iv}` (5,195 Records genau so; mit Text davor oder dahinter, auf einer Zeile,
G-Kommentar: **15,079**). Weitere: nur A{-2} (2,364), mit `;` (314), `{i…}` klein (304), mit `~` (97),
mit A{-6} (103), mit POL (139 + 137).

### Prüfregel (`pilot_t4a.py`)
- Gamma = letzter G-Record vor dem Kommentarblock. Anfangsniveau = letzter L davor. Endniveau wie in
  Teil 1: `FL=` oder E_i − E_γ − E_R mit 3σ, E_R = E_γ²/(2·A·931494 keV). Nur genau ein Kandidat.
- J_i, J_f: je ein einzelner Wert (Klammern erlaubt, als „vorläufig“ markiert). M: genau zwei Anteile
  L, L+1. δ aus dem MR-Feld derselben Zeile. Ohne Vorzeichen: beide Vorzeichen. DMR symmetrisch,
  `+x−y`, LT/LE = [0, δ], GT/GE = [δ, ∞); AP/SY/CA gelten als nicht lesbar.
- Zulässige Ausrichtung: beliebige P_m ≥ 0 mit P_m = P₋ₘ (konvexe Hülle von (ρ₂, ρ₄) aus Gl. (20))
  und dazu eine Abschwächung q_k ∈ [0, 1] je k (Q_k, G_k, U_k, partielle Ausrichtung). Großzügig, um
  Fehlalarme zu vermeiden.
- Treffer bei nσ: Für kein δ im nσ-Bereich (801 Punkte je Intervall, in arctan δ) gibt es eine
  zulässige Ausrichtung, die A₂ und A₄ innerhalb nσ liefert.
- **Ausgeschlossen (nicht auswertbar)**: γγ(θ)-Hinweis (`|g|g(`, `(…|g)(…|g)`) im Kommentar zum Gamma
  oder in den allgemeinen Kommentaren des Datensatzes. Grund: Bei γγ(θ) kann das gelistete Gamma das
  erste der Kaskade sein; dann gilt Gl. (2) mit der Phase (−1)^(L−L′+k), nicht Gl. (3) (siehe
  Fehlalarm 68Zn unten).

### Ergebnis, 200 Fälle (jeder 75. der 15,079 Records)
| Stufe | Anzahl |
|---|---|
| γγ-Kontext (Datensatzkommentar) | 63 |
| γγ-Kontext (Kommentar zum Gamma) | 17 |
| M rein (ein Anteil) | 59 |
| M leer | 8 |
| M gemischt, kein δ | 8 |
| J_i Liste/Bereich/leer | 11 |
| J_f Liste/Bereich/leer | 2 |
| unplatziert / Endniveau nicht gefunden / mehrdeutig | 4 / 1 / 1 |
| M sonst | 1 |
| **ausgewertet** | **25 (12,5 %)** |
| unvereinbar bei 1σ / 2σ / 3σ | **3 / 0 / 0** |

Laufzeit 1,4 s für alle 200.

**Vorzeichen-Gegenprobe** (δ → −δ, sonst gleich): unvereinbar bei 1σ / 2σ / 3σ = 8 / 3 / 2 von 25.
Mit dem falschen Vorzeichen gibt es also mehr Widersprüche. Das stützt die Konvention schwach (n = 25),
z. B. `110CD` Adopted, G 1125.709 M1+E2 +0.28 4, „from A{-2}=+0.36 {I2}, A{-4}=+0.02 {I4} (1992De41)“:
richtig vereinbar, umgedreht auch bei 3σ unvereinbar.

**Fehlalarme** (aus dem ersten Lauf ohne γγ-Ausschluss auf Datensatzebene; er hatte 40 Fälle ausgewertet,
2 davon bei 2σ unvereinbar, 0 bei 3σ):
- `ensdf.068:2942` 67ZN(N,G) E=THERMAL, G 1261.00 M1+E2 −0.23 +4−6, A₂ = +0.383(22): Nach dem
  Datensatzkommentar sind das γγ(θ)-Werte von 1971Ot01 (ein thermischer Einfang orientiert nichts). Das Modell
  passte nicht, deshalb gilt der Fall als Fehlalarm, und γγ auf Datensatzebene ist jetzt ausgeschlossen.
- `ensdf.032:12644` 31P(P,G), G 2162.8 (E1+M2) −0.05 2, A₂ = +0.559(20) (1969Pi10): Die übrigen sechs
  Messungen desselben Gammas liegen bei A₂ = +0.23 … +0.43. Das ist also ein Ausreißer einer
  Einzelmessung, kein Datenbankfehler. Er wird jetzt ebenfalls über den Datensatzkommentar (γγ) ausgeschlossen.

### Einschätzung für Daniels Entscheidung
- Lesbar sind nur ≈ 12 % der Kernform. Die größten Verluste kommen von γγ(θ) (40 %) und reinen M (30 %).
- Bei 25 auswertbaren Fällen gibt es keinen Treffer bei 2σ/3σ. Bei 15,079 Records wären im Volllauf
  ≈ 1,900 auswertbar; wie viele Treffer, lässt sich aus dem Pilot nicht schätzen.
- Mögliche Erweiterungen (nur nach OK):
  - reine M als δ = 0 prüfen (+30 %, eigene Kategorie „A2/A4 gegen M“);
  - γγ(θ) mit Gl. (2)·(3), wenn der Kaskadenpartner im Kommentar steht (`(E₁|g)(E₂|g)(|q)`);
  - weitere Formen (nur A{-2}, `;`, `{i…}`, `~`).
- Zertifikate (rationale Schranken) wären erst nach T3/R4 möglich, denn sie brauchen 6j.

## Entscheidung Daniel (2026-10-22 22:33)
Volllauf T4a freigegeben. Treffer erst ab 3σ, 2σ nur als Hinweis. Jeden Fall mit beiden
Vorzeichen von δ rechnen; nur mit umgekehrtem Vorzeichen vereinbar → Kategorie „Vorzeichen“.
Verwendete 3j gegen `Wigner3jRational` abgleichen, 6j nach R4. Reine M als δ = 0, eigene Kategorie.
γγ(θ) und seltenere Formen noch nicht. Danach R2.

## T4a Volllauf — erledigt (2026-10-22 23:40), Numerik, kein Beweis
`~/ensdf/t4a/volllauf_t4a.py` (aus dem Pilot; Prüfregel unverändert, siehe oben), Ausgaben
`voll.txt`, `voll_faelle.txt` (alle Treffer und Hinweise mit Rohzeilen), `voll_cg.txt`. Laufzeit 6,3 s.
Alle 15,079 Records der Kernform `A{-2}=x {Iu}, A{-4}=y {Iv}` (eine Zeile, G-Kommentar).

### Trichter
| Stufe | Anzahl |
|---|---|
| γγ-Kontext (Datensatzkommentar / Kommentar zum Gamma) | 5,192 / 1,676 |
| **ausgewertet: M rein (δ = 0)** | **3,585** |
| **ausgewertet: M gemischt mit δ** | **1,564** (davon 1,339 mit Vorzeichen) |
| M leer / M gemischt ohne δ / M sonst | 815 / 657 / 64 |
| J_i Liste/Bereich/sonst / leer | 628 / 353 |
| J_f Liste/Bereich/sonst / leer | 110 / 39 |
| unplatziert / Endniveau mehrdeutig / nicht gefunden | 227 / 90 / 14 |
| kein Gamma direkt vor dem Kommentar | 44 |
| δ nicht lesbar (MR nicht numerisch / DMR AP) | 11 / 10 |

### Zählungen mit beiden Vorzeichen (gemischt, 1,564 Fälle)
| | angegebenes Vorzeichen | umgekehrtes Vorzeichen |
|---|---|---|
| unvereinbar bei 1σ | 275 | 397 |
| unvereinbar bei 2σ | 86 | 153 |
| unvereinbar bei 3σ | 21 | 65 |

Bei δ ohne Vorzeichen (225 Fälle) sind beide Rechnungen gleich (beide Vorzeichen sind ohnehin
zugelassen). Mit dem umgekehrten Vorzeichen gibt es etwa dreimal so viele 3σ-Widersprüche; das stützt
die Konvention (Steffen) in Rechnung und Daten.

Rein (δ = 0, 3,585 Fälle): unvereinbar bei 1σ / 2σ / 3σ = 596 / 271 / 159.

### Kategorien
| Kategorie | Anzahl |
|---|---|
| **T4-δ**: 3σ, mit beiden Vorzeichen unvereinbar | **18** |
| **T4-Vorzeichen**: 3σ unvereinbar, mit umgekehrtem Vorzeichen vereinbar | **3** |
| **T4-rein**: 3σ, δ = 0 unvereinbar | **159** |
| Hinweis gemischt (2σ, nicht 3σ) | 65 |
| Hinweis rein (2σ, nicht 3σ) | 112 |

T4-rein nach Kennzeichnung: L = 1 in 124 Fällen, L = 2 in 35; davon 78 bzw. 24 mit J_i, J_f und M ohne
Klammern; 10 Fälle mit J_i = 0 oder 1/2.

### Abgleich der 3j-Werte mit `Wigner3jRational` (R1)
- Alle **3,432** im Lauf verwendeten CG-Koeffizienten (sympy, exakt) wurden über die in Lean bewiesene
  Beziehung `cgCoefficient_eq_threeJR` (⟨j₁m₁j₂m₂|JM⟩ = (−1)^(j₁−j₂+M) √(2J+1) (j₁ j₂ J; m₁ m₂ −M))
  in t·|t| umgerechnet und mit `threeJSgnSqQ` verglichen (`abgleich_3j.py`; Lean-Werte per `#eval`,
  also kompiliert gerechnet, kein Beweis; 32 s).
- Ergebnis: **3,432 verglichen, 0 Abweichungen** (exakte rationale Gleichheit einschließlich Vorzeichen).
  Ein erster Lauf meldete 5 Abweichungen; Ursache war mein Vergleichsskript (`(-1)**(-1)` ergibt in
  Python eine Gleitkommazahl), nicht die Werte.
- Racah-W (6j) ist noch nicht abgeglichen; das folgt nach R4.

### Erste Durchsicht der Treffer (meine Einschätzung, Daniel prüft gegen NNDC)
- **Fehlalarm (Modell)**: `ensdf.141:7844` 141PR, A₂/A₄ gelten laut Kommentar „for 273.7γ+272.7γ“
  (Dublett). Dubletts erkennt die Prüfregel nicht.
- **Doppelt**: `ensdf.206:8145` (Adopted) und `ensdf.206:9071` (205TL(A,3NG)) sind dieselbe Messung (1978Lo09).
- **Muster T4-δ**: Meist ist A₄ deutlich größer, als das kleine δ erlaubt (A₄ kommt nur über den
  Quadrupolanteil δ²/(1+δ²) zustande), z. B. 41K 1023.2 (δ = −0.08(1), A₄ = +0.04(1)), 166TM 166.8
  (δ = +0.25(1), A₄ = +0.13(2)).
- **Auffällig**: `ensdf.037:7122` 37CL, A₄ = +0.230 {I2} (±0.002) neben A₂ = +0.210 {I13}; die
  Unsicherheit von A₄ ist ungewöhnlich klein.
- **Muster T4-rein**: Meist ist A₄ bei reinem Dipol (D, E1, M1) deutlich von null verschieden. Für L = 1
  ist F₄ = 0, also müsste A₄ = 0 sein. Ob „M rein“ in ENSDF wirklich δ = 0 meint oder nur den
  Hauptanteil, ist nicht belegt; die Kategorie ist deshalb vorsichtig zu lesen.

### Erste 10 Treffer je Kategorie (Rohzeilen: Level, Gamma, Endniveau, Kommentar)

#### T4-delta (3 sigma, mit beiden Vorzeichen unvereinbar): 18 — erste 10
```
ensdf.023:5605  [22NE(P,G)]  Ji=7/2 Jf=7/2 (fest/fest/M fest) L=(1, 2) delta=('+0.118', '5', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     23NA  L 9732.53   13  7/2                                                  F
     23NA  G 7655.15      6.7       D+Q       +0.118 5
     23NA  L 2076.01    3 7/2+             24 FS     2
     23NA cG M$A{-2}=0.47 {I3}, A{-4}=0.10 {I3} (1989Ba42)

ensdf.036:10397  [35CL(P,G),(P,P'),(P,A):RES]  Ji=5 Jf=5 (fest/fest/M vorlaeufig) L=(1, 2) delta=('-0.04', '8', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     36AR  L 10675.9   10 5
     36AR  G 4458.3      60        D(+Q)     -0.04   8
     36AR  L 6217.3    3 5-                201 FS    35
     36AR cG M,MR$A{-2}=+0.34 {I2}, A{-4}=+0.08 {I2} (1973Ho33)

ensdf.037:7122  [36S(P,G),(P,P)]  Ji=3/2 Jf=3/2 (fest/fest/M fest) L=(1, 2) delta=('-0.06', '1', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     37CL  L 10294.5   4 3/2
     37CL  G 10293.0     46        D+Q       -0.06   1
     37CL  L 0           3/2+                                                   C
     37CL cG $A{-2}=+0.29 {I1} (1984No06); A{-2}=+0.210 {I13}, A{-4}=+0.230 {I2}

ensdf.037:8957  [34S(A,NG)]  Ji=11/2 Jf=11/2 (fest/fest/M vorlaeufig) L=(1, 2) delta=('-0.08', '4', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     37AR  L 5213.50   24  11/2+           2.50 PS   21
     37AR  G 1506.7    3 41      2 E1(+M2)   -0.08   4
     37AR  L 3707.03   23 11/2-            256 FS    14
     37AR cG $A{-2}=+0.39 {I2}, A{-4}=+0.07 {I2}, p=-0.76 {I7} (1975No01)

ensdf.039:9010  [36AR(A,PG),(A,P)]  Ji=3/2 Jf=3/2 (fest/fest/M fest) L=(1, 2) delta=('-1.2', '+6-15', 'asym')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     39K   L 3939.0    5 3/2+                87 FS   21
     39K   G 3938.3    10 91.8   12 M1+E2    -1.2    +6-15
     39K   L 0           3/2+
     39K  cG $A{-2}=+0.343 {I13}, A{-4}=+0.059 {I12}, POL=+0.24 {I11}

ensdf.041:4933  [38AR(A,PG)]  Ji=5/2 Jf=7/2 (fest/fest/M fest) L=(1, 2) delta=('-0.08', '1', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     41K   L 2317.2    2  5/2-              0.54 PS   15
     41K   G 1023.2    2  94.0   3  M1+E2     -0.08  1
     41K   L 1293.8    2  7/2-              3.1 PS    GT
     41K  cG $A{-2}=-0.03 {I1}, A{-4}=+0.04 {I1}, POL=-0.09 {I7}

ensdf.130:3001  [130TE(N,N'G)]  Ji=5 Jf=4 (fest/fest/M vorlaeufig) L=(1, 2) delta=('+0.03', '2', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
    130TE  L 2101.26   3  5-
    130TE  G 468.27    2  8.1    10 E1(+M2)  +0.03   2                          A
    130TE  L 1632.999  22 4+
    130TE cG           A{-2}=-0.206 {I3}, A{-4}=-0.023 {I6}. POL=+1.9 {I+3-2}

ensdf.138:6446  [138BA(N,N'G)]  Ji=3 Jf=2 (fest/fest/M fest) L=(1, 2) delta=('+0.018', '7', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
    138BA  L 2445.576  23 3+               0.7 PS    GE
    138BA  G 1009.70   2 33      1 M1+E2     +0.018  7
    138BA  L 1435.858  18 2+               0.19 PS   +13-6
    138BA cG $A{-2}=-0.31 {I1}, A{-4}=+0.08 {I1} (1984Di03)

ensdf.141:7844  [139LA(A,2NG)]  Ji=13/2 Jf=11/2 (fest/fest/M fest) L=(1, 2) delta=('+0.08', '6', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
    141PR  L 1767.9     513/2+
    141PR  G 273.7      3191      4M1+E2     +0.08   6     0.081
    141PR  L 1494.2     411/2+
    141PR cG M         A{-2}=-0.09 {I8}, A{-4}=-0.68 {I16}, for 273.7|g+272.7|g

ensdf.148:16355  [(HI,XNG)]  Ji=10 Jf=9 (fest/fest/M fest) L=(1, 2) delta=('0.18', 'LE', 'ohne Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
    148GD  L 3758.61   23 10+              7.6 PS    10                         D
    148GD  G 1063.6    2 260       E1+M2     0.18    LE    0.0011514
    148GD  L 2695.05   18 9-               16.6 NS   3                          B
    148GD cG           A{-2}=-0.17 {I2}, A{-4}=0.12 {I3} (|a,4n); A{-2}=-0.13 {I4},

```

#### T4-Vorzeichen (3 sigma, nur mit umgekehrtem Vorzeichen vereinbar): 3 — erste 3
```
ensdf.031:13463  [28SI(A,PG),4HE(28SI,PG)]  Ji=9/2 Jf=7/2 (fest/fest/M fest) L=(1, 2) delta=('+0.29', '4', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=True/True/True  Endniveau via E_i-E_g-E_R
     31P   L 6793      1 9/2-              139 FS    41
     31P   G 2362        75      8 M1+E2     +0.29   4
     31P   L 4430.5    5  7/2-             0.41 PS   11                         X
     31P  cG $A{-2}=-0.82 {I5}, A{-4}=+0.08 {I6}

ensdf.059:7488  [50CR(12C,2PNG)]  Ji=13/2 Jf=11/2 (fest/fest/M fest) L=(1, 2) delta=('-0.22', '5', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/True  Endniveau via E_i-E_g-E_R
     59NI  L 4455.4    6  13/2
     59NI  G  1750.5   5   12      D+Q       -0.22   5                           C
     59NI  L 2704.91   12 11/2
     59NI cG           A{-2}=-0.44 {I8}, A{-4}=+0.33 {I8}; DCO(1751|g,1367|g)=1.7

ensdf.143:8340  [141PR(A,2NG)]  Ji=21/2 Jf=21/2 (vorlaeufig/fest/M fest) L=(1, 2) delta=('+1.1', '1', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/True  Endniveau via E_i-E_g-E_R
    143PM  L 3389.7      (21/2-)
    143PM  G 376.5     1 73        M1+E2     +1.1    1     0.0335 8             &
    143PM  L 3013.2      21/2-
    143PM cG M         A{-2}=+0.27 {I2}, A{-4}=+0.15 {I4}; p=+0.07 {I4}

```

#### T4-rein (3 sigma, delta = 0 unvereinbar): 159 — erste 10
```
ensdf.022:4679  [20NE(3HE,P),(3HE,PG)]  Ji=2 Jf=1 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     22NA  L 1952         2+
     22NA  G 1366        100        M1
     22NA  L 586       4  1+                                0+(2)
     22NA cG M$A{-2}=-0.22 {I5}, A{-4}=0.07 {I2}, Pol(90)=-0.30 {I12} (1970Ol03)

ensdf.022:4683  [20NE(3HE,P),(3HE,PG)]  Ji=1 Jf=0 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     22NA  L 2214      4  1-                                (1)
     22NA  G 1556        100        E1
     22NA  L 658       4  0+                                0
     22NA cG M$A{-2}=-0.76 {I3}, A{-4}=-0.26 {I6}, Pol(90)=1.17 {I34} (1970Ol03)

ensdf.031:13468  [28SI(A,PG),4HE(28SI,PG)]  Ji=11/2 Jf=9/2 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     31P   L 6825      1 11/2-             62 FS     26
     31P   G 1482        40      10 E1
     31P   L 5343.1    6 9/2+              33 FS     11
     31P  cG $A{-2}=-0.53 {I4}, A{-4}=+0.07 {I5} and A{-2}=-0.31 {I10}, A{-4}=+0.01

ensdf.041:13709  [40CA(A,2PNG)]  Ji=15/2 Jf=11/2 (fest/fest/M fest) L=(2, 2) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     41CA  L 3831.0    12 15/2+
     41CA  G 461.1     5           E2                                           A
     41CA  L 3369.9    10 11/2+
     41CA cG $A{-2}=+0.40 {I2}, A{-4}=+0.20 {I3}

ensdf.043:3849  [40AR(A,NG)]  Ji=5/2 Jf=7/2 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     43CA  L 1394.78   205/2+              2.4 PS    8
     43CA  G 1394.8    4 11.7    4 E1
     43CA  L 0.0         7/2-
     43CA cG           A{-2}=-0.25 {I3}, A{-4}=+0.09 {I3}. Pol=+0.12 {I19}

ensdf.048:3601  [48CA(N,N'G)]  Ji=4 Jf=4 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     48CA  L 6649.7    3  4+               114 FS    +42-28
     48CA  G 2145.1    1            D                                           B
     48CA  L 4504.0    3  4+
     48CA cG $A{-2}=-0.52 {I14}, A{-4}=-0.90 {I23}

ensdf.048:14829  [10B(40CA,2PG),40CA(10B,2PG)]  Ji=5 Jf=4 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     48V   L 428.3      4 5+               14 PS     LT                         E
     48V   G 428.2     5  63     3  D
     48V   L 0.0          4+                                                    E
     48V  cG $A{-2}=-0.40 {I2}, A{-4}=+0.03 {I3}

ensdf.048:14847  [10B(40CA,2PG),40CA(10B,2PG)]  Ji=6 Jf=5 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     48V   L 627.6      4 6+               90 PS     42                         E
     48V   G 199.6     5  44     1  D
     48V   L 428.3      4 5+               14 PS     LT                         E
     48V  cG $A{-2}=-0.40 {I2}, A{-4}=+0.02 {I2}

ensdf.051:7205  [48TI(A,NG)]  Ji=3/2 Jf=7/2 (fest/fest/M fest) L=(2, 2) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     51CR  L   749.19  163/2-              7.25 NS   25
     51CR  G 749.0     2 100       E2                                            C
     51CR  L 0.0         7/2-
     51CR cG           |g(|q): A{-2}=+0.049 {I2}, A{-4}=+0.007 {I2} (1973Sa12)

ensdf.059:9103  [58NI(3HE,2PG)]  Ji=9/2 Jf=7/2 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     59NI  L 3054.52   14 9/2+                                                  X
     59NI  G 1716.4    2   2.8     E1                                            C
     59NI  L 1337.98   11 7/2-                                                  Y
     59NI cG           A{-2}=-0.190 {I13}, A{-4}=-0.011 {I2}, giving |d=-0.03

```

## Entscheidung Daniel (2026-10-22 23:27)
T4 nachschärfen: mehrfach platzierte Linien und Dubletts ausschließen (eigene Zählung), Doppelte
(gleiche Referenz in Adopted und Einzeldatensatz) einmal zählen, T4-rein teilen in „Dipol, A4 ≠ 0
bei 3σ“ und „rein, sonst“; aus den Guidelines belegen, was reine M ohne MR bedeutet. Neu laufen.
Lokal committen erlaubt, pushen nur nach „ja“.

## T4a Volllauf 2 — erledigt (2026-10-23 00:40), Numerik, kein Beweis
`~/ensdf/t4a/volllauf2_t4a.py`, Ausgaben `voll2.txt`, `voll2_faelle.txt`, `voll2_cg.txt`. 6,8 s.

### Was reine Multipolarität ohne MR in ENSDF bedeutet (Belege)
- Guidelines 2021, §1.10 Punkt 4a, PDF-S. 35: „If a single multipolarity is adopted, the MR field
  should be blank. If δ is given as a limit, there are two options. i) Give the dominant component in
  the M field, with the corresponding CC, and give the MR limit in a comment. ii) Give both components
  in the M field and give the δ limit in the MR field.“ Dazu die Note: Option i) wird empfohlen, wenn
  der beigemischte Anteil vermutlich überschätzt ist (Beispiel E2+M3); „MI+E2 with δ <0.5 should be
  retained as a mixed multipolarity entry“.
  → **Eine reine M ohne MR heißt nicht zwingend δ = 0**, sondern kann die dominante Komponente
  bedeuten; eine δ-Grenze steht dann nur im Kommentar.
- Guidelines, dieselbe Seite, Note 4: A2, A4 aus γ(θ), DCO oder Pol „should be given as continuation
  records rather than as comments“. Die hier ausgewerteten Kommentar-A2/A4 sind also die ältere oder
  nicht empfohlene Form.
- Handbuch (`ensdf-manual.pdf`), Grundlagen für Spin-Zuordnungen, PDF-S. 107, Regel 19: „A4=0 for
  ΔJ=0, dipole transition“; 19c: „If A4>0 (A2≈+0.5 to −0.8), the transition is ΔJ=1, D+Q.“ Das deckt
  die Kategorie Dipol-A4 aus Sicht der Evaluatoren-Regeln.
- Modellunabhängig: Für L = L′ = 1 ist F₄ = 0 (Hurst et al. Gl. (7), ⟨1 1 1 −1|4 0⟩ = 0), also A₄ = 0
  für jeden reinen Dipol, gleich welche Spins und welche Ausrichtung.

### Neue Ausschlüsse
- **Mehrfach platziert** (Spalte 77 der Gamma-Zeile `*`, `&`, `@`): **264**.
- **Dublett** (zwei Gamma-Energien mit `+` in einem Kommentar zum Gamma, mit oder ohne `|g`, beide
  Zahlen mindestens zweistellig): **255**. Die Form ohne `|g` kam hinzu, nachdem die Doppelten-Prüfung
  `209AT` 577.07/577.60 („for 577.07+577.60“) und `205BI` 795.9/796.0 aufgedeckt hatte. Stichprobe der
  neuen Treffer: alles Energiesummen („for 577.07+577.60“, „doublet of …“, „I|g(…+…)“).
- **Dublett-Verdacht** (gleiche A2/A4-Zeichenkette an zwei verschiedenen Gammas desselben Datensatzes,
  ≤ 1 keV auseinander): **51** aus den Ausgewerteten (Liste in `voll2.txt`).
- **Doppelte** (gleicher Kern, gleiche A2/A4 samt Unsicherheit, |ΔE| ≤ 1 keV, gleiche oder fehlende
  Referenz; einmal Adopted, einmal Einzeldatensatz): **152** Adopted-Kopien nicht mitgezählt
  (Liste in `voll2.txt`).

### Trichter (Volllauf 2)
| Stufe | Anzahl |
|---|---|
| γγ-Kontext (Datensatzkommentar / Kommentar zum Gamma) | 5,051 / 1,600 |
| mehrfach platziert / Dublett | 264 / 255 |
| M leer / M gemischt ohne δ / M sonst | 730 / 636 / 64 |
| J_i Liste/Bereich/sonst / leer; J_f Liste/Bereich/sonst / leer | 603 / 340; 105 / 37 |
| unplatziert / Endniveau mehrdeutig / nicht gefunden | 226 / 88 / 14 |
| kein Gamma davor / δ nicht lesbar | 44 / 19 |
| ausgewertet vor Dublett-Verdacht und Doppelten | 5,003 |
| − Dublett-Verdacht / − Doppelte | 51 / 152 |
| **ausgewertet: gemischt mit δ / rein** | **1,470 / 3,330** |

| gemischt (1,470; 1,274 mit Vorzeichen) | angegebenes Vorzeichen | umgekehrtes Vorzeichen |
|---|---|---|
| unvereinbar bei 1σ / 2σ / 3σ | 252 / 77 / 17 | 369 / 140 / 62 |

Rein (3,330): unvereinbar bei 1σ / 2σ / 3σ = 545 / 247 / 140.

### Kategorien (Volllauf 2)
| Kategorie | Anzahl | vorher |
|---|---|---|
| **T4-δ** (3σ, mit beiden Vorzeichen unvereinbar) | **15** | 18 |
| **T4-Vorzeichen** (3σ, nur mit umgekehrtem Vorzeichen vereinbar) | **2** | 3 |
| **T4-Dipol-A4** (rein, L = 1, \|A₄\| > 3σ; modellunabhängig) | **50** | – |
| **T4-rein-sonst** (3σ, δ = 0 unvereinbar, nicht Dipol-A4) | **91** | – (159 zusammen) |
| Hinweis gemischt (2σ, nicht 3σ) | 60 | 65 |
| Hinweis rein (2σ, nicht 3σ) | 107 | 112 |

- Die alten Fehlalarme sind weg: 141PR (Dublett) und die zweite 206BI-Kopie (doppelt).
- T4-rein-sonst ist wegen §1.10 4a i) vorsichtig zu lesen: Die angegebene M kann die dominante
  Komponente sein. T4-Dipol-A4 bleibt davon unberührt, wenn man A₄ ≠ 0 als Hinweis auf D+Q liest
  (Handbuch Regel 19c), nicht als Rechenfehler.
- 3j-Abgleich: Alle 3,312 verwendeten CG sind eine Teilmenge der bereits abgeglichenen 3,432
  (0 Abweichungen).

### Erste 10 Treffer je Kategorie (Volllauf 2; Rohzeilen Level, Gamma, Endniveau, Kommentar)

#### T4-delta (3 sigma, mit beiden Vorzeichen unvereinbar): 15 — erste 10
```
ensdf.023:5605  [22NE(P,G)]  Ji=7/2 Jf=7/2 (fest/fest/M fest) L=(1, 2) delta=('+0.118', '5', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     23NA  L 9732.53   13  7/2                                                  F
     23NA  G 7655.15      6.7       D+Q       +0.118 5
     23NA  L 2076.01    3 7/2+             24 FS     2
     23NA cG M$A{-2}=0.47 {I3}, A{-4}=0.10 {I3} (1989Ba42)

ensdf.036:10397  [35CL(P,G),(P,P'),(P,A):RES]  Ji=5 Jf=5 (fest/fest/M vorlaeufig) L=(1, 2) delta=('-0.04', '8', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     36AR  L 10675.9   10 5
     36AR  G 4458.3      60        D(+Q)     -0.04   8
     36AR  L 6217.3    3 5-                201 FS    35
     36AR cG M,MR$A{-2}=+0.34 {I2}, A{-4}=+0.08 {I2} (1973Ho33)

ensdf.037:7122  [36S(P,G),(P,P)]  Ji=3/2 Jf=3/2 (fest/fest/M fest) L=(1, 2) delta=('-0.06', '1', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     37CL  L 10294.5   4 3/2
     37CL  G 10293.0     46        D+Q       -0.06   1
     37CL  L 0           3/2+                                                   C
     37CL cG $A{-2}=+0.29 {I1} (1984No06); A{-2}=+0.210 {I13}, A{-4}=+0.230 {I2}

ensdf.037:8957  [34S(A,NG)]  Ji=11/2 Jf=11/2 (fest/fest/M vorlaeufig) L=(1, 2) delta=('-0.08', '4', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     37AR  L 5213.50   24  11/2+           2.50 PS   21
     37AR  G 1506.7    3 41      2 E1(+M2)   -0.08   4
     37AR  L 3707.03   23 11/2-            256 FS    14
     37AR cG $A{-2}=+0.39 {I2}, A{-4}=+0.07 {I2}, p=-0.76 {I7} (1975No01)

ensdf.039:9010  [36AR(A,PG),(A,P)]  Ji=3/2 Jf=3/2 (fest/fest/M fest) L=(1, 2) delta=('-1.2', '+6-15', 'asym')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     39K   L 3939.0    5 3/2+                87 FS   21
     39K   G 3938.3    10 91.8   12 M1+E2    -1.2    +6-15
     39K   L 0           3/2+
     39K  cG $A{-2}=+0.343 {I13}, A{-4}=+0.059 {I12}, POL=+0.24 {I11}

ensdf.041:4933  [38AR(A,PG)]  Ji=5/2 Jf=7/2 (fest/fest/M fest) L=(1, 2) delta=('-0.08', '1', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     41K   L 2317.2    2  5/2-              0.54 PS   15
     41K   G 1023.2    2  94.0   3  M1+E2     -0.08  1
     41K   L 1293.8    2  7/2-              3.1 PS    GT
     41K  cG $A{-2}=-0.03 {I1}, A{-4}=+0.04 {I1}, POL=-0.09 {I7}

ensdf.130:3001  [130TE(N,N'G)]  Ji=5 Jf=4 (fest/fest/M vorlaeufig) L=(1, 2) delta=('+0.03', '2', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
    130TE  L 2101.26   3  5-
    130TE  G 468.27    2  8.1    10 E1(+M2)  +0.03   2                          A
    130TE  L 1632.999  22 4+
    130TE cG           A{-2}=-0.206 {I3}, A{-4}=-0.023 {I6}. POL=+1.9 {I+3-2}

ensdf.138:6446  [138BA(N,N'G)]  Ji=3 Jf=2 (fest/fest/M fest) L=(1, 2) delta=('+0.018', '7', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
    138BA  L 2445.576  23 3+               0.7 PS    GE
    138BA  G 1009.70   2 33      1 M1+E2     +0.018  7
    138BA  L 1435.858  18 2+               0.19 PS   +13-6
    138BA cG $A{-2}=-0.31 {I1}, A{-4}=+0.08 {I1} (1984Di03)

ensdf.148:16355  [(HI,XNG)]  Ji=10 Jf=9 (fest/fest/M fest) L=(1, 2) delta=('0.18', 'LE', 'ohne Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
    148GD  L 3758.61   23 10+              7.6 PS    10                         D
    148GD  G 1063.6    2 260       E1+M2     0.18    LE    0.0011514
    148GD  L 2695.05   18 9-               16.6 NS   3                          B
    148GD cG           A{-2}=-0.17 {I2}, A{-4}=0.12 {I3} (|a,4n); A{-2}=-0.13 {I4},

ensdf.166:15393  [165HO(A,3NG)]  Ji=12 Jf=11 (fest/fest/M fest) L=(1, 2) delta=('+0.25', '1', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via FL=
    166TM  L  904.430+X12 12-                                                   C
    166TM  G   166.819  7   24.3  7 M1+E2    +0.25   1                           C
    166TM  L  737.614+X11 11-                                                   c
    166TM cG M         A{-2}=+0.14 {I2}, A{-4}=+0.13 {I2} (1995Ma07).

```

#### T4-Vorzeichen (3 sigma, nur mit umgekehrtem Vorzeichen vereinbar): 2 — erste 2
```
ensdf.031:13463  [28SI(A,PG),4HE(28SI,PG)]  Ji=9/2 Jf=7/2 (fest/fest/M fest) L=(1, 2) delta=('+0.29', '4', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=True/True/True  Endniveau via E_i-E_g-E_R
     31P   L 6793      1 9/2-              139 FS    41
     31P   G 2362        75      8 M1+E2     +0.29   4
     31P   L 4430.5    5  7/2-             0.41 PS   11                         X
     31P  cG $A{-2}=-0.82 {I5}, A{-4}=+0.08 {I6}

ensdf.059:7488  [50CR(12C,2PNG)]  Ji=13/2 Jf=11/2 (fest/fest/M fest) L=(1, 2) delta=('-0.22', '5', 'mit Vorzeichen')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/True  Endniveau via E_i-E_g-E_R
     59NI  L 4455.4    6  13/2
     59NI  G  1750.5   5   12      D+Q       -0.22   5                           C
     59NI  L 2704.91   12 11/2
     59NI cG           A{-2}=-0.44 {I8}, A{-4}=+0.33 {I8}; DCO(1751|g,1367|g)=1.7

```

#### T4-Dipol-A4 (rein L = 1, |A4| > 3 sigma; F4 = 0, modellunabhaengig): 50 — erste 10
```
ensdf.022:4679  [20NE(3HE,P),(3HE,PG)]  Ji=2 Jf=1 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     22NA  L 1952         2+
     22NA  G 1366        100        M1
     22NA  L 586       4  1+                                0+(2)
     22NA cG M$A{-2}=-0.22 {I5}, A{-4}=0.07 {I2}, Pol(90)=-0.30 {I12} (1970Ol03)

ensdf.022:4683  [20NE(3HE,P),(3HE,PG)]  Ji=1 Jf=0 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     22NA  L 2214      4  1-                                (1)
     22NA  G 1556        100        E1
     22NA  L 658       4  0+                                0
     22NA cG M$A{-2}=-0.76 {I3}, A{-4}=-0.26 {I6}, Pol(90)=1.17 {I34} (1970Ol03)

ensdf.048:3601  [48CA(N,N'G)]  Ji=4 Jf=4 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     48CA  L 6649.7    3  4+               114 FS    +42-28
     48CA  G 2145.1    1            D                                           B
     48CA  L 4504.0    3  4+
     48CA cG $A{-2}=-0.52 {I14}, A{-4}=-0.90 {I23}

ensdf.059:9103  [58NI(3HE,2PG)]  Ji=9/2 Jf=7/2 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     59NI  L 3054.52   14 9/2+                                                  X
     59NI  G 1716.4    2   2.8     E1                                            C
     59NI  L 1337.98   11 7/2-                                                  Y
     59NI cG           A{-2}=-0.190 {I13}, A{-4}=-0.011 {I2}, giving |d=-0.03

ensdf.072:5873  [62NI(13C,P2NG)]  Ji=4 Jf=3 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     72AS  L 309.70    8 4-
     72AS  G 96.1      1           E1
     72AS  L 213.60    8 3+
     72AS cG $A{-2}=-0.01 {I2}, A{-4}=-0.10 {I2}

ensdf.078:3566  [76GE(A,2NG)]  Ji=4 Jf=4 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     78SE  L 2742.45   21 4-               0.42 NS   14                         Z
     78SE  G 551.9     2    5.1  3 E1                                            C
     78SE  L 2190.54   204+                0.7 PS    3                          Y
     78SE2cG (1987Sc07); A{-2}=+0.20 {I2}, A{-4}=-0.07 {I2}, pol=-0.25 {I6}

ensdf.084:6046  [76GE(12C,4NG),81BR(6LI,3NG)]  Ji=5 Jf=4 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     84SR  L 2769.30   15 5-               9.5 PS    6                          D
     84SR  G 1001.4    1 21.7    19 D
     84SR  L 1767.90   13 4+               1.73 PS   21                         A
     84SR cG $A{-2}=-0.18 {I1}, A{-4}=+0.012 {I1}

ensdf.084:6088  [76GE(12C,4NG),81BR(6LI,3NG)]  Ji=7 Jf=6 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     84SR  L 3488.21   16 7-               4.4 PS    5                          D
     84SR  G 680.1     2 3.9     AP   D                                         X
     84SR  L 2808.11   15 6+               1.04 PS   21                         A
     84SR cG $A{-2}=-0.31 {I4}, A{-4}=+0.16 {I5}

ensdf.084:6098  [76GE(12C,4NG),81BR(6LI,3NG)]  Ji=7 Jf=6 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     84SR  L 3650.42   16 7-                                                    F
     84SR  G 551.5     2 0.9     1   D
     84SR  L 3098.91   16 6+
     84SR cG $A{-2}=-0.36 {I7}, A{-4}=+0.04 {I1}

ensdf.092:10964  [59CO(37CL,2P2NG),]  Ji=12 Jf=11 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     92MO  L 6547.4     8 12-              0.7 PS    LT
     92MO  G   2064.1   3  28.1   7 D                                           F
     92MO  L 4483.2     8 11-
     92MO cG           A{-2}=-0.50 {I10}, A{-4}=+0.44 {I6}, R=1.13 {I5} (1992Si03)

```

#### T4-rein-sonst (3 sigma, delta = 0 unvereinbar, nicht Dipol-A4): 91 — erste 10
```
ensdf.031:13468  [28SI(A,PG),4HE(28SI,PG)]  Ji=11/2 Jf=9/2 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     31P   L 6825      1 11/2-             62 FS     26
     31P   G 1482        40      10 E1
     31P   L 5343.1    6 9/2+              33 FS     11
     31P  cG $A{-2}=-0.53 {I4}, A{-4}=+0.07 {I5} and A{-2}=-0.31 {I10}, A{-4}=+0.01

ensdf.041:13709  [40CA(A,2PNG)]  Ji=15/2 Jf=11/2 (fest/fest/M fest) L=(2, 2) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     41CA  L 3831.0    12 15/2+
     41CA  G 461.1     5           E2                                           A
     41CA  L 3369.9    10 11/2+
     41CA cG $A{-2}=+0.40 {I2}, A{-4}=+0.20 {I3}

ensdf.043:3849  [40AR(A,NG)]  Ji=5/2 Jf=7/2 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     43CA  L 1394.78   205/2+              2.4 PS    8
     43CA  G 1394.8    4 11.7    4 E1
     43CA  L 0.0         7/2-
     43CA cG           A{-2}=-0.25 {I3}, A{-4}=+0.09 {I3}. Pol=+0.12 {I19}

ensdf.048:14829  [10B(40CA,2PG),40CA(10B,2PG)]  Ji=5 Jf=4 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     48V   L 428.3      4 5+               14 PS     LT                         E
     48V   G 428.2     5  63     3  D
     48V   L 0.0          4+                                                    E
     48V  cG $A{-2}=-0.40 {I2}, A{-4}=+0.03 {I3}

ensdf.048:14847  [10B(40CA,2PG),40CA(10B,2PG)]  Ji=6 Jf=5 (fest/fest/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     48V   L 627.6      4 6+               90 PS     42                         E
     48V   G 199.6     5  44     1  D
     48V   L 428.3      4 5+               14 PS     LT                         E
     48V  cG $A{-2}=-0.40 {I2}, A{-4}=+0.02 {I2}

ensdf.051:7205  [48TI(A,NG)]  Ji=3/2 Jf=7/2 (fest/fest/M fest) L=(2, 2) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     51CR  L   749.19  163/2-              7.25 NS   25
     51CR  G 749.0     2 100       E2                                            C
     51CR  L 0.0         7/2-
     51CR cG           |g(|q): A{-2}=+0.049 {I2}, A{-4}=+0.007 {I2} (1973Sa12)

ensdf.075:13591  [40CA(39K,3PNG)]  Ji=3/2 Jf=5/2 (vorlaeufig/vorlaeufig/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     75KR  L  178.8    3  (3/2-)                                                B
     75KR  G  178.6    3  100       D
     75KR  L    0.0       (5/2+)                                                A
     75KR cG           A{-2}=-0.15 {I1}, A{-4}=-0.01 {I1}

ensdf.078:3732  [76GE(A,2NG)]  Ji=9 Jf=7 (vorlaeufig/vorlaeufig/M vorlaeufig) L=(2, 2) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     78SE  L 4857.7     7 (9+)             1.1 PS    4                          Y
     78SE  G 1152.9    4   1.6   1 (E2)                                          C
     78SE  L 3704.8     6 (7+)             0.83 PS   21                         Y
     78SE cG $A{-2}=+0.35 {I8} (1987Sc07); A{-2}=+0.99 {I5}, A{-4}=-0.07 {I6},

ensdf.080:10932  [58NI(28SI,A2PG)]  Ji=26 Jf=24 (vorlaeufig/vorlaeufig/M vorlaeufig) L=(2, 2) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     80SR  L      16671  (26+)                                                  F
     80SR  G      2113       2.0  3  (Q)
     80SR  L      14558  (24+)                                                  F
     80SR cG           A{-2}=+0.87 {I12}, A{-4}=-0.11 {I15}

ensdf.080:11565  [(HI,XNG)]  Ji=8 Jf=7 (vorlaeufig/vorlaeufig/M fest) L=(1, 1) delta=('0', '', 'rein')  angegeben 1/2/3s=False/False/False  umgekehrt=False/False/False  Endniveau via E_i-E_g-E_R
     80Y   L     1490.5 9(8+)                                                   c
     80Y   G     200.0       8.7  9  D
     80Y   L     1290.2 9(7+)                                                   C
     80Y  cG           A{-2}=-0.59 {I4}, A{-4}=+0.06 {I8}

```

## Abgleich der 6j-Werte (Racah-W) mit `SixJRational` (R4) — erledigt (2026-10-23 08:05)
- Beziehung aus Hurst et al., arXiv:2606.12681v3, Anhang A.5, Gl. (A.13), S. 29:
  {j₁ j₂ J₁₂; j₃ J J₂₃} = (−1)^(j₁+j₂+j₃+J) W(j₁ j₂ J j₃; J₁₂ J₂₃), also
  W(a b c d; e f) = (−1)^(a+b+c+d) {a b e; d c f}.
- `volllauf2_t4a.py` protokolliert jetzt jeden Aufruf von sympy `racah` (Ergebnis des Laufs
  unverändert, Diff leer); `~/ensdf/t4a/abgleich_6j.py` vergleicht W|W| mit (−1)^(a+b+c+d)·`sixJSgnSqQ`
  (Lean `#eval`, kompiliert, kein Beweis).
- Ergebnis: **758 verwendete Racah-W, 0 Abweichungen** (70 s).
- Damit sind alle im T4-Lauf verwendeten 3j- und 6j-Werte gegen die Lean-Definitionen abgeglichen.

## Gegenprobe-Liste T4 (2026-10-23 12:25)
`~/ensdf/t4a/gegenprobe.tsv` (sha256 969b5f34…6131), erzeugt mit `~/ensdf/t4a/gegenprobe.py` aus
`voll2_faelle.txt` (Lauf voll2b) und den Quelldateien `~/ensdf/data_261001/ensdf.*`.
- 67 Zeilen: T4-δ 15, T4-Vorzeichen 2, T4-Dipol-A4 50 (dieselben Zählungen wie oben).
- Spalten: Kategorie, Nr, Nuklid, DSID (NNDC-Datensatzkennung aus dem ID-Satz, Spalten 10–39),
  Datei:Zeile(cG), E_i/dE_i/Jπ_i, E_γ/dE_γ, E_f/dE_f/Jπ_f, M, δ/dδ (MR/DMR), A2/dA2, A4/dA4 (Unsicherheit wie
  im Satz, `{In}` = Einheiten der letzten Stelle), Keynumber, Keynumber-Quelle, DSREF, Kommentar (vollständig,
  mit Fortsetzungszeilen).
- Alle Felder nach den festen ENSDF-Spalten aus den Originalzeilen; jede L-, G- und cG-Zeile ist wörtlich im
  jeweiligen Datensatz der Quelle vorhanden (0 Abweichungen).
- Keynumber-Quelle: 37× im A2/A4-Kommentar genannt; 26× nicht genannt → DSREF des ID-Satzes (alle Referenzen
  des Datensatzes, die konkrete ist dann offen); 4× Adopted-Kommentar nennt die Reaktion → DSREF dieses
  Reaktions-Datensatzes (203Pb: 202HG(A,3NG); 207Po: 208PB(A,5NG),206PB(A,3NG)).
