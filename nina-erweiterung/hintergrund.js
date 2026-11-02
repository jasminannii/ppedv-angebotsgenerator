// Öffnet die Nina-Seiten in einem Tab im Hintergrund, liest die Felder fürs Angebot und schließt den Tab wieder.
// Läuft mit der Nina-Anmeldung der Person; nichts geht an einen Server.
const NINA = "https://nina.ppedv.de";
const pause = ms => new Promise(r => setTimeout(r, ms));

function leseAnsprechpartner() {
  const v = n => { const e = document.querySelector('[name="VM.' + n + '"]'); return e ? e.value.trim() : ""; };
  if (!/ansprechpartneredit/i.test(location.pathname)) return null;
  if (!v("Name1") && !v("EMail")) return /Not Found/i.test(document.title) ? { nichtGefunden: true } : null;
  const a = document.querySelector('a[href*="kundenedit/" i]');
  return { anrede: v("Anrede"), vorname: v("Name2"), nachname: v("Name1"), email: v("EMail"), firma: a ? a.textContent.trim() : "", kundeUrl: a ? a.href : "" };
}

function leseFirma() {
  const v = n => { const e = document.querySelector('[name="VM.' + n + '"]'); return e ? e.value.trim() : ""; };
  if (!/kundenedit/i.test(location.pathname) || !v("Name1")) return null;
  const n2 = v("Name2");   // dort steht teils „z. Hd. …“ – das gehört nicht zum Firmennamen
  const u = v("Bemerkung").match(/\b(ATU\s?\d{8}|CHE[-.\s]?\d{3}\.?\d{3}\.?\d{3})/i);
  const b = document.querySelector(".badge.bg-success");
  return { firma: v("Name1") + (n2 && !/^(z\.?\s*H|c\/o|attn|herr|frau)/i.test(n2) ? " " + n2 : ""), strasse: v("Straße"), plz: v("Plz"), ort: v("Ort"), land: v("Land"),
    uid: u ? u[1].replace(/\s/g, "").toUpperCase() : "", betreuer: b ? b.textContent.trim() : "" };
}

// Wartet, bis Blazor die Felder gefüllt hat. Bleibt der Tab außerhalb von Nina stehen, fehlt die Anmeldung.
async function warte(tabId, func) {
  const start = Date.now();
  let draussenSeit = null;
  while (Date.now() - start < 25000) {
    await pause(300);
    const tab = await chrome.tabs.get(tabId);
    let ergebnis = null, inNina = true;
    try {
      const r = await chrome.scripting.executeScript({ target: { tabId }, func });
      ergebnis = r[0] && r[0].result;
    } catch (e) { inNina = false; }   // Seite lädt noch oder liegt außerhalb von Nina
    if (ergebnis && ergebnis.nichtGefunden) { if (Date.now() - start > 6000) return ergebnis; continue; }
    if (ergebnis) return ergebnis;
    if (!inNina && tab.status === "complete") {
      draussenSeit = draussenSeit || Date.now();
      if (Date.now() - draussenSeit > 4000) throw new Error("ANMELDUNG");
    } else draussenSeit = null;
  }
  throw new Error("ZEIT");
}

async function hole(id) {
  const tab = await chrome.tabs.create({ url: NINA + "/ppcompany/adressen/ansprechpartneredit/" + id, active: false });
  let schliessen = true;
  try {
    const ap = await warte(tab.id, leseAnsprechpartner);
    if (ap.nichtGefunden) return { fehler: "Zu dieser Nummer gibt es in Nina keinen Ansprechpartner." };
    const { kundeUrl, ...daten } = ap;
    if (kundeUrl) {
      await chrome.tabs.update(tab.id, { url: kundeUrl });
      try { Object.assign(daten, await warte(tab.id, leseFirma)); }
      catch (e) { daten.hinweis = "Die Firmenadresse konnte nicht gelesen werden. Bitte ergänzen."; }
    }
    return daten;
  } catch (e) {
    if (e.message === "ANMELDUNG") {
      schliessen = false;
      await chrome.tabs.update(tab.id, { active: true });
      return { fehler: "Bitte in Nina anmelden und dann noch einmal „Aus Nina holen“." };
    }
    return { fehler: "Nina hat nicht rechtzeitig geantwortet. Bitte noch einmal versuchen." };
  } finally {
    if (schliessen) chrome.tabs.remove(tab.id).catch(() => {});
  }
}

chrome.runtime.onMessage.addListener((nachricht, absender, antwort) => {
  if (nachricht.typ !== "hole" || !/^\d{1,9}$/.test(nachricht.id)) return;
  hole(nachricht.id).then(antwort);
  return true;
});
