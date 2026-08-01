figma.showUI(__html__, { width: 370, height: 610, themeColors: true });

const COLORS = {
  brand: "#6C5CE7",
  brandDark: "#4D3EC8",
  brandSoft: "#EEEAFE",
  blue: "#4C7DF0",
  cyan: "#32C7C1",
  background: "#F7F8FC",
  surface: "#FFFFFF",
  surfaceAlt: "#F0F2F8",
  text: "#1E2235",
  textMuted: "#687086",
  border: "#E4E7F0",
  success: "#27B984",
  successSoft: "#E5F8F1",
  warning: "#F5A623",
  warningSoft: "#FFF4DC",
  danger: "#F45B72",
  dangerSoft: "#FFE8EC",
  dark: "#111528",
  darkSoft: "#20263D",
  peach: "#F5C7A9",
  hair: "#322A35",
  white: "#FFFFFF"
};

const GENERATED_KEY = "aiTeacherGenerated";
const PAGE_NAMES = ["01 Foundations", "02 Components", "03 Screens"];

function rgb(hex) {
  const clean = hex.replace("#", "");
  const value = parseInt(clean, 16);
  return {
    r: ((value >> 16) & 255) / 255,
    g: ((value >> 8) & 255) / 255,
    b: (value & 255) / 255
  };
}

function solid(hex, opacity = 1) {
  return [{ type: "SOLID", color: rgb(hex), opacity }];
}

function mark(node, logicalName) {
  node.setPluginData(GENERATED_KEY, "true");
  if (logicalName) node.setPluginData("aiTeacherKey", logicalName);
  return node;
}

function post(message) {
  figma.ui.postMessage({ type: "progress", message });
}

async function preloadFonts() {
  const fonts = [
    { family: "Inter", style: "Regular" },
    { family: "Inter", style: "Medium" },
    { family: "Inter", style: "Semi Bold" },
    { family: "Inter", style: "Bold" }
  ];
  for (const font of fonts) await figma.loadFontAsync(font);
}

function autoFrame(parent, options = {}) {
  const frame = figma.createFrame();
  frame.name = options.name || "Frame";
  frame.layoutMode = options.direction || "VERTICAL";
  frame.primaryAxisSizingMode = options.primaryAxisSizingMode || "AUTO";
  frame.counterAxisSizingMode = options.counterAxisSizingMode || "AUTO";
  frame.itemSpacing = options.gap ?? 0;
  frame.paddingTop = options.paddingTop ?? options.padding ?? 0;
  frame.paddingRight = options.paddingRight ?? options.padding ?? 0;
  frame.paddingBottom = options.paddingBottom ?? options.padding ?? 0;
  frame.paddingLeft = options.paddingLeft ?? options.padding ?? 0;
  if (options.width) frame.resize(options.width, Math.max(options.height || 1, 1));
  if (options.height) frame.resize(frame.width, options.height);
  if (options.fill) frame.fills = solid(options.fill);
  else frame.fills = [];
  if (options.stroke) {
    frame.strokes = solid(options.stroke);
    frame.strokeWeight = options.strokeWeight || 1;
  } else {
    frame.strokes = [];
  }
  if (options.radius !== undefined) frame.cornerRadius = options.radius;
  if (options.clip !== undefined) frame.clipsContent = options.clip;
  if (options.shadow) {
    frame.effects = [{
      type: "DROP_SHADOW",
      color: { ...rgb("#18203A"), a: 0.10 },
      offset: { x: 0, y: 8 },
      radius: 24,
      spread: 0,
      visible: true,
      blendMode: "NORMAL"
    }];
  }
  parent.appendChild(frame);
  mark(frame, options.key || options.name);
  return frame;
}

function fixedFrame(parent, options = {}) {
  const frame = figma.createFrame();
  frame.name = options.name || "Frame";
  frame.resize(options.width || 100, options.height || 100);
  frame.fills = options.fill ? solid(options.fill) : [];
  frame.strokes = options.stroke ? solid(options.stroke) : [];
  if (options.stroke) frame.strokeWeight = options.strokeWeight || 1;
  if (options.radius !== undefined) frame.cornerRadius = options.radius;
  frame.clipsContent = options.clip ?? false;
  parent.appendChild(frame);
  mark(frame, options.key || options.name);
  return frame;
}

function rect(parent, x, y, width, height, fill, radius = 0, stroke = null) {
  const node = figma.createRectangle();
  node.x = x;
  node.y = y;
  node.resize(width, height);
  node.fills = fill ? solid(fill) : [];
  if (stroke) {
    node.strokes = solid(stroke);
    node.strokeWeight = 1;
  }
  node.cornerRadius = radius;
  parent.appendChild(node);
  mark(node);
  return node;
}

function ellipse(parent, x, y, width, height, fill, stroke = null) {
  const node = figma.createEllipse();
  node.x = x;
  node.y = y;
  node.resize(width, height);
  node.fills = fill ? solid(fill) : [];
  if (stroke) {
    node.strokes = solid(stroke);
    node.strokeWeight = 1;
  }
  parent.appendChild(node);
  mark(node);
  return node;
}

function line(parent, x, y, length, color, vertical = false) {
  const node = figma.createLine();
  node.x = x;
  node.y = y;
  node.resize(vertical ? 0 : length, vertical ? length : 0);
  node.strokes = solid(color);
  node.strokeWeight = 1;
  parent.appendChild(node);
  mark(node);
  return node;
}

function textNode(parent, characters, options = {}) {
  const node = figma.createText();
  node.fontName = {
    family: "Inter",
    style: options.style || "Regular"
  };
  node.characters = characters;
  node.fontSize = options.size || 14;
  node.lineHeight = { value: options.lineHeight || Math.round((options.size || 14) * 1.45), unit: "PIXELS" };
  node.letterSpacing = { value: options.letterSpacing || 0, unit: "PIXELS" };
  node.fills = solid(options.color || COLORS.text);
  node.textAlignHorizontal = options.align || "LEFT";
  if (options.width) {
    node.textAutoResize = "HEIGHT";
    node.resize(options.width, 10);
  } else {
    node.textAutoResize = "WIDTH_AND_HEIGHT";
  }
  if (options.opacity !== undefined) node.opacity = options.opacity;
  parent.appendChild(node);
  mark(node);
  return node;
}

function absoluteText(parent, characters, x, y, options = {}) {
  const node = textNode(parent, characters, options);
  node.x = x;
  node.y = y;
  return node;
}

function setFillSizing(node) {
  node.layoutSizingHorizontal = "FILL";
}

function pill(parent, label, options = {}) {
  const box = autoFrame(parent, {
    name: options.name || "Chip",
    direction: "HORIZONTAL",
    paddingTop: options.paddingY || 8,
    paddingBottom: options.paddingY || 8,
    paddingLeft: options.paddingX || 12,
    paddingRight: options.paddingX || 12,
    gap: 6,
    fill: options.fill || COLORS.brandSoft,
    stroke: options.stroke,
    radius: options.radius || 999
  });
  textNode(box, label, {
    size: options.size || 12,
    style: options.style || "Semi Bold",
    color: options.color || COLORS.brand
  });
  return box;
}

function button(parent, label, options = {}) {
  const box = autoFrame(parent, {
    name: options.name || `Button/${label}`,
    direction: "HORIZONTAL",
    paddingTop: options.height === 40 ? 11 : 14,
    paddingBottom: options.height === 40 ? 11 : 14,
    paddingLeft: options.paddingX || 18,
    paddingRight: options.paddingX || 18,
    gap: 8,
    fill: options.fill || COLORS.brand,
    stroke: options.stroke,
    radius: options.radius || 12,
    shadow: options.shadow
  });
  box.primaryAxisAlignItems = "CENTER";
  box.counterAxisAlignItems = "CENTER";
  if (options.width) {
    box.resize(options.width, options.height || 48);
    box.primaryAxisSizingMode = "FIXED";
    box.counterAxisSizingMode = "FIXED";
  }
  textNode(box, label, {
    size: options.size || 14,
    style: "Semi Bold",
    color: options.color || COLORS.white
  });
  return box;
}

function iconCircle(parent, symbol, options = {}) {
  const wrap = fixedFrame(parent, {
    name: options.name || "Icon",
    width: options.size || 48,
    height: options.size || 48,
    fill: options.fill || COLORS.surfaceAlt,
    radius: (options.size || 48) / 2,
    stroke: options.stroke
  });
  const t = absoluteText(wrap, symbol, 0, 0, {
    size: options.symbolSize || 20,
    style: "Semi Bold",
    color: options.color || COLORS.text,
    width: options.size || 48,
    align: "CENTER",
    lineHeight: options.size || 48
  });
  t.resize(options.size || 48, options.size || 48);
  return wrap;
}

function avatar(parent, x, y, size, options = {}) {
  const group = fixedFrame(parent, {
    name: "AI Teacher Avatar",
    width: size,
    height: size,
    fill: options.background || COLORS.brandSoft,
    radius: size / 2,
    clip: true
  });
  group.x = x;
  group.y = y;

  ellipse(group, size * 0.24, size * 0.17, size * 0.52, size * 0.60, COLORS.peach);
  ellipse(group, size * 0.20, size * 0.11, size * 0.60, size * 0.40, COLORS.hair);
  ellipse(group, size * 0.34, size * 0.39, size * 0.055, size * 0.07, COLORS.text);
  ellipse(group, size * 0.60, size * 0.39, size * 0.055, size * 0.07, COLORS.text);
  rect(group, size * 0.43, size * 0.58, size * 0.14, size * 0.025, options.speaking ? COLORS.danger : COLORS.text, 999);
  ellipse(group, size * 0.17, size * 0.70, size * 0.66, size * 0.48, options.shirt || COLORS.brand);
  if (options.badge) {
    ellipse(group, size * 0.72, size * 0.70, size * 0.20, size * 0.20, COLORS.success, COLORS.white);
    absoluteText(group, "✓", size * 0.72, size * 0.69, {
      size: size * 0.12,
      style: "Bold",
      color: COLORS.white,
      width: size * 0.20,
      align: "CENTER",
      lineHeight: size * 0.20
    });
  }
  return group;
}

async function pageByName(name, fallbackIndex) {
  let page = figma.root.children.find(p => p.name === name);
  if (page) {
    await page.loadAsync();
    return page;
  }

  const fallback = figma.root.children[fallbackIndex];
  if (fallback) {
    await fallback.loadAsync();
    if (fallback.children.length === 0 && (/^Page \d+$/.test(fallback.name) || fallback.name === "Page 1")) {
      fallback.name = name;
      return fallback;
    }
  }

  if (figma.root.children.length >= 3) {
    throw new Error(`Starter plan page limit reached. Rename or remove an unused page, then run again. Missing page: ${name}`);
  }

  page = figma.createPage();
  page.name = name;
  await page.loadAsync();
  return page;
}

async function ensurePages() {
  const pages = [];
  for (let i = 0; i < PAGE_NAMES.length; i++) {
    pages.push(await pageByName(PAGE_NAMES[i], i));
  }
  return pages;
}

function clearPageGenerated(page) {
  const generated = page.findAll(node => node.getPluginData && node.getPluginData(GENERATED_KEY) === "true");
  const topLevel = generated.filter(node => !node.parent || node.parent === page || node.parent.getPluginData(GENERATED_KEY) !== "true");
  topLevel.forEach(node => {
    if (!node.removed) node.remove();
  });
}

function pageTitle(page, title, subtitle) {
  const wrap = autoFrame(page, {
    name: `${title} Header`,
    direction: "VERTICAL",
    gap: 8,
    padding: 0
  });
  wrap.x = 80;
  wrap.y = 60;
  textNode(wrap, title, { size: 32, style: "Bold", color: COLORS.text });
  textNode(wrap, subtitle, { size: 14, color: COLORS.textMuted, width: 760 });
  return wrap;
}

function sectionTitle(parent, title, subtitle) {
  const wrap = autoFrame(parent, { name: `${title} Label`, direction: "VERTICAL", gap: 4 });
  textNode(wrap, title, { size: 20, style: "Bold" });
  if (subtitle) textNode(wrap, subtitle, { size: 12, color: COLORS.textMuted, width: 600 });
  return wrap;
}

async function generateFoundations(page) {
  await figma.setCurrentPageAsync(page);
  clearPageGenerated(page);
  post("Building visual foundations…");

  pageTitle(page, "AI Teacher Design System", "Friendly, premium and confidence-building interface for Android English learners.");

  const canvas = autoFrame(page, {
    name: "Foundations Canvas",
    direction: "VERTICAL",
    gap: 40,
    padding: 36,
    fill: COLORS.background,
    radius: 24,
    width: 1180
  });
  canvas.x = 80;
  canvas.y = 160;
  canvas.counterAxisSizingMode = "FIXED";

  sectionTitle(canvas, "Color foundations", "Primary, semantic and neutral colors used across the product.");

  const swatchRow = autoFrame(canvas, { name: "Color Swatches", direction: "HORIZONTAL", gap: 14 });
  const swatches = [
    ["Brand", COLORS.brand],
    ["Brand dark", COLORS.brandDark],
    ["Blue", COLORS.blue],
    ["Cyan", COLORS.cyan],
    ["Success", COLORS.success],
    ["Warning", COLORS.warning],
    ["Danger", COLORS.danger],
    ["Text", COLORS.text]
  ];
  for (const [name, color] of swatches) {
    const card = autoFrame(swatchRow, {
      name: `Color/${name}`,
      direction: "VERTICAL",
      gap: 10,
      padding: 10,
      fill: COLORS.surface,
      radius: 14,
      shadow: true
    });
    rect(card, 0, 0, 104, 76, color, 10);
    textNode(card, name, { size: 12, style: "Semi Bold" });
    textNode(card, color, { size: 10, color: COLORS.textMuted });
  }

  sectionTitle(canvas, "Typography", "Inter is used for reliable Android implementation and Figma availability.");

  const typography = autoFrame(canvas, {
    name: "Typography Samples",
    direction: "VERTICAL",
    gap: 14,
    padding: 24,
    fill: COLORS.surface,
    radius: 18,
    shadow: true
  });
  setFillSizing(typography);
  textNode(typography, "Display — Learn English with confidence", { size: 34, style: "Bold" });
  textNode(typography, "Heading 1 — Your AI speaking coach", { size: 26, style: "Bold" });
  textNode(typography, "Heading 2 — Continue your practice", { size: 20, style: "Semi Bold" });
  textNode(typography, "Body — Practice real conversations, receive helpful corrections and improve a little every day.", { size: 14, color: COLORS.textMuted, width: 720 });
  textNode(typography, "Caption — Session report updated just now", { size: 11, color: COLORS.textMuted });

  const lower = autoFrame(canvas, { name: "Foundations Lower Row", direction: "HORIZONTAL", gap: 24 });

  const spacingCard = autoFrame(lower, {
    name: "Spacing Scale",
    direction: "VERTICAL",
    gap: 14,
    padding: 24,
    fill: COLORS.surface,
    radius: 18,
    width: 520,
    shadow: true
  });
  spacingCard.counterAxisSizingMode = "FIXED";
  sectionTitle(spacingCard, "Spacing scale", "4px base grid");
  for (const value of [4, 8, 12, 16, 20, 24, 32, 40]) {
    const row = autoFrame(spacingCard, { direction: "HORIZONTAL", gap: 12 });
    fixedFrame(row, { width: value * 5, height: 12, fill: COLORS.brand, radius: 6 });
    textNode(row, `${value}px`, { size: 11, color: COLORS.textMuted });
  }

  const radiusCard = autoFrame(lower, {
    name: "Radius and Shadow",
    direction: "VERTICAL",
    gap: 18,
    padding: 24,
    fill: COLORS.surface,
    radius: 18,
    width: 520,
    shadow: true
  });
  radiusCard.counterAxisSizingMode = "FIXED";
  sectionTitle(radiusCard, "Radii and elevation", "Soft geometry keeps the AI experience approachable.");
  const radiusRow = autoFrame(radiusCard, { direction: "HORIZONTAL", gap: 18 });
  for (const value of [8, 12, 16, 24]) {
    const sample = fixedFrame(radiusRow, { width: 84, height: 64, fill: COLORS.brandSoft, radius: value, stroke: COLORS.brand });
    absoluteText(sample, `${value}px`, 0, 20, { size: 11, style: "Semi Bold", color: COLORS.brand, width: 84, align: "CENTER" });
  }
  const shadowSample = fixedFrame(radiusCard, { width: 420, height: 88, fill: COLORS.surface, radius: 16, shadow: true, stroke: COLORS.border });
  absoluteText(shadowSample, "Card elevation / subtle shadow", 20, 32, { size: 13, style: "Semi Bold" });

  page.selection = [canvas];
  figma.viewport.scrollAndZoomIntoView([canvas]);
}

function componentTitle(parent, title, description) {
  const wrap = autoFrame(parent, { direction: "VERTICAL", gap: 5 });
  textNode(wrap, title, { size: 18, style: "Bold" });
  textNode(wrap, description, { size: 12, color: COLORS.textMuted, width: 480 });
  return wrap;
}

function inputExample(parent, label, value, state = "default") {
  const wrap = autoFrame(parent, { name: `Input/${state}`, direction: "VERTICAL", gap: 8 });
  textNode(wrap, label, { size: 12, style: "Semi Bold" });
  const field = autoFrame(wrap, {
    direction: "HORIZONTAL",
    gap: 10,
    paddingTop: 14,
    paddingBottom: 14,
    paddingLeft: 14,
    paddingRight: 14,
    fill: COLORS.surface,
    stroke: state === "error" ? COLORS.danger : state === "focus" ? COLORS.brand : COLORS.border,
    strokeWeight: state === "focus" ? 2 : 1,
    radius: 12,
    width: 300,
    height: 48
  });
  field.primaryAxisSizingMode = "FIXED";
  field.counterAxisSizingMode = "FIXED";
  textNode(field, value, { size: 13, color: value ? COLORS.text : COLORS.textMuted });
  if (state === "error") textNode(wrap, "Please enter a valid value.", { size: 11, color: COLORS.danger });
  return wrap;
}

function topicCard(parent, icon, title, subtitle, accent) {
  const card = autoFrame(parent, {
    name: `Topic Card/${title}`,
    direction: "VERTICAL",
    gap: 12,
    padding: 18,
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 16,
    width: 210,
    height: 168,
    shadow: true
  });
  card.primaryAxisSizingMode = "FIXED";
  card.counterAxisSizingMode = "FIXED";
  iconCircle(card, icon, { size: 44, fill: accent, color: COLORS.white, symbolSize: 18 });
  textNode(card, title, { size: 15, style: "Semi Bold" });
  textNode(card, subtitle, { size: 11, color: COLORS.textMuted, width: 170 });
  return card;
}

function pillAt(parent, label, x, y, fill, color) {
  const width = Math.max(90, label.length * 6.8 + 24);
  const box = fixedFrame(parent, { width, height: 30, fill, radius: 999 });
  box.x = x;
  box.y = y;
  absoluteText(box, label, 0, 8, { size: 10, style: "Semi Bold", color, width, align: "CENTER" });
  return box;
}

function metricRow(parent, x, y, label, value, color) {
  ellipse(parent, x, y + 3, 10, 10, color);
  absoluteText(parent, label, x + 18, y, { size: 11, style: "Semi Bold" });
  absoluteText(parent, value, x + 112, y, { size: 11, color: COLORS.textMuted });
}

function scoreRing(parent, x, y, size, value) {
  ellipse(parent, x, y, size, size, COLORS.brandSoft);
  ellipse(parent, x + 7, y + 7, size - 14, size - 14, COLORS.surface);
  absoluteText(parent, value, x, y + 17, { size: 15, style: "Bold", color: COLORS.brand, width: size, align: "CENTER" });
}

async function generateComponents(page) {
  await figma.setCurrentPageAsync(page);
  clearPageGenerated(page);
  post("Building reusable component examples…");

  pageTitle(page, "Reusable Components", "A compact component language ready to translate into Flutter widgets.");

  const canvas = autoFrame(page, {
    name: "Components Canvas",
    direction: "VERTICAL",
    gap: 34,
    padding: 36,
    fill: COLORS.background,
    radius: 24,
    width: 1180
  });
  canvas.x = 80;
  canvas.y = 160;
  canvas.counterAxisSizingMode = "FIXED";

  componentTitle(canvas, "Buttons", "Primary, secondary, outline and destructive actions with minimum 48px touch targets.");
  const buttons = autoFrame(canvas, { direction: "HORIZONTAL", gap: 14 });
  button(buttons, "Start practice", { width: 180, fill: COLORS.brand });
  button(buttons, "View report", { width: 160, fill: COLORS.brandSoft, color: COLORS.brand });
  button(buttons, "Maybe later", { width: 150, fill: COLORS.surface, color: COLORS.text, stroke: COLORS.border });
  button(buttons, "End session", { width: 150, fill: COLORS.dangerSoft, color: COLORS.danger });

  componentTitle(canvas, "Inputs", "Clear labels, accessible focus treatment and explicit validation.");
  const inputs = autoFrame(canvas, { direction: "HORIZONTAL", gap: 18 });
  inputExample(inputs, "Email address", "learner@example.com", "default");
  inputExample(inputs, "Password", "Enter password", "focus");
  inputExample(inputs, "Email address", "wrong-email", "error");

  componentTitle(canvas, "Topic cards", "Quick, visual entry points for beginner-friendly conversations.");
  const topics = autoFrame(canvas, { direction: "HORIZONTAL", gap: 16 });
  topicCard(topics, "HI", "Daily life", "Everyday conversation and confidence.", COLORS.brand);
  topicCard(topics, "JOB", "Job interview", "Introduce yourself and answer clearly.", COLORS.blue);
  topicCard(topics, "TR", "Travel", "Airport, hotel and direction practice.", COLORS.cyan);
  topicCard(topics, "MK", "Market", "Ask prices and practice negotiation.", COLORS.success);

  componentTitle(canvas, "Teacher and learning cards", "Reusable surfaces for teachers, reports and progress.");
  const cards = autoFrame(canvas, { direction: "HORIZONTAL", gap: 20 });

  const teacher = fixedFrame(cards, { name: "Teacher Card", width: 330, height: 190, fill: COLORS.surface, radius: 18, stroke: COLORS.border, shadow: true });
  avatar(teacher, 20, 22, 88, { badge: true });
  absoluteText(teacher, "Maya", 126, 30, { size: 18, style: "Bold" });
  absoluteText(teacher, "Friendly English coach", 126, 58, { size: 12, color: COLORS.textMuted });
  pillAt(teacher, "Beginner friendly", 126, 88, COLORS.successSoft, COLORS.success);
  const teacherButton = fixedFrame(teacher, { name: "Select Teacher", width: 290, height: 46, fill: COLORS.brand, radius: 12 });
  teacherButton.x = 20;
  teacherButton.y = 128;
  absoluteText(teacherButton, "Choose Maya", 0, 13, { size: 13, style: "Semi Bold", color: COLORS.white, width: 290, align: "CENTER" });

  const progress = fixedFrame(cards, { name: "Progress Card", width: 330, height: 190, fill: COLORS.dark, radius: 18, shadow: true });
  absoluteText(progress, "Weekly progress", 22, 22, { size: 16, style: "Semi Bold", color: COLORS.white });
  absoluteText(progress, "84", 22, 60, { size: 42, style: "Bold", color: COLORS.white });
  absoluteText(progress, "minutes practiced", 91, 80, { size: 11, color: "#BBC2D5" });
  for (let i = 0; i < 7; i++) {
    const h = [34, 54, 26, 70, 48, 76, 62][i];
    rect(progress, 24 + i * 40, 154 - h, 22, h, i === 6 ? COLORS.cyan : COLORS.brand, 8);
  }

  const report = fixedFrame(cards, { name: "Report Summary Card", width: 330, height: 190, fill: COLORS.surface, radius: 18, stroke: COLORS.border, shadow: true });
  absoluteText(report, "Last session", 22, 22, { size: 12, color: COLORS.textMuted });
  absoluteText(report, "Great improvement!", 22, 47, { size: 18, style: "Bold" });
  scoreRing(report, 256, 45, 54, "82");
  metricRow(report, 22, 94, "Grammar", "8 corrections", COLORS.brand);
  metricRow(report, 22, 124, "Vocabulary", "12 new words", COLORS.blue);
  metricRow(report, 22, 154, "Confidence", "Improving", COLORS.success);

  componentTitle(canvas, "Live call controls", "Large, unambiguous controls designed for use during conversation.");
  const controls = autoFrame(canvas, {
    direction: "HORIZONTAL",
    gap: 18,
    padding: 18,
    fill: COLORS.dark,
    radius: 24
  });
  iconCircle(controls, "M", { size: 56, fill: COLORS.darkSoft, color: COLORS.white, symbolSize: 16 });
  iconCircle(controls, "CC", { size: 56, fill: COLORS.darkSoft, color: COLORS.white, symbolSize: 13 });
  iconCircle(controls, "CAM", { size: 56, fill: COLORS.darkSoft, color: COLORS.white, symbolSize: 11 });
  iconCircle(controls, "END", { size: 64, fill: COLORS.danger, color: COLORS.white, symbolSize: 11 });

  page.selection = [canvas];
  figma.viewport.scrollAndZoomIntoView([canvas]);
}

function createScreen(page, name, x, y, fill = COLORS.background) {
  const screen = fixedFrame(page, {
    name,
    width: 390,
    height: 844,
    fill,
    radius: 28,
    clip: true,
    stroke: COLORS.border,
    shadow: true,
    key: `screen/${name}`
  });
  screen.x = x;
  screen.y = y;
  addStatusBar(screen, fill === COLORS.dark ? COLORS.white : COLORS.text);
  return screen;
}

function addStatusBar(screen, color) {
  absoluteText(screen, "9:41", 22, 17, { size: 11, style: "Semi Bold", color });
  rect(screen, 320, 21, 20, 9, color, 3);
  rect(screen, 346, 19, 18, 12, null, 3, color);
  rect(screen, 349, 22, 12, 6, color, 2);
}

function addBottomNav(screen, active) {
  const nav = fixedFrame(screen, { name: "Bottom Navigation", width: 358, height: 72, fill: COLORS.surface, radius: 22, shadow: true });
  nav.x = 16;
  nav.y = 756;
  const items = [
    ["Home", "H"],
    ["Practice", "P"],
    ["Progress", "G"],
    ["Profile", "U"]
  ];
  items.forEach(([label, icon], index) => {
    const x = index * 89;
    if (label === active) rect(nav, x + 21, 10, 47, 34, COLORS.brandSoft, 17);
    absoluteText(nav, icon, x, 17, {
      size: 12,
      style: "Bold",
      color: label === active ? COLORS.brand : COLORS.textMuted,
      width: 89,
      align: "CENTER"
    });
    absoluteText(nav, label, x, 48, {
      size: 9,
      style: label === active ? "Semi Bold" : "Regular",
      color: label === active ? COLORS.brand : COLORS.textMuted,
      width: 89,
      align: "CENTER"
    });
  });
}

function addScreenHeader(screen, title, subtitle, back = false) {
  if (back) {
    ellipse(screen, 18, 52, 38, 38, COLORS.surface);
    absoluteText(screen, "←", 18, 59, { size: 18, style: "Semi Bold", width: 38, align: "CENTER" });
  }
  absoluteText(screen, title, back ? 70 : 22, 57, { size: 21, style: "Bold" });
  if (subtitle) absoluteText(screen, subtitle, back ? 70 : 22, 88, { size: 11, color: COLORS.textMuted, width: 320 });
}

function addPrimaryButtonAt(screen, label, y, options = {}) {
  const box = fixedFrame(screen, {
    name: `Button/${label}`,
    width: options.width || 346,
    height: options.height || 52,
    fill: options.fill || COLORS.brand,
    radius: 14,
    stroke: options.stroke
  });
  box.x = options.x || 22;
  box.y = y;
  absoluteText(box, label, 0, 16, {
    size: 14,
    style: "Semi Bold",
    color: options.color || COLORS.white,
    width: box.width,
    align: "CENTER"
  });
  return box;
}

function smallFeature(screen, x, y, icon, title, text, color) {
  iconCircleAt(screen, icon, x, y, 44, color, COLORS.white);
  absoluteText(screen, title, x + 58, y + 2, { size: 13, style: "Semi Bold" });
  absoluteText(screen, text, x + 58, y + 23, { size: 10, color: COLORS.textMuted, width: 245 });
}

function iconCircleAt(parent, symbol, x, y, size, fill, color) {
  const wrap = fixedFrame(parent, { width: size, height: size, fill, radius: size / 2 });
  wrap.x = x;
  wrap.y = y;
  absoluteText(wrap, symbol, 0, size / 2 - 8, { size: 12, style: "Bold", color, width: size, align: "CENTER" });
  return wrap;
}

function topicTile(screen, x, y, width, title, subtitle, icon, accent, selected = false) {
  const tile = fixedFrame(screen, {
    name: `Topic/${title}`,
    width,
    height: 128,
    fill: selected ? COLORS.brandSoft : COLORS.surface,
    radius: 18,
    stroke: selected ? COLORS.brand : COLORS.border,
    strokeWeight: selected ? 2 : 1
  });
  tile.x = x;
  tile.y = y;
  iconCircleAt(tile, icon, 16, 16, 42, accent, COLORS.white);
  absoluteText(tile, title, 16, 70, { size: 14, style: "Semi Bold", width: width - 32 });
  absoluteText(tile, subtitle, 16, 94, { size: 10, color: COLORS.textMuted, width: width - 32 });
  if (selected) {
    ellipse(tile, width - 32, 14, 18, 18, COLORS.brand);
    absoluteText(tile, "✓", width - 32, 14, { size: 10, style: "Bold", color: COLORS.white, width: 18, align: "CENTER", lineHeight: 18 });
  }
}

function permissionRow(screen, y, symbol, title, text, enabled = true) {
  const row = fixedFrame(screen, { width: 346, height: 78, fill: COLORS.surface, radius: 16, stroke: COLORS.border });
  row.x = 22;
  row.y = y;
  iconCircleAt(row, symbol, 14, 17, 44, enabled ? COLORS.brandSoft : COLORS.surfaceAlt, enabled ? COLORS.brand : COLORS.textMuted);
  absoluteText(row, title, 72, 15, { size: 13, style: "Semi Bold" });
  absoluteText(row, text, 72, 39, { size: 10, color: COLORS.textMuted, width: 190 });
  const toggle = fixedFrame(row, { width: 44, height: 26, fill: enabled ? COLORS.success : COLORS.surfaceAlt, radius: 13 });
  toggle.x = 286;
  toggle.y = 25;
  ellipse(toggle, enabled ? 21 : 3, 3, 20, 20, COLORS.white);
}

function screenLabel(page, x, y, label) {
  absoluteText(page, label, x, y - 34, { size: 13, style: "Semi Bold", color: COLORS.textMuted, width: 390, align: "CENTER" });
}

function buildSplash(page, x, y) {
  const s = createScreen(page, "01 Splash", x, y, COLORS.dark);
  screenLabel(page, x, y, "01 — Splash");
  ellipse(s, 104, 182, 182, 182, COLORS.brand);
  ellipse(s, 130, 208, 130, 130, COLORS.dark);
  absoluteText(s, "AI", 130, 241, { size: 38, style: "Bold", color: COLORS.white, width: 130, align: "CENTER" });
  absoluteText(s, "AI Teacher", 0, 414, { size: 30, style: "Bold", color: COLORS.white, width: 390, align: "CENTER" });
  absoluteText(s, "Speak. Learn. Grow.", 0, 458, { size: 14, color: "#C9CEE0", width: 390, align: "CENTER" });
  rect(s, 115, 694, 160, 5, COLORS.darkSoft, 3);
  rect(s, 115, 694, 96, 5, COLORS.cyan, 3);
  absoluteText(s, "Preparing your AI coach…", 0, 718, { size: 10, color: "#9BA4BC", width: 390, align: "CENTER" });
  return s;
}

function buildOnboarding(page, x, y) {
  const s = createScreen(page, "02 Onboarding", x, y);
  screenLabel(page, x, y, "02 — Onboarding");
  pillAt(s, "AI-powered speaking practice", 22, 62, COLORS.brandSoft, COLORS.brand);
  avatar(s, 78, 128, 234, { badge: true, shirt: COLORS.blue });
  absoluteText(s, "Build speaking confidence", 24, 406, { size: 28, style: "Bold", width: 342, align: "CENTER", lineHeight: 35 });
  absoluteText(s, "Talk naturally with a friendly AI teacher, get simple corrections and improve every day.", 36, 484, { size: 13, color: COLORS.textMuted, width: 318, align: "CENTER", lineHeight: 20 });
  smallFeature(s, 34, 574, "1", "Real conversation", "Practice without fear or judgement.", COLORS.brand);
  smallFeature(s, 34, 634, "2", "Helpful corrections", "Learn from mistakes at the right moment.", COLORS.blue);
  addPrimaryButtonAt(s, "Get started", 735);
  return s;
}

function fieldAt(screen, label, value, y) {
  absoluteText(screen, label, 22, y, { size: 11, style: "Semi Bold" });
  const field = fixedFrame(screen, { width: 346, height: 52, fill: COLORS.surface, radius: 12, stroke: COLORS.border });
  field.x = 22;
  field.y = y + 24;
  absoluteText(field, value, 14, 17, { size: 13, color: value.includes("example") ? COLORS.text : COLORS.textMuted });
}

function buildLogin(page, x, y) {
  const s = createScreen(page, "03 Login", x, y);
  screenLabel(page, x, y, "03 — Login");
  ellipse(s, 22, 58, 48, 48, COLORS.brand);
  absoluteText(s, "AI", 22, 72, { size: 15, style: "Bold", color: COLORS.white, width: 48, align: "CENTER" });
  absoluteText(s, "Welcome back", 22, 137, { size: 28, style: "Bold" });
  absoluteText(s, "Continue your English practice.", 22, 179, { size: 12, color: COLORS.textMuted });
  fieldAt(s, "Email address", "learner@example.com", 236);
  fieldAt(s, "Password", "••••••••", 326);
  absoluteText(s, "Forgot password?", 230, 409, { size: 11, style: "Semi Bold", color: COLORS.brand, width: 138, align: "RIGHT" });
  addPrimaryButtonAt(s, "Login", 450);
  line(s, 22, 540, 150, COLORS.border);
  absoluteText(s, "OR", 172, 533, { size: 9, color: COLORS.textMuted, width: 46, align: "CENTER" });
  line(s, 218, 540, 150, COLORS.border);
  addPrimaryButtonAt(s, "Continue with Google", 570, { fill: COLORS.surface, color: COLORS.text, stroke: COLORS.border });
  absoluteText(s, "New here? Create an account", 0, 660, { size: 12, style: "Semi Bold", color: COLORS.brand, width: 390, align: "CENTER" });
  return s;
}

function buildHome(page, x, y) {
  const s = createScreen(page, "04 Home Dashboard", x, y);
  screenLabel(page, x, y, "04 — Home");
  absoluteText(s, "Good morning,", 22, 62, { size: 12, color: COLORS.textMuted });
  absoluteText(s, "Dharmendra", 22, 84, { size: 24, style: "Bold" });
  iconCircleAt(s, "DG", 322, 58, 48, COLORS.brandSoft, COLORS.brand);

  const hero = fixedFrame(s, { width: 346, height: 196, fill: COLORS.dark, radius: 22 });
  hero.x = 22;
  hero.y = 133;
  absoluteText(hero, "Ready to speak?", 20, 20, { size: 21, style: "Bold", color: COLORS.white });
  absoluteText(hero, "Start a guided conversation with Maya.", 20, 55, { size: 11, color: "#BFC6DB", width: 205 });
  pillAt(hero, "Beginner • 10 min", 20, 93, COLORS.darkSoft, COLORS.cyan);
  avatar(hero, 238, 24, 88, { badge: true, shirt: COLORS.blue });
  const start = fixedFrame(hero, { width: 306, height: 48, fill: COLORS.brand, radius: 13 });
  start.x = 20;
  start.y = 130;
  absoluteText(start, "Start speaking practice", 0, 15, { size: 13, style: "Semi Bold", color: COLORS.white, width: 306, align: "CENTER" });

  absoluteText(s, "Practice topics", 22, 365, { size: 18, style: "Bold" });
  topicTile(s, 22, 402, 166, "Daily life", "Everyday English", "DL", COLORS.brand);
  topicTile(s, 202, 402, 166, "Interview", "Answer clearly", "JOB", COLORS.blue);

  absoluteText(s, "Your progress", 22, 558, { size: 18, style: "Bold" });
  const progress = fixedFrame(s, { width: 346, height: 134, fill: COLORS.surface, radius: 18, stroke: COLORS.border });
  progress.x = 22;
  progress.y = 596;
  absoluteText(progress, "5 day streak", 18, 18, { size: 13, style: "Semi Bold" });
  absoluteText(progress, "84 minutes this week", 18, 43, { size: 10, color: COLORS.textMuted });
  for (let i = 0; i < 7; i++) {
    const active = i < 5;
    ellipse(progress, 18 + i * 44, 73, 30, 30, active ? COLORS.success : COLORS.surfaceAlt);
    absoluteText(progress, ["M","T","W","T","F","S","S"][i], 18 + i * 44, 82, { size: 9, style: "Semi Bold", color: active ? COLORS.white : COLORS.textMuted, width: 30, align: "CENTER" });
  }
  addBottomNav(s, "Home");
  return s;
}

function buildTopics(page, x, y) {
  const s = createScreen(page, "05 Topic Selection", x, y);
  screenLabel(page, x, y, "05 — Topics");
  addScreenHeader(s, "Choose a topic", "Pick one goal for this practice session.", true);
  pillAt(s, "Level: Beginner", 22, 126, COLORS.brandSoft, COLORS.brand);
  pillAt(s, "10 minutes", 154, 126, COLORS.successSoft, COLORS.success);

  topicTile(s, 22, 184, 166, "Daily life", "Routine and family", "DL", COLORS.brand, true);
  topicTile(s, 202, 184, 166, "Job interview", "Career questions", "JOB", COLORS.blue);
  topicTile(s, 22, 330, 166, "Travel", "Hotel and airport", "TR", COLORS.cyan);
  topicTile(s, 202, 330, 166, "Shopping", "Price and products", "MK", COLORS.success);
  topicTile(s, 22, 476, 166, "Small talk", "Friendly chat", "ST", COLORS.warning);
  topicTile(s, 202, 476, 166, "Custom topic", "Tell Maya your goal", "+", COLORS.darkSoft);

  const selected = fixedFrame(s, { width: 346, height: 78, fill: COLORS.surface, radius: 16, stroke: COLORS.border });
  selected.x = 22;
  selected.y = 634;
  avatar(selected, 12, 12, 54, { badge: true });
  absoluteText(selected, "Teacher: Maya", 82, 15, { size: 13, style: "Semi Bold" });
  absoluteText(selected, "Friendly corrections • Indian learners", 82, 39, { size: 10, color: COLORS.textMuted, width: 240 });
  addPrimaryButtonAt(s, "Continue", 738);
  return s;
}

function buildPermissions(page, x, y) {
  const s = createScreen(page, "06 Pre-call Permissions", x, y);
  screenLabel(page, x, y, "06 — Pre-call");
  addScreenHeader(s, "Before we begin", "Check your device and privacy choices.", true);
  avatar(s, 126, 128, 138, { badge: true, shirt: COLORS.blue });
  pillAt(s, "Maya is ready", 137, 280, COLORS.successSoft, COLORS.success);
  permissionRow(s, 340, "MIC", "Microphone", "Required for speaking practice.", true);
  permissionRow(s, 432, "CAM", "Camera", "Optional. Video is not recorded.", false);
  permissionRow(s, 524, "CC", "Live captions", "Show what you and Maya say.", true);

  const privacy = fixedFrame(s, { width: 346, height: 76, fill: COLORS.warningSoft, radius: 14 });
  privacy.x = 22;
  privacy.y = 626;
  absoluteText(privacy, "Privacy first", 16, 14, { size: 12, style: "Semi Bold", color: "#9A6410" });
  absoluteText(privacy, "Raw audio and video are not saved by default.", 16, 37, { size: 10, color: "#9A6410", width: 310 });
  addPrimaryButtonAt(s, "Join practice room", 742);
  return s;
}

function buildCall(page, x, y) {
  const s = createScreen(page, "07 Live AI Call", x, y, COLORS.dark);
  screenLabel(page, x, y, "07 — Live AI Call");
  pillAt(s, "LIVE • 04:32", 22, 58, COLORS.darkSoft, COLORS.cyan);
  iconCircleAt(s, "•••", 322, 54, 46, COLORS.darkSoft, COLORS.white);

  const stage = fixedFrame(s, { width: 346, height: 458, fill: "#181E34", radius: 24, clip: true });
  stage.x = 22;
  stage.y = 118;
  avatar(stage, 51, 52, 244, { badge: true, speaking: true, shirt: COLORS.blue, background: "#2B3350" });
  pillAt(stage, "Maya • Speaking", 103, 318, COLORS.brand, COLORS.white);
  const caption = fixedFrame(stage, { width: 306, height: 92, fill: "#101528", radius: 16 });
  caption.x = 20;
  caption.y = 348;
  absoluteText(caption, "“Tell me about your morning routine.”", 16, 15, { size: 14, style: "Semi Bold", color: COLORS.white, width: 274, align: "CENTER", lineHeight: 21 });
  absoluteText(caption, "Tap captions to hide", 16, 65, { size: 9, color: "#99A4BF", width: 274, align: "CENTER" });

  const hint = fixedFrame(s, { width: 346, height: 74, fill: COLORS.darkSoft, radius: 16 });
  hint.x = 22;
  hint.y = 598;
  absoluteText(hint, "Live correction", 16, 12, { size: 10, style: "Semi Bold", color: COLORS.cyan });
  absoluteText(hint, "Say: “I wake up at seven.”", 16, 34, { size: 13, style: "Semi Bold", color: COLORS.white, width: 310 });

  iconCircleAt(s, "MIC", 45, 708, 58, COLORS.darkSoft, COLORS.white);
  iconCircleAt(s, "CC", 125, 708, 58, COLORS.brand, COLORS.white);
  iconCircleAt(s, "CAM", 205, 708, 58, COLORS.darkSoft, COLORS.white);
  iconCircleAt(s, "END", 285, 701, 72, COLORS.danger, COLORS.white);
  absoluteText(s, "AI-generated teacher", 0, 799, { size: 9, color: "#77819A", width: 390, align: "CENTER" });
  return s;
}

function reportMetricCard(screen, x, y, title, value, subtitle, accent) {
  const card = fixedFrame(screen, { width: 166, height: 130, fill: COLORS.surface, radius: 18, stroke: COLORS.border });
  card.x = x;
  card.y = y;
  ellipse(card, 16, 16, 10, 10, accent);
  absoluteText(card, title, 34, 13, { size: 11, style: "Semi Bold" });
  absoluteText(card, value, 16, 49, { size: 28, style: "Bold", color: accent });
  absoluteText(card, subtitle, 16, 88, { size: 9, color: COLORS.textMuted, width: 134, lineHeight: 14 });
}

function buildReport(page, x, y) {
  const s = createScreen(page, "08 Session Report", x, y);
  screenLabel(page, x, y, "08 — Report");
  addScreenHeader(s, "Session complete", "Daily life • 9 min 42 sec", true);
  const score = fixedFrame(s, { width: 346, height: 178, fill: COLORS.dark, radius: 22 });
  score.x = 22;
  score.y = 130;
  absoluteText(score, "Overall session", 20, 20, { size: 11, color: "#BFC6DB" });
  absoluteText(score, "Great work!", 20, 45, { size: 22, style: "Bold", color: COLORS.white });
  absoluteText(score, "You spoke more confidently today.", 20, 78, { size: 10, color: "#BFC6DB", width: 190 });
  scoreRing(score, 250, 30, 70, "82");
  pillAt(score, "+8 from last session", 20, 122, COLORS.darkSoft, COLORS.cyan);

  absoluteText(s, "What improved", 22, 340, { size: 18, style: "Bold" });
  reportMetricCard(s, 22, 380, "Grammar", "8/10", "Used past tense correctly", COLORS.brand);
  reportMetricCard(s, 202, 380, "Vocabulary", "12", "New useful words", COLORS.blue);

  absoluteText(s, "Correction to remember", 22, 542, { size: 18, style: "Bold" });
  const correction = fixedFrame(s, { width: 346, height: 118, fill: COLORS.surface, radius: 18, stroke: COLORS.border });
  correction.x = 22;
  correction.y = 580;
  absoluteText(correction, "You said", 16, 14, { size: 9, color: COLORS.textMuted });
  absoluteText(correction, "“I go to market yesterday.”", 16, 34, { size: 12, color: COLORS.danger });
  absoluteText(correction, "Try this", 16, 65, { size: 9, color: COLORS.textMuted });
  absoluteText(correction, "“I went to the market yesterday.”", 16, 84, { size: 12, style: "Semi Bold", color: COLORS.success });

  addPrimaryButtonAt(s, "Practice this mistake", 718);
  addBottomNav(s, "Progress");
  return s;
}

function buildProgress(page, x, y) {
  const s = createScreen(page, "09 Progress", x, y);
  screenLabel(page, x, y, "09 — Progress");
  addScreenHeader(s, "Your progress", "Small daily practice creates real confidence.");
  pillAt(s, "This week", 278, 57, COLORS.surface, COLORS.text);

  const stats = fixedFrame(s, { width: 346, height: 142, fill: COLORS.dark, radius: 22 });
  stats.x = 22;
  stats.y = 128;
  absoluteText(stats, "84", 20, 22, { size: 38, style: "Bold", color: COLORS.white });
  absoluteText(stats, "minutes", 82, 39, { size: 11, color: "#BFC6DB" });
  absoluteText(stats, "5", 204, 22, { size: 38, style: "Bold", color: COLORS.cyan });
  absoluteText(stats, "day streak", 245, 39, { size: 11, color: "#BFC6DB" });
  absoluteText(stats, "Goal: 100 minutes", 20, 96, { size: 10, color: "#BFC6DB" });
  rect(stats, 20, 118, 306, 7, COLORS.darkSoft, 4);
  rect(stats, 20, 118, 257, 7, COLORS.cyan, 4);

  absoluteText(s, "Weekly activity", 22, 304, { size: 18, style: "Bold" });
  const chart = fixedFrame(s, { width: 346, height: 212, fill: COLORS.surface, radius: 18, stroke: COLORS.border });
  chart.x = 22;
  chart.y = 342;
  const heights = [54, 90, 42, 112, 78, 126, 94];
  heights.forEach((h, i) => {
    rect(chart, 24 + i * 44, 150 - h, 24, h, i === 6 ? COLORS.cyan : COLORS.brand, 8);
    absoluteText(chart, ["M","T","W","T","F","S","S"][i], 18 + i * 44, 170, { size: 9, color: COLORS.textMuted, width: 36, align: "CENTER" });
  });

  absoluteText(s, "Focus areas", 22, 590, { size: 18, style: "Bold" });
  focusRow(s, 632, "Past tense", "3 mistakes to revise", COLORS.danger);
  focusRow(s, 698, "Speaking confidence", "Improved 12% this week", COLORS.success);
  addBottomNav(s, "Progress");
  return s;
}

function focusRow(screen, y, title, subtitle, accent) {
  const row = fixedFrame(screen, { width: 346, height: 58, fill: COLORS.surface, radius: 14, stroke: COLORS.border });
  row.x = 22;
  row.y = y;
  ellipse(row, 14, 21, 16, 16, accent);
  absoluteText(row, title, 44, 10, { size: 12, style: "Semi Bold" });
  absoluteText(row, subtitle, 44, 31, { size: 9, color: COLORS.textMuted });
  absoluteText(row, "›", 310, 17, { size: 18, color: COLORS.textMuted });
}

function settingRow(screen, y, symbol, title, value) {
  const row = fixedFrame(screen, { width: 346, height: 54, fill: COLORS.surface, radius: 14, stroke: COLORS.border });
  row.x = 22;
  row.y = y;
  iconCircleAt(row, symbol, 10, 9, 36, COLORS.surfaceAlt, COLORS.textMuted);
  absoluteText(row, title, 58, 10, { size: 12, style: "Semi Bold" });
  if (value) absoluteText(row, value, 58, 31, { size: 9, color: COLORS.textMuted });
  absoluteText(row, "›", 310, 15, { size: 17, color: COLORS.textMuted });
}

function buildProfile(page, x, y) {
  const s = createScreen(page, "10 Profile and Settings", x, y);
  screenLabel(page, x, y, "10 — Profile");
  addScreenHeader(s, "Profile", "Manage learning preferences and privacy.");
  avatar(s, 141, 124, 108, { badge: true });
  absoluteText(s, "Dharmendra Gupta", 0, 248, { size: 19, style: "Bold", width: 390, align: "CENTER" });
  absoluteText(s, "Beginner • 7 sessions completed", 0, 280, { size: 10, color: COLORS.textMuted, width: 390, align: "CENTER" });

  const settings = [
    ["LV", "Learning level", "Beginner"],
    ["GO", "Weekly goal", "100 minutes"],
    ["CC", "Live captions", "On"],
    ["PR", "Privacy and data", "Review"],
    ["DL", "Download my data", ""],
    ["?", "Help and support", ""]
  ];
  settings.forEach((item, index) => {
    settingRow(s, 338 + index * 62, ...item);
  });

  addPrimaryButtonAt(s, "Log out", 718, { fill: COLORS.dangerSoft, color: COLORS.danger });
  addBottomNav(s, "Profile");
  return s;
}

async function generateScreens(page) {
  await figma.setCurrentPageAsync(page);
  clearPageGenerated(page);
  post("Building 10 Android MVP screens…");

  pageTitle(page, "AI Teacher Android MVP", "390 × 844 editable screens. All screens share the same visual language and implementation-friendly spacing.");

  const startX = 80;
  const startY = 180;
  const gapX = 56;
  const gapY = 100;
  const columns = 5;
  const builders = [
    buildSplash,
    buildOnboarding,
    buildLogin,
    buildHome,
    buildTopics,
    buildPermissions,
    buildCall,
    buildReport,
    buildProgress,
    buildProfile
  ];

  const screens = [];
  builders.forEach((builder, index) => {
    const col = index % columns;
    const row = Math.floor(index / columns);
    screens.push(builder(page, startX + col * (390 + gapX), startY + row * (844 + gapY)));
  });

  page.selection = screens;
  figma.viewport.scrollAndZoomIntoView(screens);
}

async function clearAllGenerated() {
  const pages = await ensurePages();
  for (const page of pages) {
    await page.loadAsync();
    clearPageGenerated(page);
  }
  figma.ui.postMessage({ type: "done", message: "Generated AI Teacher design cleared. Unrelated content was preserved." });
}

async function generateFull() {
  await preloadFonts();
  const [foundations, components, screens] = await ensurePages();
  await generateFoundations(foundations);
  await generateComponents(components);
  await generateScreens(screens);
  figma.ui.postMessage({
    type: "done",
    message: "Complete UI generated successfully:\n• Foundations\n• Components\n• 10 Android MVP screens"
  });
}

async function generateFoundationsAndComponents() {
  await preloadFonts();
  const [foundations, components] = await ensurePages();
  await generateFoundations(foundations);
  await generateComponents(components);
  figma.ui.postMessage({ type: "done", message: "Foundations and components generated successfully." });
}

async function generateScreensOnly() {
  await preloadFonts();
  const pages = await ensurePages();
  await generateScreens(pages[2]);
  figma.ui.postMessage({ type: "done", message: "10 Android MVP screens generated successfully." });
}

figma.ui.onmessage = async message => {
  try {
    if (message.type === "generate-full") await generateFull();
    if (message.type === "generate-foundations") await generateFoundationsAndComponents();
    if (message.type === "generate-screens") await generateScreensOnly();
    if (message.type === "clear-generated") await clearAllGenerated();
  } catch (error) {
    figma.ui.postMessage({
      type: "error",
      message: error instanceof Error ? error.message : String(error)
    });
  }
};
