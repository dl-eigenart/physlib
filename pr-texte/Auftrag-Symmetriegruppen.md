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

## Stand

- **Aufgabe 1 (6j) erledigt** am 21.10.: Commit `4832a35` auf `pr/six-j-symmetry`
  (`sixJSymEdge_comp_map`, `sym2_map_perm_injective`), Build und Linter grün, nur Standardaxiome.
- **Aufgabe 2 (3j) erledigt** am 21.10.: Commit `840e0e1` auf `pr/wigner-3j` (`threeJR_perm`,
  `perm_prodMap_injective`, `prodMap_ne_swap`); `pr/six-j-symmetry` darauf umgesetzt (`e6f3bc4`).
  Build und alle Pflichtlinter grün.

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

---

## Arbeitsweise (nach Abbruch wegen 32k-Ausgabelimit, 21.10.)

- In kleinen Schritten arbeiten: erst nur die Definitionen und Aussagen mit `sorry` in die Datei
  schreiben (Edit-Tool, nicht als Antworttext), bauen, dann ein `sorry` nach dem anderen schließen
  und nach jedem Schritt bauen. Nie den ganzen Beweis in einer Antwort ausgeben.
- Zum Ausprobieren eine eigene Datei `scratch/SixJTetra.lean` o. Ä. nutzen, am Ende in
  `SixJSymmetry.lean` §C übernehmen.

## Ausgearbeiteter Entwurf für Aufgabe 1 (6j) – bitte so umsetzen

Die vier Triaden von `sixJSym j₁ j₂ j₃ j₄ j₅ j₆` sind
`A = (j₁ j₂ j₃)`, `B = (j₁ j₅ j₆)`, `C = (j₄ j₂ j₆)`, `D = (j₄ j₅ j₃)`.
Nimmt man die Triaden als Ecken `0 = A, 1 = B, 2 = C, 3 = D` eines Tetraeders, ist jedes `j`
die Kante zwischen den zwei Triaden, die es enthalten:

| Kante | `{0,1}` | `{0,2}` | `{0,3}` | `{2,3}` | `{1,3}` | `{1,2}` |
|---|---|---|---|---|---|---|
| Argument | `j₁` | `j₂` | `j₃` | `j₄` | `j₅` | `j₆` |

Die drei bewiesenen Erzeuger sind dann Eckenpermutationen (von Hand nachgerechnet):

- `sixJSym_swap₁₂` (`j₁↔j₂`, `j₄↔j₅`) = `Equiv.swap 1 2`
- `sixJSym_swap₂₃` (`j₂↔j₃`, `j₅↔j₆`) = `Equiv.swap 2 3`
- `sixJSym_flip₁₂` (`j₁↔j₄`, `j₂↔j₅`) = `Equiv.swap 0 3 * Equiv.swap 1 2`

Vorgeschlagene Aussagen:

```lean
/-- The 6j symbol as a function of edge labels of the tetrahedron whose vertices are the four
triads. -/
def sixJSymEdge (j : Sym2 (Fin 4) → ℕ) : ℝ :=
  sixJSym (j s(0, 1)) (j s(0, 2)) (j s(0, 3)) (j s(2, 3)) (j s(1, 3)) (j s(1, 2))

/-- **Tetrahedral symmetry.** The 6j symbol is invariant under all 24 symmetries of the
tetrahedron. -/
theorem sixJSymEdge_comp_map (σ : Equiv.Perm (Fin 4)) (j : Sym2 (Fin 4) → ℕ) :
    sixJSymEdge (j ∘ Sym2.map σ) = sixJSymEdge j
```

Beweisplan:
1. Drei Lemmas `sixJSymEdge_comp_map_swap12`, `…_swap23`, `…_flip` aus den Erzeugern:
   `simp only [sixJSymEdge, Function.comp, Sym2.map_pair_eq]`, die Swap-Werte auf `Fin 4`
   mit `decide`/`Equiv.swap_apply_of_ne_of_ne` auswerten, Kanten mit `Sym2.eq_swap` normalisieren,
   dann das Erzeuger-Lemma anwenden.
2. Die Menge `{σ | ∀ j, sixJSymEdge (j ∘ Sym2.map σ) = sixJSymEdge j}` ist unter Produkt
   abgeschlossen (`Sym2.map_comp` bzw. `Sym2.map.comp`).
3. Alle sechs Transpositionen daraus (jede Gleichung mit `decide` prüfbar):
   `swap 0 3 = (swap 0 3 * swap 1 2) * swap 1 2`, `swap 1 3 = swap 2 3 * swap 1 2 * swap 2 3`,
   `swap 0 2 = swap 2 3 * swap 0 3 * swap 2 3`, `swap 0 1 = swap 1 2 * swap 0 2 * swap 1 2`.
4. Abschluss mit `Equiv.Perm.swap_induction_on` (Induktion über Produkte von Transpositionen).
5. Optional, damit „24“ wörtlich stimmt: Die Wirkung `σ ↦ Sym2.map σ` ist injektiv
   (`Function.Injective`, per `decide` über `Fin 4`). Sonst „24“ im Docstring weglassen und nur
   „every permutation of the four triads“ schreiben.

Danach Docstring §C und „Key results“ anpassen: `sixJSymEdge_comp_map` als Hauptsatz,
die drei Erzeuger als Spezialfälle.
