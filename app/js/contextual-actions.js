/**
 * MeMy — one global context-aware "+" action resolver.
 * Behavior is driven by the active screen (route), not a stale FAB target.
 */
(function () {
  function svgIcon(paths, opts) {
    const o = opts || {};
    const sw = o.sw || "1.7";
    return (
      `<svg class="ctx-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="${sw}" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${paths}</svg>`
    );
  }

  const ICONS = {
    goal: svgIcon('<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1.5" fill="currentColor" stroke="none"/>'),
    tx: svgIcon('<rect x="3" y="6" width="18" height="13" rx="2.5"/><path d="M3 10h18"/><path d="M8 15h3"/>'),
    event: svgIcon('<rect x="3" y="5" width="18" height="16" rx="3"/><path d="M16 3v4M8 3v4M3 10h18"/>'),
    health: svgIcon('<path d="M19.5 12.5c0 4.5-5.5 7.5-7.5 8.5-2-1-7.5-4-7.5-8.5A4.5 4.5 0 0 1 12 9a4.5 4.5 0 0 1 7.5 3.5z"/>'),
    meal: svgIcon('<path d="M12 3c-3 4-6 6-6 10a6 6 0 0 0 12 0c0-4-3-6-6-10z"/><path d="M9.5 14.5c.8 1.2 2 1.8 2.5 1.8s1.7-.6 2.5-1.8"/>'),
    clothing: svgIcon('<path d="M8 5 4 8l2 2v9h12V10l2-2-4-3-2 2h-4L8 5z"/>'),
    water: svgIcon('<path d="M12 3c-3.2 4.2-6 7.4-6 11a6 6 0 0 0 12 0c0-3.6-2.8-6.8-6-11z"/>'),
    weight: svgIcon('<path d="M6.5 8.5h11l1.5 11.5H5L6.5 8.5z"/><path d="M9 8.5a3 3 0 0 1 6 0"/><path d="M10.5 14h3"/>'),
    hr: svgIcon('<path d="M3.5 12h3l2-4 3.5 8 2.5-5H20.5"/><path d="M19.2 8.2a3.2 3.2 0 0 0-4.5 0L12 10.8"/>', { sw: "1.8" }),
    cal: svgIcon('<path d="M12 21c4-3.2 6.5-6.2 6.5-9.4A4.4 4.4 0 0 0 12 7.8 4.4 4.4 0 0 0 5.5 11.6C5.5 14.8 8 17.8 12 21z"/><path d="M12 11.2v4.2"/><path d="M10.2 13.6h3.6"/>'),
    workout: svgIcon('<path d="M6.5 9.5v5M17.5 9.5v5"/><path d="M4 10.5v3M20 10.5v3"/><path d="M6.5 12h11"/><circle cx="9.5" cy="12" r="1.2" fill="currentColor" stroke="none"/><circle cx="14.5" cy="12" r="1.2" fill="currentColor" stroke="none"/>'),
    ai: svgIcon('<path d="M12 3 4.5 7v5.2c0 4.7 3.2 8 7.5 8.8 4.3-.8 7.5-4.1 7.5-8.8V7L12 3z"/><path d="M9.5 12.2h.01M14.5 12.2h.01"/><path d="M9.8 15c.7.8 1.8 1.2 2.2 1.2s1.5-.4 2.2-1.2"/>'),
    plan: svgIcon('<path d="M8 4h8a2 2 0 0 1 2 2v14l-6-2.5L6 20V6a2 2 0 0 1 2-2z"/><path d="M9.5 10h5M9.5 13.5h5"/>'),
    focus: svgIcon('<circle cx="12" cy="12" r="3.5"/><path d="M12 3v2.2M12 18.8V21M3 12h2.2M18.8 12H21M5.6 5.6l1.6 1.6M16.8 16.8l1.6 1.6M5.6 18.4l1.6-1.6M16.8 7.2l1.6-1.6"/>'),
    insight: svgIcon('<path d="M9 18h6"/><path d="M10 21h4"/><path d="M8.2 15.2A5.8 5.8 0 1 1 15.8 15.2c0 2-1.1 3.1-2.2 4H10.4c-1.1-.9-2.2-2-2.2-4z"/>'),
    analyze: svgIcon('<path d="M4 19V10M10 19V5M16 19v-7M22 19V8"/>'),
    compare: svgIcon('<path d="M4 17 9.5 9l3.5 4L20 5"/><path d="M15.5 5H20v4.5"/>'),
    edit: svgIcon('<path d="M12 20h8"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4 11.5-11.5z"/>'),
    photo: svgIcon('<path d="M4 8.5A2.5 2.5 0 0 1 6.5 6h2l1.2-1.6A1.5 1.5 0 0 1 10.9 4h2.2a1.5 1.5 0 0 1 1.2.4L15.5 6h2A2.5 2.5 0 0 1 20 8.5v8A2.5 2.5 0 0 1 17.5 19h-11A2.5 2.5 0 0 1 4 16.5v-8z"/><circle cx="12" cy="12.5" r="3.2"/>'),
  };

  /** @type {Record<string, { type: string, label?: string }>} */
  const contextualActions = {
    home: { type: "quick-add" },
    dashboard: { type: "quick-add" },
    goals: { type: "add-goal" },
    finance: { type: "add-transaction" },
    calendar: { type: "add-event" },
    outfit: { type: "add-clothing" },
    health: { type: "health-actions" },
    weight: { type: "health-actions" },
    bodycomp: { type: "health-actions" },
    nutrition: { type: "nutrition-actions" },
    coach: { type: "ai-actions" },
    insights: { type: "insight-actions" },
    profile: { type: "profile-actions" },
    settings: { type: "profile-actions" },
  };

  let api = null;
  let sheetEl = null;
  let panelEl = null;
  let titleEl = null;
  let bodyEl = null;
  let open = false;

  function ensureSheet() {
    if (sheetEl) return;
    sheetEl = document.getElementById("ctx-sheet");
    if (!sheetEl) return;
    panelEl = sheetEl.querySelector(".ctx-panel");
    titleEl = document.getElementById("ctx-title");
    bodyEl = document.getElementById("ctx-body");
    sheetEl.addEventListener("click", (e) => {
      if (e.target.closest("[data-ctx-close]")) {
        closeSheet();
        return;
      }
      const row = e.target.closest("[data-ctx-action]");
      if (row) {
        const action = row.dataset.ctxAction;
        // Nested menus (e.g. Health Log → health actions) replace the sheet
        if (action === "health-menu") {
          showHealthActions();
          return;
        }
        closeSheet();
        // Defer so sheet close animation doesn't fight form open
        setTimeout(() => runAction(action, row.dataset), 40);
        return;
      }
    });
  }

  function activeScreen() {
    const el = document.querySelector(".screen.active");
    return el ? el.dataset.screen : "";
  }

  function resolveConfig(screen) {
    const name = screen || activeScreen();
    return contextualActions[name] || { type: "quick-add" };
  }

  function fabLabel(type) {
    const map = {
      "add-goal": "Add goal",
      "add-transaction": "Add transaction",
      "add-event": "Add event",
      "add-clothing": "Add clothing",
      "health-actions": "Log health",
      "nutrition-actions": "Add nutrition",
      "ai-actions": "AI actions",
      "insight-actions": "Insight actions",
      "quick-add": "Quick add",
      "profile-actions": "Profile actions",
    };
    return map[type] || "Quick add";
  }

  function updateFabForScreen(screen) {
    const fab = document.getElementById("nav-fab");
    if (!fab) return;
    const cfg = resolveConfig(screen);
    fab.removeAttribute("data-go");
    fab.dataset.ctxType = cfg.type;
    fab.setAttribute("aria-label", fabLabel(cfg.type));
  }

  function openSheet(title, items) {
    ensureSheet();
    if (!sheetEl || !bodyEl) return;
    titleEl.textContent = title;
    bodyEl.innerHTML = items
      .map(
        (it) => `
      <button type="button" class="ctx-row" data-ctx-action="${it.action}"${it.payload || ""}>
        <span class="ctx-ico" aria-hidden="true">${it.icon || ICONS.goal}</span>
        <span class="ctx-copy">
          <span class="ctx-name">${it.label}</span>
          ${it.sub ? `<span class="ctx-sub">${it.sub}</span>` : ""}
        </span>
        <svg class="ctx-chev" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m9 18 6-6-6-6"/></svg>
      </button>`
      )
      .join("");
    sheetEl.hidden = false;
    requestAnimationFrame(() => sheetEl.classList.add("is-open"));
    open = true;
  }

  function closeSheet() {
    if (!sheetEl || !open) return;
    sheetEl.classList.remove("is-open");
    open = false;
    setTimeout(() => {
      if (!open) sheetEl.hidden = true;
    }, 280);
  }

  function openFormSheet(title, html) {
    ensureSheet();
    if (!sheetEl || !bodyEl) return;
    titleEl.textContent = title;
    bodyEl.innerHTML = html;
    sheetEl.hidden = false;
    requestAnimationFrame(() => sheetEl.classList.add("is-open"));
    open = true;
  }

  function clearFieldError(root) {
    if (!root) return;
    root.querySelectorAll(".field-error").forEach((el) => el.remove());
    root.querySelectorAll(".is-invalid").forEach((el) => el.classList.remove("is-invalid"));
  }

  function showFieldError(input, msg) {
    if (!input) return;
    const wrap = input.closest(".field") || input.parentElement;
    if (wrap) wrap.classList.add("is-invalid");
    input.classList.add("is-invalid");
    const err = document.createElement("p");
    err.className = "field-error";
    err.textContent = msg;
    (wrap || input).insertAdjacentElement("afterend", err);
  }

  /* ---------- action runners ---------- */

  function runAction(action, dataset) {
    switch (action) {
      case "add-goal":
        if (api && api.go) api.go("add-goal");
        break;
      case "add-transaction":
        if (api && api.go) api.go("add-tx");
        break;
      case "add-event":
        if (api && api.go) api.go("add-event");
        break;
      case "add-clothing":
        if (api && api.go) api.go("add-piece");
        break;
      case "add-meal":
        if (api && api.go) api.go("add-meal");
        break;
      case "log-water":
        if (api && api.addWater) api.addWater(0.25);
        break;
      case "log-calories":
        openCaloriesForm();
        break;
      case "log-weight":
        openWeightForm();
        break;
      case "log-hr":
        openHrForm();
        break;
      case "log-workout":
        if (api && api.go) api.go("add-event");
        if (api && api.showToast) api.showToast("Log a workout as a calendar event");
        break;
      case "health-menu":
        showHealthActions();
        break;
      case "ask-ai":
        focusCoach("What should I focus on today?");
        break;
      case "create-plan":
        focusCoach("Create a plan for my day");
        break;
      case "set-focus":
        focusCoach("Set today's focus");
        break;
      case "generate-insight":
        if (api && api.generateInsight) api.generateInsight();
        break;
      case "analyze-week":
        if (api && api.analyzeWeek) api.analyzeWeek();
        break;
      case "compare-progress":
        if (api && api.compareProgress) api.compareProgress();
        break;
      case "edit-profile":
        if (api && api.go) api.go("profile");
        if (api && api.showToast) api.showToast("Update your profile details below");
        break;
      case "change-photo":
        if (api && api.showToast) api.showToast("Photo picker coming soon");
        break;
      case "open-settings":
        if (api && api.go) api.go("settings");
        break;
      default:
        break;
    }
  }

  function focusCoach(prompt) {
    if (api && api.go) api.go("coach");
    setTimeout(() => {
      const input = document.getElementById("chat-input");
      if (input) {
        input.focus();
        if (prompt) input.value = prompt;
      }
      if (api && api.showToast) api.showToast("Ask your AI Coach");
    }, 120);
  }

  function openWeightForm() {
    const cur = (api && api.data && api.data.health.weight) || 72.5;
    openFormSheet(
      "Log Weight",
      `<div class="ctx-form" id="ctx-weight-form">
        <p class="f-label">Weight (kg)</p>
        <div class="field"><input type="number" id="ctx-weight" inputmode="decimal" step="0.1" value="${cur}" /></div>
        <button type="button" class="btn-orange" id="ctx-weight-save">Save</button>
      </div>`
    );
    const btn = document.getElementById("ctx-weight-save");
    if (btn) {
      btn.addEventListener("click", () => {
        const form = document.getElementById("ctx-weight-form");
        clearFieldError(form);
        const input = document.getElementById("ctx-weight");
        const v = parseFloat(input && input.value);
        if (!input || !Number.isFinite(v) || v <= 0 || v > 400) {
          showFieldError(input, "Enter a valid weight");
          return;
        }
        if (api && api.saveWeight) api.saveWeight(v);
        closeSheet();
      });
    }
  }

  function openHrForm() {
    const cur = (api && api.data && api.data.health.heartRate) || 95;
    openFormSheet(
      "Log Heart Rate",
      `<div class="ctx-form" id="ctx-hr-form">
        <p class="f-label">Heart rate (bpm)</p>
        <div class="field"><input type="number" id="ctx-hr" inputmode="numeric" value="${cur}" /></div>
        <button type="button" class="btn-orange" id="ctx-hr-save">Save</button>
      </div>`
    );
    const btn = document.getElementById("ctx-hr-save");
    if (btn) {
      btn.addEventListener("click", () => {
        const form = document.getElementById("ctx-hr-form");
        clearFieldError(form);
        const input = document.getElementById("ctx-hr");
        const v = parseInt(input && input.value, 10);
        if (!input || !Number.isFinite(v) || v < 30 || v > 220) {
          showFieldError(input, "Enter a valid heart rate (30–220)");
          return;
        }
        if (api && api.saveHeartRate) api.saveHeartRate(v);
        closeSheet();
      });
    }
  }

  function openCaloriesForm() {
    openFormSheet(
      "Add Calories",
      `<div class="ctx-form" id="ctx-cal-form">
        <p class="f-label">Calories (kcal)</p>
        <div class="field"><input type="number" id="ctx-cal" inputmode="numeric" placeholder="e.g. 250" /></div>
        <p class="f-label">Note (optional)</p>
        <div class="field"><input type="text" id="ctx-cal-note" placeholder="Snack, coffee…" /></div>
        <button type="button" class="btn-orange" id="ctx-cal-save">Save</button>
      </div>`
    );
    const btn = document.getElementById("ctx-cal-save");
    if (btn) {
      btn.addEventListener("click", () => {
        const form = document.getElementById("ctx-cal-form");
        clearFieldError(form);
        const input = document.getElementById("ctx-cal");
        const v = parseInt(input && input.value, 10);
        if (!input || !Number.isFinite(v) || v <= 0) {
          showFieldError(input, "Enter a valid calorie amount");
          return;
        }
        const note = ((document.getElementById("ctx-cal-note") || {}).value || "").trim() || "Extra calories";
        if (api && api.addCalories) api.addCalories(v, note);
        closeSheet();
      });
    }
  }

  function showQuickAdd() {
    openSheet("Quick Add", [
      { action: "add-goal", label: "Goal", sub: "Create a new goal", icon: ICONS.goal },
      { action: "add-transaction", label: "Transaction", sub: "Income or expense", icon: ICONS.tx },
      { action: "add-event", label: "Calendar Event", sub: "Schedule something", icon: ICONS.event },
      { action: "health-menu", label: "Health Log", sub: "Weight, heart rate & more", icon: ICONS.health },
      { action: "add-meal", label: "Meal", sub: "Log food & calories", icon: ICONS.meal },
      { action: "add-clothing", label: "Clothing Item", sub: "Add to wardrobe", icon: ICONS.clothing },
    ]);
  }

  function showHealthActions() {
    openSheet("Health Quick Actions", [
      { action: "log-weight", label: "Log Weight", icon: ICONS.weight },
      { action: "log-hr", label: "Log Heart Rate", icon: ICONS.hr },
      { action: "log-water", label: "Log Water", sub: "+0.25 L", icon: ICONS.water },
      { action: "log-calories", label: "Log Calories", icon: ICONS.cal },
      { action: "log-workout", label: "Log Workout", icon: ICONS.workout },
    ]);
  }

  function showNutritionActions() {
    openSheet("Add Nutrition", [
      { action: "add-meal", label: "Log Meal", icon: ICONS.meal },
      { action: "log-calories", label: "Add Calories", icon: ICONS.cal },
      { action: "log-water", label: "Log Water", sub: "+0.25 L", icon: ICONS.water },
    ]);
  }

  function showAiActions() {
    openSheet("AI Coach", [
      { action: "ask-ai", label: "Ask AI Coach", icon: ICONS.ai },
      { action: "create-plan", label: "Create a plan", icon: ICONS.plan },
      { action: "set-focus", label: "Set today's focus", icon: ICONS.focus },
    ]);
  }

  function showInsightActions() {
    openSheet("Insights", [
      { action: "generate-insight", label: "Generate insight", icon: ICONS.insight },
      { action: "analyze-week", label: "Analyze this week", icon: ICONS.analyze },
      { action: "compare-progress", label: "Compare progress", icon: ICONS.compare },
    ]);
  }

  function showProfileActions() {
    openSheet("Profile", [
      { action: "edit-profile", label: "Edit profile", icon: ICONS.edit },
      { action: "change-photo", label: "Change photo", icon: ICONS.photo },
      { action: "open-settings", label: "Open settings", icon: ICONS.plan },
    ]);
  }

  function triggerForScreen(screen) {
    const cfg = resolveConfig(screen);
    switch (cfg.type) {
      case "add-goal":
        runAction("add-goal");
        break;
      case "add-transaction":
        runAction("add-transaction");
        break;
      case "add-event":
        runAction("add-event");
        break;
      case "add-clothing":
        runAction("add-clothing");
        break;
      case "health-actions":
        showHealthActions();
        break;
      case "nutrition-actions":
        showNutritionActions();
        break;
      case "ai-actions":
        showAiActions();
        break;
      case "insight-actions":
        showInsightActions();
        break;
      case "profile-actions":
        showProfileActions();
        break;
      case "quick-add":
      default:
        showQuickAdd();
        break;
    }
  }

  function onFabClick(e) {
    e.preventDefault();
    e.stopPropagation();
    const fab = e.currentTarget;
    fab.classList.add("is-pressed");
    setTimeout(() => fab.classList.remove("is-pressed"), 160);
    triggerForScreen(activeScreen());
  }

  function init(options) {
    api = options || {};
    ensureSheet();
    const fab = document.getElementById("nav-fab");
    if (fab) {
      fab.removeAttribute("data-go");
      fab.addEventListener("click", onFabClick);
    }
    updateFabForScreen(activeScreen());
  }

  window.MeMyContextualActions = {
    contextualActions,
    init,
    updateFabForScreen,
    triggerForScreen,
    closeSheet,
    activeScreen,
    resolveConfig,
  };
})();
