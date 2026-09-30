/// Icônes au trait des écrans maîtres (viewBox 24×24), copiées telles quelles
/// depuis design/masters/*.html. Affichées par le widget `AppIcon`.
abstract final class AppIcons {
  static const back = '<path d="m15 18-6-6 6-6"/>';
  static const arrowRight = '<path d="M5 12h14M13 6l6 6-6 6"/>';
  static const chevronRight = '<path d="m9 6 6 6-6 6"/>';
  static const check = '<path d="m5 12 5 5 9-10"/>';
  static const minus = '<path d="M5 12h14"/>';
  static const plus = '<path d="M12 5v14M5 12h14"/>';

  // Landing
  static const cutlery = '<path d="M7 3v7a2 2 0 0 0 4 0V3M9 12v9M17 3c-2 1.5-2.5 5-2.5 8H17v10"/>';
  static const wallet = '<rect x="3" y="6" width="18" height="14" rx="3"/><path d="M3 10h18M16 15h2"/>';
  static const cart =
      '<circle cx="9" cy="20" r="1.5"/><circle cx="18" cy="20" r="1.5"/><path d="M2 3h3l2.5 12h11L21 7H6"/>';
  static const bars = '<path d="M5 20v-6M10 20V9M15 20v-9M20 20V5"/>';

  // Connexion
  static const mail = '<rect x="3" y="5" width="18" height="14" rx="2.5"/><path d="m4 7 8 6 8-6"/>';
  static const lock = '<rect x="5" y="11" width="14" height="10" rx="2.5"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>';
  static const eye = '<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>';
  static const shield = '<path d="M12 3 4 6v6c0 5 3.5 8 8 9 4.5-1 8-4 8-9V6z"/>';

  // Onboarding
  static const bulb =
      '<path d="M9 18h6M10 21h4M12 3a6 6 0 0 0-3.5 10.9c.6.5 1 1.2 1 2.1h5c0-.9.4-1.6 1-2.1A6 6 0 0 0 12 3z"/>';
  static const target = '<circle cx="12" cy="12" r="8"/><circle cx="12" cy="12" r="4"/><circle cx="12" cy="12" r="1"/>';
  static const trendDown = '<path d="m3 9 5 5 4-4 8 8M15 18h5v-5"/>';
  static const trend = '<path d="m3 15 5-5 4 4 8-8M15 6h5v5"/>';
  static const dumbbell = '<path d="M6 8v8M18 8v8M3 10v4M21 10v4M6 12h12"/>';
  static const bolt = '<path d="M13 2 5 14h6l-1 8 8-12h-6z"/>';
  static const lotus =
      '<path d="M12 20c-4 0-8-2-9-6 3 0 6 1 9 4 3-3 6-4 9-4-1 4-5 6-9 6zM12 18c-2-3-2-7 0-11 2 4 2 8 0 11z"/>';
  static const sun =
      '<circle cx="12" cy="12" r="3.5"/><path d="M12 2v4M12 18v4M2 12h4M18 12h4M5 5l2.8 2.8M16.2 16.2 19 19M5 19l2.8-2.8M16.2 7.8 19 5"/>';
  static const male = '<circle cx="10" cy="14" r="5"/><path d="M14 10l6-6M15 4h5v5"/>';
  static const female = '<circle cx="12" cy="9" r="5"/><path d="M12 14v7M9 18h6"/>';
  static const leaf = '<path d="M5 19c8 0 14-6 14-15C10 4 5 9 5 15v4zM5 19l7-7"/>';

  // Tableau de bord
  static const bell = '<path d="M6 9a6 6 0 1 1 12 0c0 6 2.5 7.5 2.5 7.5h-17S6 15 6 9M10 20a2 2 0 0 0 4 0"/>';
  static const scale = '<rect x="3" y="4" width="18" height="16" rx="4"/><path d="M8 9a4 4 0 0 1 8 0M12 9l1.5-1.5"/>';
  static const clock = '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>';

  // Barre de navigation
  static const home = '<path d="M3 11.5 12 4l9 7.5V20a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/>';
  static const week = '<path d="M7 3v8M5 3v5a2 2 0 0 0 4 0V3M7 11v10M17 3c-2 2-2 6 0 8v10"/>';
  static const fridge = '<rect x="5" y="3" width="14" height="18" rx="2.5"/><path d="M5 10h14M9 6v2M9 13v3"/>';

  // Recette
  static const heart = '<path d="M12 20s-7-4.4-9-9A5 5 0 0 1 12 6a5 5 0 0 1 9 5c-2 4.6-9 9-9 9z"/>';
  static const moon = '<path d="M20 14A8 8 0 1 1 10 4a7 7 0 0 0 10 10z"/>';
  static const level = '<path d="M6 20v-5M12 20V10M18 20V4"/>';
  static const people =
      '<circle cx="9" cy="8" r="3.5"/><path d="M2 20c0-4 3-6 7-6s7 2 7 6M16 4a3.5 3.5 0 0 1 0 7M18 14c2.5.5 4 2.5 4 6"/>';
  // Macros (style de la référence 07)
  static const flame =
      '<path d="M12 3c.5 3 5 5.5 5 10.5a5 5 0 0 1-10 0c0-2.2 1.2-3.8 2.3-4.8.2 1.8 1 2.8 2 3.1-.4-3 .2-6 .7-8.8z"/>';
  static const wheat =
      '<path d="M12 21V9M12 9c-1.8-.8-3-2.6-3-5 2 .4 3 2 3 3.6M12 9c1.8-.8 3-2.6 3-5-2 .4-3 2-3 3.6M12 14c-2.2-.6-4-2.4-4-5 2.2.4 4 2 4 4M12 14c2.2-.6 4-2.4 4-5-2.2.4-4 2-4 4M12 19c-2.2-.6-4-2.4-4-5 2.2.4 4 2 4 4M12 19c2.2-.6 4-2.4 4-5-2.2.4-4 2-4 4"/>';
  static const drop = '<path d="M12 3s6 6.5 6 11a6 6 0 0 1-12 0c0-4.5 6-11 6-11z"/>';

  // Réserve
  static const scan =
      '<path d="M4 8V5a1 1 0 0 1 1-1h3M16 4h3a1 1 0 0 1 1 1v3M20 16v3a1 1 0 0 1-1 1h-3M8 20H5a1 1 0 0 1-1-1v-3M8 12h8"/>';
  static const barcode = '<path d="M4 6v12M7 6v12M10 6v12M14 6v12M17 6v12M20 6v12"/>';
  static const camera = '<path d="M4 8h3l2-3h6l2 3h3v11H4z"/><circle cx="12" cy="13" r="3.5"/>';
  static const basket = '<path d="M3 10h18l-2 10H5zM8 10l4-6 4 6M9 14v3M15 14v3"/>';
  static const cupboard = '<rect x="4" y="3" width="16" height="18" rx="2"/><path d="M12 3v18M9.5 11v2M14.5 11v2"/>';
  static const snowflake = '<path d="M12 2v20M4.9 7l14.2 10M19.1 7 4.9 17M9 4l3 2 3-2M9 20l3-2 3 2"/>';
  // Onboarding Solo (jalon 4) — même style au trait
  static const chair = '<path d="M6 19v-3M18 19v-3M5 12h14v4H5zM7 12V6a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v6"/>';
  static const walk = '<circle cx="13" cy="4" r="2"/><path d="m9 20 3-6 3 3v4M7 12l3-4 4 1 3 3M10 8l-1 5"/>';
  static const run = '<circle cx="15" cy="4" r="2"/><path d="m5 20 4-5 3 2 1-5 3 3h3M9 10l3-3 3 1"/>';
  static const bluetooth = '<path d="m7 7 10 10-5 5V2l5 5L7 17"/>';
  static const heartPulse =
      '<path d="M19.5 12.6 12 20l-7.5-7.4A5 5 0 1 1 12 6a5 5 0 1 1 7.5 6.6z"/><path d="M4 12h4l2-3 3 6 2-3h5"/>';
  static const calendar = '<rect x="3" y="5" width="18" height="16" rx="2.5"/><path d="M3 10h18M8 3v4M16 3v4"/>';
  static const piggy =
      '<path d="M19 9c1 0 2 1 2 2v2h-2l-1 3h-2v2h-3v-2h-3v2H7v-2.5A6 6 0 0 1 11 6h3a6 6 0 0 1 5 3z"/><path d="M15.5 10.5h.01"/>';
  static const balance = '<path d="M12 3v18M7 21h10M5 7h14M5 7l-3 7a3 3 0 0 0 6 0zM19 7l-3 7a3 3 0 0 0 6 0z"/>';
  static const sparkles =
      '<path d="M12 3l1.8 4.9L19 10l-5.2 2.1L12 17l-1.8-4.9L5 10l5.2-2.1zM19 16l.8 2.2L22 19l-2.2.8L19 22l-.8-2.2L16 19l2.2-.8z"/>';
  static const block = '<circle cx="12" cy="12" r="9"/><path d="m5.6 5.6 12.8 12.8"/>';
  static const search = '<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>';
  static const close = '<path d="M6 6l12 12M18 6 6 18"/>';
  static const egg = '<path d="M12 3c-4 0-7 6-7 10a7 7 0 0 0 14 0c0-4-3-10-7-10z"/>';
  static const skillet = '<circle cx="10" cy="13" r="6"/><path d="M16 13h6"/>';
  static const chefHat = '<path d="M6 13a4 4 0 1 1 2-7.5A4 4 0 0 1 16 5.5 4 4 0 1 1 18 13v7H6z"/><path d="M6 17h12"/>';
  static const briefcase =
      '<rect x="3" y="7" width="18" height="13" rx="2.5"/><path d="M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2M3 13h18"/>';
  static const oven =
      '<rect x="3" y="3" width="18" height="18" rx="2.5"/><path d="M3 8h18M7 5.5h.01M11 5.5h.01"/><rect x="7" y="11" width="10" height="7" rx="1"/>';
  static const stovetop =
      '<rect x="3" y="4" width="18" height="16" rx="2.5"/><circle cx="8.5" cy="10" r="2.5"/><circle cx="15.5" cy="10" r="2.5"/><circle cx="8.5" cy="16" r="1.5"/><circle cx="15.5" cy="16" r="1.5"/>';
  static const microwave =
      '<rect x="2" y="5" width="20" height="14" rx="2.5"/><rect x="5" y="8" width="10" height="8" rx="1"/><path d="M18 9v.01M18 12v.01M18 15v.01"/>';
  static const airfryer =
      '<path d="M7 3h10a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z"/><path d="M5 12h14M10 16h4M9 7h6"/>';
  static const robot = '<path d="M6 10h12l-1.5 10h-9z"/><path d="M9 10V6a3 3 0 0 1 6 0v4M4 20h16"/>';
  static const blender = '<path d="M8 3h9l-2 12H9zM9 15h6l1 6H8zM5 6h3"/>';
  static const pressureCooker =
      '<path d="M4 11h16v5a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4zM7 11V9a5 5 0 0 1 10 0v2M12 4V2M2 13h2M20 13h2"/>';
  static const slowCooker = '<path d="M3 10h18M5 10v6a4 4 0 0 0 4 4h6a4 4 0 0 0 4-4v-6M8 10V8a4 4 0 0 1 8 0v2"/>';
  static const grill = '<path d="M4 10h16M6 10a6 6 0 0 0 12 0M8 16l-2 5M16 16l2 5M9 6c0-1 1-1 1-2M14 6c0-1 1-1 1-2"/>';
  static const wok = '<path d="M3 11h18a9 9 0 0 1-18 0zM21 11l2-2"/>';
  static const toaster = '<rect x="3" y="9" width="18" height="11" rx="3"/><path d="M8 9V5h8v4M17 13h.01"/>';
  static const steamer =
      '<path d="M4 12h16v4a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4zM4 16h16M9 8c0-1 1-1 1-2s-1-1-1-2M14 8c0-1 1-1 1-2s-1-1-1-2"/>';
  static const mapPin = '<path d="M12 21s-7-6-7-11a7 7 0 0 1 14 0c0 5-7 11-7 11z"/><circle cx="12" cy="10" r="2.5"/>';
  static const car = '<path d="M4 17v-5l2-5h12l2 5v5zM5 17v2M19 17v2"/><path d="M8 14h.01M16 14h.01"/>';
  static const bag = '<path d="M5 8h14l-1 12H6zM9 8V6a3 3 0 0 1 6 0v2"/>';
  static const truck =
      '<path d="M3 6h11v10H3zM14 10h4l3 3v3h-7"/><circle cx="7" cy="17.5" r="1.5"/><circle cx="17" cy="17.5" r="1.5"/>';
  static const store =
      '<path d="M4 10v10h16V10M3 6l2-3h14l2 3v2a3 3 0 0 1-6 0 3 3 0 0 1-6 0 3 3 0 0 1-6 0z"/><path d="M10 20v-5h4v5"/>';
  static const edit = '<path d="M4 20h4L19 9l-4-4L4 16z"/><path d="m13 7 4 4"/>';
  static const checkCircle = '<circle cx="12" cy="12" r="9"/><path d="m8 12 3 3 5-6"/>';
  static const info = '<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>';
  static const chevronDown = '<path d="m6 9 6 6 6-6"/>';
  static const list = '<rect x="5" y="4" width="14" height="17" rx="2.5"/><path d="M9 4V3h6v1M9 10h6M9 14h6M9 18h4"/>';
  static const user = '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>';
  static const fish = '<path d="M3 12c3-5 9-6 14-2l4-3v10l-4-3c-5 4-11 3-14-2z"/><path d="M15.5 11h.01"/>';
  static const nut =
      '<path d="M12 4c3.9 0 6.5 3 6.5 7.5S15.5 20 12 20s-6.5-4-6.5-8.5S8.1 4 12 4z"/><path d="M8 9c2.5 1 5.5 1 8 0"/>';
  static const shrimp =
      '<path d="M6 8a7 7 0 0 1 13 3.5c0 3.9-3.1 6.5-7 6.5H9"/><path d="M9 18l-3 3M9 18l-2.5-1.5M13 13a3 3 0 0 1-3.5-3"/>';
  static const sprout = '<path d="M12 21v-8M12 13c0-4-3-6-7-6 0 4 3 6 7 6zM12 11c0-3.5 2.5-6 7-6 0 3.5-2.5 6-7 6z"/>';
  // Régimes « sans … » : le pictogramme de l'aliment, barré.
  static const _slash = '<path d="m4 4 16 16"/>';
  static const milk = '<path d="M9 3h6v3l2 4v10a1 1 0 0 1-1 1H8a1 1 0 0 1-1-1V10l2-4zM7 14h10"/>';
  static const noPork = piggy + _slash;
  static const noMilk = milk + _slash;
  static const noGluten = wheat + _slash;
  static const flag ='<path d="M5 21V4M5 4h11l-2 4 2 4H5"/>';

  // Foyer : enfant (visage souriant) et bébé (tétine)
  static const child =
      '<circle cx="12" cy="12" r="9"/><path d="M8.5 14.5c1.8 2 5.2 2 7 0"/><path d="M9 9.5h.01M15 9.5h.01"/>';
  static const baby =
      '<circle cx="12" cy="10" r="3"/><path d="M12 13v2"/><path d="M7 17.5c0-1.5 2.2-2.5 5-2.5s5 1 5 2.5-2.2 2.5-5 2.5-5-1-5-2.5z"/>'
      '<path d="M12 7V4"/>';
}
