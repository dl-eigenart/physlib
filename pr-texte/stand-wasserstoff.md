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

### Rechenweg (Plan für die nächsten Schritte)
1. Operatoren erhalten den Eigenraum `W` (aus `[H,L] = [H,A] = 0`); Einschränkung auf `W`,
   dort `H = E`.
2. `K = A/√(-2mE)`: `[K_i,K_{i+1}] = iℏ L_{i+2}`; `J± = (L ± K)/2`, `[J+,J-] = 0`,
   beide `AngularMomentumRepresentation` (nach Division durch ℏ).
3. `J+² - J-² = L·K = 0` (`Σ[L_i,K_i] = 0` ⇒ `L·K = K·L`).
4. `K² = -(L² + ℏ²) - mk²/(2E)` ⇒ `2(J+² + J-²) = L² + K² = -ℏ² - mk²/(2E)`.
5. Irreduzibler Teilraum von `W` für `J+`, dort `J+²/ℏ² = j(j+1)` (`Jsq_eq_smul`) ⇒
   `ℏ²(2j+1)² = -mk²/(2E)` ⇒ `E = -mk²/(2ℏ²n²) = energyLevel (n-1)`, `n = 2j+1`.
   Achtung: Schritt 5 braucht `J-²` auf demselben Vektor = `J+²`; das gibt 3. direkt.
6. (Später) Dimension von `W` Vielfaches von `n²`.
