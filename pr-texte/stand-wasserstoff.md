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

## 2026-10-21 23:00: Umbau, Basen, Pushes (nach Daniels „ja“)
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

### 2026-10-21 23:05: `L ∧ A = 0`, Schritt 1 erledigt
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

### 2026-10-21 23:08: `L ∧ A = 0`, Schritt 2 erledigt
F1 `angularMomentum_cyclic_position`, F2 `angularMomentum_cyclic_momentum`,
F3 `angularMomentum_commutation_positionDotMomentum` bewiesen (rein algebraisch:
`momentum_comp_position_eq`, `position_comp_commute`, `momentum_comp_commute`, `KroneckerDelta.symm`
bzw. `lie_leibniz` + `KroneckerDelta.sum_smul`, Abschluss `module`/`abel`). AngularMomentum.lean ohne
`sorry`, `lake build` grün. Commit lokal, nicht gepusht. Offen: Schritt 3 (Hauptlemma, 2 `sorry`).

### 2026-10-21 23:12: `L ∧ A = 0`, Schritt 3 und 5 erledigt (lokal, nicht gepusht)
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

## 2026-10-21 23:15: `lrl-angular-cyclic` gepusht
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
