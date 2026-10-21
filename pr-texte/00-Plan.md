# physlib: Aufteilung des sl2-/Wasserstoff-Stapels in PRs

Stand 21.10.2026. Ausgangspunkt: `sl2-tetra-quant` von agents-pc (17 Commits über #1876),
umgesetzt auf das rebasete #1876 (`f755d95`). Alle 18 Lean-Dateien sind in jedem PR-Branch
byte-identisch mit dem Original auf agents-pc; geändert ist nur die Importliste `PhyslibAlpha.lean`.
**Stand 21.10.2026, agents-pc:** `lake build PhyslibAlpha` grün auf `pr/six-j-symmetry`,
`pr/wigner-eckart-cg`, `pr/projection-selection`, `pr/fine-structure`, `pr/hydrogen-quantisation`,
`pr/hydrogen-bound-states` (deckt alle Vorgänger ab). Pflichtlinter grün auf `pr/spin-orbit` und
`pr/laguerre`, 0 `sorry`.

**21.10., 16:40:** #1900 gemergt; `pr/hydrogen-radial`, `-quantisation`, `-bound-states`,
`pr/fine-structure` auf master `a46a93e` umgesetzt (Laguerre-Commit entfällt, Lean-Dateien unverändert).
Vor PR 03 auf agents-pc bauen und linten. Vor jedem weiteren PR die Linter auf dessen Branch laufen lassen.

Jeder PR fügt eine Datei bzw. ein Konzept hinzu. Die Branches liegen auf `dl-eigenart/physlib`.

## Abhängigkeiten

```
master ─┬─ 01 spin-orbit ──────────────┐
        ├─ 02 laguerre ─ 03 radial ─┬──┴─ 06 fine structure
        │                           ├──── 04 quantisation
        │                           └──── 05 bound states
        └─ #1876 Wigner-Eckart ─┬─ 08 projection/selection/irreducible
                                └─ 09 Clebsch-Gordan ─ 10 CG formulas ─┬─ 11 3j + sum rule ─┐
                                                                       └─ 12a coupling ─ 12b 6j ┴─┬─ 13 WE with CG
                                                                                                  └─ 14 6j symmetry
```

## Wellen

| Welle | PR | Branch | Zeilen | Wartet auf |
|---|---|---|---|---|
| **offen: #1899** (rebased, ready-to-merge) | 01 spin-orbit coupling | `pr/spin-orbit` | 189 | nichts |
| **gemergt: #1900** | 02 generalised Laguerre polynomials | `pr/laguerre` | 383 | nichts |
| **offen: #1909** | 03 radial functions of the hydrogen atom | `pr/hydrogen-radial` | 379 | 02 |
| nach #1909 | 04 quantisation of the hydrogen levels | `pr/hydrogen-quantisation` | 614 | 03 |
| nach #1909 | 05 bound states of the d-dimensional hydrogen atom | `pr/hydrogen-bound-states` | 329 | 03 |
| nach #1899+#1909 | 06 fine structure of hydrogen | `pr/fine-structure` | 193 | 01, 03 |
| **offen: #1910** | 08 projection theorem, selection rules, irreducible WE | `pr/projection-selection` | 742 | #1876 |
| **offen: #1911** | 09 normalised basis and Clebsch-Gordan coefficients | `pr/clebsch-gordan` | 792 | #1876 |
| nach #1911 | 10 closed formulas for Clebsch-Gordan coefficients | `pr/clebsch-gordan-formula` | 616 | 09 |
| nach 10 | 11 Wigner 3j symbols and the multipole sum rule | `pr/wigner-3j` | 583 | 10 |
| nach 10 | 12a the two coupling schemes of three angular momenta | `pr/coupling-schemes` | 507 | 10 |
| nach 12a | 12b recoupling coefficients and 6j symbols | `pr/six-j` | 447 | 12a |
| nach 11+12b | 13 Wigner-Eckart with Clebsch-Gordan coefficients | `pr/wigner-eckart-cg` | 221 | 11, 12b |
| nach 11+12b | 14 tetrahedral symmetry of the 6j symbols | `pr/six-j-symmetry` | 590 | 11, 12b |


Wichtig: 01 und 02 hängen **nicht** an #1876 und können sofort eingereicht werden. Damit laufen
zwei Review-Stränge parallel.

Gestapelte Branches (03–06, 08–14) enthalten die Commits ihrer Vorgänger. Beim Öffnen eines
gestapelten PRs `blocked-by-PR` in eine eigene Zeile schreiben; nach dem Merge des Vorgängers
auf master rebasen und `-blocked-by-PR` schreiben. 13 und 14 enthalten die Commits von 12a und 12b zusätzlich
zu 11; nach dem Merge von 11 und 12b auf master rebasen, dann sind sie weg.

Die frühere `SixJ.lean` (905 Zeilen) ist auf 12a `CouplingSchemes.lean` (Abschnitte A–D) und
12b `SixJ.lean` (Rekopplung und 6j) aufgeteilt. Der Lean-Code ist unverändert.

## Vor jedem PR auf agents-pc

```
cd /home/eigenart/physlib_ci/physlib
git fetch https://github.com/dl-eigenart/physlib.git <branch>:<branch>
git checkout <branch>
lake build PhyslibAlpha
```
Danach die Pflichtlinter wie bei den früheren PRs (Skripte in `teil11-6j-wasserstoff`).

## Kommunikation

Kommentare an Reviewer schreibt Daniel selbst (physlib `AGENTS.md` und `AI-POLICY.md` §3.1).
Die PR-Texte in diesem Ordner sind Entwürfe; jede Zeile vor dem Posten prüfen (§1.7),
Literaturangaben selbst prüfen (§2.1).


**21.10., 20:45:** #1910 (08) und #1911 (09) offen. Stapel 10–14 auf das neue `pr/clebsch-gordan`
(auf master `a945101`) umgesetzt, inkl. der neuen Symmetrie-Commits auf `pr/wigner-3j` und
`pr/six-j-symmetry`. Lean-Dateien unverändert. Vor dem nächsten PR auf agents-pc bauen.

## Wasserstoffspektrum (Langzeit)

- **E1 erledigt** (21.10., agents-pc): `hydrogen-pauli`, Commit `56a4ff7` auf master `96a6bc5`, Build und Linter grün,
  `PauliSystem.exists_energyLevel` als `theorem` in `Theorems.txt`. PR-Text: `15-hydrogen-pauli.md`.
  Unabhängig vom übrigen Stapel, kann jederzeit eingereicht werden.
- Nächstes: E2 (Entartung n²).

## Koordination

- **Philippe Kevorkian** (GitHub `KevorkianPhilippe`, per E-Mail, 21.10.): arbeitet außerhalb von physlib
  an Penroses Binor-Kalkül in Dimension 2 (ε-Tensor, Symmetrisierer, Theta-/Tetraeder-Netzwerke,
  normiertes 6j mit Orthogonalität und Biedenharn–Elliott, bisher Spins ≤ 1). Möchte auf unserer API
  aufbauen, erster Schritt: SL(2)-invariante Bilinearform auf V(n) und ε ↔ `hwVec 1 1 1`.
  **Antwort verschickt 21.10.:** bei uns Rekopplung/3j/6j/Symmetrien und als Nächstes **9j-Symbole**
  (Vier-Spin-Rekopplung, 9j als Summe über Produkte von 6j) und **Racahs geschlossene 6j-Formel**;
  bei ihm Binor-/Spin-Netzwerk-Kalkül und **Biedenharn–Elliott** (in seinem Kalkül). Brücke später:
  sein normiertes 6j = unser `sixJSym` (dann BE für alle Spins, Symmetrien übertragen sich).
  **Zusage:** Daniel schreibt ihm, sobald die 6j-PRs (12a/12b, 14) offen sind. Fork-Branches nicht genannt.
- Unsere `invForm` (#1911) ist die kontravariante Form, nicht die invariante – keine Dopplung.
