// Läuft im Angebotsgenerator: meldet die Erweiterung an und reicht Anfragen an den Hintergrund weiter
document.documentElement.dataset.ppedvNina = "1";
window.addEventListener("message", e => {
  if (e.source !== window || e.origin !== location.origin || !e.data || e.data.typ !== "ppedv-nina-anfrage") return;
  const id = String(e.data.id);
  chrome.runtime.sendMessage({ typ: "hole", id }, antwort => {
    const a = antwort || { fehler: "Keine Antwort von der Erweiterung." };
    window.postMessage(Object.assign({}, a, { typ: "ppedv-nina-antwort", id }), location.origin);
  });
});
