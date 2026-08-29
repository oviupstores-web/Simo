import * as Print from "expo-print";
import * as Sharing from "expo-sharing";
import { Platform } from "react-native";
import { DayPlan, ShoppingItem } from "./mockData";

function esc(s: string) {
  return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

export async function exportWeekPdf(weeklyPlan: DayPlan[], shoppingList: ShoppingItem[]) {
  const total = shoppingList.reduce((s, i) => s + (i.price ?? 0), 0);
  const mealTotal = weeklyPlan.reduce(
    (s, d) => s + d.meals.reduce((s2, m) => s2 + (m.price ?? 0), 0),
    0
  );
  const byStore: Record<string, ShoppingItem[]> = {};
  for (const it of shoppingList) (byStore[it.store] = byStore[it.store] || []).push(it);

  const daysHtml = weeklyPlan
    .map(
      (d) => `
    <div class="day">
      <h3>${esc(d.day)}</h3>
      <div class="meals">
        ${d.meals
          .map(
            (m) => `
          <div class="meal">
            <img src="${esc(m.image)}" alt="${esc(m.title)}"/>
            <div class="meta">
              <div class="slot">${esc(m.slot)} · ${m.time} min · ${m.price.toFixed(2)} €</div>
              <div class="title">${esc(m.title)}</div>
            </div>
          </div>`
          )
          .join("")}
      </div>
    </div>`
    )
    .join("");

  const storesHtml = Object.entries(byStore)
    .map(([store, items]) => {
      const st = items.reduce((s, i) => s + (i.price ?? 0), 0);
      return `
      <div class="store">
        <div class="storeH"><strong>${esc(store)}</strong><span>${st.toFixed(2)} €</span></div>
        <ul>
          ${items
            .map(
              (i) =>
                `<li><span>${esc(i.label)} · ${esc(i.qty)} · ${esc(i.rayon)}</span><span>${(i.price ?? 0).toFixed(2)} €</span></li>`
            )
            .join("")}
        </ul>
      </div>`;
    })
    .join("");

  const html = `<!DOCTYPE html><html><head><meta charset="utf-8"/>
    <title>Ma semaine Menoo</title>
    <style>
      * { box-sizing: border-box; }
      body { font-family: -apple-system, Roboto, Helvetica, Arial, sans-serif; color: #13261C; background: #FAF9F6; padding: 24px; margin: 0; }
      h1 { color: #19533B; margin: 0 0 4px; font-size: 28px; }
      .sub { color: #6B7A70; margin: 0 0 16px; font-size: 14px; }
      .cards { display: flex; gap: 8px; margin-bottom: 24px; }
      .card { flex: 1; background: white; border-radius: 12px; padding: 12px; box-shadow: 0 2px 6px rgba(14,50,34,0.06); }
      .card .l { color: #6B7A70; font-size: 12px; }
      .card .v { color: #19533B; font-size: 22px; font-weight: 800; margin-top: 2px; }
      .day { margin-bottom: 18px; page-break-inside: avoid; }
      .day h3 { color: #19533B; font-size: 18px; margin: 0 0 8px; }
      .meals { display: flex; gap: 8px; }
      .meal { flex: 1; background: white; border-radius: 12px; padding: 8px; }
      .meal img { width: 100%; height: 100px; object-fit: cover; border-radius: 8px; }
      .meta { margin-top: 6px; }
      .meta .slot { color: #19533B; font-weight: 700; font-size: 11px; }
      .meta .title { color: #13261C; font-size: 13px; font-weight: 600; margin-top: 2px; }
      h2 { color: #19533B; margin: 24px 0 8px; }
      .store { background: white; border-radius: 12px; padding: 12px; margin-bottom: 10px; }
      .storeH { display: flex; justify-content: space-between; margin-bottom: 6px; }
      ul { margin: 0; padding: 0; list-style: none; }
      li { display: flex; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid #E8E6E1; font-size: 13px; }
      li:last-child { border-bottom: 0; }
    </style></head><body>
      <h1>Menoo — Ma semaine</h1>
      <p class="sub">7 jours · ${weeklyPlan.reduce((s, d) => s + d.meals.length, 0)} repas · Générée automatiquement</p>
      <div class="cards">
        <div class="card"><div class="l">Coût des repas</div><div class="v">${mealTotal.toFixed(2)} €</div></div>
        <div class="card"><div class="l">Courses à prévoir</div><div class="v">${total.toFixed(2)} €</div></div>
        <div class="card"><div class="l">Articles</div><div class="v">${shoppingList.length}</div></div>
      </div>
      ${daysHtml}
      <h2>Liste de courses</h2>
      ${storesHtml}
      <p class="sub" style="margin-top:20px">Prix indicatifs — Open Prices. Aucun caractère médical.</p>
    </body></html>`;

  const { uri } = await Print.printToFileAsync({ html });
  if (Platform.OS === "web") {
    // Sur web, ouvre le PDF dans un nouvel onglet.
    try {
      // @ts-ignore
      if (typeof window !== "undefined") window.open(uri, "_blank");
    } catch {}
    return uri;
  }
  const canShare = await Sharing.isAvailableAsync();
  if (canShare) {
    await Sharing.shareAsync(uri, { mimeType: "application/pdf", dialogTitle: "Ma semaine Menoo" });
  }
  return uri;
}
