# Auftrag ENSDF, Teil 2: Restfälle, Mischungsverhältnisse, 3j²/6j²

Stand: 2026-10-22, Entwurf aus der Cowork-Session. Baut auf `Auftrag-ENSDF.md` und
`stand-ensdf.md` (Endstand A 29, A′ 24, B 131, C 66.886, S 3, P 206, N 5.459, ok 160.364) auf.
Protokoll: neue Datei `pr-texte/stand-ensdf-2.md`, nach jedem Schritt ein Eintrag.

## Rahmen (unverändert aus Teil 1)
- Branch `ensdf-check`, Code nur unter `Tools/EnsdfCheck/`, neue Lean-Mathematik in eigener Datei.
- Daten bleiben in `~/ensdf/`, nicht im Repo. Datenversion `ensdf_261001`.
- Immer nur ein `lake build`. Ein Wasserstoff-Rebase nach Merge von #1909 hat Vorrang.
- Nicht pushen ohne Daniels „ja“. Kontakt nach außen nur Daniel.
- Zitierregel: Formeln, Vorzeichenkonventionen und Definitionen nur aus heruntergeladenen
  Quellen (Datei, Seite). Nichts aus dem Gedächtnis. Fehlt eine Quelle, Schritt anhalten und
  Daniel fragen.
- Im Bericht immer getrennt: Lean-bewiesen / Lean-Definition ohne Beweis / unbewiesener Code / Numerik.
- Kategorien aus Teil 1 nicht umdeuten; Neues bekommt eigene Kategorien.

## T0 Bestand (keine Code-Änderung)
- Zählen, was strukturiert vorliegt: Gammas mit MR-Feld (δ), davon mit Unsicherheit, mit
  Grenzen, mit Vorzeichen; Gammas mit δ und gemischter M; Kommentar-Records, die A2/A4
  (oder a2/a4, Legendre-Koeffizienten, DCO, Polarisation) enthalten, mit 20 Beispielen je Form.
- Aus den Evaluators Guidelines 2021 und dem Handbuch belegen: welche δ-Vorzeichenkonvention
  ENSDF verlangt, und welche Prüfprogramme die Evaluatoren laut Guidelines laufen lassen
  (Namen, was sie prüfen). Damit klären, welche Prüfungen wirklich neu wären.
- Ergebnis als Tabelle in stand-ensdf-2.md. Danach Daniel fragen, ob T4 sich lohnt.

## T1 Restfälle aus Teil 1 ausschöpfen
- Mehrdeutiges Endniveau (≈ 5.845): wie bei Jπ-Listen behandeln. Treffer nur, wenn **alle**
  Kandidaten die Regel verletzen. Neue Kategorie A_mehrdeutig, Zertifikat als Konjunktion.
- N mit Jπ-Listen oder -Bereichen: über alle Möglichkeiten prüfen, Treffer nur wenn keine erlaubt ist.
- E0 (≈ 2.123): als Definition (nicht bewiesen) prüfen: J_i = J_f, gleiche Parität.
  Eigene Kategorie E0′, getrennt ausweisen.
- Unplatzierte Gammas und leere Jπ bleiben ungeprüft; nur zählen.
- Neue Zahlen und, wie gehabt, die ersten 10 Treffer je neuer Kategorie zur Gegenprobe.

## T2 δ-Konsistenz ohne 3j (entscheidbar, Lean-Definitionen)
- δ angegeben, aber M rein (z. B. M1 ohne +E2) oder umgekehrt.
- Gemischte M, bei der die Dreiecksregel nur einen Anteil zulässt (z. B. M1+E2 bei 1→0),
  datenbankweit, auch in B und C.
- δ-Wert und M-Reihenfolge: Bei M1+E2 mit sehr großem |δ| bzw. E2+M1 mit sehr kleinem |δ|
  nur als Hinweis zählen, keine Verletzung.
- Vorzeichen von δ für dieselbe Linie zwischen Datensätzen und Adopted vergleichen
  (Konvention aus T0). Abweichungen nur melden, nicht bewerten.

## T3 Lean: berechenbare 3j und 6j
- Darstellung r · √q mit r, q ∈ ℚ, q ≥ 0, aus der bewiesenen Racah-Form
  (`cgCoefficient_racah`, `Wigner3j`, `sixJSym`). Insbesondere 3j² und 6j² in ℚ.
- Gleichheitsbeweis zu den reellen Definitionen, kein `sorry`, nur Standardaxiome.
- `decide`/`norm_num`-Tests gegen bekannte Werte; Gegenprobe gegen sympy für j ≤ 4 außerhalb
  von Lean (wie check_3j.py).
- F-Koeffizienten der Winkelverteilung als Definition aus 3j und 6j, mit Formel und Quelle
  aus einer heruntergeladenen Arbeit. Ohne Quelle: anhalten.
- Das ist auch ein möglicher physlib-Beitrag; getrennt halten von `Tools/`.

## T4 A2/A4 gegen δ (nur nach Daniels OK aus T0)
- Kommentar-Parser für die in T0 gefundenen Formen; Unlesbares zählen, nie raten.
- Für jeden Fall mit Spins, δ und A2/A4: Gibt es eine physikalisch zulässige Ausrichtung,
  mit der die gemessenen Koeffizienten im Rahmen der Unsicherheit aus δ folgen?
  Wenn nein: Treffer. Rechnung numerisch, Koeffizienten aus T3.
- Zertifikate nur, wo sich die Verletzung mit rationalen Schranken beweisen lässt; sonst
  als Numerik-Befund ausweisen.

## T5 Bericht und Gegenprobe
- `~/ensdf/bericht2.md` mit Zahlen je Kategorie und Quellen, Spalten „auch in Adopted“ /
  „Adopted widerspricht“ wie in Teil 1.
- Erste 10 Treffer je Kategorie mit Rohzeilen und Vermutung in stand-ensdf-2.md.
  Daniel prüft gegen die NNDC-Webausgabe.

## Was Daniel entscheidet
- Ob T4 nach T0 angegangen wird.
- Push, Veröffentlichung, Meldungen an NNDC.
