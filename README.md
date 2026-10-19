# ppedv Angebotsgenerator

Eine HTML-Datei (`index.html`), kein Build. Links eingeben, rechts erscheint das Angebot als
A4-Vorschau; „PDF erstellen“ → im Druckdialog „Als PDF speichern“.

## Kategorien

1. **Öffentliche Schulung** – Kurs aus dem ppedv-Programm, Tagespauschale 1.800 € für bis zu
   6 Personen, online oder ppedv-Standort; Reisekosten Trainer 1:1 (0,60 €/km, Hotel ca. 90 €).
2. **Inhouse-Workshop A/B** – KI-Abläufe oder Copilot-Praxistag: online/Standort 3.500 €,
   beim Kunden 4.200 €; Rabattcode `bestandskunde20` = −20 % auf die Pauschale (nicht auf die Anreise).
3. **Kompetenzmodell** – kommt aus der Kompetenzmatrix
   (https://ppedv-kompetenzmatrix.vercel.app, Abschluss → „Angebot erstellen“).

Alle Preise sind vorausgewählt und im Formular änderbar (`PREIS` im Code).

## Übergabe aus der Kompetenzmatrix

Die Matrix öffnet `<Generator-Adresse>/#matrix=<base64url(JSON)>`. Die Daten stehen hinter dem `#`
und gehen an keinen Server. Der Link lässt sich auch in Schritt 4 („Übernehmen“) einfügen.
Lesen: `leseMatrix()` / `angebotAusMatrix()`. Erzeugt in der Matrix von `matrixFuerAngebot()`.

## Dateien

- `index.html` – der Generator
- `logo.png` – ppedv-Logo
- `export-pdf.ps1`, `PDF erstellen.cmd` – PDF aus einer gespeicherten Angebots-JSON per Kommandozeile
  (Edge/Chrome headless); Dateiname `ANG-<Kunden-Nr.>_<Firma>.pdf`
- `serve.ps1` – kleiner lokaler Webserver für die Vorschau
- `angebote/` – lokale Beispiel-Angebote, **nicht im Repo** (Kundendaten)

Dateiname immer `ANG-<Kunden-Nr.>_<Unternehmen>`; die Angebotsnummer ist die Kundennummer.
