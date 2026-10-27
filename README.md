# ppedv Angebotsgenerator

Eine HTML-Datei (`index.html`), kein Build. Links eingeben, rechts erscheint das Angebot als
A4-Vorschau; „PDF erstellen“ → im Druckdialog „Als PDF speichern“.

## Kategorien

1. **Öffentliche Schulung** – Kurs aus dem ppedv-Programm, Tagessatz 2.190 € (halber Tag 1.390 €, ohne Vorbereitung) für bis zu
   6 Personen, ganze und halbe Tage, online, ppedv-Standort oder beim Kunden vor Ort; optional Vorbereitung (halbe Dauer ×
   Tagessatz); Reisekosten Trainer 1:1 (0,60 €/km, Hotel ca. 90 €).
2. **Inhouse** – A KI-Abläufe / B Copilot-Praxistag (Workshop, 1 Tag): online/Standort 3.500 €, **C beliebiger Kurs aus dem Programm: 3.500 € je Schulungstag** (Dauer aus der Kursliste);
   beim Kunden 4.200 €; Rabattcode `bestandskunde20` = −20 % auf die Pauschale (nicht auf die Anreise).
3. **Kompetenzmodell** – Preis **je Schulungstag** laut ppedv-Kursdauer: 3.500 € (Bestandskunde 2.800 €), z. B. Power-Woche 5 Tage = 17.500 €; Kurse bis 4 Std. = halber Tag. Kommt aus der Kompetenzmatrix
   (https://ppedv-kompetenzmatrix.vercel.app, Abschluss → „Link für Angebotsgenerator“; Bestandskunde per Häkchen hier).

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

Dateiname immer `ANG-<Angebots-Nr.>_<Unternehmen>`; die Angebotsnummer ist die **Ansprechpartner-ID aus Nina** (z. B. 86919, aus `…/adressen/ansprechpartneredit/{id}`).

## Feste Texte

- Schulungszeiten 09.00–17.00 Uhr, halbtags 09.00–12.30 oder 13.30–17.00 Uhr
- Zahlungsbedingung: monatlich nach Leistungserbringung, 10 Tage netto
- Umsatzsteuer (`steuerModus()`, `STEUER_TEXT`): im Preiskasten nur „netto“, Steuer erst in der Preistabelle.
  Deutschland 19 % mit Brutto (leerer Satz = 19 %) · **österreichische Firma (UID eingetragen), Online-Schulung: Reverse-Charge-Verfahren** (vor Ort in Österreich: „zzgl. gesetzlicher Umsatzsteuer“) ·
  Firma in Schweiz/Liechtenstein (UID): in Deutschland nicht steuerbar (Bezugsteuer beim Kunden) · ohne UID, übriges Ausland
  oder Seminar am Standort Wien: „zzgl. gesetzlicher Umsatzsteuer“ · Schulung an deutschem ppedv-Standort immer 19 %.
  Recherche (nicht steuerlich geprüft): Österreich – für Eintrittsberechtigungen zu Seminaren seit 2012 kein Reverse Charge
  ([ICON](https://www.icon.at/news/detail/umsatzsteuer-neuerungen-fuer-das-jahr-2012-durch-das-abgaeg-2011));
  Deutschland – offene vs. geschlossene Veranstaltungen, A 3a.7a UStAE seit 2021
  ([NWB](https://www.nwb-experten-blog.de/das-ende-der-geschlossenen-veranstaltung/),
  [Haufe](https://www.haufe.de/finance/haufe-finance-office-premium/veranstaltungsleistungen-in-der-umsatzsteuer-25-steuerschuldner_idesk_PI20354_HI15284072.html));
  Schweiz – B2B-Leistungsort beim Kunden, Bezugsteuer ([sevdesk](https://sevdesk.de/rechnung-in-schweiz-muster/))
- Digitales ppedv Teilnehmerzertifikat inklusive; nicht gendern; keine Ergebnisversprechen
- Kompetenzmodell: Zeitraum nach Vereinbarung (keine Wochenangaben im Angebot)
- Mehr als 10 Teilnehmer (Inhouse, Kompetenzmodell je Kurs): Kurs wird mehrfach gebucht, jeder weitere Durchgang −20 %; jeder Vor-Ort-Durchgang zählt als eigener Anreise-Termin
- Kompetenzmodell-Reisekosten: km je Termin × 0,60 € + Hotel ca. 90 € (Anreise am Vortag = 1 Nacht je Kurstag, sonst Kurstage − 1) oder Pauschale je Termin; ohne Angaben steht „nach Aufwand“ als eigene Position
- Kursplan mit Agenda je Kurs (aus der Matrix), 12 Kurse je Seite; Hardware-Zeile und optionale Zusatzleistungen (VMs 29 €/Person/Tag) wie in der ppedv-Vorlage
- Mehr als 10 Teilnehmer, aber nur 1–2 Personen darüber: per Häkchen Aufpreis 250 € je Person und Tag statt weiterem Durchgang (Ausnahme)
- Ansprechpartner bei ppedv: feste Auswahl (`ANSPRECHPARTNER`), Auswahl merkt sich der Browser
- „Ihre Investition“ zeigt Rabatte: durchgestrichener Normalpreis + „Sie sparen …“
- Technologien, Vorkenntnisse, Voraussetzungen werden aus Kursen/Workshop/Format vorgeschlagen (`detailVorschlag()`); eigene Einträge bleiben
