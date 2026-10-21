# Auftrag: Das Spektrum des Wasserstoffatoms vollständig (Langzeitprojekt)

Läuft auf agents-pc in `tmux` (Sitzung `physlib`). Regeln wie immer: kleine Schritte,
erst Aussagen mit `sorry`, nach jedem Schritt `lake build` (nur ein Build gleichzeitig),
kein Push ohne Daniels ausdrückliches „ja“, keine Kommentare an Reviewer.
Zwischenstände knapp in `../physlib-notes/pr-texte/stand-wasserstoff.md` festhalten
(committen und nur `notes/pr-texte` pushen ist erlaubt).

## Ziel

physlib hat in `Physlib/QuantumMechanics/Hydrogen/Basic.lean` den offenen TODO:
„Prove that (the closure of) the Hydrogen Hamiltonian has eigenvalues (point spectrum)
{-½mk²ℏ⁻² / (n + ½(d - 1))² | n ∈ ℕ}.“ Dazu gehören Entartung und die „verborgene“
Symmetrie (Laplace-Runge-Lenz-Vektor, schon in `LaplaceRungeLenzVector.lean`).
Das volle Ziel (Spektraltheorie des abgeschlossenen Operators) ist schwere Funktionalanalysis.
Deshalb in Etappen, jede für sich ein PR-fähiges Ergebnis.

## Was es schon gibt

- physlib: `HydrogenAtom` (d-dimensional, `V = -k/r`, regularisierter Hamiltonian `𝐇(ε)` auf
  Schwartz-Funktionen), Bohr-Niveaus `energyLevel` (nur definiert), LRL-Operator `𝐀(ε)` mit
  Kommutatoren und `lrlOperatorSqr_eq`.
- Unser Stapel: `sl₂`-Darstellungen und Klassifikation (`spin_classification`), Laguerre,
  Radialfunktionen (#1909), Quantisierung über Potenzreihen (PR 04), Eigenfunktionen in jeder
  Dimension mit harmonischen Polynomen (PR 05).

## Etappen (Reihenfolge = Empfehlung)

### E1. Paulis algebraische Herleitung der Energien (1926) – rein algebraisch, gut machbar
Abstrakt formulieren, unabhängig von Funktionalanalysis: Operatoren `L_ij`, `A_i`, `H` auf einem
Vektorraum mit den Relationen aus `LaplaceRungeLenzVector.lean` bei `ε → 0`
(`[L,A]` wie ein Vektor, `[A_i,A_j] = -2iℏm H L_ij`, `[H, A] = 0`,
`A² = 2mH(L² + ℏ²(d-1)²/4) + m²k²`), eingeschränkt auf einen endlichdimensionalen Eigenraum
von `H` zum Eigenwert `E < 0`. Für `d = 3`: `K = A/√(-2mE)`, `J± = (L ± K)/2` sind zwei
kommutierende `su(2)`; die Relation `L·A = 0` gibt `J+² = J-²`; mit der `sl₂`-Klassifikation aus
unserem Stapel folgt `E = -mk²/(2ℏ²n²)` mit `n = 2j + 1`, und der Eigenraum hat Dimension
ein Vielfaches von `n²`.
Satz-Ziel: „Jeder endlichdimensionale Eigenraum mit `E < 0` hat `E = H.energyLevel (n-1)` für ein
`n ≥ 1`.“ Das verbindet unsere `sl₂`-Arbeit direkt mit physlibs LRL-Datei.
Prüfen: ob `L·A = 0` (bzw. `A·L = 0`) in physlib schon steht; sonst als Lemma ergänzen.

### E2. Entartung `n²` (bzw. allgemein in `d` Dimensionen) – kombinatorisch + lineare Algebra
Dimension des Raums homogener harmonischer Polynome vom Grad `l` in `d` Variablen:
`C(l+d-1, d-1) - C(l+d-3, d-1)` (in `d = 3`: `2l + 1`). Dann
`Σ_{l<n} (2l+1) = n²` und die Eigenfunktionen aus PR 05 zu festem `N + l` sind linear unabhängig.
Ergebnis: Der Eigenraum zum Bohr-Niveau hat mindestens diese Dimension.

### E3. Die Eigenfunktionen sind echte Zustände
Die Funktionen aus PR 05 liegen in `L²(ℝ^d)` (Normierbarkeit, mit den Laguerre-Integralen).
Klären, wie sie zu physlibs Hamiltonian passen: Dieser lebt auf Schwartz-Funktionen,
`e^{-κr}` ist bei 0 nicht glatt. Erst recherchieren, wie physlib Abschluss/Domain plant
(TODOs zur Selbstadjungiertheit); ggf. mit der Regularisierung `ε → 0` arbeiten. Hier zuerst
einen kurzen Plan in `stand-wasserstoff.md` schreiben, bevor Code entsteht.

### E4. Vollständigkeit der radialen Lösungen (schließt die Annahme in PR 04)
Jede bei 0 reguläre Lösung der radialen Gleichung hat die Potenzreihenform (Frobenius-Methode
am regulären singulären Punkt 0); die zweite Lösung ist singulär und fällt heraus.

### E5. Punktspektrum = genau die Bohr-Niveaus (der physlib-TODO) – langfristig
Braucht Vollständigkeit der Kugelflächenfunktionen in `L²(S^{d-1})` und die Selbstadjungiertheit.
Nicht anfangen, bevor E1–E4 stehen; vorher Machbarkeit mit Mathlib-Stand prüfen und in
`stand-wasserstoff.md` bewerten.

## Erster Schritt

E1 für `d = 3`: abstrakte Struktur (Vektorraum, Operatoren, Relationen) als `structure` mit den
Relationen als Feldern definieren, Hauptsatz mit `sorry` formulieren, bauen. Dann den Beweis
in Teilschritten: `J±` definieren → Kommutatoren → `sl₂`-Tripel → Klassifikation anwenden.
Neue Datei z. B. `PhyslibAlpha/QuantumMechanics/Hydrogen/PauliSpectrum.lean` auf einem neuen
Branch `hydrogen-pauli` von aktuellem `origin/master`.
