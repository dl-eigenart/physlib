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

## Daueranweisungen

**Daniel, 26.10.2026 (wörtlich):** Hat ein offener PR von dl-eigenart auf leanprover-community/physlib einen Merge-Konflikt, der ausschließlich in der Importliste von PhyslibAlpha.lean (oder Physlib.lean) liegt, darfst du ihn ohne Rückfrage auf origin/master umsetzen (alle Importe übernehmen, alphabetisch), check_pr.sh laufen lassen und, wenn alles grün ist und die Lean-Dateien Byte für Byte unverändert sind, mit --force-with-lease pushen. Danach im Protokoll vermerken und mir kurz melden. Alles andere (Codeänderungen, Build-Fehler auf neuem master wie bei #1932, Konflikte in anderen Dateien, Kommentare von Reviewern) legst du mir vor und pushst nicht. Lege dafür einen Hintergrund-Check an, der alle 30 Minuten den mergeable_state der offenen PRs von dl-eigenart abfragt und sich bei dirty meldet. Keine Kommentare auf GitHub, die schreibe ich.

Umsetzung (Stand 26.10.):
- Abfrage: `~/physlib_ci/scripts1911/pr_mergeable.sh` (GitHub-REST ohne Anmeldung, `gh` ist auf agents-pc nicht installiert;
  Ausgabe `<nr> <mergeable_state> <branch> <titel>`, Exit 2 bei dirty, Protokoll `~/physlib_ci/pr_mergeable.log`).
- Umsetzen: `~/physlib_ci/scripts1911/move.sh <branch> <alte-basis> <neue-basis>` (cherry-pick, Importvereinigung über
  `resolve_imports.py`, streicht `Claude-Session:`), danach `check_stack.sh` (ruft `check_pr.sh`).
- `check_pr.sh` (ab 27.10.): vor `theorem_lint` Schritt `build_roots` = `lake build Physlib QuantumInfo PhyslibAlpha`
  (Fehler = FEHLER im Report). Anlass: nach #1968 sah `theorem_lint` veraltete `.olean` (StandardModel/Basic) und
  meldete auf 12a/12b fälschlich FEHLER; mit vollem Build 10/10 OK.
- Takt: Cron-Job der Claude-Sitzung (Minute 13 und 43). Nur sitzungsgebunden, erlischt mit der Sitzung bzw. nach 7 Tagen;
  in einer neuen Sitzung neu anlegen.

**Reihenfolge (Daniel, 26.10.):** Die PRs zu E2 (`hydrogen-pauli-degeneracy`) und E3 (`hydrogen-bound-states-split`
bzw. die Teil-PRs `hydrogen-e3-1` … `hydrogen-e3-4`, Plan in `stand-e3-split.md`) werden erst **nach** 12a/12b eröffnet.
E3 in vier Teilen an Dateigrenzen (20a–20d); Teil 4 (`BoundStatesAdjoint.lean`, 741 Zeilen) bleibt ungeteilt
(Daniel, 26.10., Variante 3: #1910/#1911 in ähnlicher Größe gemergt, kein Eingriff in geprüften Code); Rückfall bei
Reviewer-Wunsch: Variante 1 (§A+§B / §C+§D).

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
| **gemergt: #1899** | 01 spin-orbit coupling | `pr/spin-orbit` | 189 | nichts |
| **gemergt: #1900** | 02 generalised Laguerre polynomials | `pr/laguerre` | 383 | nichts |
| **offen: #1909** | 03 radial functions of the hydrogen atom | `pr/hydrogen-radial` | 379 | 02 |
| nach #1909 | 04 quantisation of the hydrogen levels | `pr/hydrogen-quantisation` | 614 | 03 |
| nach #1909 | 05 bound states of the d-dimensional hydrogen atom | `pr/hydrogen-bound-states` | 329 | 03 |
| nach #1909 | 06 fine structure of hydrogen | `pr/fine-structure` | 193 | 01, 03 |
| **offen: #1910** | 08 projection theorem, selection rules, irreducible WE | `pr/projection-selection` | 742 | #1876 |
| **offen: #1911** | 09 normalised basis and Clebsch-Gordan coefficients | `pr/clebsch-gordan` | 792 | #1876 |
| **gemergt: #1962** | 10 closed formulas for Clebsch-Gordan coefficients | `pr/clebsch-gordan-formula` | 616 | 09 |
| **gemergt: #1964** | 11 Wigner 3j symbols and the multipole sum rule | `pr/wigner-3j` | 583 | 10 |
| **gemergt: #1970** | 12a the two coupling schemes of three angular momenta | `pr/coupling-schemes` | 507 | 10 |
| **gemergt: #1971** | 12b recoupling coefficients and 6j symbols | `pr/six-j` | 447 | nichts (12a gemergt) |
| **offen: #1980** (auf master, -blocked-by-PR) | 13 Wigner-Eckart with Clebsch-Gordan coefficients | `pr/wigner-eckart-cg` | 221 | nichts (12b gemergt) |
| **offen: #1981** (auf master, -blocked-by-PR) | 14 tetrahedral symmetry of the 6j symbols | `pr/six-j-symmetry` | 697 | nichts (12b gemergt) |
| **offen: #1990** | 19 reordering commuting continuous linear maps (opalg, Physlib) | `opalg-commute-v2` | 68 | nichts |


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

**Regel (Daniel, 26.10.2026, wörtlich):** "Lean-Community-Richtlinien (leanprover-community.github.io/community_guidelines.html): Please do not use an LLM when writing comments on github or Zulip. LLM-artige Nachrichten werden gelöscht, Sperre möglich. Ein Moderator hat Daniel am 26.10. auf Zulip darauf hingewiesen. Deshalb: Kommentare auf Zulip und GitHub schreibt Daniel selbst auf Englisch. Claude liefert dafür nur kurze ausformulierte Vorschläge auf DEUTSCH, die Daniel selbst ins Englische bringt; keine englischen Texte für Kommentare. PR-Beschreibungen: die Entwürfe in pr-texte/ sind nur Inhaltsvorlage, Daniel formuliert die Beschreibung selbst."

**Label awaiting-author (Daniel, 28.10.):** Ein Reviewer setzt das Label per Kommentar `awaiting-author`; der Autor entfernt es nach der Umsetzung mit einem Kommentar `-awaiting-author` in eigener Zeile. Bei #1932 am 28.10. so geschehen: Label weg, gloges als Reviewer angefragt.


**21.10., 20:45:** #1910 (08) und #1911 (09) offen. Stapel 10–14 auf das neue `pr/clebsch-gordan`
(auf master `a945101`) umgesetzt, inkl. der neuen Symmetrie-Commits auf `pr/wigner-3j` und
`pr/six-j-symmetry`. Lean-Dateien unverändert. Vor dem nächsten PR auf agents-pc bauen.

**24.10., 16:40:** #1911 (09), #1947 (04), #1948 (05) gemergt. Stapel 10–14, E4, E3 sowie rational-3j6j/rational-6j/racah-6j
lokal auf origin/master `c78d49e5` umgesetzt, geprüft, nicht gepusht (Hashes in `stand-3j6j.md`, `stand-wasserstoff.md`).

## Wasserstoffspektrum (Langzeit)

- **E1 erledigt** (21.10., agents-pc): `hydrogen-pauli`, Commit `56a4ff7` auf master `96a6bc5`, Build und Linter grün,
  `PauliSystem.exists_energyLevel` als `theorem` in `Theorems.txt`. PR-Text: `15-hydrogen-pauli.md`.
  Unabhängig vom übrigen Stapel, kann jederzeit eingereicht werden.
- E2 algebraisch (`hydrogen-pauli-degeneracy`) und analytisch (`hydrogen-degeneracy-analytic`) auf dem Fork.
- **L·A = 0 in Physlib bewiesen** (`lrl-angular-cyclic`, `bdf8396`, alle d, alle ε). PR-Text: `16-lrl-angular-cyclic.md` (PR gegen Physlib, nicht Alpha).
- E3: Plan in `stand-wasserstoff.md` (L², lineare Unabhängigkeit, schwache Eigenwertgleichung, H†). Noch kein Code.

## Physlib-PRs (nicht Alpha)

- **gemergt: #1930** Dichter Definitionsbereich des Wasserstoff-Hamiltonians (`hydrogen-dense-domain`, Text 17).
  Danach: Alpha-Stapel `hydrogen-bound-states-split` auf master rebasen (Cherry-Pick der Dichtheit faellt weg).
- **gemergt: #1932** (29.10., `49cf162e`) L·A = 0 (`lrl-angular-cyclic`, Text 16).
- **offen: #1933** (Alpha) Paulis Herleitung (`hydrogen-pauli`, Text 15).
- In Arbeit (agents-pc): E4 Vollständigkeit der radialen Lösungen (`hydrogen-radial-completeness`).

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
- **22.10.: Philippe hat die Aufteilung angenommen.** Seine Reihenfolge: invariante Form auf V(n) und
  Bezug zu `invForm` (sobald #1911 gemergt ist), dann Binor-Vertex, Brückensatz 6j, Biedenharn–Elliott.
