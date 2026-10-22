# Auftrag (Entwurf): berechenbare rationale 3j²- und 6j²-Werte mit Gleichheitsbeweis

Status: **Entwurf, noch nicht freigegeben.** Folgeauftrag zu `Auftrag-ENSDF.md` („Danach“).
Regeln wie immer:
- Kleine Schritte, erst Aussagen mit `sorry`.
- Nach jedem Schritt `lake build`, nur ein Build gleichzeitig.
- Kein Push ohne Daniels ausdrückliches „ja“, keine Kommentare an Reviewer.
- Zwischenstände knapp in `pr-texte/stand-3j6j.md`.
- **Ein Wasserstoff-Rebase nach Merge von #1909 hat Vorrang.**

## Ziel

3j- und 6j-Symbole sind in unserem Stapel reell definiert und nicht berechenbar:
- `threeJ` und `threeJR` (`Wigner3j.lean`, `SixJSymmetry.lean`) enthalten `Real.sqrt` und eine
  `finsum`;
- `sixJSym` (`SixJSymmetry.lean`) ist eine Summe über Produkte von vier 3j-Symbolen.

Ziel sind berechenbare Funktionen nach `ℚ` mit einem Beweis der Gleichheit zu den reellen
Definitionen:

- `threeJSqQ j₁ j₂ j₃ m₁ m₂ m₃ : ℚ` mit `(threeJSqQ … : ℝ) = threeJ … ^ 2`,
- `threeJSgnSqQ … : ℚ` mit `(threeJSgnSqQ … : ℝ) = threeJ … * |threeJ …|` (Vorzeichen und Betrag,
  daraus `threeJ = sign q * √|q|`),
- dasselbe für 6j: `sixJSqQ`, `sixJSgnSqQ` gegen `sixJSym`.

Damit lassen sich konkrete Werte im Lean-Kern prüfen (`decide` bzw. `norm_num`, **kein**
`native_decide`), und das ENSDF-Werkzeug kann sie kompiliert ausrechnen. Die Anwendung auf
Winkelkorrelationskoeffizienten und Mischungsverhältnisse ist ein **späterer eigener Auftrag**.
Die Formeln dafür kommen dann aus einer belegten Quelle, nicht aus dem Gedächtnis.

## Was es schon gibt (Stand fork, 22.10.2026)

- `pr/clebsch-gordan-formula`: `ClebschGordanFormula.lean`, Racahs Formel für CG
  (`cgCoefficient_racah`, `racahSum`).
- `pr/wigner-3j`: `Wigner3j.lean`, darin
  - `sixSum` (`finsum` über `ℤ` von `(-1)^z / ∏ 6 Fakultäten`, mit `invFact`),
  - `threeJR R = (-1)^… * √(∏ R_ij! / (J+1)!) * sixSum …`,
  - die Regge-Symmetrien und `cgCoefficient_eq_threeJR`.
- `pr/six-j`, `pr/six-j-symmetry`:
  - `SixJ.lean` (`sixJ` über Recoupling-Koeffizienten),
  - `SixJSymmetry.lean` (`threeJ` mit allgemeinen Argumenten, `sixJSym` als Summe von vier 3j,
    `sixJ_eq_sixJSym`, tetraedrische Symmetrie).
- **Es fehlt** eine Racah-Formel für 6j als Einfachsumme. Ohne sie ist `sixJSym²` nicht
  gliedweise rational, denn jedes Glied hat die Form ±√(Produkt von vier Vorfaktoren). Das ist der
  eigentliche mathematische Teil dieses Auftrags.

## Etappen

### R0. Plan und Machbarkeit (noch kein Code)
In `stand-3j6j.md` festhalten:
- **Auswertung im Kern**: Wie teuer sind `decide` und `rfl` auf `ℚ` mit `Nat.factorial` für
  typische Größen (2j ≤ 20, 2j ≤ 40)? Kernel-`Nat`-Operationen sind GMP-beschleunigt, `Rat`-
  Normalisierung braucht `gcd`. Alternativ `norm_num` oder `decide := true`-Varianten.
  Messen statt schätzen.
- **Mathlib**: Was gibt es für berechenbare Summen über `Finset.Icc`/`Finset.range` in `ℚ` und für
  den Cast `ℚ → ℝ` (`Rat.cast_sum`, `Rat.cast_mul`, `Nat.cast_factorial`)?
- **6j-Racah-Formel**: Beweisweg wählen und Aufwand schätzen.
  - (a) Über `SixJ.lean`: Recoupling über explizite Vektoren, wie bei `cgCoefficient_racah`.
  - (b) Direkte Summation der vier 3j-Summen in `sixJSym`.
  - Literaturbeleg: dieselben Quellen wie in `SixJ.lean`/`SixJSymmetry.lean` (Abschnitt iv);
    vor einer Verwendung in einem PR-Text gegen CrossRef prüfen.
- **Ort**: siehe „Was Daniel entscheidet“.

### R1. 3j rational
- `sixSumQ (a₁ a₂ a₃ b₁ b₂ b₃ : ℤ) : ℚ` als endliche Summe über
  `z ∈ [max aᵢ, min bᵢ]`, mit Lemma `(sixSumQ … : ℝ) = sixSum …`. Dafür `finsum` auf die endliche
  Trägermenge einschränken.
- `threeJRSqQ R : ℚ` mit `(threeJRSqQ R : ℝ) = threeJR R ^ 2` (das Vorzeichen fällt weg, `√` wird
  quadriert, nichtnegativer Radikand).
- `threeJSqQ` mit `Adm3`-Fallunterscheidung, Lemma gegen `threeJ`.
- `threeJSgnSqQ`, Lemma `= threeJ * |threeJ|`, Folgerung
  `threeJ = Real.sign q * √|q|` mit `q := threeJSgnSqQ`.

### R2. Prüfungen ohne Werte aus dem Gedächtnis
Keine Tabellenwerte aus dem Gedächtnis. Stattdessen werden bewiesene Identitäten rational
nachgerechnet und per `decide` geprüft:
- die Orthogonalität (`sum_wigner3j_mul_wigner3j_JM`) für kleine j;
- die Symmetrien (`threeJ_swap`, `threeJ_cycle`, `threeJ_neg`) auf einem Gitter;
- Gleichheit mit `cgCoefficient` über `cgCoefficient_eq_wigner3j` für einige Fälle.

Laufzeiten messen und festhalten.

### R3. Racahs Formel für 6j (Hauptarbeit)
- Dreiecksfaktor `triangleCoeff a b c` (Fakultätsquotient; quadriert rational).
- Satz `sixJSym_eq_racah`: `sixJSym j₁ … j₆ = Δ(j₁j₂j₃) Δ(j₁j₅j₆) Δ(j₄j₂j₆) Δ(j₄j₅j₃) · Σ_z …`
  (doppelte Einheiten, Zulässigkeit wie bei `sixJBox`).
  - Die genaue Form der Summe wird in R0 aus der Quelle übernommen und gegen die Normierung von
    `sixJSym` abgeglichen.
  - Erst mit `sorry` formulieren, dann in Teilschritten beweisen (Umordnen der Summen,
    Vandermonde-artige Identitäten wie bei `racahL_eq_racahR`).
- Abbruchregel: Hängt R3 nach mehreren Anläufen, aufhören, festhalten woran, Notizen pushen
  (nach Freigabe).

### R4. 6j rational
- `sixJSqQ`, `sixJSgnSqQ` mit Lemmata gegen `sixJSym` (über `sixJSym_eq_racah`).
- Prüfungen wie R2: die Orthogonalität `sum_sixJ_mul_sixJ` und die tetraedrische Symmetrie
  (`sixJSymEdge_comp_map`) rational nachgerechnet.

### R5. Anbindung (nur vorbereiten)
- Die berechenbaren Funktionen in `Tools/EnsdfCheck` importierbar machen und kompiliert testen
  (Laufzeit für alle in ENSDF vorkommenden (j, m)-Kombinationen schätzen).
- Keine physikalische Auswertung, die kommt in einen späteren Auftrag.

## Abnahme
- Kein `sorry`, Axiome Standard (`#print axioms` für die Hauptlemmata).
- `lake build` des Moduls grün, `check_pr.sh` grün (falls PhyslibAlpha).
- In `stand-3j6j.md`: Laufzeiten aus R0/R2/R4, eine Liste der Deklarationen, offene Punkte.

## Was Daniel entscheidet
1. **Ort**:
   - `PhyslibAlpha/QuantumMechanics/AngularMomentum/RationalSymbols.lean` (PR-fähig) oder
   - `Tools/EnsdfCheck/` (nur Werkzeug).
   Vorschlag: PhyslibAlpha, denn die Aussagen sind reine Mathematik über bestehende Definitionen.
2. **Basis-Branch**: Vorschlag `fork/pr/six-j-symmetry` (enthält `Wigner3j`, `SixJ`,
   `SixJSymmetry`, `ClebschGordanFormula`), neuer Branch `rational-3j6j`. Alternative: erst nach
   Merge der 3j/6j-PRs auf master.
3. **Umfang**: R1–R2 allein (3j) als erster PR, R3–R4 (6j mit Racah-Formel) als zweiter? Oder
   alles zusammen?
4. **Auswertung**: nur `decide`/`norm_num`, oder ist `native_decide` für große Tabellen im
   Werkzeug zulässig? Vorschlag: im Kern nur `decide`; Massenwerte nur kompiliert im Werkzeug,
   dort nicht als Beweis.
5. Push, Veröffentlichung, Kontakt nach außen: wie immer nur Daniel.
