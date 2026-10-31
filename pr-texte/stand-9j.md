# Stand 9j-Symbole (PhyslibAlpha)

Auftrag Daniel 31.10. Abstimmung mit Philippe Kevorkian (Mail 31.10.): die Racah-Formel für 6j und
Biedenharn–Elliott macht er (Branch `racah-6j` ruht, nicht anfassen). Wir machen 9j.
Kein Push von Code, kein PR, keine Kommentare ohne Daniels Ja.

## Phase 1 (31.10.)

### (a) Was schon da ist

**grep** (Mathlib unter `.lake/packages/mathlib`, physlib `origin/master` c5a908ba) nach
`9j|nineJ|ninej|NineJ|Fano|LS.?jj|jj.?coupling`: in physlib nichts. In Mathlib nur Fehltreffer
(`FoelnerFilter` und Ähnliches), nichts zu Drehimpuls oder Rekopplung.

Vierfache Tensorprodukte: nur `Relativity/Tensors/Constructors.lean` (Umklammern von Tensoren) und
GaugeTheory, beide ohne Bezug. In QuantumInfo nichts Verwendbares. Für eine Rekopplung auf
`V a ⊗ V b ⊗ V c ⊗ V d` gibt es also **keine** Infrastruktur.

**Verwendbare API auf master** (`PhyslibAlpha/QuantumMechanics/AngularMomentum/`):

| Datei | Zeilen | Inhalt, den wir nutzen |
|---|---|---|
| `CouplingSchemes.lean` | 507 | `Triple a b c = (V a ⊗ V b) ⊗ V c`, `embed`, `tripleCas`, `stateA` (Hyp. `0 < a + b`), `assocEmbed`, `stateB` (Hyp. `0 < b + c`) |
| `SixJ.lean` | 447 | `IndexA`, `vecA`, `recoupling`, `recoupling_eq_recoupling_zero`, `sum_recoupling_mul_recoupling`, `sixJ` (über Rekopplung), `recoupling_eq_sixJ`, `sum_sixJ_mul_sixJ` (Hyp. `ha`, `hc`) |
| `SixJSymmetry.lean` | 697 | `Adm3`, `reggeJ`, `threeJ` (doppelte Einheiten, 0 außerhalb `Adm3`), `threeJ_of_not`, `threeJ_swap/cycle/neg/swap₂₃/negCycle`, `sixJTerm`, `sixJBox`, `sixJSym j₁…j₆` (doppelte Einheiten, Summe über vier 3j), `sixJSym_swap₁₂/swap₂₃/flip₁₂`, `sixJSymEdge`, `sixJSymEdge_comp_map` (alle 24 Tetraedersymmetrien), `sixJ_eq_sixJSym` (Hyp. `0<a+b`, `0<b+c`, `0<a`, `0<c`) |
| `Wigner3j.lean` | 596 | `threeJR` auf Regge-Quadraten, `threeJR_transpose/swap_columns/cycle_columns/swap_rows/perm_columns/perm` |

Was **fehlt** und für 9j gebraucht wird: auf master gibt es keinen Satz über `threeJ` oder
`sixJSym` mit einem Argument 0 (geprüft: grep nach `zero` und nach Werten mit `0` in den
Lemma-Namen ergibt nichts). Die 9j-Reduktion auf 6j (DLMF 34.7.1) braucht genau das.

### (b) Literatur (nur heruntergeladene Quellen)

Abgelegt in `~/ensdf/sources_9j/`:
- `dlmf_34.6.html` (https://dlmf.nist.gov/34.6, HTTP 200 am 31.10., Header in `.headers`)
- `dlmf_34.7.html` (https://dlmf.nist.gov/34.7, HTTP 200 am 31.10.)
- `varsh.txt` (pdftotext von `~/ensdf/sources_3j6j/9789814415491.pdf`, 528 Seiten)

**DLMF §34.6 „Definition: 9j Symbol“**
- **34.6.1**: Summe über alle m_rs von sechs 3j-Symbolen (je eins pro Zeile und pro Spalte).
- **34.6.2**: Summe über j von (−1)^{2j} (2j+1)
  {j11 j21 j31; j32 j33 j} {j12 j22 j32; j21 j j23} {j13 j23 j33; j j11 j12}.
  (Formeltext wörtlich aus dem `alttext` der Seite gezogen.)

**DLMF §34.7 „Basic Properties: 9j Symbol“**
- **34.7.1**: Spezialfall mit einem Argument 0 (j33 = 0):
  {j11 j12 j13; j21 j22 j13; j31 j31 0} = (−1)^{j12+j21+j13+j31} ((2j13+1)(2j31+1))^{−1/2}
  {j11 j12 j13; j22 j21 j31}.
- **34.7(ii)**: invariant unter geraden Permutationen von Zeilen oder Spalten und unter
  Transposition; ungerade Permutation gibt den Faktor (−1)^R, R = Summe aller neun Argumente.
- **34.7.2**: Orthogonalität; **34.7.3**: Summenregel; **34.7.4/34.7.5**: weitere Summen.

**Varshalovich, Kap. 10 „9j Symbols“** (PDF-Seite / gedruckte Seite)
- §10.1.1 9j als Rekopplungskoeffizienten, Schemata I/II/III, Gl. (2)–(5): PDF 346–347 / S. 333–334;
  Gl. (8) als Summe über Produkte von CG-Koeffizienten.
- Orthogonalität Gl. (9), (10): PDF 348 / S. 335.
- §10.2.1 algebraische Summen: PDF 349 / S. 336; §10.2.2: PDF 350; §10.2.3 Summen über
  CG-Produkte: PDF 352.
- §10.2.4 „9j Symbols as Sums of Products of the 6j Symbols or the Racah Coefficients“:
  PDF 353 / S. 340.
- §10.4.1 Permutationssymmetrie: PDF 355 / S. 342; §10.4.2: PDF 356.
- §10.5 Rekursionen: PDF 358; §10.8 entartete Triaden: PDF 365–370.
- §10.9.1 „One of Arguments Equals Zero“ (Reduktion auf 6j): PDF 370 / S. 357.

**Numerische Probe** (sympy nur als Werkzeug, kein Beleg): `~/ensdf/9j/check_9j.py`,
`python3 -I check_9j.py 15 1`, 15 zufällige zulässige 9j (Spins 0…3 in halben Schritten):
- DLMF 34.6.2 = `sympy.wigner_9j`: 15/15.
- Transposition: Wert gleich 15/15, **summandenweise** gleich 15/15 (für jedes j einzeln).
- Zyklische Spalten- und Zeilenvertauschung: Wert gleich 15/15, summandenweise nur 1/15.

Folgerung: Die Transposition folgt in Form 34.6.2 Summand für Summand aus den
6j-Symmetrien. Die Zeilen-/Spaltenpermutationen nicht, dafür braucht es ein anderes Argument.

### (c) Plan und Abwägung

**Variante (i): Rekopplung auf V(a)⊗V(b)⊗V(c)⊗V(d)** (wie `sixJ` über `recoupling`).
Physikalisch die eigentliche Definition (LS ↔ jj), gibt Orthogonalität direkt.
Kosten: eine neue Vierfach-Kopplung (Analogon zu `CouplingSchemes` + `SixJ`, auf master zusammen
rund 950 Zeilen), mit Assoziator- und Vertauschungsabbildungen, invarianten Formen und Casimir für
zwei Zwischenkopplungen. Dazu kommen viele Hypothesen der Art `0 < a + b`. Mehrere PRs, bevor
überhaupt eine Symmetrie dasteht.

**Variante (ii): `nineJSym` als Summe über drei `sixJSym` (DLMF 34.6.2)**, doppelte Einheiten.
- Definition kurz: `∑ J ∈ Finset.range (j₁₁ + j₃₃ + 1), (-1)^J * (J + 1) * sixJSym … * sixJSym … * sixJSym …`.
  Die Schranke j ≤ j11 + j33 kommt aus der Triade (j11 j33 j) im ersten 6j. Außerhalb davon ist
  der Summand 0, weil `threeJ` außerhalb `Adm3` verschwindet. Die Transposition fixiert die
  Diagonale, also bleibt die Schranke unverändert und die Indexmenge ist für beide Seiten dieselbe.
- Transposition: Summand für Summand, jeder der drei 6j-Faktoren über `sixJSymEdge_comp_map`
  bzw. die Generatoren (numerisch abgesichert, siehe (b)).
- Keine Hypothesen `0 < a` usw., weil `sixJSym` für alle Argumente definiert ist.
- Nachteil: Die Bedeutung als Rekopplung und die Orthogonalität kommen nicht von selbst.

**Variante (iii): 3j-Form 34.6.1** (wie `sixJSym` über `sixJTerm`/`sixJBox`).
Zeilen- und Spaltenpermutationen und Transposition folgen dann aus den `threeJ`-Symmetrien durch
Umbenennen der Summationsvariablen (gleiches Muster wie `sixJSym_swap₁₂`). Die Gleichheit mit
(ii) braucht aber Summenidentitäten über 3j (Orthogonalität der 3j und die 6j-Darstellung über
3j), die auf master nur auf der Rekopplungsseite existieren.

**Empfehlung**: (ii) als Grundlage, (iii) als zweite Form für die Permutationssymmetrien,
(i) erst ganz am Ende für Bedeutung und Orthogonalität. Die Zeilen-/Spaltenpermutationen könnte
man auch über Biedenharn–Elliott beweisen; das ist Kevorkians Teil, deshalb nicht von uns, aber
als möglicher Weg nach seinem Merge vormerken.

**PR-Schnitt** (jeweils ein Konzept, unter 500 Zeilen, Moduldoku nach Schema):

| PR | Inhalt | Zeilen (Schätzung) |
|---|---|---|
| 9j-1 | `NineJ.lean`: `nineJSym` nach 34.6.2, Lemma zur Summationsschranke, `nineJSym_transpose` | 150–250 |
| 9j-2 | `threeJ` und `sixJSym` mit einem Argument 0 (geschlossene Werte), danach 9j-Reduktion nach 34.7.1 | 250–400 |
| 9j-3 | 3j-Form 34.6.1, Zeilen-/Spaltenpermutationen samt Vorzeichen (−1)^R, Gleichheit mit 34.6.2 | 400–500, ggf. zwei PRs |
| 9j-4 | Vierfach-Kopplung, 9j als Rekopplungskoeffizient, Orthogonalität 34.7.2 | 2–3 PRs zu je ~400 |

Kernel-Checks (`decide +kernel`): auf master nicht möglich. `threeJR` enthält reelle Wurzeln,
und die rationale Infrastruktur liegt nur auf `rational-6j` (unverändert, nicht PR-reif). Für
9j-1 gibt es also keine Kernel-Checks; die Zahlenprobe bleibt außerhalb von Lean.

### (d) Aufwand und Risiken

Aufwand: 9j-1 rund ein halber bis ein Tag. 9j-2 ein bis zwei Tage. 9j-3 zwei bis vier Tage.
9j-4 ein bis zwei Wochen.

Risiken:
- **9j-2**: Der Wert von `threeJ j j 0 m (−m) 0` muss aus `threeJR` (Regge-Quadrat mit einer
  Nullzeile) herausgerechnet werden, und das steht nirgends. Außerdem überschneidet es sich
  möglicherweise mit Kevorkians Racah-Arbeit: Ein 6j mit Argument 0 fällt direkt aus der
  Racah-Formel. **Mit ihm abstimmen, bevor 9j-2 beginnt.**
- **9j-3**: Die Gleichheit der Formen 34.6.1 und 34.6.2 braucht 3j-Orthogonalität in der Form von
  `threeJ`; die gibt es so nicht.
- **9j-4**: Assoziatoren und Vertauschungen auf dem Vierfachprodukt, Randfälle mit Spin 0,
  Hypothesen wie `0 < a + b`.
- **Allgemein**: Doppelte Einheiten. Mit J = 2j ist (−1)^{2j} = (−1)^J und 2j + 1 = J + 1;
  Vorzeichen (−1)^R nur bei gerader Summe definiert.

**Blocker für Phase 2: keiner.** 9j-1 baut nur auf `sixJSym` und dessen Symmetrien auf.

## Phase 2

### 9j-1 (31.10., lokal, nicht gepusht)

Branch `9j-1` auf `origin/master` c5a908ba, Commit d6261d98
„feat(PhyslibAlpha): the 9j symbols and their transposition symmetry“.
Neue Datei `PhyslibAlpha/QuantumMechanics/AngularMomentum/NineJ.lean` (117 Zeilen) und ein Import
in `PhyslibAlpha.lean`. 0 sorry.

Inhalt:
- `sixJSym_eq_zero_of_lt`: Ist für die Triade (j₁ j₅ j₆) j₁ + j₅ < j₆, dann ist das 6j gleich 0
  (jeder Summand enthält `threeJ j₁ j₅ j₆ … = 0`, über `threeJ_of_not`).
- `nineJSym`: Definition nach DLMF 34.6.2, doppelte Einheiten, Summe über `range (j₁₁ + j₃₃ + 1)`.
- `nineJSym_eq_sum`: Für jede größere Schranke N > j₁₁ + j₃₃ bleibt der Wert gleich.
- `sixJSym_shift`: {j₃ j₄ j₅; j₆ j₁ j₂} = {j₁ j₂ j₃; j₄ j₅ j₆}.
- `sixJSym_flip₁₃`: {j₄ j₂ j₆; j₁ j₅ j₃} = {j₁ j₂ j₃; j₄ j₅ j₆}.
- `nineJSym_transpose`: Summand für Summand, über die beiden Hilfslemmata.

**Einzeiler über vorhandene Lemmata (Meldung nach Regel „Vorhandenes zuerst“):**
- `sixJSym_shift` ist eine Verkettung `flip₁₂ ∘ swap₂₃ ∘ swap₁₂`, `sixJSym_flip₁₃` eine Verkettung
  `swap₂₃ ∘ flip₁₂ ∘ swap₂₃`. Beide sind auch Spezialfälle von `sixJSymEdge_comp_map`. Daniel
  entscheidet: als eigene Lemmata behalten (sie werden in `nineJSym_transpose` gebraucht und
  lassen sich direkt mit `rw` verwenden) oder inline in den Beweis.
- `nineJSym_transpose` selbst hat drei `rw` und `ring`. Inhaltlich ist es neu, eine
  Transpositionssymmetrie für 9j gab es bisher nicht.

Checks (`check_pr.sh 9j-1`): build_modules, build_alpha, runPhyslibAlphaLinters, build_roots,
theorem_lint, module_doc_lint, alphaFileImports, noAlphaImports, lint_style, alpha_python,
codespell: alle OK.
`scripts1911/ci_physlib.sh 9j-1`: alle 11 Schritte OK.

Referenzen in der Moduldoku: DLMF §34.6/§34.7 (URL, heruntergeladen) und Varshalovich et al.,
World Scientific (1988), Kap. 10. Die bibliographischen Angaben stehen im Impressum des PDFs.

**Umbau 31.10. (Cowork-Vorschlag, Daniel wird gefragt):** `sixJSym_shift` und `sixJSym_flip₁₃`
sind als eigene Lemmata gestrichen (AGENTS.md: keine trivialen Umschreibungen; Anlass #1990).
`nineJSym_transpose` verwendet jetzt direkt eine `rw`-Kette aus `sixJSym_flip₁₂`, `sixJSym_swap₂₃`
und `sixJSym_swap₁₂` (9 Schritte) und dann `ring`. Neuer Stand: Commit b66ea52f (amend, lokal),
`NineJ.lean` 106 Zeilen. Lemmata: `sixJSym_eq_zero_of_lt`, `nineJSym`, `nineJSym_eq_sum`,
`nineJSym_transpose`. Beim ersten Lauf nach dem Umbau schlug `alpha_python` fehl (eine
Moduldoku-Zeile über 100 Zeichen); korrigiert. Danach `check_pr.sh` 11/11 OK und
`ci_physlib.sh` 11/11 OK, 0 sorry.

Offen: Push und PR warten. Es sind schon PRs offen (Obergrenze laut Cowork); Daniel entscheidet. Danach 9j-2 (Werte mit einem Argument 0), aber vorher mit
Kevorkian abstimmen, weil es sich mit der Racah-Formel überschneiden kann.
