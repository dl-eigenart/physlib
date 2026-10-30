# 22 proof-angular-golf: Inhaltsvorlage

Nur Inhaltsstichpunkte für Daniel (deutsch); die PR-Beschreibung schreibt Daniel selbst auf Englisch.

Branch: `proof-angular-golf` (`e1841802`, 1 Commit) · Basis: master `a62866f3` · hängt von nichts Offenem ab ·
Bibliothek: Physlib (nicht Alpha) · lokal, nicht gepusht

## Titel (Commit)
refactor(QuantumMechanics): shorten proofs of angularMomentum_commutation_angularMomentum and angularMomentum_cyclic_lrl

## Inhalt
- Reiner Beweis-PR: keine neuen Deklarationen, Aussagen und Namen unverändert.
- `angularMomentum_commutation_angularMomentum` (`Operators/AngularMomentum.lean`): Beweis 9 → 5 Zeilen. Statt punktweise
  auszuwerten (`ext`, `natCast_apply`, `ring`) werden die Kommutatoren aufgelöst und `module` schließt.
- `angularMomentum_cyclic_lrl` (`Hydrogen/LaplaceRungeLenzVector.lean`, aus #1932): Beweis 9 → 4 Zeilen. Die lokalen
  Hilfsaussagen `hxp`, `hr` entfallen; die Umordnung macht Mathlibs `Commute.left_comm` nach `← ContinuousLinearMap.mul_def`.
- Bilanz: 2 Dateien, +7 −16, netto −9 Zeilen.

## Bezug
- Folgt aus der Diskussion zu #1990 (geschlossen): gloges' Hinweis, dass die dort neuen Lemmata Spezialfälle von Mathlib sind;
  hier dieselbe Vereinfachung nur mit vorhandener Mathlib-API.

## Prüfung
- check_pr.sh (mit `build_roots`) 11/11, ci_physlib.sh 11/11, sorry 0 (`REVIEW_golf.txt`, `REVIEW_golf-physlib.txt`).
- Keine Einzeiler-Deklarationen (Regel „Vorhandenes zuerst“): es gibt keine neuen Deklarationen.

## Hinweise
- KI-Offenlegung (AI-POLICY.md §1.7) in Daniels eigenen Worten.
