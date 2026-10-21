# Auftrag für eine Claude-Sitzung auf agents-pc: Symmetriegruppen von 3j- und 6j-Symbolen

Repo: `/home/eigenart/physlib_ci/physlib`. Vorher holen:

```
git fetch https://github.com/dl-eigenart/physlib.git pr/wigner-3j:pr/wigner-3j pr/six-j-symmetry:pr/six-j-symmetry
```

## Ausgangslage

Die Modul-Docstrings behaupten mehr, als in Lean bewiesen ist:

- `PhyslibAlpha/QuantumMechanics/AngularMomentum/Wigner3j.lean`, Zeile 42: „These generate all 72
  symmetries of the 3j symbol.“ Bewiesen sind nur die Erzeuger (Regge-Transposition, zyklische
  Spaltenvertauschung, Spaltentausch und `m ↦ -m` mit Vorzeichen `(-1)^J`).
- `PhyslibAlpha/QuantumMechanics/AngularMomentum/SixJSymmetry.lean`, Zeile 38: „These generate the
  24 symmetries of the tetrahedron.“ Bewiesen sind `sixJSym_swap₁₂`, `sixJSym_swap₂₃`,
  `sixJSym_flip₁₂`.

## Aufgabe

1. **6j (Branch `pr/six-j-symmetry`, zuerst):** Die volle Invarianz als Lean-Satz formulieren und
   beweisen. Vorschlag: Die sechs Argumente als Kanten eines Tetraeders mit Ecken `Fin 4`
   indizieren (jede Triade ist eine Fläche), `S₄ = Equiv.Perm (Fin 4)` wirkt auf die Kanten.
   Satz: `∀ σ : Equiv.Perm (Fin 4), sixJSym (Argumente ∘ Kantenwirkung σ) = sixJSym (Argumente)`.
   Beweis: Die drei bewiesenen Erzeuger entsprechen drei Ecken-Transpositionen, die `S₄` erzeugen
   (z. B. benachbarte Transpositionen, Mathlib `Equiv.Perm.mclosure_swap_castSucc_succ` oder
   Induktion über `Equiv.Perm.swap_induction_on`). Zusätzlich prüfen, dass die Wirkung treu ist,
   damit „24“ im Docstring stimmt, oder „24“ aus dem Docstring streichen.
2. **3j (Branch `pr/wigner-3j`):** analog für das Regge-Symbol `R` (3×3-Matrix): Invarianz bis auf
   Vorzeichen unter Zeilen- und Spaltenpermutationen und Transposition, Gruppe der Ordnung 72
   (`S₃ × S₃ ⋊ ℤ/2`). Vorzeichen: `sign(σ)^J` bzw. die bewiesene Regel. Ist das zu aufwendig,
   den Satz für die 12 klassischen Symmetrien (Spaltenpermutationen und `m ↦ -m`) beweisen und
   den Docstring entsprechend formulieren.
3. Neue Sätze in „Key results“ und im Inhaltsverzeichnis des Moduls nachtragen, Docstring so
   anpassen, dass nur Bewiesenes behauptet wird.
4. `lake build PhyslibAlpha`, Pflichtlinter, kein `sorry`, `#print axioms` der neuen Sätze nur
   Standardaxiome.
5. Als eigenen Commit auf den jeweiligen Branch, Commit-Titel nennt die neuen Sätze, Trailer
   `Co-Authored-By` wie in `AGENTS.md`. Nicht pushen ohne Daniels „ja“.

Hinweis: `pr/six-j-symmetry` enthält die Commits von `pr/wigner-3j`, `pr/coupling-schemes` und
`pr/six-j`. Änderungen an `Wigner3j.lean` gehören auf `pr/wigner-3j` und werden danach in
`pr/six-j-symmetry` übernommen (rebase).
