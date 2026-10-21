# Stand Wasserstoffspektrum

Auftrag: `Auftrag-Wasserstoffspektrum.md`. Nichts gepusht außer `notes/pr-texte`.

## E1 (d = 3): Paulis algebraische Herleitung

Branch `hydrogen-pauli` (lokal, von `origin/master` 96a6bc5e),
Datei `PhyslibAlpha/QuantumMechanics/Hydrogen/PauliSpectrum.lean`.

### 2026-10-21, Schritt 1: Struktur + Hauptsatz mit `sorry` — erledigt
- `PauliSystem V Hy` (`Hy : HydrogenAtom`): `L A : Fin 3 → End ℂ V`, `H`; Relationen zyklisch
  für `(i, i+1, i+2)`: `[L,L]`, `[L,A]` (self/succ/pred), `[A_i,A_{i+1}] = -2iℏm H L_{i+2}`,
  `[H,L] = [H,A] = 0`, `A² = 2mH(L² + ℏ²) + m²k²`, `L·A = 0`.
- Hauptsatz `PauliSystem.exists_energyLevel`: `Hy.d = 3`, `E < 0`, Eigenraum endlichdim. und
  `≠ ⊥` ⇒ `∃ n, E = Hy.energyLevel n`. Beweis `sorry`.
- `lake build` grün, einzige Warnung das `sorry`. Lokal committet, nicht gepusht.
- Pauli-Referenz per CrossRef geprüft: Z. Phys. 36 (1926) 336–363, doi:10.1007/BF01450175.

### Befunde
- `L·A = 0` steht in physlib (`LaplaceRungeLenzVector.lean`) **nicht**; hier vorerst als Feld.
  Für die Verbindung zu physlib später als Lemma ergänzen (ggf. eigener PR).
- `spin_classification`, `Jsq_eq_smul` (auch Spin 0, ohne `Jz ≠ 0`) und `energyLevel`
  liegen auf `origin/master`. Physlibs `AngularMomentumRepresentation` ist ohne ℏ
  (`[Jx,Jy] = iJz`) ⇒ `J±/ℏ` verwenden.
- `k = 0` braucht keine Extra-Annahme: dann folgt `(2j+1)² = 0`, Widerspruch, Eigenraum leer.

### 2026-10-21, Schritt 2: Beweis vollständig — E1 (d = 3) fertig
Commits lokal auf `hydrogen-pauli`: 24438033 (Struktur), 5b157651 (Kern), 8d503b6c (Eigenraum, Linter).
Kein `sorry`, `#print axioms exists_energyLevel` = [propext, Classical.choice, Quot.sound].
`check_pr.sh pauli`: build_modules, build_alpha, runPhyslibAlphaLinters, theorem_lint,
module_doc_lint, alphaFileImports, noAlphaImports, lint_style, alpha_python, codespell alle OK.

Aufbau der Datei:
- B: `kappa` (`κ = √(-2mE)`), `J i = (L i + A i/κ)/(2ℏ)`, `comm_J`, `plusRep`
  (`AngularMomentumRepresentation`), `plusRep_Jsq`: `J² = (2ℏ)⁻²(-ℏ² - mk²/(2E)) • 1`.
- C: `exists_Jsq_eigenvector` (primitiver Vektor, ohne Irreduzibilität),
  `exists_energyLevel_of_H_eq` (Kern, `H = E • 1`), `mapsTo_eigenspace`, `restrictEigenspace`,
  Hauptsatz `exists_energyLevel` (in `Theorems.txt` eingetragen, voll qualifiziert).

Vereinfachung gegenüber dem Plan: `J₋` wird nicht gebraucht. Mit `[Lᵢ,Aᵢ] = 0` und `L·A = 0`
ist `Σ(L+K)ᵢ² = L² + K²`, und das ist auf dem Eigenraum schon ein Skalar. `J₋` und
`J₊² = J₋²` kommen erst für die Entartung (`n²`) ins Spiel.
Lean-Notiz: Relationen auf dem Eigenraum gehen per `ext x; exact congr($(rel) (x : V))`
(definitorisch); `simp` mit `restrict_apply`/`coe_restrict_apply` greift dort nicht.

### Offen / nächste Schritte
- `L·A = 0` für physlibs `𝐀(ε)` als Lemma in `LaplaceRungeLenzVector.lean` (gilt das für ε ≠ 0
  exakt? prüfen), damit `PauliSystem` an physlibs Operatoren andockt.
- E1-Zusatz: Dimension des Eigenraums Vielfaches von `n²` (braucht `J₋`, `J₊² = J₋²`, Tensorprodukt
  zweier Spin-`j`-Darstellungen).
- Dann E2 laut Auftrag.
- 2026-10-21 22:24: zu einem Commit 56a4ff79 zusammengefasst, nach „ja“ auf `fork/hydrogen-pauli`
  gepusht (Fork-master vorher von Daniel auf 96a6bc5e synchronisiert, wegen Workflow-Scope).
  Kein PR geöffnet, PR-Text noch nicht geschrieben. `Theorems.txt`-Eintrag von Daniel bestätigt (bleibt `theorem`).

## E2 algebraisch (d = 3): Entartung — fertig
Branch `hydrogen-pauli-degeneracy` (lokal, von `hydrogen-pauli` 56a4ff79), nicht gepusht.
Commits: d6dcb30e (Refactor: `J κ` für jedes `κ² = -2mE`, `rep`, `rep_Jsq`, `minusRep` = `J` bei `-κ`),
6b013904 (`comm_J_neg_succ`, `comm_J_neg`, `plusRep_comm_minusRep`), b723e840 (Abschnitt D).
- Ergebnis `exists_energyLevel_le_finrank`: Eigenraum (≠ ⊥, endlichdim., `E < 0`) ⇒
  `∃ n, E = energyLevel n ∧ (n+1)² ≤ finrank`. Als `lemma` (nicht in `Theorems.txt`).
- Beweis ohne Vollreduzibilität: gemeinsamer primitiver Vektor (`Sl2.exists_joint_primitive`),
  Casimir ⇒ `n1 = n2`, Gitter `f₁ᵃ f₂ᵇ m0` linear unabhängig (`Sl2.grid_linearIndependent`).
  Randfall `Jz₊ = 0` oder `Jz₋ = 0` ⇒ Casimir 0 ⇒ `n = 0`, `1 ≤ dim`.
- Neues Hilfslemma `eq_energyLevel_of_casimir` (aus `exists_energyLevel_of_H_eq` herausgezogen).
- `check_pr.sh pauli-deg`: alle Schritte OK, sorry 0, Axiome Standard.
- Nicht bewiesen: „dim ist Vielfaches von n²“ (bräuchte Weyl/Vollreduzibilität, gibt es weder in
  Mathlib noch bei uns).
- Hinweis: d6dcb30e ändert `J`/`plusRep` aus PR 15 (API: `J` nimmt `κ` statt `E`). Optional
  vor dem Öffnen von PR 15 dort einarbeiten, sonst wird PR 15-Text bei Nachfolge-PR veraltet.

## E2 analytisch — fertig (kein sorry)
Branch `hydrogen-degeneracy-analytic` (lokal, von `pr/hydrogen-bound-states` c2c625dd; diese Basis
ist 7 Commits hinter master, gleiche Mathlib/Toolchain), Datei
`PhyslibAlpha/QuantumMechanics/Hydrogen/Degeneracy.lean`. Commit lokal, nicht gepusht.
- A: `polyLaplacian`, `harmonicSubmodule d l` (`MvPolynomial (Fin d) ℝ`, homogen ⊓ ker Δ),
  `finrank_harmonicSubmodule` (`C(l+d-1,d-1) - C(l+d-3,d-1)`), `_three` (`2l+1`),
  `sum_two_mul_add_one` (bewiesen).
- B: `toFun` (Polynom als Funktion auf `Space d`), `contDiff_toFun`, `euler_toFun`, `laplacian_toFun`.
- C: `boundStateMap H n : (Π l : Fin (n+1), harm l) →ₗ (Space d → ℝ)`, `boundStateMap_injective`,
  `finrank_range_boundStateMap_three = (n+1)²`.
- `lake build` grün, 9 `sorry`.
- 2026-10-21 B fertig (ae1e9e9d, lokal): `toFun_C/add/mul_X`, `contDiff_toFun(_infty)`,
  `differentiable_toFun`, `deriv_toFun` (`∂[i] (toFun P) = toFun (pderiv i P)`, Induktion
  `MvPolynomial.induction_on`), `euler_toFun` (Mathlib `IsHomogeneous.sum_X_mul_pderiv`),
  `laplacian_toFun`, Korollar `boundState_eigen_of_mem_harmonicSubmodule` (PR-05-Gleichung für
  `P ∈ harmonicSubmodule`). `lake build` grün. Offen: 6 `sorry` (A: 2 Dimension, C: 4).
- Referenz im Modul-Doc ist `[CITATION_NEEDED: …]` (Dimension harmonischer Polynome) — vor PR mit
  Tool-Lookup belegen oder streichen.

Schwierigkeitseinschätzung:
- Dimensionsformel braucht Surjektivität von `Δ : Hom_l → Hom_{l-2}` (z. B. Zerlegung
  `Hom_l = Harm_l ⊕ |x|² Hom_{l-2}` über das Fischer-Skalarprodukt). Größter Brocken.
- Injektivität: `Σ_l f_l(r) P_l(y) = 0` ⇒ alle `P_l = 0`. Idee: Radialfaktor ist `e^{-κr}` mal
  Polynom in `r`; Entwicklung nach Homogenitätsgrad entlang Strahlen `y = t·ω`. Noch auszuarbeiten.
- B ist Routine (Ableitung von `MvPolynomial.eval`).

### 2026-10-21 C und A fertig (lokal, nicht gepusht)
Commits auf `hydrogen-degeneracy-analytic`: ead3287d (Linearität, Skalierung, Hilfslemma), b6e9f141 (C),
009dd72e (A1), ae22dd0e (A2), c7375010 (A3–A5), 94146771 (Referenz).
- C: `boundStateMap_injective` ohne Annahmen an `d`, `k` (Strahl `y = t w`, kleinste Potenz von `t`,
  `L(0) = C(N+α,N) ≠ 0`, `eq_zero_of_sum_pow_mul` per Grenzwert `t → 0⁺`, dann `MvPolynomial.funext`).
  `finrank_range_boundStateMap = Σ_l dim Harm_l`, `_three = (n+1)²` (nur noch `hd : H.d = 3`).
- A: `finrank_homogeneousSubmodule` (Monome ↔ `Sym (Fin d) l`), `polyLaplacian_isHomogeneous`,
  `polyLaplacian_eq_zero_of_lt_two`, Fischer-Produkt (`fischer`, `fischer_mul_X` = Adjungiertheit
  `Xᵢ`/`∂ᵢ`, `fischer_self_pos`), `eq_zero_of_polyLaplacian_eq_zero_of_eq_rSq_mul`
  (`Harm ∩ r²·Hom = 0`), `finrank_harmonicSubmodule_add_finrank` (`dim Harm_{l+2} + dim Hom_l =
  dim Hom_{l+2}`, beide Richtungen ohne orthogonales Komplement), dann Formel und `2l+1`.
- `check_pr.sh deg-analytic`: alles OK außer `theorem_lint`: „no such file …
  Physlib/Mathematics/ForMathlib/SesquilinearForm.lean“ = veraltete .olean von neuerem master im
  gemeinsamen `.lake`, Datei fehlt auf der alten Basis 653895b0. Degeneracy.lean hat 0 `theorem`.
  Erst nach Rebase auf master sinnvoll prüfbar.
- Referenz: Axler–Bourdon–Ramey, Harmonic Function Theory, GTM 137 (2001), Kap. 5, per CrossRef
  geprüft (doi:10.1007/978-1-4757-8137-3_5). Nicht geprüft: genaue Stelle der Dimensionsformel im
  Kapitel — vor PR im Buch nachsehen.
