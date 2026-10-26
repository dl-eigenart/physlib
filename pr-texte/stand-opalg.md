# Operator-Algebra-Automatisierung: Bestandsaufnahme (2026-10-26)

Anlass: Review von gloges zur LRL-PR (`hxp`, `hr` in `LaplaceRungeLenzVector.lean`): „These both say that
`A(BC) = B(AC)` when `[A,B]=0` … we need to improve our operator algebra automation tools.“
Nur Bestandsaufnahme, kein Code im Repo. Grundlage: losgelöster Worktree auf origin/master `7823e144` (danach entfernt);
Lean-Proben mit der Umgebung der Hauptkopie (gleiches `lake-manifest.json`, Operator-Dateien identisch mit master) in einer
Scratch-Datei unter `/tmp` (danach gelöscht). Alle Namen unten per grep bzw. `#check` geprüft.

## 1. Zählung (origin/master `7823e144`)

Operator-Algebra auf `𝓢(Space d, ℂ) →L[ℂ] 𝓢(Space d, ℂ)` findet sich praktisch nur in drei Dateien:

| Datei | `∘L` | Rolle |
|---|---|---|
| `Physlib/QuantumMechanics/Hydrogen/LaplaceRungeLenzVector.lean` | 97 | Hauptverbraucher |
| `Physlib/QuantumMechanics/Operators/Commutation.lean` | 23 | Grundlemmata |
| `Physlib/QuantumMechanics/Operators/AngularMomentum.lean` | 10 | Drehimpuls |

(alle übrigen Dateien ≤ 9, meist ohne Umordnung; PhyslibAlpha 0 Treffer für die Umordnungslemmata)

| Muster | Physlib (Treffer / Dateien) | PhyslibAlpha |
|---|---|---|
| `comp_eq_comp_add_commute` | 9 / 3 | 0 |
| `comp_eq_comp_sub_commute` | 5 / 2 | 0 |
| `← comp_assoc` | 19 / 2 (LRL 18, AngularMomentum 1) | 0 |
| `comp_assoc` ohne `←` | 27 / 2 | 5 / 4 |
| `leibniz_lie` / `lie_leibniz` | 48 / 5 | 11 / 10 |
| Deklarationen `*_commutation_*` in `QuantumMechanics/` | 50 in 7 Dateien (davon ≈ 12 `@[simp]`) | – |
| Deklarationen `*_comp_*_commute` | 7 (+ die zwei `comp_eq_comp_*`) | – |
| Verwendungen `*_comp_*_commute` | 47 | – |
| `mul_def` (Brücke `*` ↔ `∘L`) | 43 in `QuantumMechanics/` | – |
| `mul_assoc` bei Operatoren | ≈ 2 (Commutation.lean:232, LRL:495); alle übrigen Treffer sind Skalare | – |
| Mathlib-`Commute` bei Operatoren | 0 (einziger QM-Treffer: `SpectralMeasure.lean:111`, Projektoren) | – |

Fundstellen `comp_eq_comp_*_commute`: Commutation.lean:104, 112, 134, 143, 174, 213; AngularMomentum.lean:323, 330, 346, 355;
LRL:236, 336. Fundstellen `← comp_assoc`: LRL:234, 237, 335, 338, 360, 435, 445, 450, 453, 455, 456, 461, 478/479, 487, 509,
510; AngularMomentum.lean:320. Im offenen LRL-PR zusätzlich `hxp`, `hr` (je 2 Zeilen Aussage + 2 Zeilen Beweis).

## 2. Musterklassen

- **K1 Kommutator null → Vertauschungslemma** (`a_comp_b_commute`): Aussage 1 Zeile, Beweis immer
  `rw [comp_eq_comp_add_commute, X_commutation_Y, add_zero]` (1 Zeile). 7 Deklarationen, z. B. `position_comp_commute`
  (Commutation.lean:103), `angularMomentum_comp_radiusRegPow_commute` (AngularMomentum.lean:322). Kosten je ≈ 3 Zeilen.
- **K2 Vertauschen in einem längeren Produkt**: `← comp_assoc, ← comp_assoc, X_comp_Y_commute, comp_assoc` bzw. mit
  `comp_eq_comp_add_commute A, h, add_zero`. Lokale `have` wie `hxp`/`hr` (je ≈ 4 Zeilen) oder Teile von `simp_rw`-Ketten
  (LRL:234–237, 435, 450, 461, 509 f.; AngularMomentum.lean:320). Kosten 1–4 Zeilen je Stelle, dazu die Mühe, die
  Klammerung mit `comp_assoc (𝐱 _) (𝐱 _) _` gezielt zu treffen. **Genau das Muster aus dem Review.**
- **K3 Vertauschen mit Korrekturterm** (`a_comp_b_eq`, Kommutator ≠ 0): `rw [comp_eq_comp_sub_commute, X_commutation_Y]`,
  z. B. `momentum_comp_angularMomentum_eq` (AngularMomentum.lean:345), Commutation.lean:174, 213. `Commute` hilft hier
  nicht; 1–2 Zeilen je Stelle.
- **K4 Kommutatoren von Produkten** (Leibniz): `simp [leibniz_lie, lie_leibniz, X_commutation_Y, …]` oder
  `simp only [dotProduct, mul_def, lie_sum, lie_leibniz, …]`; AngularMomentum §E, NumberOperator, LadderOperators. Typisch
  2–5 Zeilen `simp only`-Listen. Funktioniert, ist aber das, was am meisten Lemma-Namen braucht.
- **K5 Ausmultiplizieren und Sortieren in Summen** (LRL `sum_ppL`, `sum_LppL`, `sum_Lprx`): `conv_lhs => enter [...]`,
  `sum_symmetrize`, Ketten aus K2 und Antisymmetrie; 5–20 Zeilen je Lemma.

## 3. Vorhandene APIs (geprüft)

| Name | Fundort | Aussage / Befund |
|---|---|---|
| `Ring.instBracket` | `Mathlib/Algebra/Ring/Commute.lean:251` | `Bracket R R := ⟨fun x y => x * y - y * x⟩` für jeden `NonUnitalNonAssocRing` (Priorität 100) |
| `Ring.lie_def` | `Mathlib/Algebra/Ring/Commute.lean:254` | `⁅x, y⁆ = x * y - y * x := rfl` |
| `commute_iff_lie_eq` | `Mathlib/Algebra/Ring/Commute.lean:258` | `Commute x y ↔ ⁅x, y⁆ = 0` |
| `Commute.lie_eq` | `Mathlib/Algebra/Ring/Commute.lean:260` | `Commute x y → ⁅x, y⁆ = 0` |
| `Commute.left_comm` | `Mathlib/Algebra/Group/Commute/Defs.lean:95` | `Commute a b → ∀ c, a * (b * c) = b * (a * c)` |
| `Commute.right_comm` | ebd. :91 | `Commute b c → ∀ a, a * b * c = a * c * b` |
| `Commute.mul_mul_mul_comm` | ebd. :99 | `Commute b c → ∀ a d, a * b * (c * d) = a * c * (b * d)` |
| `Commute.eq` | (`#check`) | `Commute a b → a * b = b * a` |
| `Commute.mul_right`/`mul_left` | `Commute/Defs.lean:81/87` | Abschluss unter Produkt |
| `Commute.add_right`/`add_left`/`neg_right`/`sub_right` | `Mathlib/Algebra/Ring/Commute.lean:34/39/61/94` | Abschluss unter `+`, `-` |
| `LieRing.ofAssociativeRing` | `Mathlib/Algebra/Lie/OfAssociative.lean:47` | `def`, keine globale Instanz; Mathlib und physlib setzen sie mit `attribute [local instance 100]` |
| `ContinuousLinearMap.mul_def` | `Mathlib/Topology/Algebra/Module/ContinuousLinearMap/Basic.lean:571` | `f * g = f ∘L g := rfl` (Mul ist `⟨comp⟩`) |
| `ContinuousLinearMap.one_def` | ebd. :374 | `1 = .id R M := rfl` |
| `ContinuousLinearMap.coe_mul` | ebd. | **deprecated** (2026-05-20) → `toLinearMap_mul`; `mul_apply` → `mul_apply_eq_comp` |
| `noncomm_ring` | `Mathlib/Tactic/NoncommRing.lean` | `simp only [...]` + `abel`; kennt keine Hypothesen über Kommutatoren |

physlib selbst (`Physlib/QuantumMechanics/Operators/Commutation.lean`): **kein eigener Kommutatorbegriff**, `⁅A, B⁆` ist
Mathlibs `Ring.instBracket` (`open Bracket`; `Mathlib.Algebra.Lie.OfAssociative` importiert). Eigene Hilfslemmata:
`leibniz_lie` (:62), `lie_leibniz` (:66), `comp_eq_comp_add_commute` (:70, `A ∘L B = B ∘L A + ⁅A, B⁆`),
`id_commutation` (:76), `comp_eq_comp_sub_commute` (:80, `A ∘L B = B ∘L A - ⁅B, A⁆`). Konvention laut Moduldocstring:
`a_commutation_b` (`⁅a,b⁆ = …`), `a_comp_b_commute` (`a ∘ b = b ∘ a`), `a_comp_b_eq` (`a ∘ b = b ∘ a + …`).
**Eine Brücke „Kommutator = 0 → `Commute`“ gibt es in physlib nicht**; sie ist auch unnötig, weil Mathlibs
`commute_iff_lie_eq` direkt auf physlibs `⁅⁆` passt (geprüft, s. u.).

Lean-Proben (alle grün, `lake env lean`):
- `#synth Ring (𝓢(Space d, ℂ) →L[ℂ] 𝓢(Space d, ℂ))` → `ring`.
- `A ∘L B = A * B := rfl`, `⁅A, B⁆ = A * B - B * A := rfl`, `⁅A, B⁆ = A ∘L B - B ∘L A := rfl`.
- `(h : ⁅A, B⁆ = 0) : Commute A B := commute_iff_lie_eq.mpr h`.

## 4. Probe `hxp` / `hr`

- `hxp` (Aussage `⁅𝐋 a b, 𝐱 ⬝ᵥ 𝐩⁆ = 0` als Hypothese, da nur im PR):
  `𝐋 a b ∘L ((𝐱[d] ⬝ᵥ 𝐩) ∘L Z) = (𝐱 ⬝ᵥ 𝐩) ∘L (𝐋 a b ∘L Z) := (commute_iff_lie_eq.mpr hLD).left_comm Z` — **1 Zeile
  Beweis, Term-Modus, ohne Brückenlemma** (heute 2 Zeilen `rw`).
- `hr` mit dem master-Lemma: `(commute_iff_lie_eq.mpr (angularMomentum_commutation_radiusRegPow a b ε (-1))).left_comm Z`
  — 1 Zeile.
- **Grenze:** `rw [h.left_comm]` und `simp only [h.left_comm]` greifen auf `∘L`-Terme **nicht** („Did not find an occurrence
  of the pattern `A * (B * ?c)`“ bzw. „simp made no progress“): `*` und `∘L` sind nur definitional gleich, nicht syntaktisch.
  Abhilfen, beide geprüft: `simp only [← mul_def, h.left_comm]` oder ein Lemma in `∘L`-Form
  `Commute.comp_left_comm (h : Commute A B) (Z) : A ∘L (B ∘L Z) = B ∘L (A ∘L Z) := h.left_comm Z`, das dann mit `rw` und
  `simp only` funktioniert.
- `simp only [h.left_comm]` in `*`-Form auf `A * (B * (C * Z)) + B * (A * (C * Z))` lief ohne Schleife durch
  (Permutationslemma, simp ordnet).
- Ergebnis: Die Inline-Haves `hxp`/`hr` (je 4 Zeilen) ließen sich durch je einen Term ersetzen oder ganz in die
  `simp only`-Liste des Beweises schieben (`(…).comp_left_comm`), sobald ein `∘L`-Lemma existiert.

## 5. Vorschlag (Daniel entscheidet; nichts davon umgesetzt)

**(a) Minimallemma + Brücke** — in `Commutation.lean` §A:
`lemma commute_of_commutation_eq_zero (h : ⁅A, B⁆ = 0) : Commute A B` (Alias für `commute_iff_lie_eq.mpr`, nur für die
Auffindbarkeit) und `Commute.comp_left_comm`, `Commute.comp_right_comm` in `∘L`-Form (je 1 Zeile Beweis über
`Commute.left_comm`/`right_comm`). Danach `hxp`/`hr` als Einzeiler bzw. inline.
Umfang ≈ 10–15 Zeilen, keine Änderung bestehender Beweise nötig. Risiko gering (Namenswahl; Lemmata im Namensraum
`Commute` für einen spezialisierten Typ sind ggf. umstritten – Alternative `ContinuousLinearMap.comp_left_comm_of_commute`).

**(b) Commute-Registrierung kommutierender Operatorpaare** — zu jedem `a_comp_b_commute` (K1, 7 Stück) bzw. jedem
`a_commutation_b = 0` ein `lemma a_commute_b : Commute a b`; die K1-Lemmata würden zu Einzeilern `(a_commute_b …).eq`.
Mit (a) dann Umordnung per `simp only [(a_commute_b …).comp_left_comm]` statt `← comp_assoc`-Ketten (K2).
Umfang ≈ 15–25 neue Zeilen, optional 10–30 Zeilen Vereinfachung in LRL. Risiko mittel: als `@[simp]` sind
Permutationslemmata heikel (Termordnung, mögliche Leistungseinbußen); daher **nicht** global `@[simp]`, nur als
explizite simp-Argumente. Abschluss unter Summen/Skalaren über `Commute.add_right` usw. vorhanden; eine
`Finset`-Summen-Variante habe ich nicht gesucht.

**(c) Taktik** — z. B. ein `op_comm`/`noncomm_ring`-Aufsatz, der `∘L` per `← mul_def` nach `*` normalisiert, gegebene
`Commute`-Fakten zum Sortieren nutzt und mit `noncomm_ring`/`abel` schließt; oder eine Normalform mit bekannten
Kommutatoren (K3/K4). Umfang ≥ 100–300 Zeilen Meta-Code, Wartung, Tests. Risiko hoch (Leistung, Robustheit, Review in
physlib; gloges nennt die Aufgabe selbst „admittedly vague“). Sinnvoll erst, wenn (a)/(b) gezeigt haben, welche
Muster übrig bleiben.

Empfehlung zur Reihenfolge: (a) klein und isoliert (eigener PR gegen Physlib), dann (b) an LRL ausprobieren und die
gesparten Zeilen messen; (c) nur nach Rücksprache mit gloges.

## Stufe (a) umgesetzt (2026-10-26 16:35), lokal, nicht gepusht
- Freigabe Daniel 26.10. Branch `opalg-commute` auf origin/master `7823e144`, ein Commit **`10fb29af`**,
  `Physlib/QuantumMechanics/Operators/Commutation.lean` +20 Zeilen (keine Löschung):
  `commute_of_commutation_eq_zero` (`commute_iff_lie_eq.mpr`), `Commute.comp_left_comm`, `Commute.comp_right_comm`
  (`_root_`, Term-Beweise über `Commute.left_comm`/`right_comm`), Docstrings; Hinweis im Overview des Moduldocstrings.
  Bestehende Beweise unverändert; `hxp`/`hr` erst nach dem Merge der LRL-PR (eigener Commit).
- Vorher per `#check` geprüft (Scratch unter `/tmp`, gelöscht): `commute_iff_lie_eq`, `Commute.left_comm`,
  `Commute.right_comm`, `ContinuousLinearMap.mul_def`, `comp_eq_comp_add_commute`; Namen in Mathlib/Physlib/Alpha frei.
  Anwendungsproben mit `rw [(…).comp_left_comm]` und `simp only [← comp_assoc, (…).comp_right_comm]` grün.
- Nebenbefund: PhyslibAlpha hat `commute_of_lie_eq_zero` für `Module.End` (`Sl2/BivariateBasis.lean:63`).
- Prüfung: check_pr.sh (`REVIEW_opalg-opalg-commute.txt`) 10/10 OK, sorry 0; zusätzlich die Physlib-CI-Schritte
  (`REVIEW_opalg-physlib.txt`): `lake build -KCI --iofail`, runPhyslibLinters, check_dup_tags, check_file_imports,
  pseudo_lint und theorem_lint (Physlib, QuantumInfo), api_map_lint, forMathlib_lint, auxillary_script_test – alle OK.
- PR-Text-Entwurf `19-opalg-commute.md` (mit KI-Offenlegung).
