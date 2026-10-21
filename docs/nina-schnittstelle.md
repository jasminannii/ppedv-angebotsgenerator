# Nina-Schnittstelle für den Angebotsgenerator

**An:** Nina-Team / Geschäftsführung · **Von:** Jasmin Meilner (Sales) · **Stand:** 21.10.2026

## Ziel

Im Angebotsgenerator (https://ppedv-angebotsgenerator.vercel.app) gibt der Vertrieb die
**Ansprechpartner-ID aus Nina** ein (die Nummer aus `…/adressen/ansprechpartneredit/{id}`,
z. B. 86919). Ansprechpartner, Firma mit Adresse, **Kundennummer** (= Angebotsnummer) und der
zuständige Betreuer sollen dann automatisch übernommen werden – kein Abtippen, keine veralteten Adressen.

Die Daten gehen **direkt von Nina in den Browser** der angemeldeten Mitarbeiterin.
Der Angebotsgenerator hat keinen eigenen Server und speichert nichts zentral.

## Ist-Stand Nina (von außen gesehen)

- ASP.NET Core unter `https://nina.ppedv.de/ppcompany/…` auf IIS
- Anmeldung über **Microsoft Entra ID** (OpenID Connect, App-Registrierung `191e644b-…`)
- CORS ist bereits konfiguriert, aktuell für `https://ppedv.de`

## Was wir brauchen

### 1. Eine lesende Abfrage (GET)

```
GET https://nina.ppedv.de/ppcompany/api/angebot/ansprechpartner/{ansprechpartnerId}
```

Antwort (JSON), nur die Felder, die ins Angebot gehören:

```json
{
  "ansprechpartner": { "id": 86919, "anrede": "Frau", "titel": "", "vorname": "Erika",
                       "nachname": "Muster", "email": "e.muster@beispiel.de", "telefon": "+49 …" },
  "kundennummer": "140678156",
  "firma": "Beispiel GmbH",
  "strasse": "Musterstraße 1",
  "plz": "12345",
  "ort": "Musterstadt",
  "betreuer": { "name": "Jasmin Meilner", "funktion": "Head of Sales",
                "telefon": "+49 8677 9889-16", "email": "jasminm@ppedv.de" }
}
```

- `ansprechpartner`: die Person mit dieser ID – sie wird im Angebot angeschrieben.
- `kundennummer`, `firma`, Adresse: von der Firma, zu der der Ansprechpartner gehört.
  Die **Angebotsnummer ist die Ansprechpartner-ID** (Dateiname `ANG-<Ansprechpartner-ID>_<Firma>`);
  die Kundennummer wird nur zur Information mitgeliefert.
- `betreuer`: der **Besitzer** des Kunden in Nina – wird im Angebot „Ihr Kontakt bei ppedv“.
- Optional, falls einfach: dieselbe Antwort über die Kundennummer
  (`GET …/api/angebot/kunde/{kundennummer}`, dann mit allen Ansprechpartnern als Liste).

Fehlerfälle: `404` = unbekannte Nummer, `401/403` = nicht angemeldet bzw. keine Berechtigung.

### 2. Anmeldung – Empfehlung: Entra-ID-Token

1. In der Nina-App-Registrierung eine **API freigeben** („Expose an API“),
   z. B. Bereich `Angebot.Read`.
2. Für den Angebotsgenerator eine **eigene App-Registrierung** (Typ SPA) mit
   Redirect `https://ppedv-angebotsgenerator.vercel.app`, Berechtigung auf `Angebot.Read`.
3. Die Abfrage akzeptiert `Authorization: Bearer <Token>` und prüft die übliche Nina-Berechtigung.

Der Generator meldet die Mitarbeiterin mit ihrem Microsoft-365-Konto an (Microsoft-Bibliothek MSAL)
und schickt das Token mit. Kein eigenes Passwort, keine Weitergabe von Zugangsdaten.

*Alternative:* bestehendes Nina-Login-Cookie mit `credentials: include`. Funktioniert von einer
fremden Domain (vercel.app) wegen der Cookie-Sperren der Browser nur unzuverlässig – daher nicht empfohlen.

### 3. CORS-Freigabe

```
Access-Control-Allow-Origin:  https://ppedv-angebotsgenerator.vercel.app
Access-Control-Allow-Methods: GET, OPTIONS
Access-Control-Allow-Headers: Authorization, Content-Type
```

Kein `*`. Zieht der Generator später auf eine ppedv-Adresse um (z. B. `angebot.ppedv.de`),
kommt diese Adresse dazu.

## Datenschutz

- Nur angemeldete Mitarbeiter mit Nina-Berechtigung bekommen Daten.
- Nur die Felder oben – keine Umsätze, Notizen oder Historie.
- Der Generator speichert nichts zentral; Entwürfe liegen nur im Browser der Person bzw.
  als Datei, die sie selbst ablegt (`\\bgh\sekret\Sales\Inbound\aktiv`).

## Ansprechpartnerin

Jasmin Meilner, jasminm@ppedv.de, +49 8677 9889-16 – die Gegenseite im Generator
(Eingabe Kundennummer, Übernahme in die Felder) wird umgesetzt, sobald die Abfrage steht.
