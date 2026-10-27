# 19 opalg-commute (v2): Inhaltsvorlage

Nur Inhaltsvorlage für Daniel (deutsche Stichpunkte); die PR-Beschreibung schreibt Daniel selbst auf Englisch
(Regel `00-Plan.md`, „Kommunikation“). Vorgängerfassung (englischer Entwurf zu `opalg-commute`, `10fb29af`) in der
Git-Historie dieser Datei.

Branch: `opalg-commute-v2` (`559bd061`) · Basis: master `3bfc7af8` · hängt von nichts Offenem ab · Bibliothek: Physlib
(`Mathematics/ForMathlib`)

## Titelvorschlag (sinngemäß)
feat(Mathematics): Umordnen kommutierender stetiger linearer Abbildungen in Kompositionen

## Worum es geht
- Antwort auf Josephs Frage im Zulip-Thread, was die Lemmata bringen: Der PR zeigt es an master selbst.
- Nach Mathlib-Vorbild im Typ-Namensraum und allgemein für `M →L[R] M` statt nur für Operatoren auf Schwartz-Räumen.
- Grund für die Lemmata: Auf `M →L[R] M` ist `f * g = f ∘L g` nur per `rfl` (`ContinuousLinearMap.mul_def`), daher
  finden `rw`/`simp` mit `Commute.left_comm`/`right_comm` das Muster in `∘L`-Termen nicht. Die zwei Lemmata sind die
  `∘L`-Fassung.

## Inhalt
- `ContinuousLinearMap.comp_left_comm_of_commute`: aus `Commute A B` folgt `A ∘L (B ∘L C) = B ∘L (A ∘L C)`.
- `ContinuousLinearMap.comp_right_comm_of_commute`: aus `Commute B C` folgt `(A ∘L B) ∘L C = (A ∘L C) ∘L B`.
- Voraussetzungen wie bei `mul_def`: `[Semiring R] [TopologicalSpace M] [AddCommMonoid M] [Module R M]`.
- Neue Datei `Physlib/Mathematics/ForMathlib/ContinuousLinearMap/Commute.lean`, importiert nur Mathlib, also
  unmittelbar für Mathlib geeignet.

## Gewinn (ehrlich, Zahlen aus `stand-opalg.md`)
- Kein eigenes Brückenlemma nötig: Die vorhandenen `a_comp_b_commute`-Lemmata sind definitional schon `Commute a b` und
  lassen sich direkt einsetzen, z. B. `comp_left_comm_of_commute (momentum_comp_commute _ _)`; sonst
  `commute_iff_lie_eq.mpr`.
- Auf master wird genau eine Stelle kürzer: `sum_LppL` in `LaplaceRungeLenzVector.lean`, Sortieren der Impulse,
  2 Zeilen → 1 (`simp` mit den beiden Permutationslemmata statt vier gezielter Umschreibungen).
- An drei weiteren Stellen funktioniert es auch (hA in `positionCompMomentumSqr_comm_radiusRegInvCompPosition_add`,
  `sum_rxrx`, `angularMomentum_commutation_radiusRegPow`), wird aber nicht kürzer; unverändert gelassen.
- Bilanz: +61 Zeilen neue Datei, +2 Importe, −1 Zeile Beweis.
- Ehrliche Einordnung für den Text: Auf master ist der Gewinn klein; der Hauptnutzen ist Lesbarkeit (keine gezielte
  Klammerung wie `← comp_assoc (𝐱 _) (𝐱 _) _`) und #1932 (`hxp`, `hr` werden zu je einem Term). Ggf. Joseph fragen, ob
  das reicht oder ob der PR erst zusammen mit/nach #1932 sinnvoll ist.

## Hinweise für den Text
- Nicht `@[simp]`: Permutationslemmata, gedacht als explizite `simp`-Argumente.
- Alte Fassung (`opalg-commute`) hatte `Commute.comp_left_comm` im `Commute`-Namensraum nur für Schwartz-Operatoren und
  ein Brückenlemma; beides entfällt.
- KI-Offenlegung (AI-POLICY.md §1.7) in Daniels eigenen Worten; Physlib-Review ist strenger als PhyslibAlpha.
