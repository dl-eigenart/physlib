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
