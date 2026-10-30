# E3 aufteilen (2026-10-26)

Auftrag Daniel 26.10.: `hydrogen-bound-states-split` (5 Dateien, 2151 Zeilen) in Teil-PRs von etwa 300–600 Zeilen, als Stapel.
Reihenfolge laut `00-Plan.md`: E2- und E3-PRs erst nach 12a/12b eröffnen. Nichts gepusht. **27.10.: 12a/12b eröffnet (#1970, #1971), Bedingung erfüllt.** **29.10.: neue Bedingung (Daniel): erst nach dem Merge von #1980, #1981 und #1990 eröffnen.**

## Abhängigkeiten der Dateien (aus den Importen)

```
Eigenfunctions (05, gemergt)
  └─ Degeneracy (547)
       └─ PolyBounded (307)          (nutzt `toFun` aus Degeneracy)
            ├─ BoundStatesL2 (255)   (+ Physlib SpaceD.Basic)
            └─ GreenIdentity (296)   (nutzt aus Degeneracy nichts direkt)
                 └─ BoundStatesAdjoint (741) ← auch BoundStatesL2; nutzt `hamiltonianOperator_hasDenseDomain` (Dichtheits-PR, gemergt)
```

Jede Datei steckt schon in einem eigenen Commit von E3 (Reihenfolge Degeneracy, PolyBounded, L2, Green, Adjoint).

## Schnitt an Dateigrenzen (umgesetzt)

| Teil | Branch | Dateien | Zeilen (Lean + Importliste) | Text |
|---|---|---|---|---|
| 1 | `hydrogen-e3-1` | `Degeneracy.lean` | 547 + 1 | `20a-hydrogen-e3-degeneracy.md` |
| 2 | `hydrogen-e3-2` | `PolyBounded.lean`, `BoundStatesL2.lean` (2 Commits) | 307 + 255 + 2 = 564 | `20b-hydrogen-e3-l2.md` |
| 3 | `hydrogen-e3-3` | `GreenIdentity.lean` | 296 + 1 | `20c-hydrogen-e3-green.md` |
| 4 | `hydrogen-e3-4` | `BoundStatesAdjoint.lean` | 741 + 1 | `20d-hydrogen-e3-adjoint.md` |

Begründung:
- Teil 1 ist für sich ein Ergebnis (Dimension der harmonischen Polynome, Zählung der Zustände), nur auf Funktionen.
- `PolyBounded` (307) allein und `BoundStatesL2` (255) allein lägen am unteren Rand; zusammen ergeben sie „Zustände in L²“
  mit dem Werkzeug, das sie dafür brauchen. `GreenIdentity` könnte statt L2 neben `PolyBounded` stehen (603 Zeilen); dann
  stünde L2 allein mit 255 Zeilen. Die gewählte Variante hält inhaltlich Zusammengehöriges zusammen.
- Teil 3 (296) liegt knapp unter 300, ist aber eine abgeschlossene Analysis-Zutat ohne Wasserstoff-Bezug.
- **Teil 4 liegt mit 741 Zeilen über dem Ziel.** Ein Schnitt an Dateigrenzen geht nicht weiter; s. u.

## Möglicher Schnitt innerhalb von `BoundStatesAdjoint.lean` (NICHT umgesetzt, zur Entscheidung)

Abschnitte: §A Regularised bound states (Z. 63–161, ≈ 99), §B The weak eigenvalue equation (Z. 162–618, ≈ 457),
§C Eigenvectors of the adjoint (Z. 619–639, ≈ 21), §D The whole level (Z. 640–741, ≈ 101).
- Variante 4a/4b: §A + §B (Green-Identität für Bound States, schwache Eigenwertgleichung, ≈ 560 + Kopf) in eine neue Datei,
  §C + §D (Adjungierte, ganze Schale, `d = 3`, ≈ 125 + Kopf) in eine zweite. Teil 4b wäre klein (≈ 150 Zeilen mit Kopf).
- Alternative: §A in `GreenIdentity`-Nachbarschaft (Teil 3 → ≈ 400), Rest ≈ 640 in Teil 4.
- Beides erfordert neue Dateien bzw. das Verschieben von Deklarationen zwischen Dateien, also neue Moduldocstrings und
  einen Lean-Diff ≠ E3. Nach Auftrag nur beschrieben; Entscheidung bei Daniel.

## Ergebnis der Umsetzung (an Dateigrenzen)

- `hydrogen-e3-4` = E3-Commits per `move.sh` von Basis `2ccd1951` auf origin/master `7823e144`; `hydrogen-e3-1..3` = die
  Vorgänger-Commits (Stapel). Keine `Claude-Session:`-Zeile.
- Lean-Dateien Byte für Byte wie in `hydrogen-bound-states-split` (`git diff` 0 Zeilen für alle fünf Dateien).
- Vergleich mit „E3 auf master gemergt“: einziger Unterschied `PhyslibAlpha.lean` (Merge-Baum hat dort Konfliktmarker; in
  `hydrogen-e3-4` die fünf Importe alphabetisch). Importlisten je Branch geprüft (1, 3, 4, 5 neue Importe).

| Branch | Hash | Commits über master | Diff zu master | check_pr.sh | ci_physlib.sh | sorry |
|---|---|---|---|---|---|---|
| `hydrogen-e3-1` | `7343e99f` | 1 | 2 Dateien, +548 | 10/10 OK | 11/11 OK | 0 |
| `hydrogen-e3-2` | `35edadc9` | 3 | 4 Dateien, +1112 | 10/10 OK | 11/11 OK | 0 |
| `hydrogen-e3-3` | `7a9bbff7` | 4 | 5 Dateien, +1409 | 10/10 OK | 11/11 OK | 0 |
| `hydrogen-e3-4` | `3b8da2b9` | 5 | 6 Dateien, +2151 | 10/10 OK | 11/11 OK | 0 |

Berichte `~/physlib_ci/REVIEW_e3split-hydrogen-e3-<i>.txt`, `~/physlib_ci/REVIEW_e3split-<i>-physlib.txt`.
`hydrogen-bound-states-split` selbst unverändert (`7430cfca`, Basis `2ccd1951`).

## Teiltexte 20a–20d

Aus Text 20 geschnitten: Hauptsätze, Reviewer-Map-Punkte, Deklarationstabellen (aus den Docstrings erzeugt) und Notes je
Teil; Einleitung und Kopfzeilen je Teil neu. Text 20 bleibt als Fassung für den ungeteilten PR liegen.

### Prüfstellen für Daniel (aus Text 20 übernommen, nach Teilen)
- **Alle Teile:** Platzhalter „20a“ … „20d“ in Kopfzeilen und Einleitungen beim Eröffnen durch die PR-Nummern ersetzen;
  Kopfzeilen „Base/Depends on“ und „Builds on“ prüfen; Zeilenangaben in den Kopfzeilen nach jedem Rebase.
- **20a:** Einleitung ist meine Paraphrase; Axler–Bourdon–Ramey-Angabe aus `Degeneracy.lean` nur per CrossRef-Metadaten
  geprüft, Buch liegt nicht vor, genaue Stelle der Dimensionsformel ungeprüft; Deklarationen ohne Docstring nur als Namensliste.
- **20b:** Einleitung (Paraphrase); Formulierung zur komplexen Dimension (`linearIndependent_complex_of_real_inner`).
- **20c:** Einleitung (Paraphrase); Angabe „uses only `PolyBounded.lean`“ in der Kopfzeile (aus den Importen).
- **20d:** Satz zu essentieller Selbstadjungiertheit (Note 1); „at least `(n + 1)²` … exactly is not shown“ (Note 2);
  Einleitung (Paraphrase); Größe (741 Zeilen, über dem Ziel).

## Entscheidung Daniel (2026-10-26 17:22): Teil 4 bleibt ungeteilt (Variante 3)
- `hydrogen-e3-4` (`BoundStatesAdjoint.lean`, 741 Zeilen) wird nicht weiter geschnitten.
- Begründung: #1910 (742 Zeilen) und #1911 (792 Zeilen) wurden in dieser Größe gemergt; ein Schnitt in der Datei würde den
  geprüften Lean-Code verändern.
- Rückfall, falls ein Reviewer es verlangt: Variante 1 (§A + §B in eine Datei, §C + §D in eine zweite; s. o.).
- Damit bleibt es bei den vier Teilen 20a–20d wie umgesetzt.

## E2 und E3 auf master `a62866f3` umgesetzt (2026-10-30), nicht gepusht
Freigabe Daniel 30.10. (Bedingung #1980/#1981 gemergt, #1990 geschlossen gilt als erfüllt). Alte Basen gegen merge-base geprüft
(e2, e3-1: `7823e144`; e3-2: `7343e99f`; e3-3: `35edadc9`; e3-4: `7a9bbff7` = jeweils alter Kopf des Vorgängers).
Sicherungen `backup/<branch>-pre-20261030` (= alte Köpfe). `move.sh` ohne Konflikte außerhalb der Importliste.
Byte-Gleichheit: für jede Lean-Datei des Branches außer `PhyslibAlpha.lean`/`Physlib.lean` Blob alter Kopf = Blob neuer Kopf,
Dateilisten alt/neu gleich; Unterschied nur die neuen Importzeilen in `PhyslibAlpha.lean`.

| Branch | alt | **neu** | Basis | Zeilen gegen Basis | check_pr | CI | sorry | byteidentisch |
|---|---|---|---|---|---|---|---|---|
| `hydrogen-pauli-degeneracy` (E2, 21) | `e5da5ba6` | **`7ad5343b`** | master `a62866f3` | +131 −9 (1 Datei, `PauliSpectrum.lean`) | 11/11 | 11/11 | 0 | ja |
| `hydrogen-e3-1` (20a) | `7343e99f` | **`0791ce3d`** | master `a62866f3` | +548 (2 Dateien) | 11/11 | 11/11 | 0 | ja |
| `hydrogen-e3-2` (20b) | `35edadc9` | **`5513ad57`** (2 Commits) | e3-1 `0791ce3d` | +564 (3 Dateien) | 11/11 | 11/11 | 0 | ja |
| `hydrogen-e3-3` (20c) | `7a9bbff7` | **`f777b804`** | e3-2 `5513ad57` | +297 (2 Dateien) | 11/11 | 11/11 | 0 | ja |
| `hydrogen-e3-4` (20d) | `3b8da2b9` | **`57b4272a`** | e3-3 `f777b804` | +742 (2 Dateien) | 11/11 | 11/11 | 0 | ja |

Berichte `~/physlib_ci/REVIEW_rb1030-<branch>.txt` / `…-physlib.txt` (check_pr.sh mit `build_roots`). Push wartet auf Daniel.
**30.10. gepusht** (Daniels Ja): Fork `hydrogen-pauli-degeneracy` = `7ad5343b` (Lease gegen `e5da5ba6`), `hydrogen-e3-1`…`-4` = `0791ce3d`, `5513ad57`, `f777b804`, `57b4272a` (neu); ls-remote bestätigt.

### Prüfstellen in den PR-Vorlagen 21, 20a–20d (Daniel entscheidet)
- Zeilenzahlen stimmen mit den neuen Branches überein (21: +131/−9; 20a 547+1; 20b 307+255+2; 20c 296+1; 20d 741+1).
- Verlinkte PRs per GitHub-API geprüft, alle gemergt: #1818 (TomOleDiem, 16.10.), #1933, #1948, #1930, #1963.
- 20b–20d: Kopfzeile „Base: master after merge of `hydrogen-e3-N`“ – beim Eröffnen gestapelt; `blocked-by-PR #<20a/20b/20c>`
  in eigener Zeile und die PR-Nummern der Vorgänger eintragen (gibt es erst nach dem Eröffnen).
- 21 verweist auf `BoundStatesAdjoint.lean` „(separate PR)“ – nach dem Eröffnen von 20d durch die PR-Nummer ersetzen?
- 20a/`Degeneracy.lean` zitiert Axler–Bourdon–Ramey, *Harmonic Function Theory*, doi:10.1007/978-1-4757-8137-3_5:
  CrossRef (30.10.) bestätigt Kapiteltitel „Harmonic Polynomials“, Autoren, Springer, 2001, Reihe GTM; **nicht** aus CrossRef
  belegt: „2nd ed.“, „GTM 137“, „chapter 5“ → vor dem PR an der Quelle prüfen (CLAUDE.md, Zitierregel).
  **Erledigt 30.10. (Cowork):** Quellen in `~/physlib_ci/literatur/`. `Axler_HFT.pdf` (axler.net/HFT.pdf; Titelseite: Second
  Edition, ©2001 Springer) bestätigt Chapter 5 „Harmonic Polynomials“ (S. 73) und Proposition 5.8,
  dim Hₘ(ℝⁿ) = C(n+m−1, n−1) − C(n+m−3, n−1) für m ≥ 2, passend zur Formel in `Degeneracy.lean`;
  `openlibrary_0387952187.json` (LoC-MARC): 2nd ed., Graduate Texts in Mathematics 137, Springer, New York 2001;
  `crossref_book.json`: Reihe GTM, 2001. Zitat in 20a/`Degeneracy.lean` damit vollständig belegt, **keine Änderung nötig**.
- Alle fünf Vorlagen sind noch englische Volltexte mit KI-Offenlegungszeile – laut Regel 26.10. nur Inhaltsvorlage; Daniel
  formuliert Beschreibung und Offenlegung selbst.
- Reihenfolge/Eröffnung: E2 unabhängig; E3 als Stapel 20a→20d (20c braucht von 20b nur `PolyBounded.lean`).
