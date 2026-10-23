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

## 2026-10-21 22:59: Umbau, Basen, Pushes (nach Daniels „ja“)
- `pr/hydrogen-bound-states` lokal neu vom Fork geholt (349128d0, Basis a46a93e9 = #1900; alte
  lokale Fassung c2c625dd war inhaltsgleich, nur veraltete Basis). `hydrogen-degeneracy-analytic`
  darauf umgesetzt, zu einem Commit 7ad91892 zusammengefasst. Linter alle OK außer `theorem_lint`
  (gleiche Ursache wie oben: .olean von `Time/ManifoldCurves.lean` (#1863) im gemeinsamen `.lake`,
  fehlt auf a46a93e9; Degeneracy.lean hat 0 `theorem`).
- Umbau von `J` (κ statt E, `rep`, `rep_Jsq`, `minusRep`, `minusRep_Jsq`, `ne_zero_of_sq_eq`) in den
  einen Commit von `hydrogen-pauli` eingefaltet: fd5f5b4e. `hydrogen-pauli-degeneracy` darauf neu
  aufgesetzt, ein Commit b07c9efd (Inhalt identisch, Tree-Hash geprüft). Beide: alle Linter OK
  inkl. `theorem_lint`, Axiome Standard.
- Gepusht: `hydrogen-pauli` (`--force-with-lease` gegen 56a4ff79), `hydrogen-pauli-degeneracy`,
  `hydrogen-degeneracy-analytic` (neu). Kein PR geöffnet.
- PR-Text 15 an die neue Schnittstelle angepasst (Deklarationstabelle, Reviewer-Map, `comm_J`).

## Plan: `L ∧ A = 0` in physlib (noch kein Code)
Ziel: die Annahme `L_dot_A` aus `PauliSystem` für physlibs Operatoren beweisen.

**Aussage (d beliebig, für jedes ε exakt):** zyklische Identität
`𝐋 i j ∘L 𝐀(ε) k + 𝐋 j k ∘L 𝐀(ε) i + 𝐋 k i ∘L 𝐀(ε) j = 0` für alle `i j k`
(`angularMomentum_cyclic_lrl`), dasselbe mit `𝐀` links (`lrl_cyclic_angularMomentum`).
In d = 3 mit `Lₖ = ½ εₖᵢⱼ Lᵢⱼ` ist das für `(i,j,k) = (1,2,0)` genau `L·A = 0`
(`L 0 = 𝐋 1 2`, `L 1 = 𝐋 2 0`, `L 2 = 𝐋 0 1`), also das Feld `L_dot_A`.
Warum exakt trotz Regularisierung: ε steckt nur in `𝐫₀ ε (-1)`, und das kommutiert mit `𝐋`.

**Rechenweg** über `lrlOperator_eq`: `𝐀ₖ = 𝐱ₖ𝐩² - (𝐱·𝐩)𝐩ₖ + ½iℏ(d-1)𝐩ₖ - mk·𝐫₀(-1)𝐱ₖ`. Mit
`Σ_cyc` für die zyklische Summe über `(i,j,k)`:
- `Σ_cyc 𝐋ᵢⱼ 𝐱ₖ 𝐩² = (Σ_cyc 𝐋ᵢⱼ 𝐱ₖ) 𝐩²`, braucht (F1) `Σ_cyc 𝐋ᵢⱼ 𝐱ₖ = 0`.
- `Σ_cyc 𝐋ᵢⱼ (𝐱·𝐩) 𝐩ₖ = (𝐱·𝐩) Σ_cyc 𝐋ᵢⱼ 𝐩ₖ`, braucht (F3) `[𝐋ᵢⱼ, 𝐱·𝐩] = 0` und
  (F2) `Σ_cyc 𝐋ᵢⱼ 𝐩ₖ = 0`.
- `½iℏ(d-1) Σ_cyc 𝐋ᵢⱼ 𝐩ₖ = 0` nach (F2).
- `Σ_cyc 𝐋ᵢⱼ 𝐫₀(-1) 𝐱ₖ = 𝐫₀(-1) Σ_cyc 𝐋ᵢⱼ 𝐱ₖ = 0` nach `angularMomentum_comp_radiusRegPow_commute`
  (vorhanden) und (F1).
- `𝐀` links: `Σ_cyc 𝐀ₖ 𝐋ᵢⱼ = Σ_cyc 𝐋ᵢⱼ 𝐀ₖ - Σ_cyc [𝐋ᵢⱼ, 𝐀ₖ]`, und mit
  `angularMomentum_commutation_lrl` (vorhanden) ist `Σ_cyc iℏ(δᵢₖ𝐀ⱼ - δⱼₖ𝐀ᵢ) = 0`
  (die δ-Terme heben sich paarweise weg, auch bei gleichen Indizes).

**Hilfslemmata** (in `Operators/AngularMomentum.lean`):
- (F1) `angularMomentum_cyclic_position`: aus `𝐋ᵢⱼ = 𝐱ᵢ𝐩ⱼ - 𝐱ⱼ𝐩ᵢ` und
  `angularMomentum_commutation_position`; die `𝐱𝐱𝐩`-Terme heben sich auf, weil Orte vertauschen,
  die `iℏδ`-Terme heben sich paarweise auf.
- (F2) `angularMomentum_cyclic_momentum`: wie F1, ohne Kommutatoren (Impulse vertauschen).
- (F3) `angularMomentum_commutation_positionDotMomentum`: `[𝐋ᵢⱼ, Σₘ 𝐱ₘ𝐩ₘ] =
  Σₘ([𝐋ᵢⱼ,𝐱ₘ]𝐩ₘ + 𝐱ₘ[𝐋ᵢⱼ,𝐩ₘ]) = iℏ(𝐱ⱼ𝐩ᵢ - 𝐱ᵢ𝐩ⱼ) + iℏ(𝐱ᵢ𝐩ⱼ - 𝐱ⱼ𝐩ᵢ) = 0`, mit den
  vorhandenen `angularMomentum_commutation_position/momentum`. Gibt es in physlib noch nicht.

**Ort und Form:** Physlib selbst (nicht Alpha), Hauptlemma in `LaplaceRungeLenzVector.lean`
(neuer Abschnitt nach den `⁅𝐋, 𝐀⁆`-Kommutatoren), F1–F3 in `Operators/AngularMomentum.lean`.
Branch `lrl-angular-cyclic` von `origin/master`. Alles als `lemma` (kein `Theorems.txt`).
Optional als dritter Schritt ein d = 3-Korollar in der Form `Σₖ Lₖ Aₖ = 0`, dann gleich mit den
Indizes von `PauliSystem`.

**Schritte:** (1) F1–F3 mit `sorry`, bauen; (2) F2, F1, F3 beweisen; (3) Hauptlemma beiden Ordnungen;
(4) d = 3-Korollar; (5) Linter (Physlib-Linter strenger als Alpha: vorher prüfen, was
`check_pr.sh` für Physlib-Dateien abdeckt).

**Offen danach:** Dass physlibs `𝐋`, `𝐀(ε)`, `𝐇(ε)` im Limes ε → 0 auf einem geeigneten Raum
einen `PauliSystem` bilden, bleibt Funktionalanalysis (E3/E5). Dieses Lemma liefert nur das
fehlende algebraische Feld.

### 2026-10-21 23:02: `L ∧ A = 0`, Schritt 1 erledigt
Branch `lrl-angular-cyclic` (lokal, von `origin/master` 96a6bc5e), Commit lokal, nicht gepusht.
- `Operators/AngularMomentum.lean`, neuer Abschnitt E.4 (TOC ergänzt):
  `angularMomentum_cyclic_position`, `angularMomentum_cyclic_momentum`,
  `angularMomentum_commutation_positionDotMomentum` (`@[simp]`), je `sorry`.
- `LaplaceRungeLenzVector.lean`, nach `angularMomentumSqr_commutation_lrlSqr`:
  `angularMomentum_cyclic_lrl`, `lrl_cyclic_angularMomentum`, je `sorry`; Modul-Doc ergänzt.
- `lake build` grün, genau 5 `sorry`-Warnungen.
- Für die Beweise: Stil von `angularMomentum_commutation_angularMomentum` (punktweise `ext`,
  `positionCLM_apply`/`momentumCLM_apply`, `ring`) bzw. von `angularMomentum_commutation_lrl`
  (`lie_leibniz`, `module`).

### 2026-10-21 23:05: `L ∧ A = 0`, Schritt 2 erledigt
F1 `angularMomentum_cyclic_position`, F2 `angularMomentum_cyclic_momentum`,
F3 `angularMomentum_commutation_positionDotMomentum` bewiesen (rein algebraisch:
`momentum_comp_position_eq`, `position_comp_commute`, `momentum_comp_commute`, `KroneckerDelta.symm`
bzw. `lie_leibniz` + `KroneckerDelta.sum_smul`, Abschluss `module`/`abel`). AngularMomentum.lean ohne
`sorry`, `lake build` grün. Commit lokal, nicht gepusht. Offen: Schritt 3 (Hauptlemma, 2 `sorry`).

### 2026-10-21 23:09: `L ∧ A = 0`, Schritt 3 und 5 erledigt (lokal, nicht gepusht)
Commits auf `lrl-angular-cyclic`: e77035e5 (Aussagen), 5a4ae591 (F1–F3), d9109478 (Hauptlemmata).
Vor einem Push zu einem Commit zusammenfassen (wie bei den anderen PRs).
- `angularMomentum_cyclic_lrl`: `calc` über `lrlOperator_eq`; `𝐋` an `𝐱·𝐩` (F3) und `𝐫₀` vorbei,
  dann Summe = (F1-Summe)𝐩² − (𝐱·𝐩)(F2-Summe) + c·(F2-Summe) − mk·𝐫₀(F1-Summe) = 0.
- `lrl_cyclic_angularMomentum`: `comp_eq_comp_sub_commute` + `angularMomentum_commutation_lrl`,
  δ symmetrisiert, `linear_combination (norm := module)`.
- Gilt für jedes `d` und jedes ε, ohne Zusatzannahmen. Für d = 3 ist `(i,j,k) = (1,2,0)` genau das
  Feld `L_dot_A` von `PauliSystem` (`L 0 = 𝐋 1 2`, `L 1 = 𝐋 2 0`, `L 2 = 𝐋 0 1`); ein eigenes
  d = 3-Korollar (Schritt 4) bringt daher wenig und ist weggelassen.
- Prüfung wie CI (build.yml): `lake build -KCI --iofail`, check_file_imports, check_dup_tags,
  sorry_lint, theorem_lint Physlib QuantumInfo, module_doc_lint, api_map_lint, runPhyslibLinters,
  lint-style, codespell: alle OK. Zusätzlich `lake build -KCI PhyslibAlpha` grün (wegen neuem
  `@[simp]`-Lemma F3). Axiome Standard.
- Neue `@[simp]`: `angularMomentum_commutation_positionDotMomentum` (wie die übrigen
  `⁅𝐋, ·⁆ = 0`-Lemmata der Datei).

## 2026-10-21 23:12: `lrl-angular-cyclic` gepusht
Zu einem Commit bdf8396d zusammengefasst (Tree-Hash geprüft), auf `fork/lrl-angular-cyclic`
(von origin/master 96a6bc5e). PR-Text schreibt die Cloud-Session.

## Plan E3: Die Eigenfunktionen sind echte Zustände (noch kein Code)

### Was physlib hat (Stand origin/master 96a6bc5e)
- `SpaceDHilbertSpace d = Lp ℂ 2 volume`, `MemHS f := MemLp f 2`, `mk` für die Klasse.
- `HydrogenAtom` erbt aus `SpaceDQuantumSystem`:
  `hamiltonianOperator = kineticOperator + potentialOperator : Q.HS →ₗ.[ℂ] Q.HS`;
  `kineticOperator = (2m)⁻¹ • momentumSqOperator` mit Domain `SchwartzSubmodule`,
  `potentialOperator = 𝓜 (V)` mit Domain `{ψ | Vψ ∈ L²}` (selbstadjungiert).
  Domain von `H` also `Schwartz ∩ {Vψ ∈ L²}` (für d ≥ 3 alle Schwartz-Funktionen, da
  `1/r ∈ L²_loc`; für d = 2 nicht).
- `Unbounded.lean`: `HasDenseDomain`, `IsSymmetric`, `IsEssentiallySelfAdjoint` (Abschluss
  selbstadjungiert), Adjungierte `T†`. `SobolevSubmodule d s` (H^s).
- TODOs in `Hydrogen/Basic.lean`: nicht wesentlich s.a. für d < 3, wesentlich s.a. für d ≥ 3,
  Punktspektrum des Abschlusses = Bohr-Niveaus, kontinuierliches Spektrum [0,∞).
- `hamiltonianCLM`/`potentialCLM` setzen `HasTemperateGrowth` voraus, gilt für `-k/r` nicht;
  für Wasserstoff also nur `hamiltonianOperator` (und `hamiltonianRegCLM ε`) verwenden.

### Problem
`boundState H N l P = e^{-κr} L(2κr) P(y)` ist bei 0 nicht glatt (`e^{-κr}` hat einen Knick),
also nicht Schwartz, also nicht im Domain von `H.hamiltonianOperator`. Ins Domain des Abschlusses
käme man nur über eine Approximation, und „Abschluss = Adjungierte“ ist genau die offene TODO zur
wesentlichen Selbstadjungiertheit (für d ≥ 3, Kato–Rellich: schwer).

### Ziel von E3 (ehrlich erreichbar)
(a) Die Bound States liegen in L²; die Familie zum Niveau n ist dort linear unabhängig
    (in d = 3: `(n+1)²` unabhängige Zustände in `SpaceDHilbertSpace 3`).
(b) Jeder Bound State ist Eigenvektor der **Adjungierten**:
    `ψ ∈ (H.hamiltonianOperator)†.domain` und `H† ψ = E_n ψ`, d. h.
    `⟪ψ, H φ⟫ = E_n ⟪ψ, φ⟫` für alle `φ` im Domain von `H`.
    Mit der (separaten) TODO „wesentlich s.a. für d ≥ 3“ wird `H†` zum Abschluss, und dann folgt
    „der Abschluss hat die Bohr-Niveaus als Eigenwerte“ (eine Richtung des Haupt-TODO) sofort.
Nicht Teil von E3: Selbstadjungiertheit, Abschluss, Vollständigkeit (E4/E5).

### Schritte
1. **Machbarkeit Mathlib** (vor jedem Code): Polarkoordinaten für radiale Integranden
   (`integral_fun_norm_addHaar`/`integrable_fun_norm_addHaar`), `∫ r^a e^{-cr}` (Gamma),
   partielle Integration auf ℝ^d (`integral_bilinear_hasFDerivAt_right_eq_neg_left_of_integrable`
   o. ä.), Adjungierten-Charakterisierung für `LinearPMap` (`mem_adjoint_domain_iff`,
   `adjoint_apply_eq`), Maß auf `Space d` (= volume, Bezug zu `EuclideanSpace`). Ergebnis in
   dieser Datei festhalten, dann Lemma-Liste anpassen.
2. **Integrierbarkeit**: `Integrable (‖y‖^a · e^{-c‖y‖})` auf `Space d` für `c > 0`; Polynomschranke
   `|P(y)| ≤ C (1 + ‖y‖)^l` für `MvPolynomial`-Auswertung und für das Laguerre-Polynom in `‖y‖`.
3. **`MemHS (boundState …)`** (als ℂ-wertige Funktion), daraus `boundStateHS : … → SpaceDHilbertSpace d`.
4. **Unabhängigkeit in L²**: Bound States sind stetig, a.e.-gleich stetige Funktionen sind gleich;
   damit überträgt sich `boundStateMap_injective` (E2) auf `SpaceDHilbertSpace`; für d = 3 Dimension
   `(n+1)²` des Spanns.
5. **Schwache Eigenwertgleichung** `⟪ψ, H φ⟫ = E ⟪ψ, φ⟫` für `φ` im Domain:
   Weg (bevorzugt) Regularisierung `r → √(r² + δ²)`: `ψ_δ` ist glatt, `(-Δ/2m - k/r) ψ_δ = E ψ_δ + R_δ`
   explizit; partielle Integration auf ganz ℝ^d für glatte Funktionen mit integrierbaren
   Ableitungen; dann `δ → 0` mit dominierter Konvergenz (`∫ ψ_δ Hφ → ∫ ψ Hφ`, `∫ R_δ φ → 0`).
   Alternative: Green-Formel mit ausgeschnittener Kugel `B_δ` (braucht Divergenzsatz auf
   Kugelschalen, in Mathlib schwach). Braucht `d ≥ 2` (Randterm `O(δ^{d-1})`, `Δψ ~ 1/r`
   lokal integrierbar). Aufwendigster Teil, vermutlich mehrere Sitzungen.
6. **Abschluss**: `boundState_mem_adjoint_domain`, `adjoint_boundState = E_n • …`; Korollar
   „E_n ist Eigenwert von `H†`“ mit Vielfachheit ≥ `(n+1)²` in d = 3.

### Einschätzung
Schritte 2–4 mittel (Standard-Analysis, gute Mathlib-Abdeckung zu erwarten). Schritt 5 schwer
(singuläres Potential, Regularisierungsgrenzwert). Schritt 1 entscheidet, ob 5 über
Regularisierung oder Kugelausschnitt läuft. Branch später von `hydrogen-degeneracy-analytic`
(braucht `boundState`, `toFun`, `boundStateMap`).

## E3 (a–d), Branch `hydrogen-bound-states-l2` (lokal, von `hydrogen-degeneracy-analytic` 7ad91892)

### 2026-10-21 23:18: a) Mathlib-Recherche — erledigt
In der echten Umgebung getestet (Scratch-Datei):
- Maß: `volume` auf `Space d` ist `IsAddHaarMeasure` und `IsOpenPosMeasure` (Instanzen greifen);
  `Space.finrank_eq_dim`.
- Integrierbarkeit: `integrable_one_add_norm` (JapaneseBracket): `(1+‖x‖)^(-r)` integrierbar für
  `r > d`. Plan: `|ψ|² ≤ C (1+‖y‖)^(-(d+1))` zeigen und `Integrable.mono` nutzen — keine
  Polarkoordinaten nötig (`integrable_fun_norm_addHaar` wäre die Alternative).
- Abklingen: elementar über `x^m/m! ≤ exp x` (`Real.pow_div_factorial_le_exp`):
  `(1+t)^m e^{-ct} ≤ e^c m!/c^m` — geschlossene Schranke, kein Kompaktheitsargument.
- Polynomschranken: eigenes Prädikat `|f y| ≤ C(1+‖y‖)^k`, abgeschlossen unter `+`, `·`;
  Koordinaten über `Space.abs_eval_le_norm`; `MvPolynomial`/`Polynomial` per Induktion.
  (`HasTemperateGrowth` passt nur für den Polynomfaktor, nicht für den Laguerre-Faktor in `‖y‖`,
  der bei 0 nicht glatt ist.)
- L²: `memLp_two_iff_integrable_sq_norm`; physlib `MemHS`, `mk`, `mk_add`, `mk_const_smul`,
  `mk_eq_iff` (`mk hf = mk hg ↔ f =ᵐ g`).
- Unabhängigkeit: `MeasureTheory.Measure.eq_of_ae_eq` / `Continuous.ae_eq_iff_eq` (stetig und a.e.
  gleich ⇒ gleich), dann `boundStateMap_injective` aus E2.
- Für κ > 0 (`boundKappa`) braucht es `0 < H.k` und `2 ≤ H.d` (wie `boundState_eigen`).
Neue Datei geplant: `PhyslibAlpha/QuantumMechanics/Hydrogen/BoundStatesL2.lean`.

### 2026-10-21 23:20: b) Integrierbarkeit (allgemein) — erledigt
Neue Datei `BoundStatesL2.lean` (in `PhyslibAlpha.lean` eingetragen), Commit lokal.
- §A `IsPolyBounded f` (`∃ C ≥ 0, k, |f y| ≤ C(1+‖y‖)^k`) mit `const`, `add`, `mul`, `pow`, `coord`,
  `norm`, `toFun` (MvPolynomial), `polynomial_eval` (Polynom ∘ beschränkte Funktion).
  Hinweis: `add`/`mul`/`pow` in der Form `fun y => f y + g y` — `f + g` passt im Modulsystem nicht
  definitorisch (Instanz `Real.instAdd` nicht exponiert).
- §B `one_add_pow_mul_exp_neg_le`: `(1+t)^m e^{-ct} ≤ e^c m!/c^m`;
  `integrable_sq_of_le_mul_exp`: `|f| ≤ |g| e^{-c‖y‖}`, `g` polynomial beschränkt, `c > 0`
  ⇒ `f²` integrierbar (Schranke durch `(1+‖y‖)^{-(d+1)}`, `integrable_one_add_norm`).
- Datei elaboriert ohne Fehler/Warnungen.

### 2026-10-21 23:21: c) L² — erledigt
`boundKappa_pos` (`k > 0`, `d ≥ 2`), `continuous_boundState`, `memHS_boundState`
(über `integrable_sq_of_le_mul_exp` mit `g = L(‖y‖)·P(y)`, `c = κ`), `boundStateHS`
(`SpaceDHilbertSpace.mk`). Commit lokal.

### 2026-10-21 23:22: d) Lineare Unabhängigkeit in L² — erledigt; E3 a–d fertig
Commit lokal 2130c40d (Branch `hydrogen-bound-states-l2`, 4 Commits über 7ad91892, nicht gepusht).
- `IsPolyBounded.sum`; `boundStateMap_apply` (alle Terme haben `κ = boundKappa H n`, da
  `(n-l)+l = n`); `continuous_boundStateMap`; `memHS_boundStateMap`;
  `boundStateMapHS : (Π l, Harm_l) →ₗ[ℝ] SpaceDHilbertSpace d` (Linearität über `ext_iff`,
  `coeFn_mk`, `Lp.coeFn_add/smul`); `boundStateMapHS_injective` (a.e. null + stetig ⇒ null, dann
  `boundStateMap_injective`); `finrank_range_boundStateMapHS_three = (n+1)²`.
- `check_pr.sh l2`: alles OK außer `theorem_lint` (bekannte Ursache: .olean von
  `Time/ManifoldCurves.lean` fehlt auf Basis a46a93e9; BoundStatesL2.lean hat 0 `theorem`).
  Axiome Standard, `sorry` 0.
- Lean-Notiz: Die Null in `SpaceDHilbertSpace`-Funktionen erscheint als `{re := 0, im := 0}`;
  `simp` erkennt sie nicht als `0`, Ausweg über `Complex.ext_iff` (Realteil).
- Offen: Schritt e (schwache Eigenwertgleichung / Adjungierte), wartet auf Daniel.

## E3 Schritt e (schwache Eigenwertgleichung), Branch `hydrogen-bound-states-adjoint`
(lokal, von `hydrogen-bound-states-l2` 53805fce; nicht pushen)

### 2026-10-21 23:28: Aussagen formuliert, gebaut — 1 `sorry`
In `BoundStatesL2.lean` §E:
- `inner_boundStateHS_hamiltonianOperator` (sorry): für `P ∈ Harm_l`, `φ ∈ dom H`:
  `⟪E_{N+l} • ψ, φ⟫ = ⟪ψ, H φ⟫`, `H = H.hamiltonianOperator` (aus `SpaceDQuantumSystem`).
- `boundStateHS_mem_adjoint_domain`: bewiesen aus dem obigen über
  `LinearPMap.mem_adjoint_domain_of_exists` (braucht keine Dichtheit).
- `adjoint_boundStateHS` (Hypothese `Dense dom H`): `H† ψ = E • ψ`, bewiesen über
  `LinearPMap.adjoint_apply_eq`. Dichtheit von `dom H = Schwartz ∩ {Vφ ∈ L²}` bleibt eigenes Thema
  (für d ≥ 3 ist das alle Schwartz-Funktionen, da 1/r ∈ L²_loc).

### 2026-10-21 23:34: e1 erledigt — `H φ` als Differentialoperator
- `momentumOperator_apply_schwartzEquiv`: `𝓟ᵢ[g] = [𝐩ᵢ g]`;
  `momentumSqOperator_apply_schwartzEquiv`: `𝐩²[f] = [Σᵢ 𝐩ᵢ𝐩ᵢ f]`.
- `hamiltonianOperator_apply_ae`: jedes `φ ∈ dom H` ist `[f]` mit `f` Schwartz, und
  `H φ =ᵐ -ℏ²/(2m) Σᵢ ∂ᵢ∂ᵢ f + V f`.
- Lean-Notizen: `kineticOperator`/`potentialOperator` sind im Modulsystem nicht entfaltbar
  (`change` scheitert) — Trick: über beliebiges `T` mit `T = …` argumentieren (`rintro T rfl`)
  und `kineticOperator_eq`/`potentialOperator_eq` einsetzen. `(𝓟 i).domain` vs.
  `SchwartzSubmodule`: definitorisch, aber nicht reduzierbar gleich ⇒ `simp` scheitert, Weg über
  `calc` + `congr 1` + `Subtype.ext`. Summe von Schwartz-Abbildungen auswerten: `_root_.sum_apply`.
- Recherche für e2 (Green-Identität `∫ ψ Δf = ∫ (Δψ) f`, ψ mit Knick bei 0), Ergebnis:
  * Mathlib/physlib haben **kein** Lemma „differenzierbar außer bei 0 ⇒ partielle Integration“.
    `integral_mul_fderiv_eq_neg_fderiv_mul_of_integrable` u. Varianten
    (`Mathlib/Analysis/Calculus/LineDeriv/IntegrationByParts.lean`) brauchen Differenzierbarkeit auf
    ganz `tsupport` der Testfunktion (enthält 0).
  * physlib-Hausmethode (Space/Norm/Basic.lean ~l.392–612, `distGrad_distOfFunction_norm_zpow`,
    `distLaplacian_distOfFunction_norm_zpow`): ‖x‖ regularisieren (`normPowerSeries n x =
    √(‖x‖²+1/(n+1))`, `Norm/Regularized.lean`), partiell integrieren, dominierte Konvergenz;
    Integrierbarkeit über `IsDistBounded` (Schranken `‖x‖^p`, `p ≥ -(d-1)`;
    `IsDistBounded.integrable_space`, `integrable_space_fderiv`).
  * `distDeriv_distOfFunction` (DistOfFunction.lean:158) braucht `Differentiable ℝ f` überall.
  * Mathlib-Divergenzsatz erlaubt abzählbare Ausnahmemengen
    (`integral_divergence_of_hasFDerivAt_off_countable`), aber nur auf Quadern in `Fin (n+1) → ℝ`.

### 2026-10-21 23:35: e3 erledigt — alles auf die Green-Identität reduziert
`inner_boundStateHS_hamiltonianOperator` bewiesen bis auf das eine Lemma
`integral_boundState_mul_hamiltonian` (sorry):
`∫ ψ(-ℏ²/2m Σᵢ∂ᵢ∂ᵢf + Vf) = ∫ (-ℏ²/2m Δψ + Vψ) f` für `f` Schwartz.
Rest: `L2.inner_def` + `coeFn_mk`/`hamiltonianOperator_apply_ae`, dann Eigenwertgleichung aus PR 05
fast überall (`{0}` Nullmenge; braucht `Nontrivial (Space d)` aus `d ≥ 2`).
Commit lokal 78c2ad52.

Plan Green-Identität:
- G1 (allgemein): `u` glatt (C²), `u`, `∂ᵢu`, `∂ᵢ∂ᵢu` polynomial beschränkt ⇒
  `∫ u Σ∂ᵢ∂ᵢf = ∫ (Σ∂ᵢ∂ᵢu) f` (zweimal `integral_mul_fderiv_eq_neg_fderiv_mul_of_integrable`;
  Integrierbarkeit über `SchwartzMap.integrable_pow_mul`).
- G2: `ψ_ε(y) = G(‖y‖²+ε²) P(y)` mit `G(s) = R(√s)` — überall glatt; Ableitungsformeln
  (`laplacian_radial_mul` aus PR 05) und Schranken.
- G3: `ε → 0`, dominierte Konvergenz, `|Δψ_ε| ≤ C(1+1/‖y‖)(1+‖y‖)^k` (integrierbar gegen Schwartz in
  d ≥ 2, z. B. über `IsDistBounded`).
- Potentialterm: `ψ V f` integrierbar (|V| = k/‖y‖) — ebenfalls über `IsDistBounded`.

### 2026-10-21 23:39: G1 erledigt
- `IsPolyBounded.integrable_ofReal_mul_schwartz` (polynomial beschränkt × Schwartz integrierbar,
  über `one_add_le_sup_seminorm_apply` + `integrable_one_add_norm`).
- `deriv_ofReal`, `deriv_schwartz` (`∂[i] ⇑f = ⇑(∂_{basis i} f)`).
- `integral_ofReal_mul_sum_deriv_deriv`: `u` C², `u, ∂ᵢu, ∂ᵢ∂ᵢu` polynomial beschränkt ⇒
  `∫ u Σ∂ᵢ∂ᵢf = ∫ (Σ∂ᵢ∂ᵢu) f`. Commit lokal da245a83.
- Lean-Notizen: `(∂[i] u y : ℂ)` wird als komplexe Ableitung gelesen — `((∂[i] u y : ℝ) : ℂ)`
  schreiben; `set e := basis i` blockiert `← Space.deriv_eq` in `simp`; Fortsetzungszeilen in
  `(by simpa … using …)` tiefer einrücken als der Taktikbeginn.

Weiter (G2/G3, Regularisierung — Fubini-Weg verworfen: `Space.slice` hat kein
`MeasurePreserving`-Lemma):
- `ψ_ε(y) = R(√(‖y‖²+ε²)) P(y)`, `R = radialFactor κ N α`; `G_ε(s) = R(√(s+ε²))` ist für `s ≥ 0`
  differenzierbar (PR 05: `hasDerivAt_radialFactor` global, `hasDerivAt_comp_sqrt`).
- Ableitungsformeln für alle `y` (wie im Beweis von `laplacian_radial_mul`, aber ohne `y ≠ 0`):
  `∂ᵢψ_ε = G ∂ᵢP + 2yᵢ G' P`, `∂ᵢ∂ᵢψ_ε = G ∂ᵢ∂ᵢP + 4yᵢ G' ∂ᵢP + (2G' + 4yᵢ² G'') P`.
- Für festes ε polynomiale Schranken (1/ρ ≤ 1/ε) ⇒ G1 anwendbar.
- G3: `Δψ_ε = [(2l+d) R'(ρ)/ρ + (‖y‖²/ρ²)(R''(ρ) - R'(ρ)/ρ)] P → Δψ` für `y ≠ 0`;
  Majorante `C(1 + 1/‖y‖)(2+‖y‖)^k |P|` (ε ≤ 1); dominierte Konvergenz beidseitig.

### 2026-10-21 23:44: G2 erledigt
- `deriv_radial_mul`, `deriv_deriv_radial_mul`: Ableitungen von `G(‖y‖²)Q` an jedem Punkt (nur
  `G` auf `[0,∞)` differenzierbar nötig).
- `regG/regG'/regG''` (`f(√(s+ε²))` und Ableitungen), `hasDerivAt_regG(')` aus PR 05
  `hasDerivAt_comp_sqrt(')`.
- Schranken: `IsPolyBounded.mono/of_abs_le_const/neg`, `abs_le_regRadius` (`|ε| ≤ ρ`),
  `isPolyBounded_regRadius`, `isPolyBounded_poly_exp_regRadius`, `isPolyBounded_inv_regRadius`,
  `isPolyBounded_regG/regG'/regG''`.
- `integral_regBoundState_mul_sum_deriv_deriv`: G1 für `ψ_ε` (`ε ≠ 0`), inkl. `ContDiff ℝ 2`
  (`Polynomial.contDiff_aeval`, `ContDiff.sqrt`). Commit lokal.
Offen: G3 (Grenzwert ε → 0) und Integrierbarkeit des Potentialterms; dann ist das sorry weg.
Plan G3: dominierte Konvergenz mit ε = 1/(n+1); Majoranten uniform in ε ≤ 1:
LHS `C(1+‖y‖)^k |P| ‖Σ∂∂f‖`, RHS `C(1+‖y‖⁻¹)(1+‖y‖)^k |P| ‖f‖`; Integrierbarkeit der RHS-Majorante
über Polarkoordinaten (`integrable_fun_norm_addHaar`, d ≥ 2) oder `IsDistBounded`.

(Korrektur 23:58: Die Uhrzeiten in den Überschriften seit 22:59 waren teils geschätzt und falsch;
sie sind jetzt durch die Commit-Zeitpunkte ersetzt.)

### 2026-10-21 23:56: G3 und Potentialterm erledigt — E3 Schritt e fertig, kein `sorry`
Branch `hydrogen-bound-states-adjoint` (lokal, 20 Commits über `hydrogen-bound-states-l2`
53805fce, nicht gepusht), Datei `BoundStatesL2.lean` (1244 Zeilen).
- G3: `integrable_inv_norm_mul_one_add_norm_pow` (Polarkoordinaten,
  `integrable_fun_norm_addHaar`, d ≥ 2), `Polynomial.exists_abs_eval_le`,
  `IsPolyBounded.integrable_abs_mul_norm_schwartz`, `IsPolyBounded.integrable_inv_norm_mul`,
  `exists_abs_poly_exp_regRadius_le` (gleichmäßig in |ε| ≤ 1), `laplacian_regBoundState`
  (`Δψ_ε = ((4l+2d)G_ε' + 4‖y‖²G_ε'')P` für y ≠ 0, auch ε = 0, über PR 05
  `laplacian_radial_mul`), `boundState_eq_regG` (ψ = ψ_0),
  `exists_abs_laplacian_regBoundState_le` (`|Δψ_ε| ≤ (A(1+‖y‖)^k₁‖y‖⁻¹ + C(1+‖y‖)^k₂)|P|`),
  `integral_boundState_mul_sum_deriv_deriv` (∫ψΣ∂∂f = ∫Δψ f; dominierte Konvergenz beidseitig mit
  ε_n = 1/(n+1), Grenzwerte gleich per `tendsto_nhds_unique`).
- `integral_boundState_mul_hamiltonian` (Green mit Potential) bewiesen: Integrierbarkeit von ψS (H1),
  ψVf (P2, |V| = k/‖y‖), Δψ f (Schranke bei ε = 0).
- Damit bewiesen: `inner_boundStateHS_hamiltonianOperator` (schwache Eigenwertgleichung),
  `boundStateHS_mem_adjoint_domain`, `adjoint_boundStateHS` (Hypothese: dom H dicht).
- `check_pr.sh adj`: alles OK außer `theorem_lint` (bekannte Ursache: .olean von
  `Time/ManifoldCurves.lean` fehlt auf Basis a46a93e9; BoundStatesL2.lean hat 0 `theorem`).
  Axiome Standard, `sorry` 0.
- Offen/Hinweise: (1) Dichtheit von dom H (für d ≥ 3: Schwartz ⊆ dom V, da 1/r ∈ L²_loc) ist nur
  Hypothese. (2) Die Datei ist lang; vor einem PR evtl. teilen (L²-Teil / Adjungierten-Teil) und
  Hilfslemmata (IsPolyBounded, Integrierbarkeit, `deriv_ofReal`, `deriv_schwartz`,
  Green G1) an passendere Orte verschieben. (3) Viele `wip:`-Commits — vor Push zusammenfassen.

### 2026-10-22 11:30: Zustand nach Verbindungsabbruch geprüft; Plan-Schritt 6 erledigt
- Arbeitsbaum war sauber (keine halbfertigen Änderungen), HEAD f1a4ee9e. `lake build` des Moduls
  jetzt bestätigt grün (3337 Jobs), kein `sorry`.
- Schritt 6 (ganzes Niveau): `boundStateMap_single`, `boundStateMapHS_single`
  (`Ps = Σ Pi.single l (Ps l)` statt `Lp`-Summen — Mathlib hat kein `Lp.coeFn_sum`),
  `inner_boundStateMapHS_hamiltonianOperator`, `boundStateMapHS_mem_adjoint_domain`,
  `adjoint_boundStateMapHS` (Hypothese dom H dicht),
  `exists_finrank_eigenvectors_adjoint_three`: in d = 3 enthält der Eigenraum von `H†` zu `E_n`
  einen **reellen** Unterraum der Dimension `(n+1)²` (ℂ-Dimension nicht formuliert).
  Axiome Standard, `lint-style.py` grün. Commits lokal db1522f0 (wip), 196fb4c7; nicht gepusht.
- Nächster Schritt: Hypothese „dom H dicht“ abbauen. physlib hat
  `PolyBddSchwartzSubmodule d a` (Schwartz mit `‖x‖^{-k}|f| ≤ C_k`, k ≤ a) und
  `PolyBddSchwartzSubmodule.dense`. Plan: `PolyBddSchwartzSubmodule d 1 ≤ dom H`
  (`|f|/‖x‖` beschränkt und schnell fallend ⇒ `Vf ∈ L²`), daraus Dichtheit für alle d ≥ 1.

### 2026-10-22 11:45: Dichtheit von dom H bewiesen — E3 vollständig, ohne Zusatzhypothesen
- `polyBddSchwartzSubmodule_le_hamiltonianOperator_domain`:
  `PolyBddSchwartzSubmodule d ⌊2 - d/2⌋.toNat ≤ dom H` (für d ≥ 3 alle Schwartz-Abbildungen),
  aus physlib `radiusPowOperator_domain_ge` (s = -1), `momentumSqOperator_domain_eq`,
  `LinearPMap.smul_domain`, `HydrogenAtom.potential_eq`.
- `dense_hamiltonianOperator_domain`: dom H dicht, für **alle** d (über
  `PolyBddSchwartzSubmodule.dense`).
- Hypothese `hdense` aus `adjoint_boundStateHS`, `adjoint_boundStateMapHS`,
  `exists_finrank_eigenvectors_adjoint_three` entfernt. Axiome Standard, `sorry` 0,
  `lint-style.py` grün, Modul-Build grün. Commit lokal cd26c951; Branch
  `hydrogen-bound-states-adjoint` jetzt 23 Commits über 53805fce, **nicht gepusht**.
- Offen (Entscheidung Daniel): (1) WIP-Commits zusammenfassen; (2) Datei (≈1300 Zeilen) teilen
  (L²-Teil / Adjungierten-Teil) und Hilfslemmata (IsPolyBounded, `deriv_ofReal`,
  `deriv_schwartz`, Green G1, Dichtheit) an passendere Orte verschieben; (3) ℂ-Dimension
  `(n+1)²` des Eigenraums (bisher nur reeller Unterraum); (4) voller `check_pr.sh` /
  `lake build PhyslibAlpha` vor Push; (5) Push + PR-Text.
- Hinweis: `physlib-notes` hat kein `origin`-Ziel für Notizen — Push geht nach `fork`
  (Upstream jetzt auf `fork/notes/pr-texte` gesetzt). Die E3e-Notizen waren bis heute nicht
  gepusht.

## 2026-10-22 Aufräumen nach Daniels Freigabe (Reihenfolge 3 → 2 → 1 → 4)

### Plan Punkt 3: ℂ-Dimension `(n+1)²`
Ziel (d = 3): `∃ V : Submodule ℂ HS, finrank ℂ V = (n+1)² ∧ ∀ v ∈ V, v ∈ dom H† ∧ H† v = E_n v`,
mit `V = span ℂ (range boundStateMapHS)`.
1. Abstraktes Lemma (beliebiger ℂ-Innenproduktraum `E`): `v : ι → E` (ι endlich) mit
   `(⟪v k, v j⟫).im = 0` für alle k, j und `LinearIndependent ℝ v` ⇒ `LinearIndependent ℂ v`.
   Beweis: `Σ c_j v_j = 0`, `a = Re c`, `b = Im c`, `w_a = Σ a_j v_j`, `w_b = Σ b_j v_j`;
   `w_a = -i w_b`, also `⟪w_a, w_a⟫ = -i ⟪w_a, w_b⟫` reell und rein imaginär ⇒ `w_a = 0`, dann
   `w_b = 0`, ℝ-Unabhängigkeit ⇒ `a = b = 0`. Keine `Lp`-Summen nötig.
2. Gram-Einträge reell: `⟪boundStateMapHS Ps, boundStateMapHS Qs⟫ = ∫ (g_P g_Q : ℝ)` über
   `inner_mk_mk`/`coeFn_mk` und `integral_ofReal` ⇒ `im = 0`.
3. ℝ-Basis `b` des Definitionsbereichs (`Module.finBasis`), `v = boundStateMapHS ∘ b`:
   ℝ-unabhängig (Injektivität), also ℂ-unabhängig; `span ℂ (range boundStateMapHS) =
   span ℂ (range v)`; `finrank_span_eq_card` ⇒ `finrank ℝ (Def.-bereich) = (n+1)²`.
4. Eigenvektor-Eigenschaft auf `span ℂ` per `Submodule.span_induction` (0, +, ℂ-Vielfache;
   `H†` ist ℂ-linear).
Das reelle Korollar bleibt (billig) stehen, das komplexe kommt dazu.

### 2026-10-22 11:55: Punkt 3 erledigt (ℂ-Dimension)
`linearIndependent_complex_of_real_inner` (abstrakt, wie geplant), `im_inner_boundStateMapHS`,
`finrank_span_range_boundStateMapHS_three` (finrank ℂ des ℂ-Spanns = (n+1)²),
`exists_finrank_eigenvectors_adjoint_three_complex`. Build grün, Axiome Standard, Linter grün.
Commit lokal 1cc27d88. Als Nächstes: Vorschlag zur Aufteilung (Punkt 2).

### Vorschlag Punkt 2: Aufteilung von `BoundStatesL2.lean` (≈1450 Zeilen) — wartet auf Daniel
Inventar: §A IsPolyBounded (l. 76–168); §B Integrierbarkeit (177–320), danach in §B aber schon
Green G1 + Regularisierung (328–646); §C/§D L², Unabhängigkeit, ℂ-Dimension (654–846);
§E Adjungierte (860–1446), darin Dichtheit (1308–1331).

(a) `PhyslibAlpha/QuantumMechanics/Hydrogen/PolyBounded.lean` (~250 Z.) — `IsPolyBounded` +
    Integrierbarkeit: `one_add_pow_mul_exp_neg_le`, `integrable_sq_of_le_mul_exp`,
    `IsPolyBounded.integrable_ofReal_mul_schwartz`, `integrable_inv_norm_mul_one_add_norm_pow`,
    `Polynomial.exists_abs_eval_le`, `IsPolyBounded.integrable_abs_mul_norm_schwartz`,
    `IsPolyBounded.integrable_inv_norm_mul`. Inhaltlich nicht wasserstoffspezifisch (nur `Space d`);
    später ggf. nach `PhyslibAlpha/SpaceAndTime/Space/…` — für diesen PR im Hydrogen-Ordner lassen.
(b) `BoundStatesL2.lean` (Name bleibt, ~230 Z.) — §C, §D inkl. `linearIndependent_complex_of_real_inner`,
    `im_inner_boundStateMapHS`, `finrank_span_range_boundStateMapHS_three`. Importiert (a).
(c) `BoundStatesAdjoint.lean` (~900 Z.) — Green G1 + Regularisierung (`deriv_ofReal`,
    `deriv_schwartz`, `integral_ofReal_mul_sum_deriv_deriv`, `deriv_radial_mul`, `regG…`,
    `laplacian_regBoundState`, …), §E ohne Dichtheit (schwache Eigenwertgleichung, `H†`, ganzes
    Niveau, d=3-Korollare reell/komplex). Importiert (b) und (d).
    Optional (c) weiter teilen: (c1) `GreenIdentity.lean` (G1/G2/G3, ~550 Z.), (c2) Rest (~350 Z.).
    Empfehlung: ja, sonst ist (c) wieder die längste Datei.
(d) Dichtheit: **gehört nach Physlib**. Begründung: sie benutzt nur Physlib-API
    (`radiusPowOperator_domain_ge`, `momentumSqOperator_domain_eq`, `PolyBddSchwartzSubmodule.dense`,
    `HydrogenAtom.potential_eq`), nichts aus PhyslibAlpha; `Physlib/QuantumMechanics/Hydrogen/Basic.lean`
    importiert `Operators.Position` schon; sie ist ein natürlicher erster Schritt zu den dortigen
    TODOs (wesentliche Selbstadjungiertheit). Vorschlag: in `Hydrogen/Basic.lean` als
    `hamiltonianOperator_hasDenseDomain : H.hamiltonianOperator.HasDenseDomain` (Physlib-Prädikat aus
    `Unbounded.lean`) + `polyBddSchwartzSubmodule_le_hamiltonianOperator_domain`, im Namespace
    `QuantumMechanics.HydrogenAtom`.
    Folge: eigener kleiner Physlib-PR (strengere Prüfung, `theorem_lint` greift dort); die
    Alpha-Dateien hängen davon ab, bis er gemergt ist. Alternative: vorerst in Alpha (eigene Datei
    `HamiltonianDomain.lean`) und erst später verschieben.

Commit-Struktur (Punkt 1), neu aufgebaut auf `hydrogen-degeneracy-analytic` 7ad91892
(= Basis von 53805fce; die gepushten Branches `hydrogen-bound-states-l2`, `…-degeneracy-analytic`
bleiben unverändert): (d) → (a) → (b) → (c1) → (c2), ein Commit je Teil, jeder Commit einzeln
baubar. Inhalt am Ende identisch zu 1cc27d88 (Prüfung per `git diff` gegen 1cc27d88 bis auf die
Verschiebung).
Hinweis: Basis a46a93e9 ist alt (origin/master jetzt 8a6ce260); Rebase separat, nach Punkt 4.
Offene Fragen an Daniel: (i) (d) nach Physlib oder vorerst Alpha? (ii) (c) in c1/c2 teilen?

### 2026-10-22 11:55: Punkte 2 und 1 erledigt (Aufteilung, ein Commit je Teil); Punkt 4 Prüfläufe
Daniels Entscheidung: (d) nach Physlib, eigener Branch auf master; (c) in c1/c2 geteilt.

**Branch `hydrogen-dense-domain`** (lokal, auf origin/master 8a6ce260, 1 Commit fdd7f900, nicht gepusht):
`Physlib/QuantumMechanics/Hydrogen/Basic.lean`, neuer Abschnitt „C. Domain of the Hamiltonian“:
`HydrogenAtom.polyBddSchwartzSubmodule_le_hamiltonianOperator_domain`,
`HydrogenAtom.hamiltonianOperator_hasDenseDomain` (`lemma`, kein Eintrag in Theorems.txt — falls
`theorem` gewünscht: Daniel). Satz im Modul-Docstring ergänzt; Authors-Zeile nicht geändert.
Prüfung (`check_physlib_build.sh dense` = Schritte aus build.yml, + `check_pr.sh dense`):
`lake build -KCI --iofail` OK, check_file_imports, check_dup_tags, pseudo_lint, theorem_lint
Physlib QuantumInfo, module_doc_lint, api_map_lint, runPhyslibLinters OK; check_pr: build_alpha,
runPhyslibAlphaLinters, theorem_lint, module_doc_lint, alphaFileImports, noAlphaImports,
lint_style, alpha_python, codespell OK, sorry 0. → kann als erster PR raus (nach „ja“).

**Branch `hydrogen-bound-states-split`** (lokal, auf `hydrogen-degeneracy-analytic` 7ad91892,
nicht gepusht; ersetzt `hydrogen-bound-states-adjoint`, der als Sicherung unverändert bleibt):
- c3084668 (d) Cherry-Pick von fdd7f900
- 9a6dc607 (a) `PolyBounded.lean` (307 Z.)
- 1156a103 (b) `BoundStatesL2.lean` (255 Z.)
- 52f3b731 (c1) `GreenIdentity.lean` (296 Z., Docstring allgemein)
- f67ddc47 (c2) `BoundStatesAdjoint.lean` (741 Z.)
Jeder Teil nach dem Commit einzeln gebaut (Modul-Build grün). Abweichung vom Vorschlag: (c1) ist
kleiner/(c2) größer als geschätzt — nach (c1) kam nur der allgemeine Teil (G1, Ableitungen
radialer Funktionen, `regG` + Schranken); alles mit `boundState`/`radialFactor` (Grenzwert ε → 0)
steht in (c2). (c1) importiert über (a)/`Degeneracy` auch `Eigenfunctions` (für
`hasDerivAt_comp_sqrt`).
Inhaltsprüfung gegen 1cc27d88 (Zeilen-Multimenge): Code identisch bis auf die 2 nach Physlib
verschobenen Lemmata und 2× `adjoint_apply_eq H.hamiltonianOperator_hasDenseDomain`; dabei einen
verlorenen Docstring (`deriv_ofReal`) gefunden und per Fixup in (c1) korrigiert.
`check_pr.sh split`: build_modules, build_alpha (`lake build PhyslibAlpha`), runPhyslibAlphaLinters,
module_doc_lint, alphaFileImports, noAlphaImports, lint_style, alpha_python, codespell OK, sorry 0;
**theorem_lint FEHLER** — Werkzeugabbruch beim Laden (`import Physlib.Meta.Linters.Sorry failed,
environment already contains 'pseudoExtension'`), bekanntes Problem der alten Basis a46a93e9, nicht
unser Code (neue Dateien enthalten 0 `theorem`; auf master-Basis war theorem_lint für (d) grün).
Verschwindet mit dem Rebase des Stapels auf master.
Offen: Push beider Branches (wartet auf „ja“); Rebase des Stapels auf master (nach Merge von (d)
fällt c3084668 weg); PR-Texte.

### 2026-10-22 11:58: Gepusht (nach Daniels „ja“) — Pause
- `fork/hydrogen-dense-domain` = fdd7f900 (neu), `fork/hydrogen-bound-states-split` = f67ddc47 (neu).
- Entscheidungen: `hamiltonianOperator_hasDenseDomain` bleibt `lemma` (kein Theorems.txt-Eintrag);
  Rebase des Alpha-Stapels erst nach Merge von (d).
- Noch keine PRs geöffnet, keine PR-Texte geschrieben.
- Nächste Schritte nach der Pause: PR-Text für (d); nach Merge von (d) den Stapel auf master
  rebasen (c3084668 fällt weg), dann theorem_lint erneut, PR-Text(e) für den Alpha-Stapel.
- Lokale Hilfsdateien außerhalb der Repos: `~/physlib_ci/check_physlib_build.sh` (Physlib-Schritte
  aus build.yml), `~/physlib_ci/scratch/` (Aufteilungsskript, wegwerfbar).

## Plan E4: Vollständigkeit der radialen Lösungen (noch kein Code)

### Ziel: die Annahme in PR 04 schließen
PR 04 (`radial_quantization`, `RadialQuantization.lean`) setzt die Lösung als
`radialSeries κ l c = ρ^(l+1) e^(-κρ) Σ c_k ρ^k` mit `EntireCoeff c`, `c 0 ≠ 0` voraus. E4 zeigt:
jede bei 0 reguläre Lösung hat diese Form.

**Hauptaussage (Vollständigkeit)**, `κ : ℝ` beliebig, `l : ℕ`, `u : ℝ → ℝ`, `q ρ = l(l+1)/ρ² - 2/ρ + κ²`:
- `∀ ρ > 0, DifferentiableAt ℝ u ρ ∧ DifferentiableAt ℝ (deriv u) ρ` (sonst ist `deriv` Unsinn),
- `∀ ρ > 0, deriv (deriv u) ρ = q ρ * u ρ` (gleiche Form wie `hode` in PR 04),
- Randbedingung bei 0: `Tendsto u (𝓝[>] 0) (𝓝 0)`,

⇒ `∃ c, EntireCoeff c ∧ RadialRec κ l c ∧ ∀ ρ > 0, u ρ = radialSeries κ l c ρ`;
ist `u` auf `(0, ∞)` nicht identisch 0, gilt zusätzlich `c 0 ≠ 0`.

Warum `u → 0`: die zweite Lösung verhält sich bei 0 wie `ρ^(-l)` (l ≥ 1, unbeschränkt) bzw. wie
`1 + O(ρ log ρ)` (l = 0, beschränkt, aber `u(0) ≠ 0`). `u → 0` schließt beide aus und ist die
physikalisch richtige Bedingung (für l = 0 ist `u₂/r ~ 1/r` zwar in L²(ℝ³), aber
`Δ(1/r) = -4πδ`, also nicht im Definitionsbereich). „Beschränkt“ würde für l = 0 nicht reichen.

**Folgerung (Quantisierung ohne Ansatz)** `radial_quantization_of_tendsto`: zusätzlich
`IntegrableOn (u²) (Ioi 0)`, `κ > 0` und `u ≢ 0` auf `(0, ∞)` ⇒
`∃ ν > l, κ = 1/ν ∧ ∃ C, ∀ ρ > 0, u ρ = C * radialU ν l ρ`.
Beweis: Vollständigkeit + `radial_quantization` (Übertragung von `hode`/Integrierbarkeit über
`EqOn` auf der offenen Menge `Ioi 0`, `Filter.EventuallyEq.deriv_eq`). Danach den Satz
„… is not formalised“ im Modul-Docstring von `RadialQuantization.lean` anpassen (eigener Commit
oder im E4-PR als Hinweis; Entscheidung Daniel).

### Mathlib-Werkzeuge für lineare ODEs (Stand Mathlib im Repo, Manifest-rev 56a00585)
Recherchiert in `Mathlib/Analysis/ODE/*`:
- **Vorhanden:** `IsIntegralCurveOn` (Basic); Picard–Lindelöf nur **lokal**
  (`IsPicardLindelof`, `exists_forall_mem_closedBall_exists_eq_forall_mem_Ioo_hasDerivAt`);
  Eindeutigkeit über Gronwall: `ODE_solution_unique_of_mem_Ioo`, `…_of_eventually`,
  `ODE_solution_unique_univ` (für `x' = v t x`, `v t` Lipschitz auf `s t`, E Banachraum, also
  auch für das System `(u, u') ∈ ℝ × ℝ`), `eq_zero_of_abs_deriv_le_mul_abs_self_of_eq_zero_right`.
- **Nicht vorhanden:** lineare ODEs als eigenes Konzept, globale Existenz für lineare Systeme,
  Lösungsraum = n-dimensional, Wronski-Determinante für Funktionen (nur
  `Polynomial.wronskian`), reguläre singuläre Punkte, Frobenius-Methode, analytische
  Lösungen analytischer ODEs (Cauchy–Kowalewskaja).
- **Sonst nützlich:** Quotientenkriterium `summable_of_ratio_test_tendsto_lt_one` /
  `summable_of_ratio_norm_eventually_le`; Monotonie aus Ableitungsvorzeichen
  (`antitoneOn_of_deriv_nonpos`); `is_const_of_deriv_eq_zero` / `constant_of_derivWithin_zero`
  bzw. `IsOpen.is_const_of_deriv_eq_zero` für die konstante Wronski-Funktion.

Folge: Frobenius in voller Allgemeinheit (zweite Lösung mit `log`-Term, da die Indexdifferenz
`2l + 1` ganzzahlig ist) wäre ein großes eigenes Projekt. **Wir brauchen sie nicht**: die
reguläre Lösung wird explizit als Reihe gebaut, die zweite Lösung nie konstruiert, sondern per
Wronski-Argument ausgeschlossen. Das ist ehrlicher Umfang für einen PR; im Docstring sagen, dass
die Frobenius-Lösung nur für den Exponenten `l + 1` gebaut wird.

### Beweisweg (elementar, ohne allgemeine ODE-Theorie)
1. **Umkehrung von `recursion_of_radial_ode`**: `EntireCoeff c ∧ RadialRec κ l c ⇒` `radialSeries`
   löst die Gleichung auf `(0, ∞)`. Mit `hasDerivAt_radialSeries`, `hasDerivAt_radialSeriesD`,
   `radial_identity`; fehlt nur: Reihe `ρW'' + (2l+2-2κρ)W' + (2-2κ(l+1))W` hat Koeffizienten 0
   (gleiche Reihe `d` wie im Beweis von `recursion_of_radial_ode` — dort ggf. als Lemma herausziehen;
   PR 04 nicht ändern, falls vermeidbar → eigenes Lemma in der neuen Datei).
2. **Existenz der regulären Lösung**: `c₁` per Rekursion mit `c₁ 0 = 1`
   (`c₁ (k+1) = (2κ(k+l+1) - 2) / ((k+1)(k+2l+2)) · c₁ k`); `EntireCoeff c₁` per Quotientenkriterium
   (`|c₁(k+1)| r^(k+1) / (|c₁ k| r^k) → 0`; Fall `c₁ k = 0` ab einem Index → `summable_of_ne_finset_zero`
   bzw. `summable_of_ratio_norm_eventually_le` deckt das ab). Setze `u₁ = radialSeries κ l c₁`.
3. **Asymptotik von `u₁` bei 0**: es gibt `δ > 0`, `0 < a ≤ b` mit `a ρ^(l+1) ≤ u₁ ρ ≤ b ρ^(l+1)` auf
   `(0, δ]` (aus `psum c₁ 0 = 1`, Stetigkeit von `psum`, `e^(-κρ)` beschränkt).
4. **Wronski-Funktion** `W = u u₁' - u' u₁` ist auf `(0, ∞)` konstant (Ableitung `u q u₁ - q u u₁ = 0`).
5. **W = 0 aus `u → 0`**: auf `(0, δ)` ist `(u/u₁)' = -W/u₁²`. Für `W ≠ 0` (oBdA `W > 0`, sonst `-u`):
   `g ρ = u ρ/u₁ ρ - W/(b²(2l+1)) ρ^(-(2l+1))` hat `g' ≤ 0`, also antiton ⇒ für `ρ ≤ δ/2`:
   `u/u₁ ≥ K ρ^(-(2l+1)) - M` mit `K > 0` ⇒ `u ρ ≥ a K ρ^(-l) - b M ρ^(l+1)`, Widerspruch zu `u → 0`
   (für l = 0 Grenzwert ≥ `aK > 0`). Keine Integrale nötig.
6. **u = A u₁ auf (0, δ)**: aus `W = 0` ist `(u/u₁)' = 0` auf `(0, δ)` ⇒ konstant `A`.
7. **Fortsetzung auf (0, ∞)**: `w = u - A u₁` löst die Gleichung, `w = w' = 0` auf `(0, δ)`.
   `ODE_solution_unique_of_mem_Ioo` für das System `(w, w')` mit `v t (x, y) = (y, q t x)` auf
   `Ioo a' b'` mit `0 < a' < δ` (Lipschitz-Konstante `max 1 (sup |q|)`, `q` dort beschränkt);
   `b'` beliebig ⇒ `w = 0` auf `(0, ∞)`. (Alternative ohne System: zweites Wronski-Argument mit
   `u₁ ≠ 0` — geht nicht global, `u₁` hat Nullstellen; daher Gronwall-Eindeutigkeit.)
8. **Zusammensetzen**: `c = A • c₁` (`EntireCoeff.const_mul`, `psum_const_mul`); `u ≢ 0 ⇒ A ≠ 0 ⇒ c 0 ≠ 0`.
9. **Folgerung** `radial_quantization_of_tendsto` (s. o.).

Schwierigste Teile: 5 (Ungleichungskette mit Potenzen, Vorzeichenfall) und 7 (Lipschitz-Nachweis
für das System, `Prod`-Norm). 3 und 2 sind Routine, 1 im Wesentlichen schon in PR 04 vorhanden.

### Branch und Datei
- Basis: **`fork/pr/hydrogen-quantisation` = e9f670d4** (auf #1900 a46a93e9 + radial d588e09d).
  Achtung: der lokale Branch `pr/hydrogen-quantisation` (7222a740) ist veraltet (alte Basis
  21da4ea5); Inhalt der Wasserstoff-Dateien gleich, aber **nicht** als Basis nehmen und nicht
  anfassen.
- Neuer Branch **`hydrogen-radial-completeness`** (lokal) von `fork/pr/hydrogen-quantisation`.
- Neue Datei `PhyslibAlpha/QuantumMechanics/Hydrogen/RadialCompleteness.lean` (importiert
  `RadialQuantization`, Namespace `PhyslibAlpha.Hydrogen`), Import in `PhyslibAlpha.lean`.
  PR 04 bleibt unverändert (bis auf evtl. Docstring-Satz, s. o.).
- Bekannt: Basis a46a93e9 ist alt → `theorem_lint` bricht dort mit dem `pseudoExtension`-Fehler ab
  (s. o.); unabhängig von E4, verschwindet mit Rebase nach Merge von radial/04.

### Schritte (je mit `lake build` des Moduls, nur ein Build gleichzeitig)
- S1: Datei + alle Aussagen (1–9) mit `sorry`, bauen.
- S2: 1 und 2 (Umkehrung, Existenz/`EntireCoeff c₁`).
- S3: 3 und 4 (Asymptotik, Wronski konstant).
- S4: 5 und 6 (W = 0, lokale Proportionalität).
- S5: 7 (Gronwall-Fortsetzung).
- S6: 8 und 9, kein `sorry`; `check_pr.sh`, PR-Text-Entwurf. Push erst nach „ja“.

Offene Fragen an Daniel: (i) Randbedingung `u → 0` bei `0⁺` so recht (Alternative: `u = O(ρ)`,
stärker, einfacher Beweis von 5, aber schwächeres Ergebnis)? (ii) Docstring-Satz in PR 04 im
E4-PR anpassen oder in PR 04 selbst? (iii) Branchname ok?

## 2026-10-22 14:45: Alpha-Stapel auf master rebased (nach Merge von #1930)
- #1930 = 8d676858 auf origin/master, Inhalt identisch zu fdd7f900.
- `git rebase --onto origin/master a46a93e9 hydrogen-bound-states-split`: konfliktfrei, c3084668
  automatisch verworfen („patch contents already upstream“). Neuer Stand (lokal, **nicht gepusht**):
  d82876a0 radial · 4b601af7 bound states · 2d239514 degeneracy · 618ba633 (a) · 3a9f119f (b) ·
  58f077ee (c1) · 850eaba2 (c2). Sicherung: Branch `backup/hydrogen-bound-states-split-pre-rebase` = f67ddc47.
- `check_pr.sh split`: alles OK, **theorem_lint jetzt grün**; build_modules, build_alpha,
  runPhyslibAlphaLinters, module_doc_lint, alphaFileImports, noAlphaImports, lint_style,
  alpha_python, codespell OK, sorry 0. Alle 8 Module neu gebaut (Oleans 14:44).
- Push von `hydrogen-bound-states-split` (force, da rebased) wartet auf „ja“.

## E4, Branch `hydrogen-radial-completeness` (lokal, von fork/pr/hydrogen-quantisation e9f670d4)
Daniels Entscheidungen: Randbedingung `u → 0` bei `0⁺`; Docstring von PR 04 im E4-PR anpassen
(PR 04 selbst bleibt); Branchname ok. Datei `PhyslibAlpha/QuantumMechanics/Hydrogen/RadialCompleteness.lean`.
Lokale WIP-Commits, am Ende zu einem Commit zusammenfassen.

### 2026-10-22 14:46: S1 erledigt — alle Aussagen mit `sorry`, Modul baut
Deklarationen: `radialPot`, `regCoeff`, `radialRec_regCoeff`, `entireCoeff_regCoeff`,
`radial_ode_of_radialRec`, `regSol_near_zero`, `wronskian_const`, `wronskian_eq_zero_of_tendsto`,
`exists_eqOn_near_zero_of_tendsto`, `eqOn_zero_of_eqOn_Ioo`, `radial_regular_solution`,
`radial_quantization_of_tendsto`. Lösungen in `HasDerivAt`-Form (`u`, `u'`); nur die beiden
Hauptsätze in `deriv`-Form wie PR 04. Hinweis: auf dieser Basis steht noch `-Dwarn.sorry=false`
im lakefile, `sorry`-Warnungen sieht man nur mit `lake env lean`.

### S2 erledigt — Umkehrung der Rekursion, Existenz der regulären Lösung
`radialRec_regCoeff` (field_simp), `entireCoeff_regCoeff` (`summable_of_ratio_norm_eventually_le`
mit Quotient ≤ 1/2 ab `k ≥ ⌈4(|κ|+1)r⌉`), `radial_ode_of_radialRec` (gleiche Reihe `d` wie in
`recursion_of_radial_ode`, hier identisch 0, dann `radial_identity`). Modul baut.

### S3 erledigt — Asymptotik bei 0, Wronski konstant
`regSol_near_zero` (δ = min(ε/2, 1), a = e^(-|κ|)/2, b = 3e^(|κ|)/2), Hilfslemma
`exists_const_of_hasDerivAt_zero` (über `IsOpen.exists_is_const_of_deriv_eq_zero`),
`wronskian_const`. Modul baut.

### S4 erledigt — W = 0 aus `u → 0`, lokale Proportionalität
Hilfslemma `wronskian_nonpos_of_tendsto` (ein Vorzeichen; Anwendung auf `u` und `-u` gibt
`wronskian_eq_zero_of_tendsto`): bei `W > 0` ist `g = u/u₁ - K (ρ^(2l+1))⁻¹`, `K = W/(b²(2l+1))`,
auf `(0, δ)` antiton (`antitoneOn_of_deriv_nonpos`, `g' = -W/u₁² + W/(bρ^(l+1))² ≤ 0`), also
`u ρ ≥ K a - |M| b ρ` für `ρ ≤ min(δ/2, 1)`; Widerspruch zu `u → 0` über `Ioo_mem_nhdsGT`.
Wie geplant ohne Integrale. `exists_eqOn_near_zero_of_tendsto`: `(u/u₁)' = 0` auf `(0, δ)`. Modul baut.

### S5 erledigt — Fortsetzung auf (0, ∞)
`eqOn_zero_of_eqOn_Ioo` mit `ODE_solution_unique_of_mem_Ioo` für `(w, w')`, `v t (x, y) = (y, q t x)`
auf `Ioo (m/2) (ρ+1)`, `m = min δ ρ`, Lipschitz-Konstante `max 1 C` (`C` Schranke von `|q|` auf dem
kompakten `Icc`, `IsCompact.exists_bound_of_continuousOn`), Startpunkt `t₀ = 3m/4`; `w' t₀ = 0` über
`HasDerivAt.unique`. Import: die Eindeutigkeitssätze stehen in `Mathlib.Analysis.ODE.ExistUnique`
(nicht `Gronwall`). Modul baut.

### 2026-10-22 14:56: S6 erledigt — E4 fertig, kein `sorry` (lokal, nicht gepusht)
`radial_regular_solution` (w = u - A u₁, `eqOn_zero_of_eqOn_Ioo`; `c = A · regCoeff`, `c 0 = A`)
und `radial_quantization_of_tendsto` (Vollständigkeit + `radial_quantization`, Integrierbarkeit per
`IntegrableOn.congr_fun`). `#print axioms`: nur propext, Classical.choice, Quot.sound.
Docstring von `RadialQuantization.lean` angepasst („not formalised“ → Verweis auf
`radial_regular_solution` / `radial_quantization_of_tendsto`). Eine aus dem Gedächtnis
eingefügte Literaturangabe (ODE-Lehrbuch) wieder entfernt — nur Sakurai (aus PR 04) bleibt.
WIP-Commits zu **ad29c408** zusammengefasst (auf e9f670d4); Datei 457 Zeilen, 15 Deklarationen.
`check_pr.sh e4`: build_modules, build_alpha, runPhyslibAlphaLinters, module_doc_lint,
alphaFileImports, noAlphaImports, lint_style, alpha_python, codespell OK, sorry 0;
theorem_lint FEHLER = bekannter Werkzeugabbruch der alten Basis (`pseudoExtension`).
Gegenprobe: temporäre Kopie des Stapels (radial, quantisation, E4) auf origin/master rebased
(konfliktfrei), `lake build -KCI --iofail PhyslibAlpha` grün (dort mit sorry-Warnungen aktiv),
theorem_lint grün; Temp-Branch gelöscht. Hinweis: theorem_lint braucht ein frisch gebautes
`PhyslibAlpha`-Root-Olean, sonst derselbe Abbruch.
PR-Text-Entwurf: `18-hydrogen-radial-completeness.md`.
Offen: Push (wartet auf „ja“); Basis des Branches ist alt — vor dem PR auf master rebasen
(nach Merge von radial/quantisation oder mit dem ganzen Stapel).

### 2026-10-22 15:27: Gepusht (nach Daniels „ja“) — Pause
- `fork/hydrogen-bound-states-split` = 850eaba2 (force-with-lease gegen f67ddc47, Stapel auf master).
- `fork/hydrogen-radial-completeness` = ad29c408 (neu, Sicherung, alte Basis e9f670d4).
- Entscheidung: Rebase auf master erst nach Merge des Radialfunktionen-PRs, dann der ganze
  Wasserstoff-Stapel in einem Durchgang. Bis dahin Pause.

## Rebase nach Merge von #1909 (2026-10-23 11:30), lokal, nicht gepusht
- `git fetch origin`: origin/master = `c7d9ebb4` (enthält #1909 `7f1556a0`, #1899 `8a6ce260`, #1900 `a46a93e9`).
- **fork/master liegt 12 Commits zurück**, darunter Workflow-Änderung `a353ac40` (#1805, `.github/workflows`)
  → Daniel: „Sync fork“.
- Rebase in einem Durchgang, konfliktfrei. Weggefallen: die Kopien von „radial functions“ (#1909;
  `a20754c1`, `d588e09d`, `d82876a0`), „generalised Laguerre polynomials“ (#1900; `21da4ea5`) und
  „spin-orbit coupling“ (#1899; `b0ddc7c3`, Datei identisch mit upstream). Inhaltsgleichheit vorher geprüft
  (`git diff` leer). E3 steht jetzt auf dem neuen 05, E4 auf dem neuen 04 (vorher eigene, inhaltsgleiche Kopien).
  Sicherung: `backup/<branch>-pre-1909-rebase`.

| Branch | neu | alt | Commits über origin/master |
|---|---|---|---|
| `pr/hydrogen-quantisation` (04) | `8b087409` | `7222a740` | 1 |
| `pr/hydrogen-bound-states` (05) | `99a2a911` | `349128d0` | 1 |
| `pr/fine-structure` (06) | `1a348f67` | `3487e3a3` | 1 |
| `hydrogen-bound-states-split` (E3) | `83377cd9` | `850eaba2` | 6 (auf 05) |
| `hydrogen-radial-completeness` (E4) | `1348df99` | `ad29c408` | 2 (auf 04) |

- `check_pr.sh` je Branch (`~/physlib_ci/REVIEW_rb-{04,05,06,E3,E4}.txt`): build_modules, build_alpha,
  runPhyslibAlphaLinters, module_doc_lint, alphaFileImports, noAlphaImports, lint_style, alpha_python,
  codespell OK; sorry 0 in allen geänderten Dateien.
- theorem_lint im ersten Lauf FEHLER bei allen fünf: 13 upstream-Namen (`Hₛ_*`, `HermitianMat.log*`) „not
  theorems“, weil die lokalen QuantumInfo-Oleans veraltet waren (check_pr.sh baut QuantumInfo nicht).
  Nach `lake build QuantumInfo`: theorem_lint OK bei allen fünf (`~/physlib_ci/THEOREM_LINT_rb.txt`).
- PR-Texte 04/05/06: Kopfzeile jetzt „Base: master“ plus eigene Zeile „Builds on … both merged“
  (04/05: #1909 und #1900; 06: #1899 und #1909). Eine `-blocked-by-PR`-Zeile gab es in den Texten nicht.
  Verweise „the radial functions PR“ / „the Laguerre PR“ durch Dateinamen ersetzt; in 06 den Satz
  „Only the last commit … is new“ entfernt (jetzt ein Commit). Deklarationslisten gegen die rebasten
  Dateien geprüft: vollständig, Art und Reihenfolge stimmen (33/22/11). Reviewer-Map: Abschnitte §A–§E
  stimmen mit den Dateien; referenzierte Upstream-Namen existieren auf origin/master.
