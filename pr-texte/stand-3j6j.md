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
