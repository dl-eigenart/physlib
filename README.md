# Arbeitsnotizen zu den physlib-PRs (kein Code)

Dieser Branch enthält nur Notizen, keinen Lean-Code. Er wird nie als PR eingereicht.

- `pr-texte/00-Plan.md`: Aufteilung des sl2-/Wasserstoff-Stapels in PRs, Reihenfolge, Abhängigkeiten
- `pr-texte/NN-*.md`: Entwürfe der PR-Beschreibungen (Englisch), je PR eine Datei
- `pr-texte/Auftrag-Symmetriegruppen.md`: offener Auftrag (Beweis der vollen Symmetriegruppen)

Regeln: PR-Texte sind Entwürfe; Daniel prüft und postet selbst. Kommentare an Reviewer schreibt
nur Daniel (physlib AI-POLICY §3.1). Wer einen Branch ändert, aktualisiert hier den Plan.

Commit-Nachrichten (physlib-Branches und Notizen), seit 23.10.2026:
- keine Zeile `Claude-Session:`; `Co-Authored-By:` bleibt. Gilt für jeden neu entstehenden Commit, auch
  beim Rebase (alte Nachricht übernehmen, die Zeile `Claude-Session:` streichen). Schon gepushte Commits
  werden nicht geändert.
- Notiz-Commits ohne `#NNNN` (sonst Querverweis in der PR auf GitHub).
- Beides prüft der pre-push-Hook `~/physlib_ci/physlib/.git/hooks/pre-push` (nicht versioniert; bei
  neuem Klon neu anlegen, Text in `pr-texte/stand-wasserstoff.md`, Eintrag vom 23.10. 23:05).
