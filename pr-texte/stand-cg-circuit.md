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
