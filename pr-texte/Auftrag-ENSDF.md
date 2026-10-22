# Auftrag für die Claude-Sitzung auf agents-pc: ENSDF mit Lean prüfen

Ziel: Die Gamma-Übergänge der ganzen ENSDF-Datenbank gegen die bewiesenen Auswahlregeln aus PR 08
(#1910, `SelectionRules.lean`) prüfen. Alles läuft in Lean (`lake exe`), ohne Python. Jeder Treffer
bekommt ein eigenes Zertifikat, das der Lean-Kern prüft.

Das ist kein physlib-PR, sondern ein Werkzeug. Für einen PR oder eine Veröffentlichung entscheidet Daniel später.

## Rahmen

- Branch `ensdf-check`, lokal, von `fork/pr/projection-selection`, weil `SelectionRules.lean` noch nicht auf
  master liegt. Wird #1910 gemergt, auf master umsetzen. **Nicht pushen ohne Daniels „ja“.**
- Code in einem eigenen Verzeichnis `Tools/EnsdfCheck/` mit eigenem `lean_exe` in `lakefile`.
  `PhyslibAlpha.lean` und die Dateien von PR 08 bleiben unverändert.
- Daten **nicht** ins Repo legen, sondern nach `~/ensdf/` (Rohdaten, Datum und Version notieren).
- Es darf immer nur ein `lake build` laufen. Wartet ein Wasserstoff-Rebase, hat dieser Vorrang.
- Kleine Schritte, nach jedem Schritt ein Eintrag in `pr-texte/stand-ensdf.md` (Notizen-Worktree).
- Zitierregel: Das ENSDF-Formathandbuch und die Datenversion werden nur angegeben, wenn sie aus der
  heruntergeladenen Quelle stammen, nie aus dem Gedächtnis. Spaltenpositionen werden dem Handbuch entnommen.
- Ehrlichkeit im Bericht: Lean-gestützt ist nur die **Drehimpulsregel** (`TriangleRule`, folgt aus
  `IsTensorOperator.triangleRule`). Die **Paritätsregel** ist in PR 08 als Eingabe definiert
  (`MultipoleType.parity`), nicht bewiesen. Im Bericht beide Prüfungen getrennt ausweisen.

## Schritte

**S0 Daten und Format.**
- Die aktuelle ENSDF-Gesamtausgabe von NNDC (nndc.bnl.gov) oder IAEA nach `~/ensdf/` laden.
- Dazu das ENSDF-Formathandbuch („ENSDF manual“) laden.
- Notieren: Quelle, Datum, Dateizahl, Gesamtgröße.
- Aus dem Handbuch die Spalten folgender Records herausschreiben:
  - Level-Record (`L`): Energie, Jπ
  - Gamma-Record (`G`): Energie, Multipolarität, Mischungsverhältnis
  - die Fortsetzungs-Records, insbesondere ein explizites Endniveau (`FL=`)
- Keine Code-Änderung.

**S1 Kern in Lean** (`Tools/EnsdfCheck/Rules.lean`).
- Datentypen:
  - `SpinParity`: `twoJ : ℕ` und `parity : ℤˣ`
  - `Firmness`: fest / vorläufig, also in Klammern / Liste / unbekannt
  - `Multipolarity`: E1…E5, M1…M5, gemischt wie M1+E2, und die Kurzformen D, Q
- `checkTransition : SpinParity → SpinParity → Multipolarity → Verdict`. Die Prüfung nutzt direkt
  `TriangleRule` und `IsAllowedMultipole` aus `SelectionRules.lean`, nicht nachgebaut.
- Bei gemischten Multipolaritäten wird jeder Anteil geprüft.
- Lemma `checkTransition_eq_violation_iff`: Das Ergebnis „verletzt“ gilt genau dann, wenn
  `¬ IsAllowedMultipole …` gilt. Damit ist die Prüfung so zuverlässig wie der bewiesene Satz.
- Kein `sorry`, Axiome Standard.

**S2 Parser** (`Tools/EnsdfCheck/Parse.lean`).
- Die 80-Spalten-Records einlesen.
- Jπ-Felder zerlegen und den Grad der Festlegung erhalten. Beispiele: `3/2+`, `(3/2)+`, `(3/2,5/2)+`, `1-,2-`,
  `(2+)`, leer, sowie Ausdrücke wie `J+1` und `>=5`.
- Multipolaritäten zerlegen: `E2`, `(E2)`, `[E2]` (eckige Klammer = angenommen), `M1+E2`, `D`, `Q`, `E0`.
- Nicht Lesbares wird gezählt und mit Beispielen protokolliert, aber nie geraten.
- Der Parser ist unbewiesener Code. Im Bericht so benennen.

**S3 Endniveau zuordnen.**
- Gibt es `FL=`, dieses nehmen.
- Sonst E_f = E_i − E_γ mit der Toleranz aus den angegebenen Unsicherheiten.
  Rückstoßkorrektur nur, wenn das Handbuch sie verlangt.
- Mehrdeutige oder fehlende Zuordnungen kommen in eine eigene Kategorie und gelten nicht als Treffer.

**S4 Lauf und Bericht** (`lake exe ensdf-check ~/ensdf`).

Kategorien:
- **A**: Beide Niveaus und die Multipolarität sind fest (ohne Klammern), und die Drehimpulsregel ist verletzt.
- **A′**: wie A, aber nur die Paritätsregel ist verletzt (getrennt ausweisen, nicht Lean-bewiesen).
- **B**: Die Verletzung betrifft nur vorläufige oder angenommene Zuordnungen, also Klammern, eckige Klammern oder Listen.
  Bei Listen ist es ein Treffer nur, wenn **keine** Kombination erlaubt ist.
- **C**: Sonderfälle: E0, 0→0, D/Q ohne Typ, Zuordnung mehrdeutig.
- **P**: nicht lesbare Records.

Ausgabe `~/ensdf/bericht.md`: Zahlen je Kategorie und eine Liste der A- und A′-Treffer mit Nuklid,
Energien, Jπ, Multipolarität und Datensatzkennung.

**S5 Zertifikate.**
- Für jeden A-Treffer eine Zeile in `Tools/EnsdfCheck/Certificates.lean` erzeugen:
  `example : ¬ IsAllowedMultipole … := by decide`, mit den Daten als Kommentar.
- Bauen. Jeder Treffer ist damit vom Lean-Kern geprüft.
- Vorbild ist das Hf-178-Beispiel in `SelectionRules.lean` §C.

**S6 Gegenprobe.**
- Die ersten 10 A-Treffer kommen als Liste für Daniel in `stand-ensdf.md`. Daniel vergleicht sie selbst mit der
  aktuellen NNDC-Webausgabe.
- Zu jedem Treffer vermuten: Tippfehler, Formatfall, Parserfehler oder echter Widerspruch.
- Keine Bewertung „Fehler in ENSDF“ ohne Daniels Prüfung.

**Danach (später, eigener Auftrag):** berechenbare rationale 3j²- und 6j²-Werte mit Gleichheitsbeweis zu den
reellen Definitionen. Damit lassen sich Winkelkorrelationskoeffizienten und Mischungsverhältnisse prüfen.

## Was Daniel entscheidet

- Push des Branches.
- Ob und wo das Werkzeug veröffentlicht wird: physlib-PR, eigenes Repo oder Preprint.
- Meldung von Befunden an NNDC. Kontakt nach außen nur durch Daniel.
