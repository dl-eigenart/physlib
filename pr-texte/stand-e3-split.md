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
