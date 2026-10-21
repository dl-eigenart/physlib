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
  Kein PR geöffnet, PR-Text noch nicht geschrieben. Offen: `Theorems.txt`-Eintrag bestätigen.
