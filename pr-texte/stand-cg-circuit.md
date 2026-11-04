# Stand CG-Schaltkreis ½ ⊗ ½ (Auftrag B, Schritt 1: Bestandsaufnahme)

Daniel hat das am 01.11. freigegeben. Regeln: kein Push, kein PR, kein Commit auf Upstream-Branches; Arbeit auf dem
lokalen Branch `cg-circuit-half-half` oder als Scratch. Heute **nur Bestandsaufnahme**, noch kein Beweis
(Regel „Vorhandenes zuerst“, Anlass #1990). Stand: physlib origin/master a8823c76.

## (a) physlib

**CG-Koeffizienten**, Datei `PhyslibAlpha/QuantumMechanics/AngularMomentum/ClebschGordanCoefficients.lean`,
Namespace `PhyslibAlpha.Sl2`.
- Z. 321: `def cgCoefficient (k l a b : ℕ) : ℝ` mit explizitem `(m n)` davor, also
  `cgCoefficient m n k l a b : ℝ`. Werte in **ℝ**. Definiert als
  `tensorForm m n (normVec m a ⊗ₜ normVec n b) (coupledVec m n k l)`.
- Indexkonvention (Docstring): `⟨j₁ m₁ j₂ m₂ | J M⟩` mit `j₁ = m/2`, `m₁ = j₁ − a`, `j₂ = n/2`, `m₂ = j₂ − b`,
  `J = (m+n)/2 − k`, `M = J − l`. Für ½ ⊗ ½ heißt das: `m = n = 1`; `a, b ∈ {0, 1}` mit 0 = ↑ und 1 = ↓;
  Triplett `k = 0` mit `l = 0, 1, 2` für M = +1, 0, −1; Singulett `k = 1, l = 0`.
- Normierung: Die gekoppelten Zustände sind orthonormal (`tensorForm_coupledVec`). Phase: Condon–Shortley
  (`cgCoefficient_top_pos`, Z. 396: `0 < cgCoefficient m n k 0 0 k`).
- Werte:
  - Z. 482 `cgCoefficient_stretched : cgCoefficient m n 0 0 0 0 = 1`
  - Z. 496 `cgCoefficient_singlet_up : cgCoefficient 1 1 1 0 0 1 = 1 / Real.sqrt 2`
  - Z. 503 `cgCoefficient_singlet_down : cgCoefficient 1 1 1 0 1 0 = -1 / Real.sqrt 2`
  - Z. 526 `cgCoefficient_triplet_zero_up : cgCoefficient 1 1 0 1 0 1 = 1 / Real.sqrt 2`
  - Z. 535 `cgCoefficient_triplet_zero_down : cgCoefficient 1 1 0 1 1 0 = 1 / Real.sqrt 2`
- Weitere API:
  - Z. 336 `cgCoefficient_eq_zero_of_ne (hmn : 0 < m+n) (hkm : k ≤ m) (hkn : k ≤ n) (h : a + b ≠ k + l)`: Gewichtsregel.
  - Z. 454 `coupledVec_eq_sum`: Entwicklung in der Produktbasis.
  - Z. 461 `sum_cgCoefficient_mul`: Orthogonalität Σ_{a,b} C·C' = δδ, das ist die Spaltenorthonormalität der
    Basiswechselmatrix.
  - Z. 277 `tensorF_coupledVec` und Z. 509 `coupledVec_one_one_zero_one`: Leiteroperator.
- **Lücke:** Der Wert für **T₋₁**, `⟨½ −½ ½ −½ | 1 −1⟩ = cgCoefficient 1 1 0 2 1 1 = 1`, steht **nicht** auf
  master. Alle übrigen 15 Einträge der 4×4-Matrix sind abgedeckt: die vier Nicht-Null-Werte oben, `stretched`
  für T₊₁, und elf Nullen über `cgCoefficient_eq_zero_of_ne`. Den fehlenden Wert kann man analog zu
  `cgCoefficient_triplet_zero_up` herleiten (`tensorF_coupledVec` mit l = 1 und `tensorForm_tensorE`), etwa
  10–15 Zeilen. Aus `sum_cgCoefficient_mul` allein folgt nur ±1, das Vorzeichen bleibt offen.
- Eine **Matrix-Formulierung** gibt es nicht. In PhyslibAlpha kommen weder `Matrix (Fin 4) (Fin 4)` noch
  `unitaryGroup` noch eine Basiswechselmatrix vor; es gibt nur die Summenformen oben.

**QuantumInfo** (gehört zu physlib und ist eine eigene `lean_lib`). PhyslibAlpha darf daraus importieren:
`noAlphaImports` verbietet nur die Gegenrichtung.
- `QuantumInfo/ForMathlib/HermitianMat/Unitary.lean`:
  - Notation `𝐔[n]` für `Matrix.unitaryGroup n ℂ`;
  - `unitary_kron` mit Notation `⊗ᵤ` (scoped in `Matrix`), `unitary_kron_apply`, `kron_unitary`.
- `QuantumInfo/States/Pure/Qubit.lean`:
  - `abbrev Qubit := Fin 2`;
  - Gatter in `𝐔[Qubit]` über **ℂ**: `X`, `Y`, `Z`, `H` (= √(1/2)·!![1,1;1,−1]), `S`, `T`;
  - `controllize g : 𝐔[Qubit × k]` mit Notation `C[g]` (scoped). Die Steuerung ist die **erste** Komponente:
    bei 0 Identität, bei 1 wird `g` angewandt;
  - `CNOT := C[X]` mit Steuerung auf Qubit 1 und Ziel auf Qubit 2;
  - `CNOT_matrix` (`reindex finProdFinEquiv` auf die 4×4-Permutationsmatrix);
  - `controllize_mul`, `X_controllize_X`;
  - die Taktik **`matrix_expand`**: `ext`, `fin_cases`, dann `simp` mit `Matrix.mul_apply`,
    `Fintype.sum_prod_type`, `Complex.ext_iff`, danach `norm_num`, `field_simp`, `ring_nf`.
- **Kein Ry** und kein allgemeines Rotationsgatter. Basis ist `Qubit × Qubit`, nicht `Fin 4`.

## (b) Mathlib (Version von physlib master)

Lean `v4.35.0`, Mathlib rev `56a00585…` (Tag v4.35.0, Commit vom 13.10.2026).
- `Mathlib/LinearAlgebra/Matrix/Kronecker.lean`:
  - Z. 55 `kroneckerMap`; Z. 274 `kronecker`;
  - Z. 278 `scoped[Kronecker] infixl:100 " ⊗ₖ "`;
  - Z. 283 `kronecker_apply`; Z. 368 `one_kronecker_one`;
  - Z. 382 `mul_kronecker_mul : (A * B) ⊗ₖ (A' * B') = A ⊗ₖ A' * B ⊗ₖ B'`; `kronecker_assoc`.
- `Mathlib/LinearAlgebra/UnitaryGroup.lean`: Z. 105 `Matrix.unitaryGroup`; Z. 117/121 `mem_unitaryGroup_iff(')`
  (`A * star A = 1` bzw. `star A * A = 1`).
- `Mathlib/LinearAlgebra/Matrix/Notation.lean`: `!![a, b; c, d]`.
- `Mathlib/Logic/Equiv/Fin/Basic.lean`: Z. 330 `finProdFinEquiv`. Dazu `Matrix.reindex` und `Equiv.prodComm` zum
  Vertauschen der Qubits.
- Taktiken für konkrete Matrizen mit √2: Der bewährte Weg in physlib ist `matrix_expand` (s. o.). Sonst `ext i j`,
  `fin_cases`, `simp [Matrix.mul_apply, Fintype.sum_prod_type]`, `field_simp` und `Real.sq_sqrt` bzw.
  `Real.mul_self_sqrt`. `decide` geht wegen `Real.sqrt` nicht.

## (c) LeanQuantum

- Geklont nach `~/scratch/LeanQuantum`, nur gelesen. Commit `44fc4eb1f4ba512e659deacd3468fda0a764d162`
  (15.05.2026), Lizenz MIT.
- Version: Lean `v4.30.0-rc2`, Mathlib `c1e30e17…`. physlib nutzt Lean v4.35.0 mit Mathlib v4.35.0. **Als
  Abhängigkeit nicht kompatibel**, nur als Vorlage brauchbar.
- Gatter und Bausteine:
  - `hadamard`, `cnot`, `notc`, `swap` als `!![…]`, `controlM`;
  - `rotate θ φ δ`, `xRotate`, `yRotate θ = !![cos(θ/2), −sin(θ/2); sin(θ/2), cos(θ/2)]`;
  - Pauli-Gatter mit Notation, eigene `kron` auf `Fin (a*c)` (= `reindex finProdFinEquiv` von `⊗ₖ`);
  - Taktik `SolveMatrix`.
- Typen: `CSquare n = Matrix (Fin n) (Fin n) ℂ`. Die Konvention weicht von physlib/QuantumInfo ab
  (`Qubit × Qubit`, `𝐔[·]`).
- Folgerung: QuantumInfo in physlib reicht aus. LeanQuantum höchstens als Vorlage für `yRotate`, falls eine
  Ry-Variante gewünscht ist.

## (d) Vorschlag

**Basis und Ordnung.**
- Zeilen: `Qubit × Qubit`, (0,0), (0,1), (1,0), (1,1) = |00⟩, |01⟩, |10⟩, |11⟩ = |↑↑⟩, |↑↓⟩, |↓↑⟩, |↓↓⟩.
  Dabei ist Qubit 1 = Spin 1 (Index `a`), Qubit 2 = Spin 2 (Index `b`) und 0 = ↑. Das entspricht genau den
  physlib-Indizes `a, b`.
- Spalten: (0,0), (0,1), (1,0), (1,1) = T₊₁, T₀, T₋₁, S, also (k, l) = (0,0), (0,1), (0,2), (1,0).
- Zielmatrix mit diesen Werten:
  `[[1,0,0,0],[0,1/√2,0,1/√2],[0,1/√2,0,−1/√2],[0,0,1,0]]`.

**Schaltkreis.**
- `CH₂₁` zuerst, dann `CNOT₁₂`, also Matrix `CNOT · CH₂₁`.
  - `CH₂₁` ist ein kontrolliertes Hadamard mit Steuerung auf Qubit 2 und Ziel Qubit 1. In QuantumInfo ist das
    `reindex (Equiv.prodComm) (Equiv.prodComm) C[H]`, weil `C[·]` die Steuerung vorn hat.
  - `CNOT₁₂` ist `Qubit.CNOT`.
- Numerisch gesucht (numpy als Werkzeug, Skript
  `/tmp/claude-1002/-home-eigenart-physlib-ci-physlib/74a14363-1138-4d7d-8a65-ee822727d54c/scratchpad/cgsearch.py`).
  Aus {CNOT₁₂, CNOT₂₁, H, X, Z auf jedem Qubit} gibt es **keine** Folge bis Länge 5. Das ist auch klar: Die
  Zielmatrix ist auf span{|01⟩,|10⟩} ein Hadamard, die Clifford-Gatter in der Liste liefern das nicht ohne
  kontrolliertes Gatter. Mit {CH, kontrolliertes Ry(±π/2)} dazu ist `CH₂₁ → CNOT₁₂` die **einzige** Folge der
  Länge 2.
- Probe von Hand:
  - |00⟩ → |00⟩ = T₊₁
  - |01⟩ → (|01⟩+|11⟩)/√2 → (|01⟩+|10⟩)/√2 = T₀
  - |10⟩ → |10⟩ → |11⟩ = T₋₁
  - |11⟩ → (|01⟩−|11⟩)/√2 → (|01⟩−|10⟩)/√2 = S
- Ry-Variante: H = Ry(π/4)·Z·Ry(−π/4), numerisch exakt geprüft, ohne Phase. Damit ist
  CH₂₁ = (Ry(π/4) auf Qubit 1) · CZ · (Ry(−π/4) auf Qubit 1). Das ist nicht nötig und bräuchte ein neues
  Ry-Gatter.

**Zielmatrix aus den physlib-Lemmas, ohne die Werte neu hinzuschreiben.** Die Matrix wird direkt aus
`cgCoefficient` gebildet; die Werte kommen erst im Beweis über die Lemmas hinein. Das Ziel-Statement hat
elaboriert, Scratch-Datei `…/scratchpad/CgCircuitStatement.lean`, `lake env lean` mit nur der `sorry`-Warnung.

```lean
import PhyslibAlpha.QuantumMechanics.AngularMomentum.ClebschGordanCoefficients
import QuantumInfo.States.Pure.Qubit

open PhyslibAlpha.Sl2 Qubit Matrix

/-- `k` der Spalte: Spalten `(0,0), (0,1), (1,0), (1,1)` = `T₊₁, T₀, T₋₁, S`. -/
def cgK : Qubit × Qubit → ℕ := fun q => if q = (1, 1) then 1 else 0

/-- `l = J - M` der Spalte. -/
def cgL : Qubit × Qubit → ℕ := ![![0, 1], ![2, 0]] |> fun f q => f q.1 q.2

noncomputable def cgMatrix : Matrix (Qubit × Qubit) (Qubit × Qubit) ℂ :=
  Matrix.of fun p q => ((cgCoefficient 1 1 (cgK q) (cgL q) p.1 p.2 : ℝ) : ℂ)

/-- Kontrolliertes H, Steuerung Qubit 2, Ziel Qubit 1. -/
noncomputable def CH21 : Matrix (Qubit × Qubit) (Qubit × Qubit) ℂ :=
  Matrix.reindex (Equiv.prodComm _ _) (Equiv.prodComm _ _) (C[H]).val

example : CNOT.val * CH21 = cgMatrix := by
  sorry
```

**Weg zum Beweis (Schritt 2, noch nicht begonnen).**
1. Neues Lemma `cgCoefficient 1 1 0 2 1 1 = 1` für T₋₁, analog zu `cgCoefficient_triplet_zero_up`. Das ist die
   einzige Lücke.
2. `ext p q; fin_cases` über 16 Einträge. Rechts die fünf Werte-Lemmas plus das neue, die elf Nullen über
   `cgCoefficient_eq_zero_of_ne (by norm_num) (by norm_num) (by norm_num) (by norm_num)`. Links
   `matrix_expand [CNOT, X, H]`.
3. Daraus folgt Unitarität der CG-Matrix gratis, als Produkt von Elementen aus `𝐔[·]`.

Optional als zweite Aussage: Spaltenorthonormalität aus `sum_cgCoefficient_mul`, als Gegenprobe ohne Schaltkreis.

**Offene Entscheidungen für Daniel.**
- Wo kommt es hin? PhyslibAlpha mit Import aus QuantumInfo, also ℂ, oder rein reell in PhyslibAlpha mit eigener
  4×4-Matrix?
- Soll das T₋₁-Lemma ein eigener kleiner PR vor dem Schaltkreis-PR werden?
- H-Variante (kürzer, vorhandene Gatter) oder Ry-Variante (bräuchte neues Gatter)?

## Schritt 2 (01.11., nur lokal, kein Push, kein PR)

Daniels Entscheidungen: (1) T₋₁-Lemma als eigener kleiner PR vorab, (2) Schaltkreis in PhyslibAlpha mit Import aus
QuantumInfo, also über ℂ und mit `Qubit × Qubit`, (3) Hadamard-Variante `CNOT * CH21`.

| Branch | Commit | Basis | Umfang | check_pr.sh | ci_physlib.sh | sorry |
|---|---|---|---|---|---|---|
| `cg-tminus1` | 10df2a7f „feat(PhyslibAlpha): the Clebsch-Gordan coefficient of the lowest triplet state“ | origin/master a8823c76 | `ClebschGordanCoefficients.lean` +22 −2 | 11/11 OK | 11/11 OK | 0 |
| `cg-circuit-half-half` | 6f630bd0 „feat(PhyslibAlpha): a two-qubit circuit for the Clebsch-Gordan coefficients of two spins 1/2“ | `cg-tminus1` | neue Datei `ClebschGordanCircuit.lean` (100 Zeilen) + 1 Import | 11/11 OK | 11/11 OK | 0 |

**Inhalt cg-tminus1.**
- `coupledVec_one_one_zero_two`: `|1,−1⟩ = (1/√2) J₋ |1,0⟩`, analog zu `coupledVec_one_one_zero_one`.
- `cgCoefficient_triplet_minus : cgCoefficient 1 1 0 2 1 1 = 1`, Docstring „Triplet: `⟨½ -½ ½ -½ | 1 -1⟩ = 1`“.
  Herleitung wie bei `cgCoefficient_triplet_zero_up`: `J₊` nach links, dann die beiden T₀-Werte einsetzen.
- Moduldoku (Liste der Werte, Key results) ergänzt. Die Lemmas stehen am Ende von D.3 direkt nach
  `cgCoefficient_triplet_zero_down`.

**Inhalt cg-circuit-half-half** (`PhyslibAlpha/QuantumMechanics/AngularMomentum/ClebschGordanCircuit.lean`).
- `cgK`, `cgL`: die Labels (k, l) der Spalten (0,0), (0,1), (1,0), (1,1) = T₊₁, T₀, T₋₁, S.
- `cgMatrix`: `Matrix.of fun p q => (cgCoefficient 1 1 (cgK q) (cgL q) p.1 p.2 : ℂ)`. Die Werte werden nicht neu
  hingeschrieben.
- `CH21 := reindex (Equiv.prodComm _ _) (Equiv.prodComm _ _) C[H]`.
- `cnot_mul_CH21 : CNOT.val * CH21 = cgMatrix`. Beweis: `fin_cases` über 16 Einträge, `simp` mit den sechs
  Wert-Lemmas und der Gewichtsregel `cgCoefficient_eq_zero_of_ne` für die Nullen.
- `CH21_mem_unitaryGroup` über `conjTranspose_reindex`, `coe_reindexAlgEquiv` und `map_mul`. In Mathlib gibt es
  kein fertiges Lemma „reindex erhält unitaryGroup“; danach habe ich gesucht.
- `cgMatrix_mem_unitaryGroup` als Korollar: `Submonoid.mul_mem` aus `CNOT.2` und `CH21_mem_unitaryGroup`.
- Moduldoku nach Schema mit Basisordnung |00⟩, |01⟩, |10⟩, |11⟩ = |↑↑⟩, |↑↓⟩, |↓↑⟩, |↓↓⟩ und Spalten T₊₁, T₀,
  T₋₁, S. Unter „References“ steht keine Literatur, nur Verweise auf `ClebschGordanCoefficients` und
  `QuantumInfo.States.Pure.Qubit`, weil keine heruntergeladene Quelle vorliegt.

**Lint.**
- `check_pr.sh` (build_modules, build_alpha, runPhyslibAlphaLinters, build_roots, theorem_lint, module_doc_lint,
  alphaFileImports, noAlphaImports, lint_style, alpha_python, codespell) und `ci_physlib.sh` (11 Schritte): alles
  OK, auf beiden Branches.
- Zusätzlich `lake exe lint_all` auf `cg-circuit-half-half`: Build, Importe, Duplikate, Pseudo, Theorem-Lint und
  API-Map sind OK. Es bleiben 46 Meldungen „Transitive imports“, **alle in `Physlib/…`-Dateien**, die die Branches
  nicht berühren, also Altbestand. In PhyslibAlpha und in den neuen Dateien gibt es keine Meldung.

**Einzeiler über vorhandene Lemmata (Regel „Vorhandenes zuerst“).**
- `cgMatrix_mem_unitaryGroup` ist ein Zweizeiler aus `cnot_mul_CH21`, `CNOT.2` und `CH21_mem_unitaryGroup`.
- `CH21_mem_unitaryGroup` ist ein einziges `rw` über Mathlib-Lemmas.
- Beide sind inhaltlich neu (Unitarität der CG-Matrix bzw. des umindizierten Gatters) und keine Umschreibung
  vorhandener Lemmata. Daniel entscheidet, ob `CH21_mem_unitaryGroup` eigenständig bleibt.

**Qiskit-Abgleich.**
- venv `~/venvs/qiskit` neu angelegt (qiskit 2.6.1). Skript `~/physlib_ci/cg_circuit/qiskit_abgleich.py`, Ausgabe
  `~/physlib_ci/cg_circuit/qiskit_ausgabe.txt`.
- Schaltkreis: `qc.ch(1, 0)` (Steuerung Qiskit-Qubit 1 = Spin-Qubit 2, Ziel Qiskit-Qubit 0 = Spin-Qubit 1), dann
  `qc.cx(0, 1)`.
- Qiskit ist little endian, Index = q1 + 2·q2. Für unsere Ordnung |q1 q2⟩ mit Index 2·q1 + q2 wird umsortiert.
- Ergebnis: **max |U − Ziel| = 0.0 (≤ 1e-12, OK)**. Ohne Umsortierung wären es 1.414. Die Bitordnung ist also
  tatsächlich relevant, und sie ist richtig behandelt.

**Stichpunkte für Daniels PR-Beschreibungen** (Inhalt, Daniel formuliert selbst).
- PR 1 (`cg-tminus1`):
  - ergänzt den fehlenden Wert `⟨½ −½ ½ −½ | 1 −1⟩ = 1`, also `cgCoefficient_triplet_minus`;
  - damit sind alle vier Zustände von ½ ⊗ ½ explizit;
  - Herleitung wie bei T₀ mit dem Absteigeoperator: `|1,−1⟩ = (1/√2) J₋|1,0⟩`, dann `J₊` adjungiert nach links;
  - +22/−2 Zeilen, nur `ClebschGordanCoefficients.lean`, Moduldoku angepasst;
  - Vorbereitung für den Schaltkreis-PR.
- PR 2 (`cg-circuit-half-half`, blocked-by PR 1):
  - die 4×4-Basiswechselmatrix von Produkt- zu gekoppelter Basis für zwei Spins ½, gebaut direkt aus
    `cgCoefficient`, Condon–Shortley-Phase;
  - Spaltenordnung T₊₁, T₀, T₋₁, S; Zeilenordnung |↑↑⟩, |↑↓⟩, |↓↑⟩, |↓↓⟩ mit ↑ = |0⟩;
  - Satz: der Schaltkreis „kontrolliertes H (Steuerung Qubit 2, Ziel Qubit 1), dann CNOT (1 → 2)“ ergibt genau
    diese Matrix; Korollar: die CG-Matrix ist unitär;
  - erste Verbindung zwischen der Drehimpuls-Kopplung in PhyslibAlpha und den Qubit-Gattern in QuantumInfo; es gibt
    keine neuen Gatter, `C[H]` wird nur umindiziert;
  - 100 Zeilen, eine neue Datei;
  - unabhängig mit Qiskit 2.6.1 numerisch gegengeprüft (nur als Hinweis, kein Teil des PR).

## Stand 01.11. abends

- **#2006 offen** (`cg-tminus1`, 10df2a7f): Daniel hat den PR eröffnet.
- `cg-circuit-half-half` (6f630bd0) liegt auf fork (Cowork hat gepusht). PR 2 ist **noch nicht eröffnet**; Daniel
  eröffnet ihn später mit blocked-by #2006.
- PR-Check: `pr_mergeable.sh` holt die offenen PRs dynamisch über die API und listet #2006 schon (Lauf 01.11.
  abends: unstable, CI läuft). Am Skript und am Cron musste nichts geändert werden.
- **#2007 offen**: Daniel hat PR 2 eröffnet (`cg-circuit-half-half`, 6f630bd0, blocked-by #2006). Der PR-Check erfasst ihn automatisch über die dynamische API-Suche.

## Schritt 3: 1 × ½ und j × ½ (01.11., nur Bestandsaufnahme und Plan, kein Beweis, kein Push)

### (a) CG-Werte für n = 1

**Einzelwerte für m = 2, n = 1:** keine, weder auf master noch auf unseren Branches (grep nach
`cgCoefficient 2 1`). Vorhanden sind nur die Werte für m = n = 1 und `cgCoefficient_stretched` (beliebige m, n).

**Geschlossene Formeln gibt es schon auf master**, in
`PhyslibAlpha/QuantumMechanics/AngularMomentum/ClebschGordanFormula.lean`:
- Z. 309 `cgSum`; Z. 354 `cgCoefficient_eq_cgSum`.
- Z. 364 `cgCoefficient_closed`: für α + β = k + l gilt `cgCoefficient m n k l α β = cgSum m n k l α · √(…)`, mit
  den Hypothesen k ≤ m, k ≤ n, l ≤ m + n − 2k, α ≤ m, β ≤ n.
- Z. 581 `cgCoefficient_racah`: Racahs Formel.
- Z. 151 `sum_cgCoefficient_mul_cgCoefficient`: zweite Orthogonalität.

Für n = 1 ist k ∈ {0, 1}. `cgSum m 1 k l α` hat dann höchstens zwei Summanden. Die vier Fälle (k, β) ∈ {0,1}²
folgen also durch **Spezialisierung von `cgCoefficient_closed`**, ohne Induktion. Eine Induktion über l mit dem
Absteigeoperator wie bei T₀/T₋₁ ist nicht nötig. Für 1 × ½ (m = 2) gehen die sechs Werte notfalls auch einzeln mit
`norm_num [cgSum, cgCoeff, normSq, hwNormNum, Finset.sum_range_succ]`.

**Erwartete Form, aus der heruntergeladenen Quelle** (Varshalovich et al., Tab. 8.1, gedruckte S. 271 = PDF-S. 284
von `~/ensdf/sources_3j6j/9789814415491.pdf`, am Seitenbild abgelesen). C^{cγ}_{aα ½β}:

| c | β = ½ | β = −½ |
|---|---|---|
| a + ½ | [(c+γ)/(2c)]^{1/2} | [(c−γ)/(2c)]^{1/2} |
| a − ½ | −[(c−γ+1)/(2c+2)]^{1/2} | [(c+γ+1)/(2c+2)]^{1/2} |

In physlib-Indizes: a = m/2, c = J, γ = M, also 2c = m+1 für k = 0 und 2c+2 = m+1 für k = 1, und l = J − M.
- k = 0: β = 0 ↦ √((m+1−l)/(m+1)), β = 1 ↦ √(l/(m+1)).
- k = 1: β = 0 ↦ −√((l+1)/(m+1)), β = 1 ↦ √((m−l)/(m+1)).
- Die Vorzeichen sind Condon–Shortley, passend zu `cgCoefficient_top_pos`.
- Numerisch (sympy `CG`, exakt): **160/160 Werte für m = 1…8 gleich, 0 Abweichungen**. Skript
  `~/physlib_ci/cg_circuit/jhalf_check.py`, Ausgabe `jhalf_ausgabe.txt`.

### (b) Kodierung von Spin 1 auf Qubits

**QuantumInfo hat dafür:**
- keinen Qutrit-Typ (`Fin 3` kommt nur bei der Bloch-Kugel vor);
- `Matrix.Isometry` (A Aᴴ = 1), `Equiv.Perm.permMatrix_mem_unitaryGroup`, `Matrix.reindex_one_mem_unitaryGroup`
  und `Matrix.reindex_eq_conj_unitaryGroup'` (in `QuantumInfo/ForMathlib/Isometry.lean`);
- `controllize` für beliebiges Ziel `k`, also `C[g] : 𝐔[Qubit × k]`;
- kein Ry, keine Unterraum- oder Symmetrisierer-Konstruktion.

**Nebenbefund zu #2007:** `CH21_mem_unitaryGroup` könnte statt über `conjTranspose_reindex` und
`coe_reindexAlgEquiv` auch über `Matrix.reindex_eq_conj_unitaryGroup'` (QuantumInfo) bewiesen werden. Ein Lemma,
das genau „reindex erhält unitaryGroup“ sagt, gibt es aber auch dort nicht. Unser Lemma dupliziert also nichts, ist
nur ein anderer Weg. Daniel zur Kenntnis.

**Optionen.**
- (i) Zwei Qubits mit einem unbenutzten Zustand.
  - Bei 1 × ½ ist das eine 8×8-Matrix; die Aussage gilt nur auf dem 6-dim. Unterraum bzw. als Isometrie.
  - Für allgemeines j braucht das Register ⌈log₂(2j+1)⌉ Qubits mit Lücken, und die Aussagen werden umständlich.
  - Vorteil: echte Qubit-Gatter, direkt auf Hardware oder in Qiskit abbildbar.
- (ii) Register `Fin (m+1)` (2j+1 Zustände) × `Qubit`.
  - Die Basis entspricht genau den physlib-Indizes (α, β); keine unbenutzten Zustände; derselbe Satz für alle m.
  - `C[·]` aus QuantumInfo passt direkt, weil sein Ziel beliebig ist, und für die Permutationen gibt es
    `permMatrix_mem_unitaryGroup`.
  - Für m = 1 ergibt sich wieder ½ × ½, allerdings mit anderer Spaltenordnung als in #2007.
- (iii) Spin 1 als symmetrischer Unterraum von ½ ⊗ ½ (Triplett aus #2007), also 1 × ½ ⊂ ½ ⊗ ½ ⊗ ½.
  - Physikalisch schön und baut auf #2007 auf.
  - Man braucht aber die Einbettung als Isometrie und eine Kopplung mit drei Spins (Rekopplung). Allgemeines j
    hieße 2j Qubits im symmetrischen Unterraum; dafür gibt es keine Infrastruktur.

**Empfehlung: (ii).** Sie ist am kleinsten, deckt 1 × ½ und j × ½ mit **einer** Konstruktion ab, nutzt nur
vorhandenes (`C[·]`, `permMatrix`, `reindex`) plus ein neues Ry, und die Indizes passen 1:1 zu `cgCoefficient m 1`.
(i) kann später als Korollar folgen: Register `Fin 3` per Isometrie in zwei Qubits einbetten. (iii) wäre ein
eigenes, späteres Thema (Rekopplung mit drei Spins, Bezug zu 6j/9j).

### (c) Schaltkreisfamilie für j × ½

Auf `Fin (m+1) × Qubit`, m = 2j: **U = D · R**.
- R = Σ_r |r⟩⟨r| ⊗ Ry(θ_r), also ein vom Register gesteuertes Ry (Multiplexer, blockdiagonal), mit
  cos(θ_r/2) = √(1 − r/(m+1)) und sin(θ_r/2) = √(r/(m+1)); θ₀ = 0.
- D: Ist das Qubit 1, wird das Register zyklisch um eins erniedrigt (r ↦ r − 1 mod m+1). In QuantumInfo ist das
  `reindex prodComm (C[P])` mit P = Permutationsmatrix der zyklischen Verschiebung auf `Fin (m+1)`.
- Spalten:
  - (r, 0) ↦ |J = j+½, l = r⟩ für r = 0…m;
  - (0, 1) ↦ |j+½, l = m+1⟩, der gestreckte Zustand unten;
  - (r, 1) ↦ |j−½, l = r−1⟩ für r = 1…m.
- Probe am Ry-Block: Ry|r,0⟩ = c|r,0⟩ + s|r,1⟩. D macht daraus c|α=r, β=0⟩ + s|α=r−1, β=1⟩, das ist Tab. 8.1 mit
  k = 0. Entsprechend ergibt (r,1) die Spalte k = 1 mit −s und c.
- Numerisch (numpy): **max |U − CG| ≤ 1.1e-16 für m = 1…8**, U jeweils unitär (gleiches Skript wie oben).

**Ry fehlt in QuantumInfo.** Vorschlag: `Ry` über (c, s) mit c² + s² = 1 als `!![c, −s; s, c]`, das ist reell und
unitär. Damit braucht man weder arccos noch Real.cos/sin; die Winkel sind √-Ausdrücke. Alternativ θ-Form wie
LeanQuantum `yRotate θ = !![cos(θ/2), −sin(θ/2); sin(θ/2), cos(θ/2)]` (MIT-Lizenz, nur als Vorlage) mit
`θ_r = 2·arcsin √(r/(m+1))` und `Real.cos_arcsin`/`Real.sin_arcsin`; das ist mehr Aufwand im Beweis.
Daniel entscheidet: Ry nach QuantumInfo (Fremdcode von A. Meiburg, physlib-intern) oder lokal in PhyslibAlpha.

**1 × ½ als Spezialfall m = 2:** `Fin 3 × Qubit`, 6×6.
- R hat Ry-Blöcke mit (c, s) = (1, 0), (√(2/3), √(1/3)), (√(1/3), √(2/3)); D ist das Qubit-gesteuerte zyklische
  Verschieben auf `Fin 3`.
- Ein Qiskit-Abgleich ginge über Option (i), Register auf zwei Qubits. Das habe ich noch nicht gemacht, weil (ii)
  empfohlen ist.

### (d) Aufwand und PR-Schnitt

Jeder Schritt ist ein kleiner PR mit genau einem Konzept, im physlib-Stil:

| PR | Inhalt | Zeilen | Aufwand |
|---|---|---|---|
| 3a | `cgCoefficient m 1 …` für alle vier Fälle (k, β) als Spezialisierung von `cgCoefficient_closed` (Moduldoku-Quelle: Varshalovich Tab. 8.1, heruntergeladen) | 80–150 | 1–2 Tage |
| 3b | `Ry` (c, s)-Form mit Unitarität, ggf. `Ry_mul`, plus Multiplexer `Σ_r |r⟩⟨r| ⊗ g_r` als unitäres Element | 60–100 | 0,5–1 Tag |
| 3c | j × ½: `cgMatrixHalf m` aus `cgCoefficient m 1` (Werte nicht neu hingeschrieben), Satz `D * R = cgMatrixHalf m`, Korollar unitär; 1 × ½ als `example` für m = 2 | 150–250 | 2–4 Tage |

Wenn Daniel 1 × ½ ausdrücklich zuerst als eigenen PR will: dann vor 3c ein PR „1 × ½ konkret“ mit Werten per
`norm_num` aus `cgCoefficient_closed` und `fin_cases` über 36 Einträge, 100–150 Zeilen, etwa 1 Tag. 3c verallgemeinert
ihn dann.

Abhängigkeiten: 3a hängt nur an master. 3b ist unabhängig. 3c braucht 3a und 3b, sinnvollerweise auch #2007, weil es
dieselbe Datei und dieselben Konventionen nutzt.

**Risiken.**
- Indexarithmetik in ℕ (α = k + l − β, zyklisches r − 1) bei `fin_cases` für allgemeines m: Für allgemeines m geht
  `fin_cases` nicht, dann braucht es `Finset.sum`-Argumente über Blöcke.
- Die Hypothesen von `cgCoefficient_closed` (l ≤ m + 1 − 2k usw.) sind an den Rändern r = 0 und l = m+1 zu
  beachten.
- Ry in QuantumInfo berührt Fremdcode; die Ablage klärt Daniel.

**Offene Entscheidungen für Daniel.**
- (1) Kodierung (ii) `Fin (m+1) × Qubit`?
- (2) Ry in QuantumInfo oder in PhyslibAlpha, (c, s)- oder θ-Form?
- (3) 1 × ½ als eigener PR vor dem allgemeinen j × ½ oder nur als Beispiel darin?
- (4) Ist #2007 bei `CH21_mem_unitaryGroup` so in Ordnung (Alternative über QuantumInfo, s. o.)?

## Schritt 3 Umsetzung (01.11. abends, nur lokal, kein Push, kein PR)

Daniels Entscheidungen: (1) Kodierung (ii) `Fin (m+1) × Qubit`. (2) Ry lokal in PhyslibAlpha, (c, s)-Form,
QuantumInfo bleibt unberührt. (3) 1 × ½ nur als `example` in 3c. (4) #2007 bleibt wie er ist.

| Branch | Commit | Basis | Umfang | check_pr.sh | ci_physlib.sh | sorry |
|---|---|---|---|---|---|---|
| `cg-jhalf-values` (3a) | 0db37cec „feat(PhyslibAlpha): the Clebsch-Gordan coefficients for coupling with a spin 1/2“ | origin/master **3d3ec913** (#1975; korrigiert 01.11. abends, vorher fälschlich a8823c76 notiert) | `ClebschGordanFormula.lean` +103 (neuer Abschnitt F, Moduldoku) | 11/11 OK | 11/11 OK | 0 |
| `cg-ry` (3b) | dafef917 „feat(PhyslibAlpha): real qubit rotations and multiplexed gates“ | origin/master **3d3ec913** (korrigiert) | neue Datei `PhyslibAlpha/QuantumMechanics/QubitGates.lean` (99 Zeilen) + 1 Import | 11/11 OK | 11/11 OK | 0 |

**3a, Inhalt** (`ClebschGordanFormula.lean`, Abschnitt „F. Coupling with a spin ½“; Namespace und Stil der Datei):
- `cgCoefficient_add_half_up (hl : l ≤ m) : cgCoefficient m 1 0 l l 0 = √((m + 1 − l)/(m + 1))`, also
  ⟨j₁ m₁ ½ ½ | j₁+½, M⟩
- `cgCoefficient_add_half_down (hl : l ≤ m) : cgCoefficient m 1 0 (l+1) l 1 = √((l + 1)/(m + 1))`, also
  ⟨j₁ m₁ ½ −½ | j₁+½, M⟩
- `cgCoefficient_sub_half_up (hl : l + 1 ≤ m) : cgCoefficient m 1 1 l (l+1) 0 = −√((l + 1)/(m + 1))`, also
  ⟨j₁ m₁ ½ ½ | j₁−½, M⟩
- `cgCoefficient_sub_half_down (hl : l + 1 ≤ m) : cgCoefficient m 1 1 l l 1 = √((m − l)/(m + 1))`, also
  ⟨j₁ m₁ ½ −½ | j₁−½, M⟩

Weitere Punkte:
- Jeder Docstring nennt die physikalische Form (z. B. √((j₁ + M + ½)/(2j₁ + 1))) und die physlib-Indizes
  (j₁ = m/2, J, M = J − l, m₁).
- Beweise: `cgCoefficient_closed` anwenden, `cgSum` mit `simp` ausrechnen (für n = 1 höchstens zwei Summanden),
  dann `c·√q = √(c²q)` und Gleichheit der Radikanden mit `field_simp`.
- „Vorhandenes zuerst“: Mein Hilfslemma `(m+1−l)·(m+1)^{(l)} = (m+1)·m^{(l)}` habe ich wieder **gestrichen**, weil
  Mathlib es als `Nat.succ_descFactorial` hat; das wird jetzt direkt verwendet. Weitere Hilfslemmata gibt es nicht.
- Literatur in der Moduldoku, Abschnitt iv:
  „D. A. Varshalovich, A. N. Moskalev, V. K. Khersonskii, *Quantum Theory of Angular Momentum: Irreducible Tensors,
  Spherical Harmonics, Vector Coupling Coefficients, 3nj Symbols*, World Scientific (1988), Table 8.1, p. 271.“
  - **Fundstelle für Daniels Prüfung:** `~/ensdf/sources_3j6j/9789814415491.pdf`.
    - Titel, Untertitel und Autoren vom Titelblatt (PDF-S. 4; im Druck steht „3*nj* Symbols“).
    - Verlag „World Scientific“ steht ebenfalls auf dem Titelblatt.
    - Das **Jahr 1988 steht nicht auf dem Titelblatt**, sondern im Impressum (PDF-S. 5: „Copyright © 1988 by World
      Scientific Publishing Co. Pte. Ltd.“; das Open-Access-E-Book ist von 2021).
    - Tabelle 8.1 auf gedruckter S. 271 = PDF-S. 284.
  - Die Tabelle in physlib-Indizes übersetzt und gegen sympy geprüft: 160/160 Werte gleich (Schritt 3, (a)).
- **Korollare für m = n = 1** (nur notiert, die vorhandenen Lemmas werden nicht ersetzt). Mit √(1/2) = 1/√2 ergeben
  sich alle sechs Werte für ½ ⊗ ½ als Spezialfälle:
  - `cgCoefficient_stretched` (m = n = 1) aus `add_half_up` mit l = 0;
  - `triplet_zero_down` aus `add_half_up` mit l = 1;
  - `triplet_zero_up` aus `add_half_down` mit l = 0;
  - `triplet_minus` (#2006) aus `add_half_down` mit l = 1;
  - `singlet_down` aus `sub_half_up` mit l = 0;
  - `singlet_up` aus `sub_half_down` mit l = 0.

  Von Hand nachgerechnet, nicht in Lean.

**3b, Inhalt** (`PhyslibAlpha/QuantumMechanics/QubitGates.lean`, Namespace `PhyslibAlpha.Qubit`, kein Namenskonflikt mit
QuantumInfos `Qubit.*`):
- `ry (c s : ℝ) (h : c ^ 2 + s ^ 2 = 1) : 𝐔[Qubit]` mit Matrix `!![c, −s; s, c]`; die Unitarität steckt im Element.
- `ry_apply`: die Matrix, per `rfl`.
- `blockDiagonal_mem_unitaryGroup (g : ι → 𝐔[k])`: Mathlibs `Matrix.blockDiagonal` von Unitären ist unitär.
- `multiplex (g : ι → 𝐔[k]) : 𝐔[ι × k]`, also Σ_r |r⟩⟨r| ⊗ g r. Das ist `reindex prodComm` von `blockDiagonal`,
  weil Mathlibs Blockindex hinten steht und unser Register vorn.
- `multiplex_apply` (@[simp]): Eintrag `if r = r' then g r q q' else 0`.
- Allgemein für beliebige endliche `ι` und `k`; für 3c dann `ι = Fin (m+1)`, `k = Qubit`.
- „Vorhandenes zuerst“:
  - In Mathlib gibt es `Matrix.blockDiagonal` mit `blockDiagonal_conjTranspose`, `blockDiagonal_mul`, `blockDiagonal_one`
    und `blockDiagonalRingHom`, aber **kein** Lemma zur Unitarität.
  - In QuantumInfo gibt es nichts Blockdiagonales.
  - Deshalb ist `blockDiagonal_mem_unitaryGroup` neu, ein Fünfzeiler über genau diese Mathlib-Lemmas.
  - Die Unitarität von `multiplex` verwendet dasselbe `reindexAlgEquiv`-Argument wie `CH21_mem_unitaryGroup` in #2007,
    hier inline.
- Keine Literatur, nur ein Verweis auf `QuantumInfo.States.Pure.Qubit`.

**Einzeiler über vorhandene Lemmata (Meldung):** `ry_apply` ist `rfl`. `multiplex_apply` ist ein `simp` über
`blockDiagonal_apply'`. Beide sind Rechenlemmas für spätere Beweise, keine Umschreibung eines vorhandenen Lemmas.
Daniel entscheidet, ob `ry_apply` bleibt.

**Stichpunkte für Daniels PR-Beschreibungen** (Inhalt, Daniel formuliert selbst).
- PR 3a (`cg-jhalf-values`):
  - die vier CG-Koeffizienten für die Kopplung eines beliebigen Spins j₁ = m/2 mit Spin ½, in geschlossener
    Wurzelform;
  - gewonnen als Spezialisierung der vorhandenen geschlossenen Formel `cgCoefficient_closed`;
  - Condon–Shortley-Phase, Vorzeichen nur bei J = j₁ − ½, m₂ = +½;
  - Werte stimmen mit Varshalovich et al., Tab. 8.1, überein (Literatur in der Moduldoku);
  - enthält die vorhandenen ½ ⊗ ½-Werte als Spezialfälle (nicht ersetzt);
  - +103 Zeilen, nur `ClebschGordanFormula.lean`;
  - Grundlage für den j × ½-Schaltkreis.
- PR 3b (`cg-ry`):
  - die reelle Rotation Ry eines Qubits, gegeben durch (cos, sin) statt Winkel, damit Wurzelwerte ohne
    Trigonometrie gehen;
  - das vom Register gesteuerte Gatter Σ_r |r⟩⟨r| ⊗ g_r (Multiplexer) für beliebige Register und Ziele, unitär über
    Mathlibs `blockDiagonal`;
  - lokal in PhyslibAlpha, QuantumInfo unverändert;
  - 99 Zeilen, neue Datei;
  - Baustein für den j × ½-Schaltkreis.
- Danach 3c auf 3a + 3b (+ #2007).

## Schritt 3c (01.11. abends, nur lokal, kein Push, kein PR)

**Branch `cg-jhalf-circuit`, Commit df5d628e** „feat(PhyslibAlpha): a circuit for the Clebsch-Gordan coefficients of a
spin j and a spin 1/2“.
- Aufgebaut auf `cg-circuit-half-half` (6f630bd0); lokal gemergt mit `cg-jhalf-values` (0db37cec, Merge 672799d5) und
  `cg-ry` (dafef917, Merge 87cd6676). Keine Konflikte, nicht gepusht.
- Neue Datei `PhyslibAlpha/QuantumMechanics/AngularMomentum/ClebschGordanCircuitHalf.lean` (221 Zeilen) + 1 Import.
- `check_pr.sh` 11/11 OK, `ci_physlib.sh` 11/11 OK, 0 sorry, alle Dateien des Stapels.

**Inhalt.**
- Register `Fin (m+1) × Qubit`, wie von Daniel entschieden.
- `cHalf m r = √((m+1−r)/(m+1))`, `sHalf m r = √(r/(m+1))`, `cHalf_sq_add_sHalf_sq`.
- `rotHalf m := multiplex (r ↦ ry (cHalf m r) (sHalf m r) _)`: Ry auf dem Qubit, vom Register gesteuert.
- `shiftHalf m`: `blockDiagonal` über das Qubit. Block |0⟩ ist `1`, Block |1⟩ ist
  `(finRotate (m+1)).permMatrix`, also r ↦ r − 1 zyklisch in den Spalten.
  - Vorhandenes genutzt: Mathlib `finRotate`, `coe_finRotate`, `Equiv.Perm.permMatrix`;
    QuantumInfo `Equiv.Perm.permMatrix_mem_unitaryGroup`; aus 3b `blockDiagonal_mem_unitaryGroup`.
  - Der Mathlib-Blockindex steht hinten, hier ist das gerade das Qubit, deshalb ist kein `reindex` nötig.
- `cgKHalf`, `cgLHalf`, `cgMatrixHalf m := of fun p q => cgCoefficient m 1 (cgKHalf q) (cgLHalf q) p.1 p.2`. Die
  Werte werden nicht neu hingeschrieben. Spaltenbelegung wie im Plan:
  - (r,0) ↦ J = j+½, l = r;
  - (0,1) ↦ J = j+½, l = m+1;
  - (r,1) ↦ J = j−½, l = r−1.
- `shiftHalf_mul_rotHalf_apply` ist das Eintragslemma; `finRotate_eq_iff` übersetzt `a + 1 = r` zyklisch in Werte.
- **`shiftHalf_mul_rotHalf : (shiftHalf m).val * (rotHalf m).val = cgMatrixHalf m` für alle m.** Der allgemeine Beweis
  ging durch, ein Rückfall auf m = 2, 3 war nicht nötig.
  - Beweis: vier Fälle (b, q).
  - Die Nicht-Null-Einträge kommen aus den vier 3a-Lemmas `cgCoefficient_add_half_up/_down` und
    `cgCoefficient_sub_half_up/_down`, die Nullen aus der Gewichtsregel `cgCoefficient_eq_zero_of_ne`.
- Korollar `cgMatrixHalf_mem_unitaryGroup`.
- 1 × ½ (m = 2) als zwei `example`s:
  - der Schaltkreis auf `Fin 3 × Qubit`;
  - der konkrete Eintrag ⟨1 0 ½ ½ | 3/2 ½⟩ = √(2/3) als Konventionsprobe; geht mit `simp` + `norm_num` durch.
- Moduldoku nach Schema mit Basis- und Spaltenbelegung. Keine Literatur, nur Verweise auf die physlib-Dateien.

**Hinweise für Daniel.**
- Der PR für 3c braucht #2006, #2007, #2009 und #2010 auf master, dann wird er auf master neu aufgesetzt (nur die
  neue Datei + Import, etwa 221 Zeilen). Der lokale Branch enthält die Merges nur zum Bauen.
- `finRotate_eq_iff` ist ein kleines Fin-Lemma im Namespace `PhyslibAlpha.Sl2`; in Mathlib gibt es keins dieses
  Namens. Es könnte auch nach `Mathematics` oder inline. Daniel entscheidet.
- Für m = 1 ergibt sich die ½ ⊗ ½-Matrix in anderer Spaltenreihenfolge als in #2007 (T₊₁, T₋₁, T₀, S statt T₊₁, T₀,
  T₋₁, S) und mit Ry(π/2)-artigem Block statt H. Das ist kein Widerspruch, beide Sätze stehen nebeneinander.

**Stichpunkte für Daniels PR-Beschreibung (3c)** (Inhalt, Daniel formuliert selbst):
- Schaltkreis für die CG-Basiswechselmatrix eines beliebigen Spins j = m/2 mit Spin ½, auf einem Register mit 2j+1
  Zuständen und einem Qubit;
- zwei Gatter: vom Register gesteuerte Ry-Rotationen mit cos/sin = √((m+1−r)/(m+1)), √(r/(m+1)), danach die
  vom Qubit gesteuerte zyklische Verschiebung des Registers;
- Satz für alle m: das Produkt ist genau die Matrix der `cgCoefficient m 1`-Werte; Korollar unitär;
- 1 × ½ als Beispiel (m = 2), mit einem konkreten Eintrag √(2/3) als Konventionsprobe;
- baut auf #2009 (Werte), #2010 (Ry, Multiplexer) und #2007 (½ ⊗ ½) auf; nutzt `finRotate`/`permMatrix` aus
  Mathlib/QuantumInfo;
- eine neue Datei, etwa 221 Zeilen.

## Stand 01.11. spät

- **#2009 offen** (`cg-jhalf-values`, 0db37cec), nur von master abhängig.
- **#2010 offen** (`cg-ry`, dafef917), nur von master abhängig.
- Beide erfasst der PR-Check automatisch über die dynamische API-Suche.

02.11.: **#2006 gemergt** (11:36 UTC, `e92c18ab`), **#2009 gemergt** (11:51 UTC, `1640f520`). Offen sind #2007 (Blocker #2006 erledigt) und #2010.

## Review #2010 (02.11., nur Bestandsaufnahme, nichts geändert, nichts gepusht)

Kommentar von jstoobysmith (02.11. 11:56 UTC): „I'd be happy to merge this, but see #1960. Might be better to
integrate this directly into stuff in ./Physlib or already in ./PhyslibAlpha“.
Issue #1960 (offen seit 25.10., Labels `help-wanted`, `priority: High`): „Merge ./QuantumInfo into ./Physlib … while
correctly taking care of the integration of the foundations“.

### (a) Stand von #1960 auf master (origin/master, Abfrage 02.11.)

- **Nichts verschoben.**
  - `git log --diff-filter=R` findet keinen Commit, der QuantumInfo-Dateien nach Physlib bewegt.
  - Die Commits mit „QuantumInfo“ im Titel sind alle Arbeiten *in* QuantumInfo (zuletzt #1983, #1957, #1939, #1921).
- **Kein Plan, kein Zielordner:**
  - Das Issue hat keinen Kommentar und keine Unteraufgaben.
  - Kein PR verweist auf 1960 (GitHub-Suche „1960“: nur das Issue selbst).
- Hinweise auf die Richtung gibt es in Physlib selbst:
  - **`Physlib/QuantumMechanics/Qubit/API-map.md`** (aus #1501/#1807). Die API-Karte für Qubits liegt schon in Physlib.
    Ihre „Lean References“ zeigen aber alle auf `QuantumInfo/States/Pure/Qubit.lean`, `Braket.lean`,
    `BlochSphere.lean`, `BargmannInvariant.lean`. Lean-Dateien liegen in diesem Ordner noch nicht.
  - Die Karte führt als **[TODO]** genau Dinge, die wir gebaut haben:
    - „The rotation gates about the three coordinate axes, together with a phase, decompose an arbitrary single-qubit
      unitary …“ (Z. 36), das passt zu `ry` aus #2010;
    - „The singlet and triplet states of a pair of qubits split their state space into an antisymmetric line and a
      symmetric plane.“, das passt zu #2007;
    - „a single-qubit gate extends to a gate acting on one component of a register“, das passt zu `multiplex`.
  - `Physlib/QuantumMechanics/HilbertSpaces/FiniteTarget/Basic.lean`: Ein TODO nennt den Abgleich von
    `FiniteHilbertSpace` (𝓗[d]) mit QuantumInfo als Ziel („To match this with the results currently in the
    `QuantumInfo` part of the library …“).
- Offene PRs mit Qubit-/Gatter-Bezug (Suche `is:pr is:open QuantumInfo`, 57 Treffer):
  - #2008 (Sammybro11), `[QuantumInfo/StabilizerFormalism]: PauliGroups and CliffordGroups`, also **neu in
    QuantumInfo**;
  - #1139 (wock9000), Qubit-Ket mit Winkeln, QuantumInfo;
  - #1849 (naype888-cloud), Pauli-diagonale Qubit-Abbildungen, ProbabilisticTheory;
  - #2012 (RuthWangXuzhu), Ket, QuantumInfo.

  Andere bauen also weiter in QuantumInfo; es gibt keine Regel „nichts Neues in QuantumInfo“.
- Importe heute:
  - `Physlib` importiert QuantumInfo genau einmal (`Physlib/StatisticalMechanics/MicroCanonicalEnsemble/ThermoQuantities.lean`).
  - `PhyslibAlpha` importiert QuantumInfo auf master **gar nicht**. #2007 wäre der erste solche Import, ebenso 3c.

### (b) Vorhandene Infrastruktur in Physlib und PhyslibAlpha (ohne QuantumInfo)

- **Pauli-Matrizen:**
  - `Physlib/Relativity/PauliMatrices/Basic.lean:37` `pauliMatrix : Fin 1 ⊕ Fin 3 → Matrix (Fin 2) (Fin 2) ℂ`,
    dazu `:67` `pauliMatrix_selfAdjoint`, `:86` `pauliMatrix_mul_self`, `:98` `pauliMatrix_inv`, `:217`
    `pauliMatrix_anticommutator`;
  - `SelfAdjoint.lean`: Basis der selbstadjungierten 2×2-Matrizen (`pauliBasis`, `pauliBasis'`, `eq_sum_pauli`).

  Das ist Relativitäts-Kontext (Weyl-Spinoren), keine Gatter, aber derselbe Typ `Matrix (Fin 2) (Fin 2) ℂ`.
- **unitaryGroup-Lemmas:**
  - `Physlib/Mathematics/ForMathlib/DataStructures/Matrix/LieTrace.lean:167` `trace_unitary_conj`, `:175`
    `det_unitary_conj`, `:181` `exp_unitary_conj`, `:192` `det_exp_unitary_conj`, alle mit `U : unitaryGroup m 𝕂`.
    Das ist der natürliche Ort für allgemeine Matrix-/Unitär-Lemmas in Physlib.
  - `Physlib/Mathematics/ForMathlib/SchurTriangulation.lean:261` `schurTriangulationUnitary : unitaryGroup n 𝕜`.
  - `Physlib/Mathematics/Groups/SpecialUnitary/LieAlgebra/Adjoint.lean:234`: dort wird
    `Equiv.Perm.permMatrix ℂ σ⁻¹ ∈ unitaryGroup` **inline** bewiesen (drei Zeilen). Das zeigt, dass man das
    QuantumInfo-Lemma `permMatrix_mem_unitaryGroup` für 3c nicht braucht.
  - SU(n): `Physlib/Mathematics/Groups/SpecialUnitary/…` (`specialUnitaryGroup_le_unitaryGroup`, `conj`);
    SL(2,ℂ): `Physlib/Relativity/SL2C/CayleyKlein.lean`, `Cover.lean`.
- **blockDiagonal:** In Physlib nur `Physlib/Mathematics/Calculus/Wirtinger/Hessian.lean:218` (`blockDiagonal'` für
  Hesse-Matrizen). Ein Unitaritätslemma gibt es in Physlib, PhyslibAlpha, QuantumInfo und Mathlib nicht.
- **Qubit, Spin ½ als Gatter:** In Physlib/PhyslibAlpha gibt es **keinen** Lean-Typ `Qubit` und keine Gatter.
  Spin ½ gibt es nur darstellungstheoretisch (`StandardSl2Module ℝ 1`, `normVec`, CG-Dateien in PhyslibAlpha).
- **Hilbertraum endlicher Systeme:** `Physlib/QuantumMechanics/HilbertSpaces/FiniteTarget/Basic.lean`
  (`FiniteHilbertSpace d`, Notation `𝓗[d]`), `Physlib/QuantumMechanics/FiniteTarget.lean` (`FiniteTarget`,
  Zeitentwicklung).

### (c) Optionen für #2010 und Auswirkungen auf #2007 und 3c

**Wichtiger Befund zum Aufwand von (3):** `QuantumInfo/States/Pure/Qubit.lean` (276 Zeilen) zieht transitiv **14
QuantumInfo-Module mit zusammen 5025 Zeilen** nach. Es benutzt davon aber nur die Notation `𝐔[·]` (14×) und
`⊗ᵤ`/`unitary_kron` (4×). Die lange Kette kommt allein daher, dass `HermitianMat/Unitary.lean` `HermitianMat.Inner`
importiert. Importiert wird `Qubit.lean` nur von `QuantumInfo.lean`.

**(1) QubitGates ohne QuantumInfo.**
- `ry` als Element von `Matrix.unitaryGroup (Fin 2) ℂ` und `multiplex` in `Matrix.unitaryGroup (ι × k) ℂ`, ohne
  `𝐔`-Notation, ohne Import aus QuantumInfo. `Fin 2` ist definitorisch gleich `Qubit` (abbrev).
- `blockDiagonal_mem_unitaryGroup` nach `Physlib/Mathematics/ForMathlib/DataStructures/Matrix/` (neue kleine Datei
  neben `LieTrace.lean`); das wäre dann ein eigener Physlib-PR.
- Ort für `ry`/`multiplex`: `PhyslibAlpha/QuantumMechanics/Qubit/Rotations.lean` o. ä., passend zur Physlib-API-Karte.
- Aufwand etwa 0,5 Tag. #2010 schrumpft auf zwei kleine PRs.
- Trifft #2007 nicht direkt: Es braucht `H`, `CNOT` und `C[·]` aus QuantumInfo. Ohne QuantumInfo müsste man diese
  Gatter duplizieren, und Duplikate wären schlecht.
- 3c: Ersetzt man `permMatrix_mem_unitaryGroup` inline (wie in `Adjoint.lean:234`), ist 3c QuantumInfo-frei.

**(2) In eine vorhandene Datei integrieren.**
- In Physlib/PhyslibAlpha gibt es keine Lean-Datei für Qubits. Die einzige echte „Heimat“ von `ry` ist
  `QuantumInfo/States/Pure/Qubit.lean` (die API-Karte nennt Rotationsgatter dort als TODO).
- Das hieße QuantumInfo anfassen, was Daniel bisher nicht wollte; und es widerspricht dem Hinweis, nicht mehr in
  QuantumInfo zu bauen.
- Für `blockDiagonal_mem_unitaryGroup` wäre `LieTrace.lean` thematisch falsch (Spur/Exp); eine neue Nachbardatei passt
  besser.
- Als eigenständige Option daher nicht sinnvoll.

**(3) Bei #1960 helfen: `Qubit.lean` zuerst nach Physlib.**
- Schritt 3a: Neue Physlib-Datei, etwa `Physlib/Mathematics/ForMathlib/DataStructures/Matrix/Unitary.lean`, mit
  `star_kron`, `kron_unitary`, `unitary_kron`/`⊗ᵤ`, der Notation `𝐔[·]` und `blockDiagonal_mem_unitaryGroup`, rund
  60 Zeilen. `QuantumInfo/ForMathlib/HermitianMat/Unitary.lean` importiert sie dann statt eigener Definitionen.
- Schritt 3b: `Qubit.lean` (276 Zeilen) wandert nach `Physlib/QuantumMechanics/Qubit/Basic.lean`.
  - Dazu `ry` und `multiplex` aus #2010; das füllt das API-Karten-TODO „rotation gates“.
  - Die „Lean References“ der API-Karte und `QuantumInfo.lean` müssen angepasst werden.
- Danach importieren #2007 und 3c nur noch Physlib, und PhyslibAlpha bleibt QuantumInfo-frei.
- Aufwand: 1–2 Tage plus Abstimmung.
- Risiken:
  - Das ist Fremdcode (A. Meiburg), und die Namensräume `Qubit` und `Matrix` werden in Physlib neu eingeführt.
  - Es kann mit #2008, #1139 und #2012 kollidieren, die Qubit- bzw. Ket-Code in QuantumInfo ändern.
  - Ohne Zustimmung der Maintainer sollte man das nicht anfangen.

**Betroffenheit:**

| | (1) | (3) |
|---|---|---|
| #2010 | wird QuantumInfo-frei, in 2 kleine PRs geteilt | wird Teil von „Qubit nach Physlib“ |
| #2007 | **bleibt** mit QuantumInfo-Import (erster PhyslibAlpha→QuantumInfo-Import), sonst Gatter duplizieren | wird QuantumInfo-frei, nachdem Qubit.lean verschoben ist |
| 3c | QuantumInfo-frei, wenn `permMatrix_mem_unitaryGroup` inline bewiesen wird | QuantumInfo-frei |

**Empfehlung: (3), aber erst nach Rückfrage. Bis dahin #2010 nicht ändern.**
- Der Maintainer hat ausdrücklich „integrate into ./Physlib“ geschrieben, und #1960 hat hohe Priorität ohne Plan.
  Der Qubit-Teil ist ein natürlicher und kleiner erster Schritt: Er braucht nur Notation und Kronecker, nicht die
  HermitianMat-Kette.
- Er löst #2007, #2010 und 3c auf einmal und füllt TODOs der Physlib-API-Karte, statt in PhyslibAlpha eine zweite
  Gatterwelt aufzumachen.
- Vorher sollte Daniel bei jstoobysmith nachfragen. Mögliche Inhalte, die Daniel selbst auf Englisch formuliert:
  - Ist als erster #1960-Schritt erwünscht, `Qubit.lean` samt einer kleinen Unitär- und Kronecker-Datei nach
    `Physlib/QuantumMechanics/Qubit/` zu verschieben und Ry/Multiplexer dort zu ergänzen?
  - Gibt es einen Wunsch-Zielort oder ein Namensschema (`Qubit` vs. `QuantumMechanics.Qubit`)?
  - Soll A. Meiburg einbezogen werden?
- **Rückfall, falls das nicht erwünscht ist oder zu lange dauert: (1).** Dann #2010 als zwei kleine PRs:
  `blockDiagonal_mem_unitaryGroup` nach `Physlib/Mathematics/ForMathlib/DataStructures/Matrix/`, `ry`/`multiplex`
  QuantumInfo-frei in PhyslibAlpha. #2007 bliebe vorerst mit QuantumInfo-Import.

## Zulip: Tom Diem / vorhandene API (03.11., nur gelesen, nichts geändert)

Thread „First step towards merging QuantumInfo into Physlib: the Qub…“ (Kanal Physlib). Die Antwort von Joseph
Tooby-Smith, wie Daniel sie wiedergibt (den Zulip-Thread habe ich nicht selbst gelesen): „1) Should we integrate this
directly with the work that Tom Diem is doing? 2) How can we best make use of the API which already exists in
./Physlib/QuantumInfo. I agree that here the move should be minimal as possible.“

### (a) Was mit „./Physlib/QuantumInfo“ gemeint sein kann

Einen Ordner `Physlib/QuantumInfo` gibt es auf origin/master **nicht** (`git ls-tree -d origin/master
Physlib/QuantumInfo` ist leer). Kandidaten:

- **`Physlib/ProbabilisticTheory/`** (Tom Ole Diem, alle Dateien von 2026). Allgemeine, abstrakte
  Wahrscheinlichkeitstheorie auf Ordnungseinheitsräumen, nicht speziell quantenmechanisch:
  - `OrderUnit/Basic.lean:55` `class OrderedVectorSpace`, `:61` `class OrderUnitSpace` (Observablenräume);
  - `State/Basic.lean:44/47` Notationen `𝓟[𝕜, A]` (positive Funktionale) und `𝓢[𝕜, A]` (Zustände = unitale positive
    Funktionale), `:63` `comap`;
  - `Effect/Basic.lean:51` `abbrev Effect E := Set.Icc 0 1`;
  - `Channel/Basic.lean:54` `structure UnitalPositiveLinearMap`, Notation `→ₚ₁`, also Kanäle;
    `Channel/Reversible.lean:63` `structure Reversible E F extends E ≃ₗ[ℝ] F` (ordnungserhaltend, unital, mit
    `refl/symm/trans`);
  - `Weight/Basic.lean:54` `Weight`; `LocalNet/Basic.lean:71` `structure LocalNet`.
- **`Physlib/QuantumMechanics/HilbertSpaces/FiniteTarget/Basic.lean`**:
  - `:62` `structure FiniteHilbertSpace (d) [Fintype d] [DecidableEq d]` mit Notation `𝓗[d]`, dazu `:75`
    `equivEuclidean`, `:106` `linearEquivEuclidean`, `:140` `isometryEquivEuclidean`, `:151` `basisFun`;
  - TODO in der Moduldoku: „To match this with the results currently in the `QuantumInfo` part of the library …“.
    Das ist die ausdrücklich vorgesehene Brücke zu QuantumInfo.
- **`Physlib/QuantumMechanics/FiniteTarget.lean`** (J. Tooby-Smith): `structure FiniteTarget` (endlichdimensionaler
  Hilbertraum mit selbstadjungiertem Hamiltonoperator, Zeitentwicklung).
- **PhyslibAlpha `…/HilbertSpaces/FiniteTarget/`**:
  - `Operators.lean` (C⋆-Instanzen auf `𝓗[d] →L[ℂ] 𝓗[d]`);
  - `Product.lean:80/90` `onFst`/`onSnd`, das ist das Analogon zu „Gatter auf einem Faktor“;
  - `ProductState.lean:74` `prodVec`.
- **PhyslibAlpha `ProbabilisticTheory/CStarAlgebra/…`** (u. a. `QuantumChannel.lean`, `Stinespring/…`, `GNS…`).
- **Tom Diems offene PRs** (alle gegen master):
  - #1958 „observables, states and tracial states of a star algebra“ (aktualisiert 02.11.): neu
    `Physlib/ProbabilisticTheory/StarAlgebra/State.lean`, `…/Traciality.lean`, `…/CStarAlgebra/OrderUnit.lean`
    (letztere aus PhyslibAlpha nach Physlib verschoben).
  - #1959 „vector states and density operator states of a Hilbert space“ (Stand 25.10.; enthält die Dateien aus
    #1958 mit):
    - `State/HilbertSpace.lean`: `ofVec` ist der Vektorzustand ⟪ψ, x ψ⟫ eines Einheitsvektors, `rayState` sind reine
      Zustände als Strahlen;
    - `State/FiniteHilbertSpace.lean`: `ofDensity` (Dichteoperator-Zustände), `maximallyMixed`;
    - allgemein für `H` mit `InnerProductSpace ℂ H`, also auch für `𝓗[d]`.
  - #1954 „interactions on a local net“: `Channel/Norm.lean`, `LocalNet/Interaction/…`. Für Qubits nicht relevant.

**Vermutung:** Mit „./Physlib/QuantumInfo“ ist am ehesten `Physlib/ProbabilisticTheory` gemeint (Tom Diems Arbeit, der
in Physlib liegende Teil der Quanteninformations-Grundlagen), eventuell zusammen mit `FiniteHilbertSpace`/`𝓗[d]`.
Ein Tippfehler für „./QuantumInfo“ ist auch möglich. Das sollte Daniel nachfragen.

### (b) Inhalt von `QuantumInfo/States/Pure/Qubit.lean` und natürliche Entsprechungen

Inhalt (276 Zeilen, A. Meiburg, Namespace `Qubit`):
- `:67` `abbrev Qubit := Fin 2`;
- `:75` Taktik `matrix_expand`;
- `:111–131` Gatter `Z, X, Y, H, S, T : 𝐔[Qubit]`, als Matrizen in `Matrix.unitaryGroup Qubit ℂ`;
- `:140–195` Identitäten (`Z_sq` … `T_sq`, `X_Y_anticomm`, `Y_Z_anticomm`, `Z_X_anticomm` als `theorem`,
  `H_mul_X_eq_Z_mul_H`, `H_mul_Z_eq_X_mul_H`, `S_Z_comm`, `T_Z_comm`, `S_T_comm`);
- `:206` `controllize (g : 𝐔[k]) : 𝐔[Qubit × k]` mit Notation `C[g]`; `:226` `CNOT := C[X]`; `:229` `CNOT_matrix`;
- Rechenlemmas zu `controllize`; `X_controllize_X` benutzt `⊗ᵤ`.

**Keine Ket/Bra:** Zustände stehen in `Braket.lean`, das `Qubit.lean` weder importiert noch benutzt. `Qubit.lean` ist
also reine Matrix- und Gatterebene. Außer dem Wurzel-Import in `QuantumInfo.lean` wird die Datei von nichts
importiert.

Entsprechungen in (a):

| Qubit.lean | natürliche Entsprechung | Bemerkung |
|---|---|---|
| `Qubit := Fin 2` | `𝓗[Qubit] = FiniteHilbertSpace (Fin 2)` als Zustandsraum | `Qubit` ist nur der Indextyp; der Hilbertraum wäre `𝓗[Qubit]` |
| Gatter in `𝐔[Qubit]` (Matrizen) | unitäre Operatoren auf `𝓗[Qubit]` über `basisFun` (Mathlib: `Matrix.toEuclideanCLM`, `Matrix.UnitaryGroup.toLinearEquiv`, `isometryEquivEuclidean`) | Brücke Matrix → Operator |
| Gatter als Zeitentwicklung | `Reversible` (`Channel/Reversible.lean:63`) auf dem Observablenraum, Heisenberg-Bild x ↦ U* x U | erst mit #1958 (Observablen einer ⋆-Algebra) bequem |
| `controllize`, `⊗ᵤ` | `onFst`/`onSnd` (PhyslibAlpha `Product.lean`) für Operatoren auf `𝓗[α × β]` | kontrollierte Gatter haben dort noch kein Gegenstück |
| (Zustände, nicht in Qubit.lean) | `ofVec`, `rayState`, `ofDensity` aus #1959 | betrifft `Braket.lean`, nicht diesen Umzug |

### (c) Vorschlag für einen minimalen Umzug, der zu (a) passt (nur Plan)

- **Matrix-Ebene bleibt, wie sie ist.** `Qubit`, die Gatter als Elemente von `Matrix.unitaryGroup`, `controllize`,
  `CNOT`, `matrix_expand` und `⊗ᵤ` werden 1:1 verschoben, ohne Typänderung. Das ist der vorbereitete Branch
  `qubit-to-physlib` (Commit c45d679f, lokal). Ziel ist `Physlib/QuantumMechanics/Qubit/Basic.lean`, dort, wo die
  Qubit-API-Karte schon liegt. Damit ist der Umzug minimal, wie Joseph es wünscht, und A. Meiburg kann ihn leicht
  prüfen.
- **Später als Brücke, eigene kleine PRs, nicht im Umzug:**
  - (i) Gatter-Matrix als unitärer Operator: für `U : 𝐔[d]` ein Operator `𝓗[d] →L[ℂ] 𝓗[d]` (bzw. Element von
    `unitary (𝓗[d] →L[ℂ] 𝓗[d])`), der auf `basisFun` die Matrixeinträge hat; Homomorphie (`U * V ↦ ∘`) und
    Unitarität. Ort: neben `FiniteTarget/Basic.lean`, oder in PhyslibAlpha neben `Operators.lean`.
  - (ii) Kontrollierte Gatter und `⊗ᵤ` gegen `onFst`/`onSnd` auf `𝓗[α × β]`.
  - (iii) Gatter als reversible Kanäle (`Reversible`, Konjugation x ↦ U* x U), sobald #1958 gemergt ist.
  - (iv) Zustände: `Braket.lean`-Kets ↔ `ofVec`/`rayState` aus #1959. Das wäre ein eigener Schritt von #1960,
    zusammen mit Tom Diem.
- **Mit Tom Diem integrieren** heißt dann: Den Umzug nicht an #1958/#1959 koppeln, weil sie andere Dateien betreffen
  und kein Konflikt besteht. Die Brücken (i)–(iv) aber so planen, dass sie seine Typen (`𝓢`, `Reversible`, `ofVec`)
  benutzen und keine Parallelstrukturen aufbauen.
- **Folgen für unsere PRs:** #2010 (Ry, Multiplexer), #2007 und 3c bleiben auf der Matrix-Ebene und ziehen nach dem
  Umzug nur die Pfade nach (Plan in Abschnitt „Schritt 4“). Die Operator-Brücke (i) wäre der natürliche nächste PR,
  wenn Joseph eine Anbindung an `𝓗[d]` wünscht.

### (d) Stichpunkte für Daniels Zulip-Antwort (Inhalt, Daniel formuliert selbst auf Englisch)

- Danke, einverstanden: Der erste Schritt soll ein reiner Umzug sein, ohne neue Mathematik, damit Alex ihn leicht
  prüfen kann.
- Rückfrage: Was ist mit „./Physlib/QuantumInfo“ gemeint? Auf master gibt es diesen Ordner nicht. Ist
  `Physlib/ProbabilisticTheory` (Tom Diems Zustände, Effekte, Kanäle) gemeint, oder `FiniteHilbertSpace`/`𝓗[d]`?
- Beobachtung: `Qubit.lean` ist reine Matrixebene: `Fin 2`, Gatter in `Matrix.unitaryGroup`, kontrollierte Gatter,
  keine Zustände. Es braucht aus QuantumInfo nur die Notation `𝐔[·]` und das Kronecker-Produkt unitärer Matrizen.
  Der Umzug ist deshalb klein: eine neue kleine Datei in `Physlib/Mathematics/ForMathlib/…` und die verschobene
  Datei unter `Physlib/QuantumMechanics/Qubit/Basic.lean`, neben der vorhandenen API-Karte.
- Vorschlag zur Integration mit Tom Diems Arbeit: nicht im Umzug, sondern danach als kleine Brücken-PRs, mit seinen
  Typen statt eigener:
  - Gatter-Matrix als unitärer Operator auf `𝓗[2]`;
  - Gatter als reversibler Kanal, sobald #1958 drin ist;
  - Kets ↔ Vektorzustände (#1959).
- Frage an Tom Diem (ggf. erwähnen, Daniel entscheidet): Passt diese Reihenfolge zu seinen Plänen für #1958/#1959,
  und gibt es eine bevorzugte Form für unitäre Operatoren/Zeitentwicklung, an die die Gatter andocken sollen?
- Alex soll Gelegenheit haben, den Umzugs-PR zu kommentieren, wie Joseph vorgeschlagen hat.

## Schritt 4: Qubit nach Physlib (03.11., lokal, kein Push, kein PR)

Anlass: jstoobysmith auf #2010 (03.11.): „I think this sounds the right scope. I think we should give Alex the option to
comment on the PR moving things into Physlib. But I think moving the Qubit results is a good first step. This file
name looks right to me.“ Grundsatz: reiner Umzug, keine neue Mathematik.

### (1) Vorab geprüft

- **Bisherige Umzüge:** reine `git mv` ohne deprecated-Aliase oder Re-Export-Stubs, die Importeure werden direkt
  umgestellt. Beispiele: #2021 `Physlib/Relativity/PauliMatrices/* → Bispinors/Pauli/*`, #1968 GaugeGroup, #1873
  AngularMomentum, #1780 Causality. Ein `deprecated_module` und `@[deprecated]` gibt es in Physlib und QuantumInfo
  nicht (0 Treffer).
- **Importregeln:**
  - Physlib → QuantumInfo ist erlaubt, bisher 1 Datei (`StatisticalMechanics/MicroCanonicalEnsemble/ThermoQuantities.lean`).
  - QuantumInfo → Physlib ist erlaubt, bisher 2 Dateien (`ClassicalInfo/Capacity.lean`, `States/Mixed/Fidelity.lean`).
  - `noAlphaImports` verbietet nur Importe aus PhyslibAlpha.
  - `forMathlib_lint`: Dateien in `Physlib/Mathematics/ForMathlib/` dürfen nur Mathlib importieren und müssen
    außerhalb von ForMathlib benutzt werden.
  - `check_file_imports` prüft `Physlib.lean`/`QuantumInfo.lean` auf Vollständigkeit und Sortierung.
- **Lint-Status:**
  - `QuantumInfo/ForMathlib/HermitianMat/Unitary.lean` steht in `scripts/lint/exemptions/LinterExemption.txt` und ist
    daher von allen Lintern ausgenommen. `Qubit.lean` steht dort nicht und war also schon voll gelintet.
  - Die drei `theorem`s `Qubit.X_Y_anticomm`, `Y_Z_anticomm`, `Z_X_anticomm` stehen in
    `scripts/lint/exemptions/Theorems.txt` im Abschnitt `[QuantumInfo]` und müssen nach `[Physlib]`.
- **Importeure (origin/master 4c943e61):**
  - `QuantumInfo/States/Pure/Qubit.lean` wird nur von `QuantumInfo.lean` importiert.
  - `HermitianMat/Unitary.lean` wird importiert von `QuantumInfo.lean`, `HermitianMat.lean`, `HermitianMat/Peierls.lean`,
    `HermitianMat/Rpow.lean`, `MatrixNorm/TraceNorm.lean` und `States/Pure/Qubit.lean`.
  - Den Namen `Matrix.unitary_kron` benutzt nur `HermitianMat/Rpow.lean` (3×), die Notation `⊗ᵤ` außerdem `Entropy/DPI.lean`.

### (2)–(4) Umsetzung: Branch `qubit-to-physlib`, Commit **eb4371e4** „refactor: move the qubit gates from QuantumInfo to Physlib“

Basis origin/master 4c943e61. 8 Dateien, +97 −48:

| Datei | Änderung |
|---|---|
| `Physlib/Mathematics/ForMathlib/DataStructures/Matrix/UnitaryKronecker.lean` | **neu**, 82 Zeilen; Kopf „Copyright (c) 2025 Alex Meiburg … Authors: Alex Meiburg“, weil der Code von ihm ist. Inhalt aus `HermitianMat/Unitary.lean` verschoben: Notation `𝐔[n]`, `neg_unitary_val`, `star_kron`, `kron_unitary`, `unitaryKron` mit `⊗ᵤ`, `unitary_kron_apply`, `unitary_kron_one_one`. Importiert nur Mathlib (`Mathlib.Basic.Complex.Basic`, `…Matrix.Kronecker`, `…UnitaryGroup`). Neu sind Moduldoku nach Schema und Docstrings für `𝐔[·]`, `⊗ᵤ`, `unitaryKron` (vom Physlib-Linter verlangt). |
| `QuantumInfo/ForMathlib/HermitianMat/Unitary.lean` | der Block oben gelöscht, stattdessen `public import` der neuen Datei. Keine Duplikate. Rest (`unitary_row_sum_norm_sq`, `HermitianMat`-Lemmas) unverändert. |
| `QuantumInfo/States/Pure/Qubit.lean → Physlib/QuantumMechanics/Qubit/Basic.lean` | **`git mv`**, Git erkennt die Umbenennung (Historie bleibt). Namespace `Qubit`, Copyright und Autor unverändert. Nur der Import geändert: statt `QuantumInfo.ForMathlib.HermitianMat.Unitary` jetzt `Mathlib.Analysis.Complex.Basic` und die neue Datei (vorher kamen ℂ als ℝ-Algebra und `√` transitiv über die HermitianMat-Kette). |
| `QuantumInfo/ForMathlib/HermitianMat/Rpow.lean` | 3× `Matrix.unitary_kron` → `Matrix.unitaryKron` (s. u.) |
| `Physlib.lean`, `QuantumInfo.lean` | Importlisten (neu sortiert eingetragen bzw. entfernt) |
| `scripts/lint/exemptions/Theorems.txt` | die 3 `Qubit.*_anticomm` von `[QuantumInfo]` nach `[Physlib]` |
| `Physlib/QuantumMechanics/Qubit/API-map.md` | „Lean References“ 1, 3, 4, 5 auf `Physlib/QuantumMechanics/Qubit/Basic.lean` |

**Einzige inhaltliche Abweichung vom reinen Umzug, bitte prüfen:**
- Der Physlib-Linter `defsWithUnderscore` (in QuantumInfo durch die Ausnahmeliste abgeschaltet) beanstandet die
  Definition `Matrix.unitary_kron`. Physlib benutzt `@[nolint defsWithUnderscore]` nirgends.
- Ich habe deshalb nur die **Definition** in `Matrix.unitaryKron` umbenannt und die 3 Stellen in `Rpow.lean`
  nachgezogen. Die Lemma-Namen `unitary_kron_apply` und `unitary_kron_one_one` und die Notation `⊗ᵤ` bleiben
  unverändert, weil der Linter bei Lemmas keine Unterstriche beanstandet.
- Alternativen für Daniel/Alex:
  - (a) so lassen;
  - (b) Lemmas konsistent `unitaryKron_apply`/`unitaryKron_one_one` nennen (mehr Änderungen in QuantumInfo);
  - (c) `@[nolint defsWithUnderscore]` und Name unverändert (wäre ein Präzedenzfall in Physlib).

**Checks** (nach dem amend, eb4371e4):
- `check_pr.sh` 11/11 OK, inkl. build_roots und theorem_lint.
- `ci_physlib.sh` 11/11 OK: `runPhyslibLinters`, `forMathlib_lint`, `check_file_imports`, `api_map_lint`.
- 0 sorry. Zusätzlich `lake build Physlib QuantumInfo PhyslibAlpha` vollständig OK.
- Erster Lauf vor dem Fix: `runPhyslibLinters` FEHLER mit 3 Meldungen: `unitary_kron` mit Unterstrich, `𝐔[·]` und
  `⊗ᵤ` ohne Docstring. Alle drei sind behoben.

### (5) Plan danach (nur Text)

- **#2010 neu auf `qubit-to-physlib`:**
  - `ry` und `multiplex` nach `Physlib/QuantumMechanics/Qubit/` als neue Datei, etwa `Rotation.lean` bzw.
    `Multiplex.lean` oder zusammen `Gates.lean`, nicht in Alex' `Basic.lean`. Die Physlib-API-Karte führt die
    Rotationsgatter als TODO; der Eintrag wäre dort nachzuziehen.
  - `blockDiagonal_mem_unitaryGroup` nach `Physlib/Mathematics/ForMathlib/DataStructures/Matrix/`. Weil es `𝐔[·]`
    benutzt, entweder in `UnitaryKronecker.lean` (dann ist der Dateiname zu eng, vielleicht `Unitary.lean`) oder als
    eigene Datei `UnitaryBlockDiagonal.lean`.
  - Danach gelten Physlib-Standards (strengere Review). Namespace für Ry/Multiplex dann `Qubit` statt
    `PhyslibAlpha.Qubit`.
  - #2010 auf GitHub entweder per Force-Push auf `cg-ry` umbauen (Daniel entscheidet) oder schließen und neu eröffnen
    mit Verweis auf den Umzugs-PR.
- **#2007** (offen, PhyslibAlpha, importiert `QuantumInfo.States.Pure.Qubit`):
  - Wird #2007 vor dem Umzug gemergt, muss der Umzugs-PR zusätzlich die Importzeile in
    `PhyslibAlpha/QuantumMechanics/AngularMomentum/ClebschGordanCircuit.lean` auf `Physlib.QuantumMechanics.Qubit.Basic`
    umstellen (1 Zeile). Sonst baut master nach dem Umzug nicht.
  - Wird der Umzug zuerst gemergt, muss #2007 vor dem Merge auf den neuen Pfad umgestellt werden.
  - Inhaltlich bleibt #2007 gleich.
- **3c (`cg-jhalf-circuit`, lokal):**
  - Importe auf `Physlib.QuantumMechanics.Qubit.*` umstellen.
  - `Equiv.Perm.permMatrix_mem_unitaryGroup` liegt weiter in `QuantumInfo/ForMathlib/Isometry.lean`. Entweder inline
    beweisen (3 Zeilen, wie `Physlib/Mathematics/Groups/SpecialUnitary/LieAlgebra/Adjoint.lean:234`), damit
    PhyslibAlpha QuantumInfo-frei bleibt, oder den QuantumInfo-Import behalten.
  - Danach auf master neu aufsetzen, sobald #2007, der Umzug und das neue #2010 drin sind.
- **Integration mit Tom Diem** (s. Abschnitt „Zulip“): erst nach dem Umzug, als Brücken-PRs.

### Stichpunkte für Daniels PR-Beschreibung (Umzug; Inhalt, Daniel formuliert selbst)

- Erster Schritt für #1960: Die Qubit-Gatter ziehen von `QuantumInfo/States/Pure/Qubit.lean` nach
  `Physlib/QuantumMechanics/Qubit/Basic.lean`, neben die vorhandene Qubit-API-Karte.
- Reiner Umzug, keine neue Mathematik. Code, Namespace `Qubit`, Copyright und Autor (A. Meiburg) unverändert. Die
  Datei ist per `git mv` verschoben, die Historie bleibt erhalten.
- `Qubit.lean` brauchte aus QuantumInfo nur die Notation `𝐔[·]` und das Kronecker-Produkt unitärer Matrizen. Diese
  Teile liegen jetzt in einer kleinen Datei `Physlib/Mathematics/ForMathlib/DataStructures/Matrix/UnitaryKronecker.lean`
  (nur Mathlib-Importe). `QuantumInfo/ForMathlib/HermitianMat/Unitary.lean` importiert sie, es gibt keine Duplikate.
- Einzige Namensänderung: Die Definition `Matrix.unitary_kron` heißt jetzt `Matrix.unitaryKron` (Physlib-Linter
  `defsWithUnderscore`); 3 Stellen in `HermitianMat/Rpow.lean` sind angepasst. Lemma-Namen und Notation `⊗ᵤ` bleiben.
- Theorem-Ausnahmen für die drei Antikommutator-Sätze von `[QuantumInfo]` nach `[Physlib]`; API-Karte aktualisiert.
- **Alex Meiburg soll den PR kommentieren können, wie von Joseph vorgeschlagen.** Ihn im PR erwähnen und bitten, den
  Umzug und die Umbenennung zu prüfen.
- Als Nächstes folgen Ry/Multiplexer (#2010) in `Physlib/QuantumMechanics/Qubit/` und danach Brücken zu Tom Diems
  `ProbabilisticTheory` bzw. `𝓗[d]`.

## Q1: Ry als Puls (04.11., nur Bestandsaufnahme)

Ziel (später): Brückenlemma „`ry c s` aus #2010/`cg-ry` in der (c, s)-Form ist die Zeitentwicklung eines Pulses um die
y-Achse mit Winkel θ, c = cos(θ/2), s = sin(θ/2)“. Heute nur Bestandsaufnahme, kein Lean-Code in Branches.

Stand der Quellen:
- physlib origin/master **4a0b4acf** (03.11.);
- Mathlib in physlibs Manifest **56a00585** (v4.35.0);
- `cg-ry` **dafef917**;
- Toms Draft #2023 Head **6efad7f1** (nur gelesen, als lokaler Ref `pr2023`).

### 1. Vorhandenes

**a) `Physlib/QuantumMechanics/FiniteTarget.lean` (4a0b4acf)**
- `:30` `structure FiniteTarget (H) (n)`: `hdim : finrank ℂ H = n`, `Ham : H →L[ℂ] H`, `Ham_selfAdjoint`. Der
  Hamiltonoperator ist also ein **Operator** auf einem abstrakten endlichdimensionalen Hilbertraum, keine Matrix.
- `:46` `unitaryTimeEvolution := UnitaryOneParameterGroup.ofSelfAdjoint (A := (ℏ : ℂ)⁻¹ • Ham)`.
- `:54` `unitaryTimeEvolution_generator : … .generator = (ℏ : ℂ)⁻¹ • Ham`.
- `:62` `timeEvolution t := unitaryTimeEvolution t`.
- `:64–65` `timeEvolution_eq_exp : timeEvolution t = NormedSpace.exp ((-(t : ℂ) * I / ℏ) • Ham)`. Das Vorzeichen ist
  **U(t) = exp(−i t H/ℏ)**.
- `:71` `timeEvolutionMatrix t b := LinearMap.toMatrix b b (timeEvolution t)`; `:76` `timeEvolutionMatrixStandard` mit
  `Module.finBasisOfFinrankEq` (Basis nicht kanonisch).
- **ℏ ist kein Parameter**: `Physlib/QuantumMechanics/PlanckConstant.lean:26`
  `def ℏ : {x : ℝ // 0 < x} := ⟨1.054571817e-34, _⟩` (SI-Wert), dazu `ℏ_pos`/`ℏ_ne_zero` (`:30`, `:38`).
  „ℏ = 1“ lässt sich in physlib also nicht setzen. Man muss H = ℏ·(Ω/2)σ_y schreiben, damit ℏ herausfällt.
- Unitarität, Gruppengesetz und Ableitung liegen in
  `Physlib/Mathematics/ForMathlib/OneParameterSubgroups/Unitary.lean` (4a0b4acf):
  - `:43` `structure UnitaryOneParameterGroup`;
  - `:80` `apply_eq_exp_generator : U t = exp ((-(t : ℂ) * I) • U.generator)`; Konvention U(t) = exp(−itA), Moduldoku
    `:18`;
  - `:136` `hasDerivAt`; `:164` `ofSelfAdjoint` mit `toFun t := exp ((t : ℂ) • (-I • A))` (`:169`), unitär über
    `exp_mem_unitary_of_mem_skewAdjoint` (`:178`); `:186` `ofSelfAdjoint_apply`; `:72` `adjoint_eq`.

**b) Mathlib (56a00585)**
- Matrix-Exponential: `Mathlib/Analysis/Normed/Algebra/MatrixExponential.lean`, u. a.:
  - `:82` `exp_diagonal`, `:85` `exp_blockDiagonal`, `:93` `exp_conjTranspose`, `:97` `IsHermitian.exp`;
  - `:175` `exp_neg`, `:179` `exp_zsmul`, `:185` `exp_conj` (`exp (U * A * U⁻¹) = U * exp A * U⁻¹` für `IsUnit U`),
    `:190` `exp_conj'`.
  - Allgemein `NormedSpace.exp`, `exp_add_of_commute`, `NormedSpace.star_exp`.
- **`selfAdjoint.expUnitary`**: `Mathlib/Analysis/CStarAlgebra/Exponential.lean:37`
  `expUnitary (a : selfAdjoint A) : unitary A := ⟨exp (I • a), _⟩`.
  - **Positiver Exponent exp(+i a).** Voraussetzung ist eine C⋆-Algebra `A`; für Matrizen braucht das die
    C⋆-Norm-Instanz aus `Mathlib/Analysis/CStarAlgebra/Matrix.lean`.
  - Dazu `:45` `expUnitary_zero`, `:55` `Commute.expUnitary_add`, `:61` `Commute.expUnitary`; außerdem
    `Mathlib/Analysis/CStarAlgebra/Unitary/Connected.lean:171` `expUnitary_argSelfAdjoint`.
- **Exp einer Involution oder von A² = −1: in Mathlib nicht vorhanden.** `exact?` auf
  `exp (r • a) = cosh r • 1 + sinh r • a` (mit `a * a = 1`, vollständiges `import Mathlib`) findet nichts; grep findet
  auch nichts.
- Nächste Vorlage ist `Mathlib/Analysis/Normed/Algebra/QuaternionExponential.lean`:
  `:39`/`:59` `expSeries_even/odd_of_imaginary`, `:82` `hasSum_expSeries_of_imaginary`, `:97` `exp_of_re_eq_zero`
  (Aufspaltung der Reihe in gerade und ungerade Glieder).
  - Skalare Bausteine: `Complex.hasSum_cos'` und `Complex.hasSum_sin'`
    (`Mathlib/Analysis/SpecialFunctions/Trigonometric/Series.lean:36` ff.).
  - `Complex.exp_mul_I` (`Mathlib/Analysis/Complex/Trigonometric.lean:514`).

**c) Pauli-Matrizen (4a0b4acf)**
- `pauliMatrix` liegt weiterhin in **`Physlib/Relativity/PauliMatrices/Basic.lean`**. #2021 hat nur `Relations.lean`
  und `ToTensor.lean` nach `Physlib/Relativity/Bispinors/Pauli/` verschoben; `Basic.lean` und `SelfAdjoint.lean`
  liegen noch unter `PauliMatrices/`, die Typ-Definition ist unverändert.
- `:37` `def pauliMatrix : Fin 1 ⊕ Fin 3 → Matrix (Fin 2) (Fin 2) ℂ` im Namespace `PauliMatrix`, mit:
  - `Sum.inl 0 ↦ 1`;
  - `Sum.inr 0 ↦ !![0, 1; 1, 0]` (σ_x);
  - **`Sum.inr 1 ↦ !![0, -I; I, 0]` (σ_y)**;
  - `Sum.inr 2 ↦ !![1, 0; 0, -1]` (σ_z).
- Scoped-Notationen `σ`, `σ0`…`σ3`; **σ_y = `σ2` = `pauliMatrix (Sum.inr 1)`**.
- Lemmas: `:67` `pauliMatrix_selfAdjoint`, `:86` `pauliMatrix_mul_self` (σ_μ·σ_μ = 1), `:98` `pauliMatrix_inv`,
  `:180–210` Kommutatoren, `:217` `pauliMatrix_anticommutator`, `:228` `vectorMatrix`, `:300` `vectorMatrix_sq`.
- `Physlib/Relativity/PauliMatrices/SelfAdjoint.lean`: `pauliSelfAdjoint`, `pauliBasis` (Basis der selbstadjungierten
  2×2-Matrizen).

**d) `ry` in `cg-ry` (dafef917, `PhyslibAlpha/QuantumMechanics/QubitGates.lean`)**
- `:56` `def ry (c s : ℝ) (h : c ^ 2 + s ^ 2 = 1) : 𝐔[Qubit] := ⟨!![(c : ℂ), -s; s, c], _⟩`.
- `:65` `ry_apply` (rfl).
- Basis |0⟩, |1⟩ = `Fin 2` 0, 1; Hypothese `c² + s² = 1`.
- **Vorzeichen geprüft:**
  `ry (cos(θ/2)) (sin(θ/2)) = cos(θ/2)·1 − i sin(θ/2)·σ_y = exp(−i θ σ_y/2)`, mit σ_y = `!![0,-I;I,0]`.
  - Numerisch (numpy/scipy `expm`, θ ∈ {0, 0.3, π/2, 1.7, π, 2.5, −1.1, 5.9}): max. Abweichung **1.1e-16**.
  - Gegenprobe mit positivem Exponenten exp(+iθσ_y/2): Abweichung 2.0, also klar falsch.
- `ry c s` ist genau `cayleyKlein c s` (`Physlib/Relativity/SL2C/CayleyKlein.lean:61`,
  `!![a, -conj b; b, conj a]`, bei reellem a = c, b = s). Das ist für Auftrag 3 (SU(2) → SO(3)) relevant und wird
  hier nicht weiterverfolgt.

**e) Toms Draft #2023** (TomOleDiem, Draft, „feat(PhyslibAlpha): qubit“, Stand 03.11. 16:47; nur gelesen, nichts übernommen)
- 15 Dateien, +1873, alle unter `PhyslibAlpha/QuantumMechanics/Qubit/`. Laut README ohne direkte oder transitive
  QuantumInfo-Abhängigkeit.
- `README.md`:
  - Konvention „`U(t) = exp(-itH)` with `ℏ = 1`“ für die abstrakte Ebene.
  - „Mathlib's `expUnitary` uses a positive imaginary exponent, so the recovered definition passes `-t • H`.“ Ein
    älterer Stand hatte das Vorzeichen falsch.
  - Offen sind u. a. „finite rotation action, its norm and determinant proofs, the Bloch equation and the double-cover
    results“, die Brücke Matrix ↔ abstrakte `QubitAlgebra` und „identify pulse matrix evolution with that geometric
    signal“.
- `Algebra/Dynamics.lean:49` `unitaryEvolution H t := selfAdjoint.expUnitary ((-t) • H)`, abstrakt, ℏ = 1, mit
  `:54` `unitaryEvolution_zero` und `:58` `unitaryEvolution_add`.
- `Algebra/AdjointAction.lean:50` `adjointAction H : v ↦ 2(h × v)`; `Algebra/Unitary.lean:44` `IsRotation`,
  `:51` `IsScalarUnitary`, `:55` `IsSpecialUnitary` (nur Prädikate). `Algebra/Basic.lean`: abstrakte Klasse mit
  Pauli-Basis (`:82` `gen_mul_cyc_symm`, `:95` `gen_mul_skip`).
- **`Hamiltonian.lean`** (Matrix-/Operator-Ebene, **mit physikalischem ℏ**):
  - `:56` `HilbertSpace := EuclideanSpace ℂ (Fin 2)`; `:59` `Hamiltonian := selfAdjoint (Matrix (Fin 2) (Fin 2) ℂ)`;
    `:64` `pauliCoeff`, `:97` `vectorPart`, `:101` `pauliRadius`.
  - `:162` `Qubit.timeEvolution A := UnitaryOneParameterGroup.ofSelfAdjoint ((ℏ : ℂ)⁻¹ • operator A)`. Das ist
    dieselbe Bauweise wie `FiniteTarget.unitaryTimeEvolution`, aber ohne `FiniteTarget` zu benutzen.
  - `:169` `timeEvolution_apply`: `exp ((-(t : ℂ) * I / ℏ) • operator A)`.
  - **`:237` `ContinuousLinearMap.exp_neg_I_mul_of_sq_eq_one`**:
    `A * A = 1 → exp ((-(r : ℂ) * I) • A) = (cos r : ℂ) • 1 + (-(sin r : ℂ) * I) • A`. Das ist genau das allgemeine
    Hilfslemma, allerdings für `K →L[ℂ] K`. Bewiesen über `:178` `negIMul`, `:182/:197` gerade und ungerade Potenzen
    und `:208/:221` `hasSum_even/odd_negIMul`.
  - `:376` `evolutionMatrix A t` (geschlossene Form e^{−ita₀/ℏ}(cos(tr/ℏ)·1 − i sin(tr/ℏ)(a·σ)/r)) und `:389`
    `timeEvolution_apply_eq_evolutionMatrix`. Bewiesen, 0 sorry laut README.
- **`Control.lean`**:
  - `:67` `structure Pulse` mit `axis`, `rabiFrequency`, `duration`;
  - `:78` `angle := Ω·duration`;
  - `:81` `hamiltonian := (ℏ * Ω / 2) • Σ_i axis_i • pauliSelfAdjoint (Sum.inr i)`, also **H = ℏΩ(n·σ)/2**, ℏ kürzt sich;
  - `:86` `evolutionMatrix := Qubit.evolutionMatrix hamiltonian duration`;
  - `:90` `ofAngle axis Ω θ` (duration = θ/Ω), `:101/:104` `piPulse`/`piHalfPulse`, `:56` `yAxis := ![0, 1, 0]`;
  - `:115/:123` `PulseSequence`.
  - **Nicht bewiesen:** die Identifikation der Pulsmatrix mit einer Rotation; laut README auch nicht, dass eine
    beliebige Achse normiert ist.

**f) Sonstiges**
- Ein exp(−iθσ/2) oder eine Spin-Rotationsmatrix in Exponentialform gibt es auf master (Physlib, PhyslibAlpha,
  QuantumInfo) nicht; grep nach `exp…pauli`, `exp…σ`, `cos (…/2)`.
- Verwandt, aber ohne exp:
  - `Physlib/Relativity/SL2C/CayleyKlein.lean:61` `cayleyKlein a b h : SL(2,ℂ)` und `:92` `cayleyKleinRotation`
    (Bild in der Lorentzgruppe);
  - `Physlib/Relativity/SL2C/AxisRotations.lean:37` `rotationZToAxis`;
  - `PhyslibAlpha/Relativity/SL2C/AxisRotations.lean:129` `rotationCycle` und Halbdrehung „`-i σ_k`“ (`:156`, `:175`).
- QuantumInfo: `BlochSphere.lean` mit Bloch-Kugel und Winkeln, ohne Zeitentwicklung. Die Gatter liegen in
  `Qubit.lean`, bzw. nach dem lokalen Umzug in `Physlib/QuantumMechanics/Qubit/Basic.lean`.

### 2. Konventionen (Vorschlag)

- **Physik:** U(t) = exp(−i t H/ℏ) (wie `FiniteTarget.timeEvolution_eq_exp`). Puls um y: **H = ℏ(Ω/2)σ_y**, θ = Ωt.
  Dann gilt U(t) = exp(−i(Ωt/2)σ_y) = **Ry(θ) = exp(−iθσ_y/2) = cos(θ/2)·1 − i sin(θ/2)σ_y =
  `ry (cos(θ/2)) (sin(θ/2))`**.
  - „ℏ = 1“ wird nicht gesetzt (ℏ ist in physlib der SI-Wert). Der Faktor ℏ im Hamiltonoperator kürzt sich, genau wie
    in Toms `Pulse.hamiltonian`.
- **Umrechnung zu Mathlib:** `expUnitary a = exp(+i a)`, also Ry(θ) = `expUnitary (-(θ/2) • σ_y)` (σ_y als Element von
  `selfAdjoint`). Toms abstrakte Ebene macht es genauso (`expUnitary ((-t) • H)`).
- **Umrechnung zu `FiniteTarget`:** Für `A : FiniteTarget (EuclideanSpace ℂ (Fin 2)) 2` mit
  `Ham = (ℏ Ω/2) • toEuclideanCLM σ_y` gilt `A.timeEvolution t = exp ((-(t : ℂ) * I / ℏ) • Ham)
  = exp ((-(Ω t / 2 : ℂ) * I) • toEuclideanCLM σ_y)`.
  - In der Standardbasis `EuclideanSpace.basisFun` ist die Matrix `ry (cos(Ωt/2)) (sin(Ωt/2))`.
  - Achtung: `timeEvolutionMatrixStandard` nimmt `Module.finBasisOfFinrankEq`, also nicht automatisch die
    Standardbasis. Man nimmt deshalb `timeEvolutionMatrix t (EuclideanSpace.basisFun _ ℂ).toBasis`.

### 3. Plan (nur Text)

**Lemma-Aussagen** (Matrixebene, `Q := Fin 2`):
1. Hilfslemma Involution:
   `Matrix.exp_neg_I_smul_of_mul_self_eq_one {A : Matrix n n ℂ} (hA : A * A = 1) (r : ℝ) :
    exp ((-(r : ℂ) * I) • A) = (Real.cos r : ℂ) • 1 + (-(Real.sin r : ℂ) * I) • A`.
   - Allgemeiner wäre es für eine vollständige normierte ℂ-Algebra; Matrizen brauchen dann
     `Matrix.linftyOpNormedAlgebra` o. ä. lokal.
2. Ry als Exponential:
   `ry_cos_sin_eq_exp (θ : ℝ) : (ry (cos (θ/2)) (sin (θ/2)) _ : Matrix Q Q ℂ)
    = exp ((-((θ/2 : ℝ) : ℂ) * I) • pauliMatrix (Sum.inr 1))`.
   Beweis: Hilfslemma 1 mit `pauliMatrix_mul_self`, dann `ext` und `fin_cases`, `simp [pauliMatrix]`, etwa 10 Zeilen.
3. Optional als Zeitentwicklung: Für `A : FiniteTarget (EuclideanSpace ℂ Q) 2` mit `A.Ham = (ℏ * Ω / 2 : ℂ) •
   toEuclideanCLM (σ_y)` gilt `A.timeEvolutionMatrix t (EuclideanSpace.basisFun Q ℂ).toBasis = ry (cos(Ωt/2))
   (sin(Ωt/2)) _`. Beweis: `timeEvolution_eq_exp`, ℏ kürzen (`ℏ_ofReal_ne_zero`), Matrix ↔ CLM über
   `Matrix.toEuclideanCLM` (exp vertauscht mit der Algebra-Äquivalenz), dann Lemma 2. Etwa 30–50 Zeilen; die
   Algebra-Äquivalenz ist der unsichere Teil.
4. Optional Toms Ebene: `(Pulse.ofAngle yAxis Ω θ).evolutionMatrix = ry (cos(θ/2)) (sin(θ/2)) _` für Ω ≠ 0, über
   seine `evolutionMatrix`. Erst sinnvoll, wenn #2023 gemergt ist; sonst hängen wir an einem Draft.

**Beweisweg für 1:**
- (i) Reihe spalten wie bei der Quaternion-Exponentialfunktion oder bei Toms `exp_neg_I_mul_of_sq_eq_one`, etwa 40
  Zeilen.
- (ii) Für den 2×2-Fall eventuell kürzer: σ_y diagonalisieren (Eigenwerte ±1, Eigenvektoren (1, ±i)/√2) und
  `exp_conj` mit `exp_diagonal` benutzen, etwa 25 Zeilen.
- (iii) Toms Lemma auf CLM-Ebene über `toEuclideanCLM` übertragen; das bindet an #2023.
- Empfehlung: (i) allgemein für Matrizen; als allgemeines Hilfslemma ist es auch für Mathlib interessant.

**Ort:**
- (A) Nach dem Qubit-Umzug (`qubit-to-physlib`, lokal eb4371e4; in der Aufgabe stand der Vor-amend-Hash c45d679f)
  neben Ry in `Physlib/QuantumMechanics/Qubit/` (dort, wo #2010 neu landen soll). Das braucht Importe
  `Physlib.Relativity.PauliMatrices.Basic`, und für Lemma 3 `Physlib.QuantumMechanics.FiniteTarget`; beide liegen in
  Physlib, es gibt keine Linter-Hürde.
- (B) Eigene Datei, z. B. `Physlib/QuantumMechanics/Qubit/Pulse.lean` (Lemmas 2–3), getrennt von den Gattern.
- Hilfslemma 1 nach `Physlib/Mathematics/ForMathlib/…/MatrixExponential…` (forMathlib-Lint: nur Mathlib-Importe;
  Nutzung außerhalb durch die Qubit-Datei). Alternativ in derselben Datei.
- PhyslibAlpha wäre nur nötig, wenn das Lemma vor dem Umzug kommen soll. `noAlphaImports` verbietet Physlib →
  Alpha, deshalb wäre ein späterer Umzug nach Physlib dann nochmals nötig.

**Was fehlt allgemein:** exp einer Involution (bzw. A² = −1) für Matrizen oder Banach-Algebren fehlt in Mathlib.
Toms CLM-Version (#2023 `Hamiltonian.lean:237`) existiert nur im Draft. Das sollte man mit Tom abstimmen, damit es
nicht doppelt entsteht: Entweder er zieht sein Lemma vorgezogen nach Physlib-ForMathlib, oder wir liefern eine
allgemeine Version, die er dann benutzt.

**Offene Entscheidungen für Daniel:**
1. Matrix-Ebene (Lemmas 1–2) zuerst, `FiniteTarget`-Brücke (3) später, ja oder nein?
2. Ort: (A) neben Ry nach dem Umzug, oder (B) eigene `Pulse.lean`?
3. Hilfslemma 1 allgemein in `ForMathlib` (wir) oder Toms CLM-Lemma aus #2023 abwarten bzw. übernehmen lassen?
   Mit Tom abstimmen, weil sein Draft `Pulse`/`evolutionMatrix` schon hat.
4. Bezug zu Toms `Pulse`: Lemma 4 erst nach Merge von #2023, oder seine Struktur ignorieren und nur `FiniteTarget`
   benutzen?
5. Reihenfolge: erst Qubit-Umzug und #2010 neu, dann Q1. Q1 hängt an `ry` aus #2010.

### Validierung

- grep über physlib origin/master 4a0b4acf und Mathlib 56a00585 (Fundstellen oben mit Datei:Zeile).
- `exact?` in Lean auf `exp (r • a) = cosh r • 1 + sinh r • a` (Involution, `import Mathlib`): **kein Treffer**.
- Numerik (numpy/scipy, Werkzeug, kein Beleg): `ry(cos θ/2, sin θ/2) = expm(−iθσ_y/2)` für 8 Werte θ, max. Fehler
  1.1e-16. Mit +i Fehler 2.0, also Vorzeichen eindeutig. Auch `= cos(θ/2)·1 − i sin(θ/2)σ_y` geprüft.
- #2023 nur über einen lokalen Ref gelesen (`git fetch origin pull/2023/head:pr2023`), nichts gebaut, nichts
  übernommen.
