# Stand 3j²/6j² rational

Auftrag: `Auftrag-3j6j-rational.md` (mit Daniels Entscheidungen vom 22.10.2026 19:20). Nichts gepusht.

## R0 Plan und Machbarkeit — erledigt (2026-10-22 20:00)

### Branch
`rational-3j6j` (lokal) von `fork/pr/six-j-symmetry` (d041872f), noch **ohne Commit**.
`lake build …SixJSymmetry` grün (17 s). Prototyp nur in `~/physlib_ci/scratch/r0/`
(wegwerfbar, in keinem Branch).

### Quellen für die Formeln (heruntergeladen, `~/ensdf/sources_3j6j/`)
NIST DLMF, Kapitel 34 (3j, 6j, 9j):
- `dlmf_34.2.html` (https://dlmf.nist.gov/34.2):
  - **34.2.4** 3j als Einfachsumme mit Δ und Wurzel aus Fakultäten;
  - **34.2.5** Δ(j₁j₂j₃) = ((j₁+j₂−j₃)!(j₁−j₂+j₃)!(−j₁+j₂+j₃)!/(j₁+j₂+j₃+1)!)^½.
- `dlmf_34.4.html` (https://dlmf.nist.gov/34.4):
  - **34.4.1** 6j als Summe über vier 3j-Symbole;
  - **34.4.2** Racahs Einfachsumme
    `{j₁ j₂ j₃; l₁ l₂ l₃} = Δ(j₁j₂j₃)Δ(j₁l₂l₃)Δ(l₁j₂l₃)Δ(l₁l₂j₃) Σ_s (−1)^s (s+1)! / [(s−j₁−j₂−j₃)!(s−j₁−l₂−l₃)!(s−l₁−j₂−l₃)!(s−l₁−l₂−j₃)! (j₁+j₂+l₁+l₂−s)!(j₂+j₃+l₂+l₃−s)!(j₃+j₁+l₃+l₁−s)!]`
    (Wortlaut aus dem `alttext` der Seite übernommen).
- Auch `dlmf_34.3.html` und `dlmf_34.5.html` liegen bereit (Symmetrien, Basiseigenschaften).
- Vor einer Verwendung in R3 die Vorzeichen von 34.4.1 gegen `sixJTerm` abgleichen; die
  Konventionen sind nicht automatisch dieselben.

### Kernauswertung (gemessen, Prototyp `threeJSqQ` aus `sixSumQ` über `List.range`)
- Das **reine `decide` scheitert** („failed to reduce“): Der Elaborator reduziert die
  `Rat`-Arithmetik nicht, weil `Nat.gcd` wohlfundiert definiert ist.
- **`decide +kernel` funktioniert**: Die Prüfung läuft ganz im Lean-Kern, der `Nat`-Operationen
  einschließlich `gcd` beschleunigt. Kein `native_decide`, kein zusätzliches Axiom.
  **Daniel bitte bestätigen**, dass `decide +kernel` unter „im Kern nur decide“ fällt.
- Zeiten (gesamte Datei inkl. ≈ 1,4 s Laden):

  | Test | Zeit |
  |---|---|
  | 2 Gleichungen mit `threeJSqQ`, 2j = 4 / 10 / 20 / 40 | 1,8 / 1,8 / 1,8 / 1,9 s |
  | Summe von `threeJSqQ` über alle (m₁, m₂), (20 20 20): 441 Terme | 7,6 s |
  | dasselbe für (40 40 40): 1681 Terme | 43,9 s |
  | Gegenprobe: falsche Gleichung (`= … + 1`) | **abgelehnt** |

  Folgerung: Einzelwerte sind praktisch kostenlos; Orthogonalitätsprüfungen in R2 bis 2j ≈ 20
  (j ≈ 10) liegen im Sekundenbereich.

### Mathlib-Werkzeuge (vorhanden, geprüft mit `#check`)
`Rat.cast_sum`, `Rat.cast_mul`, `Rat.cast_div`, `Rat.cast_pow`, `Rat.cast_natCast`,
`finsum_eq_sum_of_support_subset` (für `sixSum` als `finsum`), `Real.sq_sqrt`, `Real.sqrt_sq`,
`Real.sign`, `List.sum_range_succ`. `Rat.cast_ite` gibt es nicht; stattdessen `apply_ite`.

### Entwurfsentscheidungen für R1 (Vorschlag)
- Zwei Fassungen von `sixSumQ`:
  - zum Beweisen `∑ z ∈ Finset.Icc lo hi, …` über `ℤ`, damit `Rat.cast_sum` und
    `finsum_eq_sum_of_support_subset` direkt greifen;
  - zum Rechnen eine `List`-Faltung, dazu ein Gleichheitslemma.
  Falls `decide +kernel` auch mit `Finset.Icc` schnell genug ist, entfällt die zweite Fassung;
  das wird in R1 gemessen.
- `threeJSqQ` über `Adm3`/`reggeJ` aus `SixJSymmetry.lean`, damit das Lemma direkt gegen
  `threeJ` geht.

### Beweisweg für R3 (Racah 6j)
- **Weg (a), bevorzugt**:
  - `sixJ` ist in `SixJ.lean` über den Recoupling-Koeffizienten bei `l = 0` definiert, also das
    Skalarprodukt zweier Höchstgewichtsvektoren (`recoupling_eq_recoupling_zero`).
  - Bei M = J haben die CG-Koeffizienten geschlossene Produktformen ohne Summe
    (`cgCoefficient_closed`, `hwNormSq_closed` in `ClebschGordanFormula.lean`).
  - Das Skalarprodukt wird dadurch eine **Einfachsumme**. Ergebnis: 6j = Vorzeichen ·
    √(rational) · (rationale Summe). Das reicht für 6j² ∈ ℚ, ohne vorher DLMF 34.4.2
    nachzuweisen.
  - Der Abgleich mit 34.4.2 kann danach folgen (optional) und braucht eine kombinatorische
    Identität (Vandermonde-artig wie `racahL_eq_racahR`).
- Weg (b): Direkte Summation der vier 3j-Summen in `sixJSym` (DLMF 34.4.1 → 34.4.2). Deutlich
  aufwendiger, vier verschachtelte Summen.
- Übergang zu `sixJSym` über das vorhandene `sixJ_eq_sixJSym`.
- Aufwand: R3 bleibt die Hauptarbeit, ist mit Weg (a) aber auf **eine** Summe reduziert.

### Nächster Schritt
R1: Datei `PhyslibAlpha/QuantumMechanics/AngularMomentum/RationalThreeJ.lean` (Name zur
Diskussion), Aussagen mit `sorry`, bauen. Wartet auf Daniels Go und die Bestätigung von
`decide +kernel`.

### Nachprüfung R0 (2026-10-22 22:30, neue Sitzung)
- `run40.lean` erneut gelaufen: grün, 1,9 s. Branch `rational-3j6j` steht unverändert auf d041872f.
- Zusätzlich im Kern geprüft (`/tmp/r0chk`, Wegwerf-Dateien):
  - grün: Σ_{m₁} 3j(2 2 2; m₁, −m₁, 0)² = 1/5 und Σ_{m₁,m₂} 3j(2 2 2; …)² = 1;
  - abgelehnt: `2/3 = 1/2`, `threeJSqQ 4 4 4 0 0 0 = 0`, dieselbe Summe = 1/4.
- **Einschränkung**: `decide +kernel` meldet bei einer falschen Aussage dieselbe Meldung
  („failed to reduce“) wie bei steckengebliebener Reduktion. Eine Ablehnung zeigt also nicht,
  ob die Aussage falsch ist oder die Reduktion hängt. Eine grüne Prüfung ist dagegen ein
  Kernbeweis. Für R2 deshalb nur positive Aussagen als Tests verwenden; Werte bei Bedarf vorher
  mit `#eval` ansehen.

## Entscheidungen Daniel (2026-10-22 22:17)
- `decide +kernel` zählt als „im Kern“. In der Bibliotheksdatei nur kurze Tests (≈ ≤ 2 s je Test),
  lange Rechnungen nur im Werkzeug. Verletzungen als positive Aussage `¬ P := by decide +kernel`.
- Dateiname `Wigner3jRational.lean` neben `Wigner3j.lean`, später `SixJRational.lean`.
- Reihenfolge: R1, dann T4a (Auftrag-ENSDF-2).

## R1 3j rational — erledigt (2026-10-22 22:40), nicht committet, nicht gepusht
Datei `PhyslibAlpha/QuantumMechanics/AngularMomentum/Wigner3jRational.lean` (≈ 200 Zeilen),
Import in `PhyslibAlpha.lean` ergänzt. Sie importiert `SixJSymmetry` (dort steht `threeJ`), der PR
setzt also PR 14 voraus.

Deklarationen (alle bewiesen, kein `sorry`):
- `invFactQ`, `negOnePowQ`, `sixTermQ`, `sixSumQ` (Summe über `Finset.Icc (max aᵢ) (min bᵢ)`) mit
  `cast_invFactQ`, `cast_negOnePowQ`, `cast_sixTermQ`, `cast_sixSumQ` (`= sixSum`);
- `threeJRRadQ` (∏ R_ij!/(J+1)!), `threeJRSumQ`, `threeJRSqQ`, `threeJRSgnSqQ` mit
  `cast_threeJRRadQ`, `threeJRRadQ_nonneg`, `cast_threeJRSumQ`, `threeJR_eq_rat`,
  `cast_threeJRSqQ` (`= threeJR R ^ 2`), `cast_threeJRSgnSqQ` (`= threeJR R * |threeJR R|`);
- `threeJSqQ`, `threeJSgnSqQ` mit `cast_threeJSqQ`, `cast_threeJSgnSqQ` (gegen `threeJ`);
- `threeJ_eq_sign_mul_sqrt`: `threeJ = Real.sign q * √|q|`, `q = threeJSgnSqQ`.
  (`Real.sign` aus `Mathlib.Basic.Real.Sign`; `Mathlib.Data.Real.Sign` ist seit 2026-08-27 veraltet.)

`#print axioms` für `cast_sixSumQ`, `cast_threeJSqQ`, `cast_threeJSgnSqQ`,
`threeJ_eq_sign_mul_sqrt`: nur `propext`, `Classical.choice`, `Quot.sound`.

Prüfungen (Schritte wie `check_pr.sh`, aber auf die nicht committete Datei angewandt): build_module, build_alpha,
runPhyslibAlphaLinters, theorem_lint, module_doc_lint, alphaFileImports, noAlphaImports,
lint_style, alpha_python, codespell: alle OK, `sorry`: 0.

Kernauswertung mit der `Finset`-Fassung (keine zweite `List`-Fassung nötig), netto nach 1,34 s
Laden:
| Test | netto |
|---|---|
| 2 Gleichungen `threeJSqQ`, 2j = 4 / 10 / 20 / 40 | 1,3 / 1,3 / 1,4 / 1,4 s |
| `threeJSgnSqQ 2 2 0 2 (-2) 0 = 1/3` | < 0,1 s |
| Σ über alle (m₁, m₂) für 2j = 10 (121 Terme) = 1 | 1,0 s |
| dasselbe für 2j = 20 (441 Terme) | 5,7 s, also nur im Werkzeug |

Nächster Schritt R2 (Prüfungen + sympy-Gegenprobe), laut Daniel nach T4a.

### Korrektur zu R1 (2026-10-22 23:50)
`lint-style.sh` prüft nur `Physlib/` und `QuantumInfo/` (per `git ls-files`), nie `PhyslibAlpha/`.
Das „OK“ in R1 sagt daher über die neue Datei nichts aus. Ab R2 läuft zusätzlich
`lint-style.py` direkt auf die Datei.

## R2 Prüfungen — erledigt (2026-10-23 00:10), nicht committet, nicht gepusht
In `Wigner3jRational.lean` neu:
- **D.** `sq_cgCoefficient`: ⟨j₁m₁j₂m₂|JM⟩² = (2J+1)·`threeJSqQ …` (in den Parametern von
  `ClebschGordanCoefficients`), aus `cgCoefficient_eq_wigner3j`, `wigner3j_eq_threeJ`,
  `cast_threeJSqQ`. Axiome: Standard.
- **E.** Kernprüfungen bewiesener Identitäten (`decide +kernel`), Zeiten netto nach 1,34 s Laden:
  | Prüfung | Umfang | netto |
  |---|---|---|
  | Σ_{m₁m₂} 3j² = 1/(2J+1) (`sum_wigner3j_mul_wigner3j`, diagonal) | j₁ = 2, j₂ = 3/2, alle J, M | 0,6 s |
  | Σ_J (2J+1) 3j² = 1 (`sum_wigner3j_mul_wigner3j_JM`, diagonal) | j₁ = 2, j₂ = 3/2, alle m₁, m₂ | 0,5 s |
  | `threeJ_swap` | alle j ≤ 3/2, alle Projektionen (400 Fälle) | ≈ 2,1 s |
  | `threeJ_cycle` | dasselbe | ≈ 2,1 s |
  | `threeJ_neg` | dasselbe | ≈ 2,1 s |
  | (1 1 1; 0 0 0) = 0 und `¬ (2 2 2; 0 0 0)² = 0` | | < 0,1 s |
  - Nicht-diagonale Orthogonalität (J ≠ J′) ist gliedweise nicht rational (Produkte von zwei
    Wurzeln) und wird deshalb nicht geprüft.
  - Der Vergleich mit `cgCoefficient` läuft über das allgemeine Lemma `sq_cgCoefficient`, nicht über
    Einzelfälle.
  - Die Symmetrietests liegen mit ≈ 2,1 s knapp über der Vorgabe „≈ ≤ 2 s“; kleiner ginge mit j ≤ 1.

**Befunde zur Kernauswertung** (gemessen, wichtig für R4 und das Werkzeug):
- **`let` im Prüfterm vermeiden**: Der Kern setzt `let`-Werte unausgewertet ein. Mit `let` dauerten
  72 Fälle 46 s, ohne `let` 0,1 s.
- **Zwei berechnete Werte nicht direkt mit `=` vergleichen**: `threeJSqQ 1 1 0 1 (-1) 0 =
  threeJSqQ 1 1 0 (-1) 1 0` braucht 1,7 s, `… = 1/2` und `a - b = 0` brauchen ≈ 0 s. Vermutlich versucht
  der Kern zuerst einen symbolischen Abgleich beider Seiten. Deshalb vergleichen die Tests die Differenz mit 0.
- Auswertungen einzelner Werte sind billig (7 Werte von `threeJSqQ` bei 2j = 6 in ≈ 0,1 s).

**sympy-Gegenprobe** `~/physlib_ci/checks/check_3j.py` (außerhalb des Repos):
- alle j₁, j₂, j₃ ≤ 4 mit allen zulässigen Projektionen, insgesamt **4,451 Fälle** (4,338 ≠ 0);
- `threeJSgnSqQ` (Lean, `#eval`, kompiliert) exakt gegen `t|t|` aus `sympy.physics.wigner.wigner_3j`;
- Ergebnis: **0 Abweichungen**, 57 s.
- `check_6j.py` folgt mit R4, wenn es rationale 6j gibt.
- **Prüfungen R2** (alle Schritte aus AGENTS.md, Datei nicht committet): build_module, build_alpha,
  runPhyslibAlphaLinters, theorem_lint, module_doc_lint, alphaFileImports, noAlphaImports,
  forMathlib_lint, auxillary_script_test, lint_all, alphaPythonLinters, `lint-style.py` auf die
  Datei, codespell: **alle OK**, `sorry`: 0. Im Protokoll von `lint_all` stehen rote Meldungen
  „Transitive imports“ zu älteren `Physlib/`-Dateien, aus einem Linter, der laut Ausgabe „not checked
  by GitHub“ ist; unsere Datei kommt darin nicht vor.

Nächster Schritt laut Plan: R3 (Racah-Formel für 6j). Erster PR (R1/R2) erst nach Merge von PR 11 und 14.

## Entscheidung Daniel (2026-10-22 23:27)
R3 starten. Lokal committen jederzeit erlaubt; pushen nur nach „ja“.

## Commits (lokal)
- `rational-3j6j`: **b6347087** `feat(PhyslibAlpha): threeJSqQ, threeJSgnSqQ, rational values of the
  Wigner 3j symbols` (R1 + R2, ohne `sorry`).
- `rational-6j` (neu, von `rational-3j6j`): **5d1a319f** `wip(PhyslibAlpha): …` (R3-Zwischenstand,
  enthält ein `sorry`, nicht für einen PR).

## Korrektur zu R0 (Weg (a))
In R0 stand, Weg (a) (Recoupling bei M = J) liefere eine Einfachsumme. Das stimmt nicht. Bei M = J
sind nur die beiden äußeren CG-Koeffizienten geschlossen; die inneren ⟨j₁m₁j₂m₂|j₁₂m₁₂⟩ und
⟨j₂m₂j₃m₃|j₂₃m₂₃⟩ behalten je eine Racah-Summe, dazu kommt die Summe über (m₁, m₂). Das ergibt
vier Summen, die man mit Vandermonde-Identitäten auf eine bringen müsste.

## R3 — begonnen (2026-10-23 01:30)
Datei `PhyslibAlpha/QuantumMechanics/AngularMomentum/SixJRational.lean` (Branch `rational-6j`).

### Normierung abgeglichen (vor jedem Beweis)
`~/physlib_ci/checks/check_6j_racah.py`: `sixJSym` exakt nach der Lean-Definition (Phase und
vier 3j aus `sixJTerm`, sympy) gegen DLMF 34.4.2 (aus `dlmf_34.4.html`, alttext) und sympy
`wigner_6j`. **570 zulässige Sechstupel bis j = 2: 0 Abweichungen.** `sixJSym j₁…j₆` ist also genau
{j₁ j₂ j₃; j₄ j₅ j₆} von DLMF 34.4.2, ohne zusätzliches Vorzeichen.

### Aufbau (neue Idee, ersetzt Weg (a)/(b) für den ersten Teil)
Jedes jᵢ steht in genau zwei der vier 3j-Symbole von `sixJTerm`, mit ±mᵢ. Die Fakultäten
(jᵢ−mᵢ)!(jᵢ+mᵢ)! unter den vier Wurzeln kommen also paarweise vor, und das Produkt der Wurzeln ist
√C · ∏ᵢ (jᵢ−mᵢ)!(jᵢ+mᵢ)! mit C = Δ(j₁j₂j₃)²Δ(j₁j₅j₆)²Δ(j₄j₂j₆)²Δ(j₄j₅j₃)², unabhängig von m.
- **R3b, bewiesen**: `sixJSym_eq_sqrt_mul_sixJSumQ`: `sixJSym = √C · sixJSumQ` mit einer
  rationalen Summe `sixJSumQ` über `sixJBox`. Dazu `threeJRRadQ_reggeJ`, `threeJ_eq_sqrt_mul`,
  `sixJTerm_eq_sqrt_mul`, `facPairQ_neg`. Axiome: Standard.
- **R3c, offen (`sorry`)**: `sixJSumQ_eq_racahSumQ`: `sixJSumQ = racahSumQ` (DLMF-34.4.2-Summe) unter
  den vier Dreiecksbedingungen. Das ist eine reine Identität zwischen endlichen rationalen Summen, der
  kombinatorische Kern von Racahs Formel.
- **R3, folgt**: `sixJSym_eq_racah` ist aus beiden schon zusammengesetzt (zwei Zeilen).

### Numerische Gegenprobe der Aussagen
`~/physlib_ci/checks/check_6j.py` (Lean `#eval` gegen sympy): **570 Sechstupel bis j = 2:
C·T|T| = 6j|6j| in allen Fällen, T = `racahSumQ` in allen Fällen** (37 s).

### Kernauswertung
- `racahSumQ` lässt sich im Kern auswerten.
- `sixJSumQ` (über `sixJBox`, d. h. `Fintype.piFinset`) nicht: Der Kern bricht mit „application type
  mismatch“ ab, schon bei `(sixJBox 2 2 2 2 2 2).card`. Für Kerntests braucht R4 eine Fassung mit
  verschachtelten Summen über die drei freien Projektionen und ein Gleichheitslemma.

### Folgen für die Reihenfolge (Vorschlag, Daniel entscheidet)
- **R4 hängt nicht an R3c.** `sixJSqQ := C · sixJSumQ²` und `sixJSgnSqQ := C · sixJSumQ |sixJSumQ|`
  folgen direkt aus R3b. Damit ist 6j² ∈ ℚ samt Gleichheitsbeweis in kurzer Zeit erreichbar.
  Rechnen geht so allerdings nur über die Mehrfachsumme; schnell wird es erst mit Racahs Einfachsumme.
- **R3c ist die eigentliche Hauptarbeit.** Plan: die drei freien Projektionen und die vier
  z-Summen der 3j-Symbole schrittweise mit Chu-Vandermonde wegsummieren, mit den vorhandenen Werkzeugen
  `zchoose`, `sum_range_choose_succ_mul`, `racahL_eq_racahR` aus `ClebschGordanFormula`. Die
  Abbruchregel aus dem Auftrag gilt.

## Entscheidung Daniel (2026-10-23 07:46)
Erst R4, dann R3c mit Abbruchregel.

## R4 6j rational — erledigt (2026-10-23 08:10), Commit **56ec853f** (lokal, `rational-6j`)
In `SixJRational.lean`:
- `sixJSumQ` jetzt als Summe über die drei freien Projektionen (m₁, m₂, m₅) über `sixJVec`;
  `sixJSumQ_eq_sum_sixJBox` (Umindizierung, bewiesen) verbindet sie mit der Summe über `sixJBox`.
  Grund: Über `sixJBox` (`Fintype.piFinset`) bricht der Kern ab.
- **C.** `sixJRadQ_nonneg`, `sixJSqQ := C · T²`, `sixJSgnSqQ := C · T|T|`, `cast_sixJSqQ`
  (`= sixJSym ^ 2`), `cast_sixJSgnSqQ` (`= sixJSym * |sixJSym|`), `sixJSym_eq_sign_mul_sqrt`.
  Alle ohne `sorry`, sie hängen nur an R3b, nicht an R3c.
- **E.** Kernprüfungen (netto nach 1,5 s Laden):
  | Prüfung | netto |
  |---|---|
  | Σ_{j₁₂} (2j₁₂+1)(2j₂₃+1) 6j² = 1 (`sum_sixJ_mul_sixJ`, diagonal), j₁ = j₂ = j₃ = J = 1, alle j₂₃ | 2,0 s |
  | `sixJSym_swap₁₂` auf zwei Sechstupeln | 1,6 s |
  | `sixJSym_swap₂₃` auf zwei Sechstupeln | 1,6 s |
  | `sixJSym_flip₁₂` auf zwei Sechstupeln | 1,2 s |
  | unzulässiges 6j = 0, `¬ {1 1 1; 1 1 1}² = 0` | 0,8 s |
  Eine 6j-Auswertung kostet im Kern 0,2–0,5 s bei Spins ≤ 3/2, bei Spin 2 schon ≈ 5 s. Deshalb gibt
  es nur wenige Werte, kein Gitter (die 47 zulässigen Sechstupel bis j = 1 brauchen 19 s).
- `sixJSym_eq_racah` (`theorem`, bekanntes Resultat) ist in `scripts/lint/exemptions/Theorems.txt`
  eingetragen; `theorem_lint` grün.
- **sympy-Gegenprobe** `~/physlib_ci/checks/check_6j.py`: `sixJSgnSqQ` gegen `wigner_6j` und
  `sixJSumQ = racahSumQ`, **alle 3,418 zulässigen Sechstupel bis j = 3: 0 Abweichungen** (40 s).
- Prüfungen: build, runPhyslibAlphaLinters, theorem_lint, module_doc_lint, alphaFileImports,
  noAlphaImports, forMathlib_lint, auxillary_script_test, lint_all, alphaPythonLinters,
  `lint-style.py` auf die Datei (vier zu lange Zeilen umgebrochen), codespell: grün.
  `sorry`: 1 (R3c, gewollt offen).

## R3c — Plan (2026-10-23 08:15)
Weg über M = J (statt direkt über die 7-fache Summe T):
- `recoupling_eq_sum` schreibt den Recoupling-Koeffizienten als Summe über vier CG-Koeffizienten;
  `recoupling_eq_recoupling_zero` erlaubt l = 0 (M = J); `recoupling_eq_sixJ`, `sixJ_eq_sixJSym` und
  R3b verbinden mit `sixJSumQ`.
- ~~Bei l = 0 erzwingen die Indexbedingungen 2β = k₁ + k₂ + k₃ − k₄, also eine Dreifachsumme.~~
  **Korrektur (08:30):** Mit μ = α+β−k₁, γ = K−α−β, ν = K−k₃−α ist die vierte Bedingung
  β + γ = k₃ + ν identisch erfüllt; β ist frei. Die beiden äußeren CG sind geschlossen (l = 0), die
  beiden inneren haben je eine Summe (`cgSum`). Das ergibt eine **Vierfachsumme** über (α, β, x, y),
  also drei Summationsschritte bis zur Einfachsumme.
- Unter den Wurzeln heben sich `normSq e μ` und `normSq f ν` weg (Zähler und Nenner), `normSq a α`,
  `normSq b β`, `normSq c γ` kommen quadriert vor: Wurzel = √(konstant) · rational.
- Vorgehen: jeden Zwischenschritt erst in Python exakt prüfen (rationale Identitäten), dann in Lean.
- **P1 erledigt** (`~/physlib_ci/checks/r3c/p1_recoupling.py`): Python-Abschrift von `normSq`,
  `cgCoeff`, `cgSum`, `hwNormNum`, `cgCoefficient_closed` und `recoupling_eq_sum` bei l = 0 gegen die
  `sixJ`-Definition mit sympy `wigner_6j`: 365 Fälle (a, c ≤ 3, b ≤ 3), 0 Abweichungen.
- Wurzelbuchhaltung (von Hand, wird in P2 numerisch geprüft): Das Produkt der vier CG-Wurzeln ist
  normSq(a,α)·normSq(b,β)·normSq(c,γ)·(g+1)! · √((e+1)!(f+1)!/∏ hwNormNum).

### R3c — Stand (2026-10-23 09:30): zwei Anläufe, Kern noch offen
Skripte in `~/physlib_ci/checks/r3c/` (exakte Rechnung mit `fractions`/sympy, kein Lean).

**Gesichert (numerisch exakt geprüft, noch nicht in Lean):**
- P1: Python-Abschrift der Lean-Formeln für `recoupling`(K, 0) = 6j-Relation aus `sixJ`: 365 Fälle, 0 Abw.
- P2: `recoupling`(K, 0) = √D · Q4 mit rationaler Vierfachsumme Q4 über (α, β, x, y),
  D = (e+1)!(f+1)!/∏ hwNormNum: 3,457 Fälle, 0 Abw.
- P3: **rationale Zielidentität** Q4 = (−1)^(a+b+c−K) · C · a!b!c! · P · racahSum mit
  P = (a+b−k₁+1)!(e+c−k₂+1)!(a+f−k₄+1)!(b+c−k₃+1)!. Von Hand: hwNormNum(a,b,k₁) =
  a!b!(a+b−k₁+1)!²·Δ(abe)² usw., daher heben sich alle Wurzeln weg. 3,457 Fälle (a, b, c ≤ 5), 0 Abw.
  Diese Identität ist zu `sixJSumQ_eq_racahSumQ` äquivalent (über `sixJ_eq_sixJSym` und R3b).
- P5: In den Variablen u = α − x, v = β − y kürzen sich μ!, ν!, α!, (a−α)!, γ!, (c−γ)!; die
  u-Summe ist **Chu-Vandermonde mit laufendem oberem Index**
  Σ_u C(A−u, A−C) C(B+u, B) = C(A+B+1, A−C+B+1) und schließt sich: 1,254 Fälle, 0 Abw.
  Ergebnis: Dreifachsumme über (x, y, v).

**Nicht gefunden:** der Weg von der Dreifachsumme zur Einfachsumme.
- Anlauf 1 (binomische Form `cgSum`): Keine der Einzelsummen über x, y oder v ist allgemein
  geschlossen. Für v sah es zunächst so aus (Primfaktor-Heuristik bei Spins ≤ 2), bei Spins bis 7
  zeigen sich aber große Primfaktoren (z. B. 29 bei Fakultätsargumenten ≤ 11). Als ₃F₂ gelesen ist die
  v-Reihe in keiner Richtung ausgeglichen, Pfaff-Saalschütz greift nicht.
  Die β-Summe (vor der u-Summation) ist ebenfalls nicht geschlossen.
- Anlauf 2 (Racahs Form `racahSum` für die inneren CG): Die geschlossenen CG fallen auf je einen Term,
  die Wurzeln werden ein vollständiges Quadrat; die Erkundung der Einzelsummen blieb ohne Ergebnis
  (Stichproben zu dünn, die z- und w-Summen sind die inneren Racah-Summen selbst).
- Quellen gesucht: Rosengren, arXiv:math/0312310 (elementarer Zugang, aber über Polynomräume, nicht
  über CG-Summen; Übertragung wäre ein eigenes Projekt); Venkatesh/Wang (ohne explizite Formeln).
  Eine frei zugängliche Herleitung „CG-Summe → Racah-Einfachsumme“ habe ich nicht gefunden. Die
  Lehrbücher (Edmonds, Varshalovich) liegen nicht vor.

**Mögliche nächste Schritte (Daniel entscheidet):**
1. Weiter suchen: Thomae-Transformationen / Zweifachsummen-Identitäten systematisch testen
   (Werkzeug `hyp.py` liegt bereit). Ausgang offen.
2. Literatur besorgen, die die Herleitung ausführt (z. B. Edmonds Kap. 6, Varshalovich §9.2), und
   den Weg daraus übernehmen.
3. Abbruch nach Regel: R3c zurückstellen. Der zweite PR ginge dann ohne Racah-Formel, aber ohne
   `sorry`: `sixJSym_eq_sqrt_mul_sixJSumQ` (R3b) + R4 sind vollständig bewiesen; Abschnitt D
   (`racahSumQ`, `sixJSumQ_eq_racahSumQ`, `sixJSym_eq_racah`) käme heraus oder in eine eigene Datei.

## Entscheidung Daniel (2026-10-23 11:11): Option 3
R3c zurückgestellt. 2. PR = R3b + R4 ohne `sorry`; Abschnitt D in eigene Datei, nicht im PR.

### 2. PR — erledigt (2026-10-23 11:13), lokal, nicht gepusht
- Branch `rational-6j`, ein Commit `51c86ed2` auf `b6347087`:
  feat(PhyslibAlpha): sixJSym_eq_sqrt_mul_sixJSumQ, sixJSqQ, sixJSgnSqQ, rational values of the 6j symbols.
  Die beiden wip-Commits sind zusammengefasst; alter Stand gesichert als `backup/rational-6j-wip` (`56ec853f`).
- `SixJRational.lean`: Abschnitt D (Racah) entfernt, Kernprüfungen jetzt Abschnitt D. Docstring ohne Racah;
  Referenz Racah 1942 entfernt (Literatur liegt nicht vor). Bleibt: DLMF §34.2/§34.4, gegen die Seiten
  geprüft (34.2.5 Δ, 34.4.1 Definition, 34.4.2 Racah-Summe).
- `Theorems.txt`: `sixJSym_eq_racah` nicht mehr eingetragen.
- Prüfung `~/physlib_ci/check_r34.sh` → `ERGEBNIS_r34.txt`: axioms (nur propext/choice/Quot.sound),
  build_alpha, runPhyslibAlphaLinters, theorem_lint, module_doc_lint, alphaFileImports, noAlphaImports,
  lint_style, alpha_python, codespell: alle OK; sorry 0.
- Abschnitt D: eigene Datei `SixJRacah.lean` auf Branch `racah-6j` (`43ff6944`, wip, 1 `sorry`,
  nicht in Theorems.txt). Docstring zitiert nur DLMF 34.4.2.

### R3c′ (Zeilberger) — angehalten (2026-10-23 11:17) wegen Vorrang Wasserstoff-Rebase
- Maxima 5.49.0 per apt installiert (Paket `maxima`, Paket `zeilberger` aus share).
- Erster Lauf `~/physlib_ci/checks/r3c/zb/z1.mac`: `Zeilberger(F, s, n)` für den Racah-Summanden mit
  allen sieben Parametern symbolisch, Verschiebung in j₄: nach 600 s ohne Ergebnis, abgebrochen.
  Nächster Versuch: Parameter teilweise numerisch setzen bzw. kleinere Parametrisierung.
  Verbrauchte Zeit für R3c′: ≈ 15 min von ½ Tag.

### Varshalovich (OAPEN) — Download gescheitert (2026-10-23 11:14)
- URL `https://library.oapen.org/bitstream/20.500.12657/50493/1/9789814415491.pdf`: HTTP 403,
  Bot-Abfrage („Making sure you're not a bot!“, Proof of Work). Auch Landingpage und DOAB-API: 403.
  Abfrage nicht umgangen. Kein PDF, daher noch keine Lizenzangabe, kein sha256, nichts zitiert.
- Bitte: PDF im Browser laden und nach `~/ensdf/sources_3j6j/` legen; dann sha256, Lizenz (Impressum)
  und Kap. 9 ins Protokoll.

## Quelle Varshalovich (2026-10-23 11:45)
- D. A. Varshalovich, A. N. Moskalev, V. K. Khersonskii, *Quantum Theory of Angular Momentum*,
  World Scientific; `~/ensdf/sources_3j6j/9789814415491.pdf`, von Daniel im Browser geladen von
  library.oapen.org/handle/20.500.12657/50493 (automatischer Abruf scheitert an der Bot-Abfrage).
- Nachgerechnet: 20,748,080 Bytes, **sha256 1b3ffec7f8e0dd70986c37b10d893891e32d191d0ad8967941194b089e4be655**
  (stimmt mit Daniels Angabe). 528 Seiten, ABBYY-OCR (Text für Formeln unbrauchbar, Formeln von Seitenbildern
  gelesen: `~/ensdf/sources_3j6j/pages/v-NNN.png`, NNN = PDF-Seite).
- **Lizenz im PDF selbst:** Impressum (Text Z. 58–63) „converted to Open Access in 2021 through the sponsorship
  of SCOAP3, licensed under the terms of the Creative Commons Attribution 4.0 International License“; Kapitel-
  kopf S. 290: „2021 © The Author(s). … (CC BY 4.0). https://doi.org/10.1142/9789814415491_0010“ (DOI vom
  Seitenbild abgeschrieben, nicht aus dem Gedächtnis). Deckt sich mit der OAPEN-Angabe CC BY 4.0.
- Seitenzuordnung: PDF-Seite = gedruckte Seite + 13.

### Kap. 9 gelesen (§9.1, §9.2, §9.6, §9.7; gedruckte S. 290–296, 303–305)
- §9.1.1 Gl. (5), (8), S. 291: Definition über die Recoupling-Matrix bzw. die Summe über vier CG.
- §9.2.1 Gl. (1), S. 293: **Racahs Formel**, Beleg „(Racah [91])“; Gl. (2) durch n → a+b+d+e−n.
  Bedingung: alle vier Triaden erfüllen das Dreieck. Δ(abc) nach Gl. 8.2(1).
- §9.2.1 Gl. (3)–(6), S. 294: weitere Einfachsummen „which cannot be easily reduced to (1) and (2)“ [45, 50].
- §9.2.2 Gl. (7), S. 294: Bargmann-Formel [53] im R-Symbol; reduziert sich mit x_i = A_i − n,
  y_α = n − B_α auf (1).
- §9.2.4 Gl. (13), S. 296: 6j als Summe über vier 3jm (entspricht unserer `sixJSym`-Definition).
- §9.6.2 Gl. (5), S. 304: Dreiterm-Rekursion in c (Schritt 1), Gl. (6), (7) Spezialfälle; §9.6.1 Gl. (1)–(4),
  S. 303–304: Rekursionen mit Schritt 1/2.
- §9.7 Gl. (1), (2), S. 305: erzeugende Funktion (Bargmann [53]).
- **Ergebnis: Kap. 9 enthält keine Herleitung von Racahs Formel.** Gl. 9.2(1) wird mit Verweis auf Racah [91]
  angegeben, die Rekursionen in §9.6 ohne Beweis. Die einzigen „Wege“ im Kapitel sind Verweise: Racah [91],
  Bargmann [53] (erzeugende Funktion), [45, 50].
- Numerisch geprüft (`~/physlib_ci/checks/r3c/varsh/rec965.py`): Abschrift von 9.6(5) gegen sympy
  `wigner_6j`, 1,500 zulässige Fälle (Spins ≤ 4), 0 Abweichungen.

### R3c auf diesem Weg — Bewertung, **Abbruch nach Regel** (2026-10-23 11:55)
Weg „Rekursion + Startwert“ mit 9.6(5) hätte zwei Hälften:
1. `racahSumQ` (mit √C) erfüllt 9.6(5): rein rational, per Zeilberger/WZ-Zertifikat machbar (Maxima liegt
   bereit; der vollsymbolische Lauf brauchte > 600 s, mit festen Parametern kleiner).
2. `sixJSumQ` bzw. `sixJSym` erfüllt 9.6(5): **das ist der Kern, und dafür gibt Kap. 9 nichts her.** Physikalisch
   kommt 9.6(5) aus der Matrix von J₂·J₃ in der Basis |(j₁j₂)j₁₂ j₃; J⟩ (tridiagonal in j₁₂). In Lean fehlt dafür
   die Theorie: Skalarprodukte zweier Spins in einem gekoppelten Dreispin-Zustand mit expliziten Nebendiagonal-
   elementen (vorhanden sind nur `recoupling_*`, `sum_sixJ_mul_sixJ`, `cgCoeff_rec` und L·S für zwei Spins in
   `SpinOrbit`). Schätzung: mehrere Tage, also deutlich über dem halben Tag.
Verbrauchte Zeit R3c′ gesamt ≈ 1 h. R3c bleibt zurückgestellt (`racah-6j`, `43ff6944`, 1 `sorry`).

**Optionen (Daniel entscheidet):**
- (a) Edmonds Kap. 6 und Racah 1942 (Phys. Rev.) prüfen, ob dort eine Herleitung aus der CG-Summe ausgeführt ist.
- (b) Den Weg über J₂·J₃ als eigenes Projekt (mehrere Tage): Dreispin-Skalarprodukt, Tridiagonalität, 9.6(5) für
  `sixJSym`, dazu Zeilberger-Zertifikat für `racahSumQ`, Startwert c = |a − b|.
- (c) R3c ruhen lassen; der 2. PR braucht es nicht.

## Stapel 10–14 nach dem Merge von #1911 auf master umgesetzt (2026-10-24 16:40), nicht gepusht
- origin/master beim Umsetzen: `c78d49e5` (über `4d63576c` hinaus: #1784, #1905, #1948, #1901).
- Ausgangspunkt die Fork-Stände (Basis altes #1911 `35cf02e4`); Sicherungen `backup/<branch>-pre-1911-rebase`
  = Fork-Köpfe. Die veralteten lokalen Branches gesichert als `backup/{wigner-3j,wigner-eckart-cg,six-j-symmetry}-lokal-alt`.
- Skript `~/physlib_ci/scripts1911/rebase_stack.sh`: je Commit cherry-pick; Konflikt nur in `PhyslibAlpha.lean`
  (Importvereinigung, alphabetisch, `resolve_imports.py`); Zeile `Claude-Session:` aus allen Nachrichten gestrichen
  (danach 0 Treffer in origin/master..Branch). 13 und 14 teilen die Commits 11 + 12a + 12b (gleiche Hashes bis `33e61d14`).
- Alle Lean-Dateien jedes Branches byte-identisch mit dem Fork-Stand (`git diff` 0 Zeilen); geändert nur die Importliste.

| PR | Branch | Fork alt | neu | check_pr.sh |
|---|---|---|---|---|
| 10 | `pr/clebsch-gordan-formula` | `4d2919d1` | `b50cbcd6` | 10/10 OK, sorry 0 |
| 11 | `pr/wigner-3j` | `5ee8561a` | `32cce545` | 10/10 OK, sorry 0 |
| 12a | `pr/coupling-schemes` | `468b74a6` | `b1c34a37` | 10/10 OK, sorry 0 |
| 12b | `pr/six-j` | `7d2bb3ac` | `6ddf4a76` | 10/10 OK, sorry 0 |
| 13 | `pr/wigner-eckart-cg` | `8cd698cd` | `a0213a75` | 10/10 OK, sorry 0 |
| 14 | `pr/six-j-symmetry` | `d041872f` | `f1b9048e` | 10/10 OK, sorry 0 |

Berichte `~/physlib_ci/REVIEW_rb1911-<branch>.txt`. PR-Texte: 10 Kopfzeile „Base: master“ + „Builds on #1911 … and
#1876 …, both merged“; 11, 12a, 13, 14 „#1911 and #1876 are merged“; 12b unverändert.

### rational-3j6j, rational-6j, racah-6j auf das neue 14 umgesetzt (nicht gepusht)
- `git rebase --onto pr/six-j-symmetry d041872f racah-6j`, Konflikte nur in der Importliste; die beiden anderen
  Branches auf die entsprechenden neuen Commits gesetzt. Sicherungen `backup/<branch>-pre-1911-rebase`.
  Lean-Dateien (`Wigner3jRational`, `SixJRational`, `SixJRacah`) unverändert.

| Branch | alt | neu | Ergebnis |
|---|---|---|---|
| `rational-3j6j` | `b6347087` | `a735d244` | check_pr.sh 10/10 OK, sorry 0 |
| `rational-6j` | `51c86ed2` | `f43f74cc` | check_pr.sh 10/10 OK; check_r34.sh alle OK, Axiome nur propext/choice/Quot.sound, sorry 0 |
| `racah-6j` | `43ff6944` | `7abb5d90` | `lake build PhyslibAlpha` grün, einzige Warnung das bekannte `sorry` (SixJRacah.lean:64); mit `-KCI` Abbruch wegen dieser Warnung |

## Erneut umgesetzt auf origin/master `9b583cb6` und gepusht (2026-10-25 19:50)
- `~/physlib_ci/scripts1911/move.sh` je Branch von der Basis `c78d49e5`; Lean-Dateien unverändert, keine `Claude-Session:`-Zeile.
  Sicherungen `backup/<branch>-pre-9b58-rebase`. Berichte `~/physlib_ci/REVIEW_rb9b58-<branch>.txt`.

| PR | Branch | Fork alt | neu | check_pr.sh | Push |
|---|---|---|---|---|---|
| 10 | `pr/clebsch-gordan-formula` | `4d2919d1` | `1f0ce3f3` | 10/10 OK, sorry 0 | ja |
| 11 | `pr/wigner-3j` | `5ee8561a` | `a2f712ac` | 10/10 OK, sorry 0 | ja |
| 12a | `pr/coupling-schemes` | `468b74a6` | `62cb4a2a` | 10/10 OK, sorry 0 | ja |
| 12b | `pr/six-j` | `7d2bb3ac` | `d9b8967f` | 10/10 OK, sorry 0 | ja |
| 13 | `pr/wigner-eckart-cg` | `8cd698cd` | `059c243a` | 10/10 OK, sorry 0 | ja |
| 14 | `pr/six-j-symmetry` | `d041872f` | `43799477` | 10/10 OK, sorry 0 | ja |
| – | `rational-3j6j` | lokal `a735d244` | `5eaf449f` | 10/10 OK, sorry 0 | nein |
| – | `rational-6j` | lokal `f43f74cc` | `f98c7128` | 10/10 OK, sorry 0 | nein |
| – | `racah-6j` | lokal `7abb5d90` | `9163d8bd` | Build grün, 1 bekanntes `sorry` | nein |

- Pushes je `--force-with-lease` gegen den vollen Fork-Hash, per `ls-remote` bestätigt.

## 10 gemergt (2026-10-26, festgestellt 13:18 im Hintergrund-Check)
- `pr/clebsch-gordan-formula` als Squash `9db4bcc9` auf origin/master. Offene PRs (E4, 15, 16) laut `git merge-tree`
  konfliktfrei mit dem neuen master; GitHub meldet vorerst `unknown`. 11–14 basieren noch auf `1f0ce3f3` (altes 10),
  sind keine offenen PRs; Umsetzen erst auf Daniels Auftrag.

## 11 nach dem Merge von 10 auf master umgesetzt und gepusht (2026-10-26 15:46)
- origin/master `7823e144`; Squash von 10 (`9db4bcc9`) inhaltsgleich mit `1f0ce3f3` (ClebschGordanFormula.lean 0 Diffzeilen).
- `pr/wigner-3j` `a2f712ac` → **`1c24e593`** (3 Commits, move.sh, Dateien unverändert, keine `Claude-Session:`-Zeile).
  check_pr.sh (`REVIEW_rb7823-wigner-3j.txt`) 10/10 OK, sorry 0. **Gepusht**, `--force-with-lease` gegen a2f712ac, ls-remote bestätigt.
  Sicherung `backup/wigner-3j-pre-7823e144-rebase`. PR-Text 11: „Base: master“, „Builds on #1962 … and #1911 …, both merged“.
- 12a, 12b, 13, 14 und die rational-Branches liegen noch auf dem alten 10 (`1f0ce3f3`).

## 12a und 12b nach dem Merge von 10 auf master umgesetzt (2026-10-26 16:09), nicht gepusht
- 11 ist jetzt als eigener PR offen. Ausgangspunkt die Fork-Stände (= lokal), Sicherungen `backup/{coupling-schemes,six-j}-pre-1962-rebase`.
- origin/master `7823e144`; move.sh von der alten Basis `1f0ce3f3` (Squash von 10 inhaltsgleich). Dateien unverändert, keine `Claude-Session:`-Zeile.

| PR | Branch | Fork alt | neu | check_pr.sh |
|---|---|---|---|---|
| 12a | `pr/coupling-schemes` | `62cb4a2a` | `6928283c` | 10/10 OK, sorry 0 |
| 12b | `pr/six-j` | `d9b8967f` | `2e739ee3` (2 Commits, auf 6928283c) | 10/10 OK, sorry 0 |

- Berichte `~/physlib_ci/REVIEW_rb1962-<branch>.txt`. PR-Texte 12a („Base: master“, Builds on 10 und 09, unabhängig von 11)
  und 12b (Basis 12a, Builds on 10 und 09). Push wartet auf Daniels Freigabe (nach dem nächsten Merge eines offenen PRs).
  13, 14, rational-Branches nicht angefasst.

## 12a und 12b auf master 3bfc7af8 (nach #1963/#1964), gepusht und eröffnet (2026-10-27)
- Umsetzung per Skript (`rebase1964.sh`): `pr/coupling-schemes` **`38402a08`**, `pr/six-j` **`11094981`** (auf 38402a08);
  Sicherungen `backup/coupling-schemes-pre-1964-rebase` (`6928283c`), `backup/six-j-pre-1964-rebase` (`2e739ee3`).
- check_stack.sh (`REVIEW_rb1964-<branch>.txt`): zunächst je 9/10, `theorem_lint` FEHLER wegen veralteter `.olean`
  (StandardModel/Basic, Dateiumzug #1968). Nach Löschen von `.lake/build/{lib/lean,ir}/Physlib/Particles/StandardModel`
  und vollem `lake build Physlib QuantumInfo PhyslibAlpha` je **10/10 OK**, sorry 0; Gegenprobe master 3bfc7af8 theorem_lint grün.
  Seitdem baut `check_pr.sh` vor `theorem_lint` die vollen Wurzeln (`build_roots`).
- Push zum Fork mit `--force-with-lease` (gegen `62cb4a2a` bzw. `d9b8967f`); erster Versuch abgelehnt (Token ohne
  `workflow`-Scope, `.github/workflows/build.yml` aus Upstream), nach Daniels „Sync fork“ (Fork-master 3bfc7af8) ok,
  ls-remote bestätigt.
- **Daniel hat eröffnet: 12a = #1970, 12b = #1971 (blocked-by-PR #1970).** Cron-Check fragt #1932, #1970, #1971 ab.
- Zusage an Philippe (6j-PRs offen) siehe `00-Plan.md`: 12a/12b offen, 14 noch nicht.

## Nach dem Merge von 12a (2026-10-28): 12b auf master, 13/14 gestapelt auf 12b, gepusht
- 12a gemergt (Squash `183c8a6c`); origin/master `848dca44`; `CouplingSchemes.lean` auf master byte-gleich mit 38402a08.
- 12b: Sicherung `backup/six-j-pre-1970-rebase` (`11094981`), `move.sh pr/six-j 38402a08 origin/master` → **`c47116d4`**
  (nur der 12b-Commit, `SixJ.lean` byteidentisch, Blob `c099e723`). check_pr.sh (`REVIEW_rb1970-six-j.txt`, mit `build_roots`)
  11/11, ci_physlib.sh 11/11, sorry 0. **Gepusht** mit `--force-with-lease` gegen `11094981`.
- 13/14 lagen noch auf dem alten Stapel (10, 11 ×3, 12a, 12b alt `e53501b7`) auf master `9b583cb6`; alle mitgeschleppten
  Lean-Dateien waren schon byte-gleich mit master bzw. neuem 12b. Sicherungen `backup/wigner-eckart-cg-pre-1970-rebase`
  (`059c243a`), `backup/six-j-symmetry-pre-1970-rebase` (`43799477`); `move.sh <branch> e53501b7 pr/six-j`:

| PR | Branch | vorher | neu | Lean-Datei | Prüfung |
|---|---|---|---|---|---|
| 13 | `pr/wigner-eckart-cg` | `059c243a` | **`ea6490bd`** (1 Commit auf c47116d4) | `WignerEckartNormalized.lean` byteidentisch (`bf2f1e98`), +221 | 11/11 + 11/11, sorry 0 |
| 14 | `pr/six-j-symmetry` | `43799477` | **`455ec989`** (2 Commits auf c47116d4) | `SixJSymmetry.lean` byteidentisch (`9d0f2d73`), +697 | 11/11 + 11/11, sorry 0 |

- Berichte `~/physlib_ci/REVIEW_rb1970-<branch>.txt` und `…-physlib.txt`. **Gepusht** mit Lease gegen 059c243a/43799477,
  ls-remote bestätigt; kein workflow-Scope-Problem. Keine PRs eröffnet.
- PR-Texte 13/14: Kopfzeile „Base: `pr/six-j` (#1971), stacked · blocked-by-PR #1971“, 11/12a/10 als gemergt. Nach dem
  Merge von 12b: `move.sh <branch> c47116d4 origin/master`, dann `-blocked-by-PR`.
- **28.10.: Daniel hat 13 eröffnet: #1980** (`pr/wigner-eckart-cg` `ea6490bd`, blocked-by-PR #1971). 14 noch nicht eröffnet.
  Cron-Check fragt #1932, #1971, #1980 ab.
- **28.10.: Daniel hat 14 eröffnet: #1981** (`pr/six-j-symmetry` `455ec989`, blocked-by-PR #1971). Offen: #1932, #1971,
  #1980, #1981. **Auftrag nach dem Merge von #1971:** #1980 und #1981 per `move.sh <branch> c47116d4 origin/master`
  umsetzen (vorher Sicherungen `backup/<branch>-pre-1971-rebase`), check_pr.sh + ci_physlib.sh, Daniel vorlegen;
  **Push nur nach seinem Ja.**

## Nach dem Merge von 12b (2026-10-29): 13/14 auf master, nicht gepusht
- #1971 gemergt 29.10. 05:19 UTC (Squash `02053e52`, `SixJ.lean` = c47116d4); #1932 gemergt 01:42 UTC (`49cf162e`).
  origin/master beim Umsetzen **`2fd010eb`** (danach noch #1943, #1973).
- Sicherungen `backup/wigner-eckart-cg-pre-1971-rebase` (`ea6490bd`), `backup/six-j-symmetry-pre-1971-rebase` (`455ec989`).
  `move.sh <branch> c47116d4 origin/master` (06:43, auf `02053e52`), dann `move.sh <branch> 02053e52 origin/master` (09:35):

| PR | Branch | Fork | neu (lokal) | Lean-Datei | Prüfung |
|---|---|---|---|---|---|
| #1980 (13) | `pr/wigner-eckart-cg` | `ea6490bd` | **`2fd27deb`** (1 Commit) | `WignerEckartNormalized.lean` byteidentisch, +221 | 11/11 + 11/11, sorry 0 |
| #1981 (14) | `pr/six-j-symmetry` | `455ec989` | **`0828d673`** (2 Commits) | `SixJSymmetry.lean` byteidentisch, +697 | 11/11 + 11/11, sorry 0 |

- Berichte `REVIEW_rb1971b-<branch>.txt` / `…-physlib.txt`. **Push wartet auf Daniels Ja** (Lease ea6490bd / 455ec989;
  ggf. workflow-Scope → Sync fork). Danach `-blocked-by-PR` (Daniel).
- **29.10.: gepusht** (Daniels Ja): `pr/wigner-eckart-cg` `ea6490bd` → **`2fd27deb`**, `pr/six-j-symmetry` `455ec989` →
  **`0828d673`** (Lease, ls-remote bestätigt, kein workflow-Problem). Daniel hat bei #1980/#1981 `-blocked-by-PR`
  kommentiert (Label weg). Offen: #1980, #1981, #1990.
- **29.10.: #1981 (14) gemergt** 14:34 UTC (Squash `2725b6f6`). Offen: #1980 (13), #1990 (opalg). E2/E3 erst nach dem
  Merge von #1980 und #1990 (Regel 29.10., `00-Plan.md`).
- **30.10.: #1980 (13) gemergt** 05:45 UTC (Squash `06e0b6c9`). Damit ist der sl2-/Drehimpuls-Stapel 01–14 komplett auf
  master (Wellen-Tabelle in `00-Plan.md` per GitHub-API abgeglichen). Offen nur noch #1990.

## Vorhandenes zuerst 30.10. (rational-3j6j, rational-6j; racah-6j am Rand) – nur Prüfung, nichts gepusht

**Umsetzung auf origin/master `a62866f3`** (Sicherungen `backup/rational-3j6j-pre-20261030` = `5eaf449f`,
`backup/rational-6j-pre-20261030` = `f98c7128`). Alle mitgeschleppten Dateien des alten Stapels (10–14, Stand `43799477`)
vorher gegen master geprüft: byte-gleich. `move.sh rational-3j6j 43799477 origin/master` → **`eb3c7d36`**,
`move.sh rational-6j 5eaf449f rational-3j6j` → **`20d72682`**; keine Konflikte außerhalb der Importliste, Lean-Dateien
byteidentisch. check_pr.sh (mit `build_roots`) + ci_physlib.sh je 11/11 + 11/11, sorry 0 (`REVIEW_rb1030-rational-*.txt`).

**Echter Neuinhalt:** `rational-3j6j`: `Wigner3jRational.lean` +285 (+1 Import); `rational-6j`: `SixJRational.lean` +324
(+1 Import). `racah-6j` (`9163d8bd`, WIP, nicht umgesetzt): `SixJRacah.lean` +76, `sixJSumQ_eq_racahSumQ` mit `sorry`.

**Suche:** Mathlib (`.lake/packages/mathlib`): keine Wigner-/Racah-/Clebsch-Gordan-/6j-Symbole (grep). physlib master: keine
ℚ-Fassungen, kein `decide +kernel` für diese Größen; die reellen Gegenstücke `invFact`, `sixTerm`, `sixSum` (`finsum`),
`threeJR` stehen in `Wigner3j.lean:90–169`, `threeJ`, `sixJTerm`, `sixJSym` in `SixJSymmetry.lean:99–233`. Zweck der neuen
Dateien laut Moduldocstring: berechenbare ℚ-Werte, damit Identitäten mit `decide +kernel` geprüft werden können; die reellen
Symbole sind wegen `√` und `finsum` nicht auswertbar. Proben auf `rational-6j` (Scratch-Datei, gelöscht).

| Deklaration | Fund | Bewertung | Vorschlag |
|---|---|---|---|
| `invFactQ`, `cast_invFactQ` | ℚ-Kopie von `invFact` (`Wigner3j.lean:90`) | Spezialfall (Kopie für Berechenbarkeit) | behalten oder `invFact` über beliebigen Körper verallgemeinern (master-Änderung) |
| `negOnePowQ`, `cast_negOnePowQ` (6 Z.) | `(-1 : ℚ) ^ (z : ℤ)` (zpow); Mathlib `Int.negOnePow` (`Algebra/Ring/NegOnePow.lean:28`) | **Duplikat**: `decide +kernel` rechnet `(-1 : ℚ) ^ (3 : ℤ) = -1` und `∑ z ∈ Icc 0 5, (-1 : ℚ) ^ z = 0` direkt (Probe) | streichen, `(-1 : ℚ) ^ z` verwenden; Cast über `Rat.cast_zpow`/`push_cast` |
| `sixTermQ`, `cast_sixTermQ` (**Einzeiler** `simp only`) | ℚ-Kopie von `sixTerm` | Spezialfall | behalten (Brücke), Einzeiler melden |
| `sixSumQ`, `cast_sixSumQ` (14 Z.) | `sixSum` (`finsum`), Muster `finsum_eq_sum_of_support_subset` wie `Wigner3j.lean:436` | neu (Finset-Form) | behalten |
| `threeJRRadQ`, `threeJRSumQ`, `threeJRSqQ`, `threeJRSgnSqQ` | keine | neu | behalten |
| `cast_threeJRRadQ` (**Einzeiler** `simp only`) | – | Cast-Brücke | behalten, Einzeiler melden |
| `cast_threeJRSumQ` (**Einzeiler** `cast_sixSumQ _ _ _ _ _ _`) | `cast_sixSumQ` | **Spezialfall**; Probe: `rw [threeJRSumQ, cast_sixSumQ]` ersetzt ihn; 1 Verwendung | streichen, an der Verwendungsstelle `rw [threeJRSumQ, cast_sixSumQ]` |
| `threeJR_eq_rat` (**Einzeiler** `rw`) | Definition `threeJR` + zwei Casts | triviale Umschreibung; 3 Verwendungen | inline möglich, Daniel entscheidet |
| `threeJRRadQ_nonneg`, `facPairQ_nonneg`, `triangleSqQ_nonneg`, `sixJRadQ_nonneg` (je 2 Z.) | `positivity` (Probe: `unfold …; positivity` schließt `facPairQ`, `triangleSqQ`) | trivial | behalten oder inline `positivity`; `facPairQ_nonneg` hat 1 Verwendung |
| `facPairQ_neg` (**Einzeiler** `rw`) | – | trivial; 1 Verwendung | inline möglich |
| `cast_threeJRSqQ`, `cast_threeJRSgnSqQ`, `threeJSqQ`, `threeJSgnSqQ`, `cast_threeJSqQ`, `cast_threeJSgnSqQ` | keine | neu (Kern) | behalten |
| `threeJ_eq_sign_mul_sqrt`, `sixJSym_eq_sign_mul_sqrt` (je 8 Z.) | keine | neu (Hauptaussagen) | behalten |
| `sq_cgCoefficient` (4 Z.) | Korollar aus `cgCoefficient_eq_wigner3j` (`Wigner3j.lean:520`), `wigner3j_eq_threeJ`, `cast_threeJSqQ` | Spezialfall; **0 Verwendungen** (auch nicht in racah-6j) | streichen oder bewusst als Ergebnis behalten |
| `triangleSqQ`, `facPairQ`, `threeJNumQ`, `threeJRRadQ_reggeJ`, `threeJ_eq_sqrt_mul` | keine | neu (Zerlegung des Radikanden) | behalten; `threeJRRadQ_reggeJ`, `threeJ_eq_sqrt_mul` je 1 Verwendung |
| `sixJRadQ`, `sixJTermQ`, `sixJVec`, `sixJSumQ`, `adm_of_sixJTermQ_ne_zero`, `sixJSumQ_eq_sum_sixJBox` (33 Z.), `sixJTerm_eq_sqrt_mul` (55 Z.), `sixJSym_eq_sqrt_mul_sixJSumQ` | keine; Hilfsschritte nutzen Mathlib (`Real.sqrt_mul`, von `exact?` als `Real.sqrt_mul hx y` bestätigt) | neu (Kern 6j) | behalten |
| `sixJSqQ`, `sixJSgnSqQ`, `cast_sixJSqQ`, `cast_sixJSgnSqQ` | keine | neu | behalten |
| Abschnitte E (`example … := by decide +kernel`) | prüfen bewiesene Identitäten (Orthogonalität, Symmetrien aus `SixJSymmetry`) numerisch | keine neue Mathematik (Tests) | Daniel/Reviewer: als Tests behalten oder kürzen |

**Einzeiler über vorhandene Lemmata (gemeldet):** `cast_threeJRSumQ` (= `cast_sixSumQ`), `threeJR_eq_rat` (`rw` über die
Definition), `cast_sixTermQ`, `cast_threeJRRadQ` (je `simp only` mit Cast-Lemmata), `facPairQ_neg` (`rw`).
`negOnePowQ` + `cast_negOnePowQ` doppeln zpow.

**Mögliche Einsparung:** `negOnePowQ`/`cast_negOnePowQ` (≈ 10 Z. inkl. Doc), `cast_threeJRSumQ` (≈ 4), `sq_cgCoefficient`
(≈ 13), optional Inlining von `threeJR_eq_rat`, `facPairQ_neg`, `facPairQ_nonneg` (≈ 8) → ≈ 25–35 Zeilen von 609.
Nicht getestet: der Ersatz in allen Verwendungsstellen (würde Codeänderung bedeuten; nicht beauftragt).

**Grundsatzfrage (Daniel/Reviewer):** Die ℚ-Kopien (`invFactQ`, `sixTermQ`, `sixSumQ` mit Cast-Lemmata) existieren nur,
weil die master-Definitionen über `ℝ` und mit `finsum` stehen. Alternative: `invFact`/`sixTerm` über einen beliebigen Körper
und `sixSum` als `Finset`-Summe auf master definieren; dann entfielen die Kopien und die Cast-Lemmata würden zu einem
`map`-Lemma. Das wäre ein Eingriff in gemergten Code (eigener PR, Rücksprache mit Reviewern).

**Literatur:** `Wigner3jRational.lean` zitiert Edmonds (1957), §3.7; `SixJRational.lean` DLMF §34.2, §34.4. Nicht belegt
(Edmonds liegt laut Notiz oben nicht vor) → vor einem PR an der Quelle prüfen (CLAUDE.md).

**Aufteilung in PRs (unter ~300–500 Zeilen):** schon gegeben: PR A `rational-3j6j` (`Wigner3jRational.lean`, 286 Z.),
PR B `rational-6j` (`SixJRational.lean`, 325 Z.) gestapelt auf A. Nach den Streichungen ≈ 265 + 315. Optional Abschnitt E
(Kernel-Checks, ≈ 45 Z. in A) in einen eigenen Test-PR. `racah-6j` (76 Z., `sorry`) bleibt WIP, kein PR.
Code-Branches lokal, nicht gepusht; keine Lean-Datei geändert.
