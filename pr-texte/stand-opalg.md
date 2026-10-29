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

## v2 nach Zulip (2026-10-27), lokal, nicht gepusht
- Anlass: Daniel schlug auf Zulip vor, die Lemmata nach Mathlib-Vorbild (`Module.End.commute_pow_left_of_commute`,
  `ContinuousLinearMap.IsIdempotentElem.commute_iff`) in den Typ-Namensraum zu legen und zu verallgemeinern; Joseph
  Tooby-Smith: „would be good to see what this gains us in a PR“.
- Branch `opalg-commute-v2` auf origin/master `3bfc7af8`, ein Commit **`559bd061`**; `opalg-commute` (`10fb29af`) bleibt
  als Backup.
- Neue Datei `Physlib/Mathematics/ForMathlib/ContinuousLinearMap/Commute.lean` (61 Zeilen inkl. Header/Moduldocstring):
  `ContinuousLinearMap.comp_left_comm_of_commute` (`Commute A B → A ∘L (B ∘L C) = B ∘L (A ∘L C)`) und
  `ContinuousLinearMap.comp_right_comm_of_commute` (`Commute B C → (A ∘L B) ∘L C = (A ∘L C) ∘L B`) für `M →L[R] M`.
  Voraussetzungen `[Semiring R] [TopologicalSpace M] [AddCommMonoid M] [Module R M]` = die von
  `ContinuousLinearMap.mul_def`; damit ist `M →L[R] M` ein Monoid und `Commute.left_comm`/`right_comm` (brauchen nur
  `Semigroup`) greifen (per `#check`/`#synth` geprüft). Import nur Mathlib (`forMathlib_lint` OK).
- Brückenlemma `commute_of_commutation_eq_zero` **weggelassen**: Die bestehenden K1-Lemmata (`position_comp_commute i j :
  𝐱 i ∘L 𝐱 j = 𝐱 j ∘L 𝐱 i` usw.) sind definitional schon `Commute (𝐱 i) (𝐱 j)` und werden direkt als Argument
  angenommen, auch mit Platzhaltern in `rw`/`simp_rw`/`simp` (geprüft). Wo nur `⁅A,B⁆ = 0` vorliegt, reicht
  `commute_iff_lie_eq.mpr`.
- Import der neuen Datei in `LaplaceRungeLenzVector.lean` (dem einzigen Verwender), nicht in `Commutation.lean`.

### Gewinn je Stelle (Zeilen des Beweisschritts vorher → nachher)

| Stelle (master `3bfc7af8`) | Klasse | vorher | nachher | Befund |
|---|---|---|---|---|
| K1-Lemmata (7×, Commutation.lean:104/112/134/143, AngularMomentum.lean:322/329/354) | K1 | 1 | 1 | `(commute_iff_lie_eq.mpr …).eq` ebenfalls 1 Zeile, passt nicht auf die Aussagezeile; **unverändert** |
| LRL:450–451 `sum_LppL`, Sortieren der `𝐩` | K2 | 2 | **1** | `simp [comp_left_comm_of_commute (momentum_comp_commute _ _), momentum_comp_commute]` ersetzt 4 gezielte Umschreibungen inkl. `← comp_assoc (𝐩 _)` und `sub_sub_sub_cancel_right`; **übernommen** |
| LRL:234–237 `hA` | K2 | 4 | 4 | `comp_left_comm_of_commute` statt `← comp_assoc … comp_assoc` und `← comp_assoc (𝐱 _) (𝐱 _) _` kompiliert, Inhalt ≈ 313 Zeichen passt nicht in 3 Zeilen; `simp`-Form scheitert; **unverändert** |
| LRL:509–510 `sum_rxrx` | K2 | 2 | 2 | kompiliert (eine `comp_finsetSum`/`comp_assoc`-Runde weniger), aber nicht kürzer; **unverändert** |
| AngularMomentum.lean:319–320 | K2 | 2 | 2 | kompiliert ohne `comp_neg`, `← comp_assoc`; nicht kürzer; **unverändert** |
| LRL:456–457 `sum_LppL` (Schluss) | K2 | 2 | – | `simp`-Form mit `(momentumSqr_comp_angularMomentum_commute _ _).symm` scheitert; **unverändert** |
| LRL:435, 428 (`sum_ppL`, `sum_pLp`), 461, 478 f., 487, 445 | K2 | je 1–2 | – | `← comp_assoc` dient dort nur der Klammerung bzw. der Satz ist schon 1 Zeile; nicht versucht/kein Gewinn möglich |

### Gesamtbilanz
- Beweise: −1 Zeile (eine Stelle, LRL:450 f.).
- Neu: +61 Zeilen (Datei), +1 Import in `Physlib.lean`, +1 Import in LRL.
- Netto **+62 Zeilen**. Auf master ersetzt das Werkzeug also kaum etwas: Die meisten `← comp_assoc` dienen der Klammerung,
  die Umordnungen stecken in langen `simp_rw`-Ketten, in denen der längere Lemmaname die gesparten Schritte auffrisst.
- Der eigentliche Nutzen liegt in #1932: `hxp`/`hr` (je 4 Zeilen) werden zu je einem Term bzw. entfallen (Probe 26.10.,
  §4), und in den Stellen gewinnt man Lesbarkeit (keine gezielte Klammerung `comp_assoc (𝐱 _) (𝐱 _) _` mehr), nicht Zeilen.
- Prüfung: check_pr.sh (`REVIEW_opalg-v2.txt`, jetzt mit `build_roots`) 11/11 OK, `ci_physlib.sh`
  (`REVIEW_opalg-v2-physlib.txt`) 11/11 OK, sorry 0.

## Stufe c: aesop-Regelsatz (Bestandsaufnahme und Entwurf, 2026-10-27; kein Code im Repo)

Anlass: gloges auf Zulip (27.10.): „build up an aesop ruleset to organize expressions, e.g. xs left of ps, a^dag left
of a, collect coefficients out front, move brackets. This could even be a separate aesop tactic like aesop_graph.“
Grundlage: Hauptkopie auf `opalg-commute-v2` (= master `3bfc7af8` + `559bd061`), Mathlib/aesop aus `.lake/packages`.

### 1. Wie Mathlib eigene Regelsätze baut (Fundstellen geprüft)
Muster immer: (a) eigene Init-Datei nur mit `declare_aesop_rule_sets [Name]`, (b) Regeln per
`attribute [aesop <Phase> <Builder> (rule_sets := [Name])]` bzw. `add_aesop_rules`, (c) `macro`, das `aesop` mit
`(rule_sets := [Name, …])` und `config` aufruft. Grund für (a), wörtlich im Docstring der Init-Dateien: „Aesop rule sets
only become visible once the file in which they're declared is imported, so we must put this declaration into its own file.“

| Taktik | Init (Deklaration) | Regeln | Makro / Konfiguration |
|---|---|---|---|
| `aesop_graph` | `Mathlib/Combinatorics/SimpleGraph/Init.lean:20` `declare_aesop_rule_sets [SimpleGraph]` | `SimpleGraph/Basic.lean:45 f.` `attribute [aesop norm (rule_sets := [SimpleGraph])] symm_def`, `irrefl_def` | `Basic.lean:58` `macro (name := aesop_graph)`: `aesop $c* (config := { introsTransparency? := some .default, terminal := true }) (rule_sets := [SimpleGraph])`; dazu `aesop_graph?` und `:77` `aesop_graph_nonterminal` (`warnOnNonterminal := false`, Docstring: „Use this only for exploration! Nonterminal Aesop is even worse than nonterminal `simp`.“) |
| `continuity` | `Mathlib/Tactic/Continuity/Init.lean:19` `[Continuous]` | `Continuity.lean:17` `attribute [aesop (rule_sets := [Continuous]) unfold norm] Function.comp`; `:24` Attribut-Makro `macro "continuity" : attr => aesop safe apply (rule_sets := [Continuous])` | `:38` `aesop (config := { terminal := true }) (rule_sets := [Continuous])` |
| `bound` | `Mathlib/Tactic/Bound/Init.lean:19` `[Bound]` | `Bound.lean:191/198` `attribute [aesop unsafe 10% tactic (rule_sets := [Bound])] boundNormNum` bzw. `boundLinarith`; eigenes Attribut `@[bound]` in `Bound/Attribute.lean` | `:205` `boundConfig := { enableSimp := false, terminal := true }`, `:247` `aesop (rule_sets := [Bound, -default]) (config := Bound.boundConfig)` |
| **`commutes` (QuantumInfo!)** | `QuantumInfo/ForMathlib/Tactic/Commutes/Attribute.lean:20` `declare_aesop_rule_sets [Commutes] (default := false)` | `Commutes.lean:67 ff.` `aesop safe apply`/`unsafe apply 5%`/`add_aesop_rules safe tactic`/`aesop simp` für `Commute`-Abschlusslemmata | `:49` `syntax "commutes"`, `aesop (config := { introsTransparency? := some .reducible, terminal := true, useSimpAll := false, useDefaultSimpSet := false }) (rule_sets := [Commutes, -default])`; 203 Zeilen, 16 Verwendungen in QuantumInfo |

Weitere: `Finset/Attr.lean:21` `[finsetNonempty] (default := true)`, `Tactic/SetLike.lean:25 f.`, `Measurability/Init.lean:20`,
`CategoryTheory/Category/Init.lean:22`. Nebenbefund: `commutes` beweist Ziele `Commute A B` – genau die Argumente, die
`comp_left_comm_of_commute` braucht; Physlib importiert QuantumInfo schon (z. B. `StatisticalMechanics/…/ThermoQuantities.lean`).

### 2. Eignet sich aesop zum Umordnen/Normalisieren?
- aesop ist eine **Beweissuche** (README: Suchbaum, safe/unsafe-Regeln, „stopping if the root goal has been proved“).
  Umschreiben passiert ausschließlich in der **Normphase**: README (Suchschleife): „Run `simp` on all hypotheses and the
  target, using the global simp set … plus Aesop's `simp` rules“, eingerahmt von `norm`-Regeln mit negativer/positiver
  Strafe; `maxNormIterations := 100` (`Aesop/Options/Public.lean:65`). `safe`/`unsafe`-Regeln verzweigen bzw. wenden
  Lemmata an (`apply`, `cases`, Taktiken) – zum Sortieren eines Terms tragen sie nichts bei.
- Nicht-terminal: `terminal := false` (Voreinstellung, `Public.lean:113`) liefert „the goals remaining after safe rules were
  applied“ („safe prefix“, `:66–75`), mit Warnung (`warnOnNonterminal`, `:118`). Mathlib rät davon ab (Zitat oben).
- **Probe bestätigt das:** `aesop?` auf das Beispiel unten liefert als Skript `simp_all only [Ring.lie_def, mul_def,
  comp_assoc, momentum_comp_position_eq, comp_sub, momentum_comp_position_comp, comp_smul, comp_id]` + `module` – die
  ganze Arbeit ist ein `simp only`; aesop steuert nur den Abschluss bei. Die Gegenprobe mit `simp only [dieselben Regeln]`
  + `module` schließt dieselben Ziele.
- Folgerung: Für „organize expressions“ ist das passende Werkzeug ein **eigenes simp-Set** (`register_simp_attr`, Beispiele
  `Mathlib/Tactic/Attr/Register.lean:26 ff.` `functor_norm`, `monad_norm`, `parity_simps`, `rclike_simps`; eigene Datei wegen
  Reihenfolge wie bei aesop) bzw. für Sonderfälle eine **simproc**. aesop lohnt als dünne Hülle `aesop_op` = Normalisieren +
  Abschluss (`module`/`abel`/`ring_nf`), analog `commutes`; eine nicht-terminale Variante nur zum Erkunden.

### 3. Was physlib schon hat
- **Normalordnung/Wick (QFT):** `FieldSpecification.normalOrderRel` (`QFT/PerturbationTheory/FieldSpecification/NormalOrder.lean:30`,
  Erzeuger vor Vernichtern über `CreateAnnihilate.normalOrder`, `CreateAnnihilate.lean:42`), `normalOrderSign :=
  Wick.koszulSign …` (`:54`), `normalOrderList`, `FieldOpFreeAlgebra.normalOrderF` (`FieldOpFreeAlgebra/NormalOrder.lean:46`,
  Notation `𝓝ᶠ(a)`) als **lineare Abbildung, per `Basis.constr` auf Listen definiert**. Sortiert wird also kombinatorisch
  (Einfügesortieren auf `List`, Vorzeichen per Koszul), nicht per Umschreiben – kein Vorbild für eine Taktik, aber die
  Zielordnung „cr links von an“ ist dort festgelegt. Zeitordnung analog (`TimeOrder.lean`, `insertionSortMinPos`).
- **Leiteroperatoren:** `HarmonicOscillator/LadderOperators.lean` `loweringCLM`/`raisingCLM` (:75/:80),
  `lowering_commutation_raising : ⁅aᵢ, aⱼ†⁆ = δᵢⱼ • id` (:103), `lowering_commutation_lowering`, `raising_commutation_raising`
  (:120/:135), `raising_commutation_lowering` (:151); `NumberOperator.lean:122` `lowering_comp_raising : aᵢ ∘ aᵢ† = Nᵢ + 𝟙`
  (nur gleicher Index, über `numberCLM`). **Kein** Lemma `aᵢ ∘L aⱼ† = aⱼ† ∘L aᵢ + δᵢⱼ • id` – müsste ergänzt werden
  (eine Zeile über `comp_eq_comp_add_commute`). PhyslibAlpha: `LadderSystem` (`Mathematics/LadderSystem/Basic.lean:150`,
  abstrakt auf `Module.End`, `comm_a_ac` usw.).
- **x, p, L (Commutation.lean, AngularMomentum.lean):** in Zielrichtung „x links von p“ vorhanden:
  `momentum_comp_position_eq : 𝐩 j ∘L 𝐱 i = 𝐱 i ∘L 𝐩 j - (I*ℏ) • δ[i,j] • id` (Commutation.lean:172),
  `momentum_comp_radiusRegPow_eq : 𝐩 i ∘L 𝐫₀ ε s = 𝐫₀ ε s ∘L 𝐩 i - (s*I*ℏ) • 𝐫₀ ε (s-2) ∘L 𝐱 i` (:211),
  `momentum_comp_angularMomentum_eq` (AngularMomentum.lean:345), dazu die K1-Vertauschungen (`position_comp_commute`,
  `momentum_comp_commute`, `position_comp_radiusRegPow_commute`, …) und `positionDotMomentum_commutation_position`.
  Es fehlen die **Fassungen im Kontext** `𝐩 j ∘L (𝐱 i ∘L Z) = 𝐱 i ∘L (𝐩 j ∘L Z) - … • Z` (simp findet `𝐩 ∘ 𝐱` in rechts
  geklammerten Produkten sonst nur am Ende) – genau dafür sind `comp_left_comm_of_commute` (Vertauschungen) bzw. je ein
  Einzeiler (Korrekturterme) da.
- **Terminierung:** Ordnung der Erzeuger `𝐫₀ < 𝐱 < 𝐩` (bzw. `a† < a`), Produkte rechts geklammert. Maß je Monom:
  (Grad, Zahl der Fehlstände `p` vor `x`), lexikographisch, über die Multimenge der Monome. `p∘x → x∘p - c·δ·id` senkt die
  Fehlstände des Hauptterms um 1 und erzeugt einen Term mit Grad −2; `p∘𝐫₀^s → 𝐫₀^s∘p - c·𝐫₀^(s-2)∘x` senkt die
  Fehlstände (Korrekturterm: gleicher Grad, `p` durch `x` ersetzt, weniger Fehlstände); `a∘a† → a†∘a + δ` analog (Wick).
  Multimengenordnung über einer wohlfundierten Ordnung ist wohlfundiert ⇒ terminiert ([CITATION_NEEDED: Wohlfundiertheit der Multimengenordnung; ggf. Mathlib-Lemma suchen]). Gleichartige
  Faktoren (`x/x`, `p/p`, `𝐫₀/x`) sortiert simp mit **Permutationslemmata** nur, wenn das Ergebnis in der internen
  Termordnung kleiner ist – terminiert, aber die Reihenfolge der Indizes ist nicht steuerbar (für Gleichheitsziele egal,
  da beide Seiten gleich normalisiert werden). Gefahr: `L` (`𝐋 i j = 𝐱 i ∘ 𝐩 j - 𝐱 j ∘ 𝐩 i`) – entweder auflösen
  (`angularMomentumCLM` als Regel, Grad wächst einmalig) oder `L` als eigenen Erzeuger mit eigenen Regeln; **nicht beides**,
  sonst Schleife. Antisymmetrie `𝐋 j i = -𝐋 i j` nur gerichtet (nach Index) als Regel.

### 4. Probe (Scratch außerhalb des Repos, danach gelöscht)
Zwei Dateien unter dem Sitzungs-Scratchpad (`OpAesop/Init.lean` mit `declare_aesop_rule_sets [OpOrder]`, kompiliert mit
`lean --root` und `LEAN_PATH` der Hauptkopie; `OpAesop/Test.lean`). Regelsatz (alle `aesop norm simp (rule_sets := [OpOrder])`):
R1 `comp_assoc`; R2 `add_comp comp_add sub_comp comp_sub smul_comp comp_smul comp_id id_comp`, `Ring.lie_def mul_def`;
R3 `momentum_comp_position_eq` + Kontextfassung `momentum_comp_position_comp` (neu, 1 Zeile); R4 `position_comp_commute`,
`momentum_comp_commute` + Kontextfassungen über `comp_left_comm_of_commute` (neu, je 1 Zeile); R5 `dotProduct comp_finsetSum
finsetSum_comp Finset.sum_sub_distrib Finset.sum_add_distrib`; R6 `KroneckerDelta.sum_smul` + Skalare aus Summen (neu).
Makro `aesop_op := aesop (rule_sets := [OpOrder, -default]) (add safe (by module)) (config := { terminal := true,
useDefaultSimpSet := false })`. Ergebnisse (alle ≈ 2 s für die ganze Datei):

| Probe | Ziel | Ergebnis |
|---|---|---|
| 1 | `𝐩 j ∘L 𝐱 i ∘L 𝐩 k = X` (nicht-terminal) | normalisiert zu `𝐱 i ∘ 𝐩 j ∘ 𝐩 k - (I*ℏ) • δ[i,j] • 𝐩 k` ✔ |
| 2 | Commutation.lean:181 `⁅𝐱 i, 𝐩 j ∘L 𝐩 k⁆ = (I*ℏ) • (δ[i,k] • 𝐩 j + δ[i,j] • 𝐩 k)` | ohne `module`: bleibt als lineare Restgleichung stehen; mit `module` ✔ |
| 3 | Commutation.lean:186 `⁅𝐱 i, 𝐩 ⬝ᵥ 𝐩⁆ = (2*I*ℏ) • 𝐩 i` | erst mit R5+R6 ✔ |
| 4 | `𝐱 i ∘ 𝐱 j ∘ 𝐩 k ∘ 𝐱 i = 𝐱 j ∘ 𝐱 i ∘ 𝐱 i ∘ 𝐩 k - (I*ℏ) • δ[i,k] • (𝐱 j ∘ 𝐱 i)` | erst mit den Kontextfassungen von R4 ✔ |
| 5 | LRL-Muster `𝐱 i ∘ (𝐱 j ∘ Z) = 𝐱 j ∘ (𝐱 i ∘ Z)` | ✔ |
| 7 | `(𝐱 ⬝ᵥ 𝐩) ∘L 𝐱 i = 𝐱 i ∘L (𝐱 ⬝ᵥ 𝐩) - (I*ℏ) • 𝐱 i` (vgl. `positionDotMomentum_commutation_position`) | ✔ |
| Gegenprobe | Probe 3 als `simp only [R1–R6]; module` ohne aesop | ✔ |

### 5. Entwurf (Daniel entscheidet; nichts umgesetzt)
- **Kern als simp-Set, aesop als Hülle.** Name z. B. Attribut `op_norm` (`register_simp_attr op_norm`) und Taktik
  `op_norm` = `simp only [op_norm]` (normalisieren, nicht-terminal erlaubt wie `simp only`) sowie `aesop_op` = Normalisieren
  + Abschluss (`module`, ersatzweise `abel`), terminal, nach dem Muster von `commutes`/`aesop_graph`.
- **Dateien:** `Physlib/QuantumMechanics/Operators/OpNorm/Attr.lean` (nur `register_simp_attr` bzw.
  `declare_aesop_rule_sets [OpNorm] (default := false)`), `…/OpNorm/Basic.lean` (Makros, R1/R2/R5/R6 für allgemeine
  `M →L[R] M`), Regeln R3/R4 als `@[op_norm]` direkt an den bestehenden Lemmata in `Commutation.lean`/`AngularMomentum.lean`
  bzw. `LadderOperators.lean`, Kontextfassungen dort daneben. Test-Datei mit den Proben 1–7 + LRL-Zielen (z. B. `hA`,
  `sum_LppL`, `hxp`/`hr` aus #1932).
- **Regeln:** R1–R6 wie in der Probe; Leiter: `aᵢ ∘ aⱼ† → aⱼ† ∘ aᵢ + δ • id` (neu) + Kontextfassung, `aᵢ/aⱼ` und
  `aᵢ†/aⱼ†` als Permutationen; Radius: `momentum_comp_radiusRegPow_eq` + Kontextfassung, `position_comp_radiusRegPow_commute`,
  `radiusRegPowCLM_comp_eq`; `L` zunächst **auflösen** statt eigener Erzeuger.
- **Umfang:** Attr + Basic ≈ 40–60 Zeilen, Kontextfassungen ≈ 2 Zeilen je Paar (x/p, x/r, p/r, a/a†: ≈ 10–20 Zeilen),
  Tests ≈ 50–80 Zeilen; Anwendung auf LRL/AngularMomentum getrennt messen (wie in v2).
- **Risiken:** (i) Termordnung der Permutationslemmata nicht steuerbar → Normalform nicht „schön“, nur kanonisch;
  (ii) Grad- und Laufzeitwachstum bei langen Produkten (LRL hat Summen über Produkte mit 4–5 Faktoren; Ausmultiplizieren
  kann groß werden); (iii) `module` scheitert, wenn Koeffizienten nicht-triviale Körperrechnung brauchen (`ℏ`, `ε.1 ^ 2`,
  `√2`) → dann `ring_nf`/`field_simp` nötig, Abschluss unsicher; (iv) Schleifen bei unvorsichtiger Regelwahl (L auflösen und
  zugleich `L` als Ziel, Antisymmetrie ungerichtet); (v) Pflege: jede neue Operatorart braucht Kontextfassungen;
  (vi) nicht-terminale Nutzung ist in Mathlib verpönt – `op_norm` als `simp only`-Set ist dafür der saubere Weg;
  (vii) Review: Meta-Anteil klein (nur Makros), aber neue Konvention für ganz `QuantumMechanics/Operators`.
- **Empfehlung:** erst `op_norm` als simp-Set mit R1–R4 für x/p (kleiner PR, misst Gewinn an Commutation/LRL), dann
  Leiter und Radius; `aesop_op` als Hülle erst, wenn der Abschluss (`module`) an den echten Zielen zuverlässig greift.
  Als Rückmeldung an gloges (Daniel formuliert selbst): Probe zeigt, dass die Arbeit in der simp-Normphase steckt; aesop
  bringt nur den Abschluss; Vorbild `commutes` in QuantumInfo existiert bereits.

## v2 nach dem Merge von #1932 (2026-10-29), lokal, nicht gepusht
- Sicherung `backup/opalg-commute-v2-pre-1932` (`559bd061`); `move.sh opalg-commute-v2 3bfc7af8 origin/master` →
  `7d8a8499` (auf master `2fd010eb`, `Commute.lean` byteidentisch); zweiter Commit **`1f2c2d20`**
  „refactor(QuantumMechanics): reorder commuting operators in angularMomentum_cyclic_lrl“.
- In `angularMomentum_cyclic_lrl` (LRL, jetzt auf master): die Hilfsaussagen `hxp`, `hr` entfallen; die Umordnung steht in der
  `simp only`-Liste als `comp_left_comm_of_commute (commute_iff_lie_eq.mpr (angularMomentum_commutation_positionDotMomentum _ _))`
  und `comp_left_comm_of_commute (angularMomentum_comp_radiusRegPow_commute _ _ _ _)`. Aussage unverändert.
  (Für `𝐋`/`𝐱 ⬝ᵥ 𝐩` gibt es kein K1-Lemma `a_comp_b_commute`, daher dort `commute_iff_lie_eq.mpr`.)

| Stelle | vorher | nachher | Befund |
|---|---|---|---|
| LRL `angularMomentum_cyclic_lrl`: `have hxp` (4) + `have hr` (3) + `simp only` (2) | 9 | **4** | haves inline ersetzt; keine gezielte Klammerung `← comp_assoc, ← comp_assoc` mehr |

### Neue Gesamtbilanz (`opalg-commute-v2`, 2 Commits auf master `2fd010eb`)
- Beweise: −1 (LRL `sum_LppL`) −5 (`angularMomentum_cyclic_lrl`) = **−6 Zeilen**.
- Neu: +61 (Datei `Commute.lean`) +1 Import `Physlib.lean` +1 Import LRL = +63.
- Netto **+57 Zeilen** (`git diff --stat origin/master opalg-commute-v2`: 3 Dateien, +68 −11).
- Prüfung: check_pr.sh (`REVIEW_opalg-v2b.txt`) 11/11, ci_physlib.sh 11/11, sorry 0. Kein Push, kein PR.
- **29.10.: gepusht** (Daniels Ja) als neuer Fork-Branch `opalg-commute-v2` **`1f2c2d20`**; Daniel hat **#1990** eröffnet.
  Inhaltsvorlage `19-opalg-commute.md` (Stand v2 ohne hxp/hr-Commit; Bilanz jetzt −6 Beweiszeilen, netto +57).
