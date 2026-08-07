(function () {
  const D = window.MeMyData;
  const phone = document.getElementById("phone");
  const screens = document.querySelectorAll(".screen");
  const navItems = document.querySelectorAll("#bottom-nav [data-nav-id]");
  const toastEl = document.getElementById("toast");
  const drawer = document.getElementById("drawer");
  const drawerScrim = document.getElementById("drawer-scrim");

  let txType = "expense";
  let waterLiters = D.health.waterCurrent;
  let ecgSeconds = 11;
  let ecgTotal = 30;
  let ecgTimer = null;
  let ecgPaused = false;
  let goalFilter = "all";
  let moneyFilter = "lent";
  let coachSphere = null;
  let voiceListening = false;
  let chatBusy = false;
  const AUTH = new Set(["signin", "signup", "forgot"]);

  const GOAL_EMOJI = {
    home: "🏠",
    shield: "💰",
    fitness: "👕",
    book: "📄",
  };

  function openDrawer() {
    phone.classList.add("drawer-open");
    drawer.setAttribute("aria-hidden", "false");
    drawerScrim.hidden = false;
  }

  function closeDrawer() {
    phone.classList.remove("drawer-open");
    drawer.setAttribute("aria-hidden", "true");
    drawerScrim.hidden = true;
  }

  function showToast(msg) {
    toastEl.textContent = msg;
    toastEl.classList.add("show");
    clearTimeout(showToast._t);
    showToast._t = setTimeout(() => toastEl.classList.remove("show"), 2200);
  }

  function go(name) {
    if (!name) return;
    const target = document.querySelector(`.screen[data-screen="${name}"]`);
    if (!target) return;

    closeDrawer();

    screens.forEach((s) => s.classList.remove("active"));
    target.classList.add("active");

    const isAuth = AUTH.has(name);
    phone.classList.toggle("auth-mode", isAuth);

    const nav = target.dataset.nav || "none";
    phone.classList.toggle("hide-nav", nav === "none" || isAuth);

    navItems.forEach((item) => {
      const on = item.dataset.navId === nav;
      item.classList.toggle("active", on);
    });

    document.querySelectorAll(".drawer-link[data-go]").forEach((link) => {
      link.classList.toggle("active", link.dataset.go === name);
    });

    if (name === "ecg") startEcg();
    else stopEcg();

    if (name === "coach") {
      ensureCoachSphere();
      resetCoachIdleUI();
    } else if (voiceListening) {
      stopVoiceListening();
    }

    if (name === "outfit" && window.MeMyWardrobe) MeMyWardrobe.render();
    if (name === "add-piece" && window.MeMyWardrobe) MeMyWardrobe.resetForm();
    if (name === "bodycomp") renderBodyComp();
    if (name === "exercises") renderExerciseLibrary();

    if (window.MeMyContextualActions) {
      MeMyContextualActions.updateFabForScreen(name);
      MeMyContextualActions.closeSheet();
    }

    history.replaceState(null, "", "#" + name);
  }

  function ensureCoachSphere() {
    if (!window.AICoachSphere) return;
    const host = document.getElementById("coach-sphere");
    if (!host) return;
    if (host._aiCoachSphere) {
      coachSphere = host._aiCoachSphere;
      return;
    }
    coachSphere = AICoachSphere.mount(host, {
      state: "idle",
      size: 168,
      interactive: true,
      label: "AI Coach sphere",
      onTap: function () {
        if (chatBusy || voiceListening) return;
      },
    });
  }

  function setCoachState(state) {
    ensureCoachSphere();
    if (coachSphere) coachSphere.setState(state);
  }

  function resetCoachIdleUI() {
    const prompts = document.getElementById("coach-prompts");
    const hi = document.getElementById("coach-hi");
    const thread = document.getElementById("chat-thread");
    if (thread && thread.children.length) {
      if (prompts) prompts.classList.add("is-hidden");
      if (hi) hi.classList.add("is-compact");
    } else {
      if (prompts) prompts.classList.remove("is-hidden");
      if (hi) hi.classList.remove("is-compact");
    }
    if (!chatBusy && !voiceListening) setCoachState("idle");
  }

  function stopVoiceListening() {
    voiceListening = false;
    const mic = document.getElementById("chat-mic");
    if (mic) {
      mic.classList.remove("is-listening");
      mic.setAttribute("aria-pressed", "false");
    }
    if (!chatBusy) setCoachState("idle");
  }

  function toggleVoiceListening() {
    ensureCoachSphere();
    if (chatBusy) return;
    voiceListening = !voiceListening;
    const mic = document.getElementById("chat-mic");
    if (mic) {
      mic.classList.toggle("is-listening", voiceListening);
      mic.setAttribute("aria-pressed", voiceListening ? "true" : "false");
    }
    if (voiceListening) {
      setCoachState("listening");
      showToast("Listening… tap mic again to stop");
    } else {
      setCoachState("idle");
      sendChat("What should I focus on today?");
    }
  }

  function renderGoals() {
    const list = document.getElementById("goals-list");
    if (!list) return;
    list.innerHTML = D.goals
      .map((g) => {
        const hide = goalFilter !== "all" && g.status !== goalFilter;
        const dim = g.subtitle.startsWith("PKR") ? "" : " dim";
        return `
        <div class="card goal-row"${hide ? " hidden" : ""}>
          <div class="goal-thumb">${GOAL_EMOJI[g.icon] || "🎯"}</div>
          <div class="goal-main">
            <p class="title">${g.title}</p>
            <p class="sub${dim}">${g.subtitle}</p>
            <div class="progress"><i style="width:${g.progress}%"></i></div>
          </div>
          <span class="goal-pct">${g.progress}%</span>
        </div>`;
      })
      .join("");
    const active = D.goals.filter((g) => g.status === "active");
    const avg = active.length
      ? Math.round(active.reduce((s, g) => s + g.progress, 0) / active.length)
      : 0;
    const avgEl = document.getElementById("goals-avg");
    if (avgEl) avgEl.innerHTML = avg + "<span>%</span>";
  }

  function renderFinance() {
    document.getElementById("fin-balance").textContent = D.formatPKR(D.finance.balance);
    document.getElementById("fin-income").textContent = D.formatPKR(D.finance.income);
    document.getElementById("fin-expense").textContent = D.formatPKR(D.finance.expenses);
    const cats = D.finance.categories;
    let acc = 0;
    const stops = cats
      .map((c) => {
        const start = acc;
        acc += c.pct;
        return `${c.color} ${start}% ${acc}%`;
      })
      .join(", ");
    document.getElementById("fin-donut").style.background = `conic-gradient(${stops})`;
    document.getElementById("fin-legend").innerHTML = cats
      .map(
        (c) =>
          `<div class="legend-row"><span class="legend-dot" style="background:${c.color}"></span>${c.name}<span class="legend-right"><span class="p">${c.pct}%</span><span class="a">${D.formatPKR(c.amt)}</span></span></div>`
      )
      .join("");
    renderMoneyFlows();
  }

  function moneyInitials(name) {
    return name
      .split(/\s+/)
      .filter(Boolean)
      .slice(0, 2)
      .map((p) => p[0].toUpperCase())
      .join("");
  }

  function renderMoneyFlows() {
    const lent = D.finance.lent || [];
    const loans = D.finance.loans || [];
    const lentTotal = lent.reduce((s, x) => s + x.amount, 0);
    const loanTotal = loans.reduce((s, x) => s + x.amount, 0);
    const summary = document.getElementById("money-summary");
    const list = document.getElementById("money-list");
    if (!summary || !list) return;

    summary.innerHTML = `
      <div class="money-sum">
        <p class="l">Expecting back</p>
        <p class="v num">${D.formatPKR(lentTotal)}</p>
        <p class="hint">${lent.length} people</p>
      </div>
      <div class="money-sum">
        <p class="l">You owe</p>
        <p class="v num">${D.formatPKR(loanTotal)}</p>
        <p class="hint">${loans.length} loans</p>
      </div>`;

    const rows = moneyFilter === "loans" ? loans : lent;
    const empty =
      moneyFilter === "loans"
        ? "No loans listed yet."
        : "No money lent out yet.";

    list.innerHTML = rows.length
      ? rows
          .map(
            (r) => `
      <button class="money-row" type="button" data-toast="${r.name}: ${D.formatPKR(r.amount)}">
        <span class="money-avatar">${moneyInitials(r.name)}</span>
        <span class="money-copy">
          <p class="name">${r.name}</p>
          <p class="meta">${r.note}</p>
        </span>
        <span class="money-side">
          <p class="amt num">${D.formatPKR(r.amount)}</p>
          <p class="due ${r.status}">Due ${r.due}</p>
        </span>
      </button>`
          )
          .join("")
      : `<p class="muted" style="padding:8px 2px">${empty}</p>`;
  }

  function spark(el, heights) {
    if (!el) return;
    el.innerHTML = heights
      .map((h, i) => `<span class="${i > heights.length - 4 ? "on" : ""}" style="height:${h}%"></span>`)
      .join("");
  }

  function renderHealthSparks() {
    // metric sparks removed from health measure screen (matches ref)
  }

  function renderHrvPlot() {
    // 24 smudge columns like the ref scatter; label every 4th column
    const labels = ["12am", "4am", "8am", "12pm", "4pm", "8pm"];
    const tops = [42, 30, 22, 12, 26, 18, 34, 40, 24, 14, 30, 20, 8, 16, 28, 36, 22, 30, 18, 26, 38, 46, 54, 60];
    const lens = [22, 34, 40, 46, 30, 42, 26, 22, 38, 48, 30, 40, 52, 44, 32, 24, 40, 30, 42, 34, 24, 20, 18, 14];
    const flecks = [64, null, 70, null, null, 66, null, 72, null, 70, null, null, 68, null, null, 66, null, 74, null, null, 68, null, null, 78];
    let html = "";
    for (let i = 0; i < 24; i++) {
      const li = i % 4 === 0 ? labels[i / 4] : null;
      const active = i === 17;
      html += `<div class="hrv-col${active ? " active" : ""}">
        <span class="blob" style="top:${tops[i]}%;height:${lens[i]}%"></span>
        ${flecks[i] ? `<span class="fleck" style="top:${flecks[i]}%"></span>` : ""}
        ${li ? `<span class="lbl">${li}</span>` : ""}
      </div>`;
    }
    document.getElementById("hrv-plot").innerHTML = html;
  }

  function renderWater() {
    const goal = D.health.waterGoal;
    const pct = Math.min(100, Math.round((waterLiters / goal) * 100));
    const remainMl = Math.max(0, Math.round((goal - waterLiters) * 1000));
    const el = document.getElementById("water-label");
    if (el) el.innerHTML = `${waterLiters.toFixed(1)} <span>/ ${goal.toFixed(1)} L</span>`;
    const hint = document.getElementById("water-hint");
    if (hint) {
      hint.textContent =
        remainMl <= 0 ? "Daily water goal reached!" : "You're " + remainMl + " ml away from your goal";
    }
    const ring = document.getElementById("water-ring");
    if (ring) ring.style.setProperty("--p", pct);
    const ringPct = document.getElementById("water-ring-pct");
    if (ringPct) ringPct.textContent = pct + "%";

    const glasses = 8;
    const per = goal / glasses;
    const filled = waterLiters / per;
    const g = document.getElementById("water-glasses");
    if (!g) return;
    let html = "";
    for (let i = 0; i < glasses; i++) {
      let cls = "glass";
      if (i + 1 <= Math.floor(filled)) cls += " full";
      else if (i < filled) cls += " half";
      html += `<div class="${cls}"></div>`;
    }
    g.innerHTML = html;
  }

  function renderNutritionSummary() {
    const goal = D.health.calorieGoal || 2000;
    const cur = D.health.calories || 0;
    const pct = Math.min(100, Math.round((cur / goal) * 100));
    const remain = Math.max(0, goal - cur);
    const kcalEl = document.getElementById("nutrition-kcal");
    if (kcalEl) kcalEl.innerHTML = cur.toLocaleString() + " <span>kcal</span>";
    const pctEl = document.getElementById("nutrition-pct");
    if (pctEl) pctEl.innerHTML = pct + "% of your daily goal <span class=\"up\">↑</span>";
    const remainEl = document.getElementById("nu-remain");
    if (remainEl) remainEl.textContent = remain.toLocaleString() + " kcal";
    const goalEl = document.getElementById("nu-goal");
    if (goalEl) goalEl.textContent = goal.toLocaleString() + " kcal";
    const bar = document.getElementById("nutrition-kcal-bar");
    if (bar) bar.style.width = pct + "%";
    const barLabel = document.getElementById("nutrition-kcal-bar-label");
    if (barLabel) barLabel.textContent = cur.toLocaleString() + " / " + goal.toLocaleString() + " kcal";
    const donutKcal = document.getElementById("nu-donut-kcal");
    if (donutKcal) donutKcal.textContent = cur.toLocaleString();
    const insight = document.getElementById("nu-insight-text");
    if (insight) {
      insight.textContent =
        "You're " +
        remain.toLocaleString() +
        " kcal below your target and your protein intake is already strong today.";
    }
  }

  function renderMeals() {
    const host = document.getElementById("meals-list");
    if (!host) return;
    host.innerHTML = (D.meals || [])
      .map((m) => {
        if (!m.logged) {
          return `
          <div class="nu-meal is-empty">
            <div class="nu-meal-thumb empty" aria-hidden="true">🍽️</div>
            <div class="nu-meal-main">
              <p class="slot">${m.slot || "Meal"}</p>
              <p class="n">Not logged yet</p>
              <p class="tags">${m.tags || "Add what you had"}</p>
            </div>
            <button type="button" class="nu-meal-add" data-go="add-meal" aria-label="Add meal">+</button>
          </div>`;
        }
        return `
        <div class="nu-meal">
          <img class="nu-meal-thumb" src="${m.img || "assets/meal.png?v=14"}" alt="" />
          <div class="nu-meal-main">
            <p class="slot">${m.slot || ""}</p>
            <p class="n">${m.name}</p>
            <p class="tags">${m.tags || m.time || ""}</p>
          </div>
          <span class="nu-meal-kcal num">${m.kcal} kcal</span>
        </div>`;
      })
      .join("");
    renderNutritionSummary();
  }

  function renderMacros() {
    const m = D.health.macros || {};
    const items = [
      { label: "Protein", p: m.protein || 45, c: "#34C759", g: (m.proteinG || 185) + " g" },
      { label: "Carbs", p: m.carbs || 30, c: "#FF9F1C", g: (m.carbsG || 120) + " g" },
      { label: "Fats", p: m.fat || 25, c: "#E07A3D", g: (m.fatG || 55) + " g" },
    ];
    const host = document.getElementById("macros");
    if (host) {
      host.innerHTML = items
        .map(
          (x) =>
            `<div class="macro"><div class="macro-ring" style="--p:${x.p};--c:${x.c}"><span>${x.p}<i>%</i></span></div><p class="macro-label">${x.label}</p><div class="g">${x.g}</div></div>`
        )
        .join("");
    }
    const donut = document.getElementById("nu-donut");
    if (donut) {
      const p = m.protein || 45;
      const c = m.carbs || 30;
      const f = m.fat || 25;
      donut.style.background = `conic-gradient(#34C759 0 ${p}%, #FF9F1C ${p}% ${p + c}%, #E8501F ${p + c}% 100%)`;
    }
    const legend = document.getElementById("nu-legend");
    if (legend) {
      legend.innerHTML = items
        .map(
          (x) =>
            `<div class="nu-leg-row"><span class="dot" style="background:${x.c}"></span><span class="name">${x.label}</span><span class="meta">${x.g} · ${x.p}%</span></div>`
        )
        .join("");
    }
    const micros = document.getElementById("nu-micros");
    const microData = (D.nutritionExtras && D.nutritionExtras.micros) || [];
    if (micros) {
      micros.innerHTML = microData
        .map(
          (x) =>
            `<div class="nu-micro"><div class="nu-micro-top"><span>${x.name}</span><span class="num">${x.pct}%</span></div><div class="nu-micro-bar"><i style="width:${x.pct}%;background:${x.color}"></i></div></div>`
        )
        .join("");
    }
  }

  function renderNutritionExtras() {
    const extras = D.nutritionExtras || {};
    const chart = document.getElementById("nu-trend-chart");
    if (chart && extras.weekly) {
      const vals = extras.weekly;
      const max = Math.max.apply(null, vals) || 1;
      const labels = extras.weekLabels || ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      const todayIdx = 4;
      chart.innerHTML =
        `<div class="nu-trend-bars">` +
        vals
          .map((v, i) => {
            const h = Math.round((v / max) * 100);
            const on = i === todayIdx ? " on" : "";
            return `<div class="nu-trend-col${on}"><span class="bar" style="height:${h}%"></span>${
              i === todayIdx ? `<span class="tip num">${v.toLocaleString()}</span>` : ""
            }<span class="d">${labels[i]}</span></div>`;
          })
          .join("") +
        `</div>`;
    }
    const habits = document.getElementById("nu-habits");
    if (habits && extras.habits) {
      habits.innerHTML = extras.habits
        .map(
          (h) =>
            `<div class="card nu-habit ${h.tone || ""}"><p class="t">${h.title}</p><p class="v num">${h.value}</p><p class="s">${h.sub}</p></div>`
        )
        .join("");
    }
  }

  function addWater(amount) {
    const add = amount != null ? amount : 0.25;
    waterLiters = Math.min(D.health.waterGoal, +(waterLiters + add).toFixed(2));
    D.health.waterCurrent = waterLiters;
    const pct = Math.min(100, Math.round((waterLiters / D.health.waterGoal) * 100));
    if (D.nutritionExtras && D.nutritionExtras.habits) {
      const wh = D.nutritionExtras.habits.find((h) => h.id === "water");
      if (wh) {
        wh.value = pct + "%";
        wh.sub = waterLiters.toFixed(1) + " / " + D.health.waterGoal.toFixed(1) + " L";
      }
    }
    renderWater();
    renderNutritionExtras();
    showToast(waterLiters >= D.health.waterGoal ? "Daily water goal reached!" : "Water logged (+250 ml)");
  }

  function saveWeight(kg) {
    D.health.weight = Math.round(kg * 10) / 10;
    const trend = D.health.weightTrend || [];
    trend.push(D.health.weight);
    if (trend.length > 6) trend.shift();
    D.health.weightTrend = trend;
    const gauge = document.querySelector(".gauge-center .gv");
    if (gauge) gauge.innerHTML = D.health.weight + " <span>kg</span>";
    showToast("Weight logged: " + D.health.weight + " kg");
  }

  function saveHeartRate(bpm) {
    D.health.heartRate = bpm;
    D.health.hrAvg = bpm;
    showToast("Heart rate logged: " + bpm + " bpm");
  }

  function addCalories(kcal, note) {
    D.health.calories = (D.health.calories || 0) + kcal;
    const empty = D.meals.find((m) => !m.logged);
    if (empty) {
      empty.logged = true;
      empty.name = note || "Snack";
      empty.tags = "Logged just now";
      empty.kcal = kcal;
      empty.time = new Date().toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
      empty.img = "assets/meal.png?v=14";
    } else {
      D.meals.unshift({
        id: "m" + Date.now(),
        slot: "Snack",
        name: note || "Calories",
        tags: "Logged just now",
        kcal,
        time: new Date().toLocaleTimeString([], { hour: "numeric", minute: "2-digit" }),
        img: "assets/meal.png?v=14",
        logged: true,
      });
    }
    renderMeals();
    showToast("+" + kcal + " kcal logged");
  }

  function generateInsight() {
    const box = document.querySelector("#insights .insight p, .screen[data-screen='insights'] .insight p");
    const tips = [
      "Your Life Score is trending up. Keep the morning workout streak going this week.",
      "Food spending is steady. Shifting 10% to your emergency fund would accelerate Goal #2.",
      "Sleep looks solid. Pair it with 2 L water to lift tomorrow's energy score.",
    ];
    const tip = tips[Math.floor(Math.random() * tips.length)];
    if (box) box.textContent = tip;
    showToast("New insight generated");
  }

  function analyzeWeek() {
    showToast("Week analyzed · Life Score +6% vs last week");
  }

  function compareProgress() {
    showToast("3 of 4 goals on track · Emergency fund leading");
  }

  function renderCalendar() {
    const cal = D.calendar;
    const firstDow = new Date(cal.year, cal.monthIndex, 1).getDay();
    const daysInMonth = new Date(cal.year, cal.monthIndex + 1, 0).getDate();
    const dows = ["S", "M", "T", "W", "T", "F", "S"];
    let html = dows.map((d) => `<div class="cal-dow">${d}</div>`).join("");
    for (let i = 0; i < firstDow; i++) html += `<div class="cal-day muted"></div>`;
    for (let d = 1; d <= daysInMonth; d++) {
      const sel = d === cal.selectedDay ? " sel" : "";
      html += `<div class="cal-day${sel}"><span>${d}</span></div>`;
    }
    document.getElementById("cal-grid").innerHTML = html;
    document.getElementById("cal-agenda").innerHTML = cal.agenda
      .map(
        (a) => `
      <div class="card ag-card">
        <div class="ag-time"><b>${a.start}</b><span>${a.end}</span></div>
        <i class="ag-bar" style="background:${a.color}"></i>
        <div><p class="ag-title">${a.title}</p><p class="ag-place">${a.place}</p></div>
      </div>`
      )
      .join("");
  }

  function escapeHtml(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }

  let bodyExFilter = "all";

  function sparkPath(values, w, h) {
    if (!values || !values.length) return "";
    const min = Math.min.apply(null, values);
    const max = Math.max.apply(null, values);
    const span = max - min || 1;
    return values
      .map((v, i) => {
        const x = (i / Math.max(values.length - 1, 1)) * w;
        const y = h - ((v - min) / span) * (h - 4) - 2;
        return (i ? "L" : "M") + x.toFixed(1) + " " + y.toFixed(1);
      })
      .join(" ");
  }

  function moveIcon() {
    return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M6 12h12M9 8l-3 4 3 4M15 8l3 4-3 4"/></svg>';
  }

  function renderBodyComp() {
    const H = D.health;
    if (!H || !document.getElementById("bc-bmi")) return;

    const setHtml = (id, html) => {
      const el = document.getElementById(id);
      if (el) el.innerHTML = html;
    };
    const set = (id, val) => {
      const el = document.getElementById(id);
      if (el) el.textContent = val;
    };

    set("bc-bmi", String(H.bmi));
    setHtml("bc-height", (H.heightCm || 175) + '<span class="sm"> cm</span>');
    setHtml("bc-weight", (H.weight || 72.5) + '<span class="sm"> kg</span>');
    setHtml("bc-fat", (H.bodyFat || 18.6) + '<span class="sm">%</span>');
    set("bc-score", String(H.bodyScore || 84));

    const wDelta = H.weightDelta != null ? H.weightDelta : -0.5;
    const fDelta = H.bodyFatDelta != null ? H.bodyFatDelta : -1.2;
    set("bc-weight-delta", (wDelta <= 0 ? "↓ " : "↑ ") + Math.abs(wDelta) + " kg");
    set("bc-fat-delta", (fDelta <= 0 ? "↓ " : "↑ ") + Math.abs(fDelta) + "%");

    const spark = document.getElementById("bc-spark");
    if (spark) {
      const d = sparkPath(H.bodyScoreSpark || [62, 68, 70, 74, 78, 80, 84], 72, 28);
      spark.innerHTML =
        '<path d="' +
        d +
        '" fill="none" stroke="#FF6A1A" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>';
    }

    const muscleList = document.getElementById("bc-muscle-list");
    if (muscleList) {
      muscleList.innerHTML = (H.muscleBalance || [])
        .map((m) => {
          const st = (m.status || "").toLowerCase() === "excellent" ? "excellent" : "";
          return (
            '<div class="bc-muscle-row">' +
            '<p class="n">' +
            escapeHtml(m.name) +
            "</p>" +
            '<p class="st ' +
            st +
            '">' +
            escapeHtml(m.status) +
            "</p>" +
            '<div class="bc-muscle-bar"><i style="width:' +
            Math.max(0, Math.min(100, m.pct || 0)) +
            '%"></i></div></div>'
          );
        })
        .join("");
    }

    const focus = H.workoutFocus || {};
    set("bc-plan-title", focus.title || "Focus on core & lower body");
    set("bc-plan-sub", focus.subtitle || "");
    const planImg = document.getElementById("bc-plan-img");
    if (planImg && focus.image) planImg.src = focus.image;
    const tags = document.getElementById("bc-plan-tags");
    if (tags) {
      tags.innerHTML = (focus.tags || [])
        .map((t) => '<span class="bc-plan-tag">' + escapeHtml(t) + "</span>")
        .join("");
    }

    const today = document.getElementById("bc-today");
    const todayItems = H.todayWorkout || [];
    if (today) {
      today.innerHTML = todayItems
        .map(
          (ex) =>
            '<button type="button" class="bc-today-card' +
            (ex.selected ? " is-on" : "") +
            '" data-toast="' +
            escapeHtml(ex.name) +
            '">' +
            '<span class="bc-today-check" aria-hidden="true"></span>' +
            '<div class="bc-today-thumb">' +
            moveIcon() +
            "</div>" +
            '<p class="bc-today-name">' +
            escapeHtml(ex.name) +
            '</p><p class="bc-today-meta">' +
            escapeHtml(ex.detail || "") +
            "</p></button>"
        )
        .join("");
    }

    renderBodyExercises();
  }

  function renderBodyExercises() {
    const H = D.health;
    const list = document.getElementById("bc-ex-list");
    const count = document.getElementById("bc-ex-count");
    if (!list || !H) return;
    const all = H.exercises || [];
    const filtered =
      bodyExFilter === "all" ? all : all.filter((ex) => ex.tag === bodyExFilter);
    if (count) count.textContent = filtered.length + (filtered.length === 1 ? " move" : " moves");
    const plus =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><path d="M12 5v14M5 12h14"/></svg>';
    list.innerHTML = filtered
      .map(
        (ex) =>
          '<div class="bc-ex-card">' +
          '<span class="bc-ex-visual">' +
          moveIcon() +
          "</span>" +
          "<div><p class=\"bc-ex-name\">" +
          escapeHtml(ex.name) +
          '</p><p class="bc-ex-meta">' +
          escapeHtml(ex.muscles || ex.tag || "") +
          '</p><span class="bc-ex-level">' +
          escapeHtml(ex.level || "Bodyweight") +
          '</span><p class="bc-ex-detail">' +
          escapeHtml(ex.detail || "") +
          "</p></div>" +
          '<button type="button" class="bc-ex-add" data-toast="Added ' +
          escapeHtml(ex.name) +
          '" aria-label="Add ' +
          escapeHtml(ex.name) +
          '">' +
          plus +
          "</button></div>"
      )
      .join("");
  }

  function coachReply(msg) {
    const m = msg.toLowerCase();
    if (m.includes("focus") || m.includes("today") || m.includes("plan my day")) return D.coachReplies.focus;
    if (m.includes("goal")) return D.coachReplies.default;
    if (m.includes("afford") || m.includes("buy")) return D.coachReplies.afford;
    if (m.includes("workout") || m.includes("gym")) return D.coachReplies.workout;
    if (m.includes("spend") || m.includes("budget") || m.includes("manage")) return D.coachReplies.spend;
    if (m.includes("calendar")) return "You have Research Work at 2:00 PM and Gym at 6:00 PM. Protect the afternoon focus block — it's your highest-leverage hour today.";
    if (m.includes("outfit")) return "For today's weather and calendar: navy knit, charcoal trousers, and clean white sneakers. Smart enough for campus, comfortable for the gym commute.";
    return D.coachReplies.default;
  }

  function formatCoachCard(msg) {
    const m = msg.toLowerCase();
    if (m.includes("focus") || m.includes("today") || m.includes("plan my day") || m.includes("goal")) {
      return `
        <div class="card rec-card">
          <p class="intro">Based on your goals and schedule, I'd focus on completing your AI research task today.</p>
          <div class="rec-item"><span class="check"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m5 12 5 5L20 7"/></svg></span><div><p class="t">Finish AI Research Paper</p><p class="d">High priority · protect 2–3:30</p></div></div>
          <div class="rec-item"><span class="check"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m5 12 5 5L20 7"/></svg></span><div><p class="t">Gym Workout</p><p class="d">Keep your streak at 6:00 PM</p></div></div>
          <div class="rec-item"><span class="check"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m5 12 5 5L20 7"/></svg></span><div><p class="t">Save PKR 500</p><p class="d">Stay ahead of emergency fund</p></div></div>
        </div>`;
    }
    return `<div class="card rec-card"><p class="intro">${escapeHtml(coachReply(msg)).replace(/\n/g, "<br/>")}</p></div>`;
  }

  function sendChat(text) {
    const msg = (text || "").trim();
    if (!msg || chatBusy) return;
    if (voiceListening) stopVoiceListening();

    const thread = document.getElementById("chat-thread");
    const prompts = document.getElementById("coach-prompts");
    const hi = document.getElementById("coach-hi");
    const input = document.getElementById("chat-input");

    chatBusy = true;
    try {
      ensureCoachSphere();
      setCoachState("thinking");

      if (prompts) prompts.classList.add("is-hidden");
      if (hi) hi.classList.add("is-compact");

      thread.insertAdjacentHTML("beforeend", `<div class="bubble-user">${escapeHtml(msg)}</div>`);
      if (input) input.value = "";
      if (thread.parentElement) thread.parentElement.scrollTop = thread.parentElement.scrollHeight;

      setTimeout(() => {
        setCoachState("responding");
        thread.insertAdjacentHTML("beforeend", formatCoachCard(msg));
        if (thread.parentElement) thread.parentElement.scrollTop = thread.parentElement.scrollHeight;
        setTimeout(() => {
          chatBusy = false;
          setCoachState("idle");
        }, 480);
      }, 920);
    } catch (err) {
      chatBusy = false;
      setCoachState("idle");
      console.error(err);
    }
  }

  function startEcg() {
    stopEcg();
    ecgSeconds = 11;
    ecgPaused = false;
    updateEcg();
    ecgTimer = setInterval(() => {
      if (ecgPaused) return;
      ecgSeconds += 1;
      if (ecgSeconds >= ecgTotal) {
        ecgSeconds = ecgTotal;
        updateEcg();
        stopEcg();
        showToast("ECG recording complete");
        return;
      }
      updateEcg();
    }, 1000);
  }

  function stopEcg() {
    if (ecgTimer) clearInterval(ecgTimer);
    ecgTimer = null;
  }

  function updateEcg() {
    const m = String(Math.floor(ecgSeconds / 60)).padStart(2, "0");
    const s = String(ecgSeconds % 60).padStart(2, "0");
    document.getElementById("ecg-timer").textContent = m + ":" + s;
    document.getElementById("ecg-pause").style.setProperty("--p", (ecgSeconds / ecgTotal) * 100);
  }

  // Events
  document.body.addEventListener("click", (e) => {
    const drawerBtn = e.target.closest("[data-drawer]");
    if (drawerBtn) {
      e.preventDefault();
      if (drawerBtn.dataset.drawer === "open") openDrawer();
      else closeDrawer();
      return;
    }

    if (e.target === drawerScrim) {
      closeDrawer();
      return;
    }

    const toastBtn = e.target.closest("[data-toast]");
    if (toastBtn && !toastBtn.dataset.go) {
      e.preventDefault();
      closeDrawer();
      showToast(toastBtn.dataset.toast);
      return;
    }

    const eyeBtn = e.target.closest("[data-toggle-pass]");
    if (eyeBtn) {
      e.preventDefault();
      const input = document.getElementById(eyeBtn.dataset.togglePass);
      if (!input) return;
      const show = input.type === "password";
      input.type = show ? "text" : "password";
      eyeBtn.classList.toggle("is-on", show);
      const on = eyeBtn.querySelector(".eye-on");
      const off = eyeBtn.querySelector(".eye-off");
      if (on && off) {
        on.hidden = show;
        off.hidden = !show;
      }
      eyeBtn.setAttribute("aria-label", show ? "Hide password" : "Show password");
      return;
    }

    const todoCheck = e.target.closest(".todo-check");
    if (todoCheck) {
      e.preventDefault();
      const item = todoCheck.closest(".todo-item");
      if (!item) return;
      const done = item.classList.toggle("done");
      todoCheck.setAttribute("aria-pressed", done ? "true" : "false");
      const list = item.closest(".todo-list");
      const countEl = list && list.parentElement && list.parentElement.querySelector(".todo-count");
      if (countEl && list) {
        const total = list.querySelectorAll(".todo-item").length;
        const doneCount = list.querySelectorAll(".todo-item.done").length;
        countEl.textContent = doneCount + " of " + total;
      }
      return;
    }

    const goEl = e.target.closest("[data-go]");
    if (goEl) {
      e.preventDefault();
      go(goEl.dataset.go);
      return;
    }

    const tab = e.target.closest("#goal-tabs .tab");
    if (tab) {
      goalFilter = tab.dataset.filter;
      document.querySelectorAll("#goal-tabs .tab").forEach((t) => t.classList.remove("active"));
      tab.classList.add("active");
      renderGoals();
      return;
    }

    const moneyTab = e.target.closest("#money-tabs .money-tab");
    if (moneyTab) {
      moneyFilter = moneyTab.dataset.money || "lent";
      document.querySelectorAll("#money-tabs .money-tab").forEach((t) => t.classList.remove("active"));
      moneyTab.classList.add("active");
      renderMoneyFlows();
      return;
    }

    const toggle = e.target.closest("#tx-toggle button");
    if (toggle) {
      txType = toggle.dataset.type;
      document.querySelectorAll("#tx-toggle button").forEach((b) => b.classList.remove("active"));
      toggle.classList.add("active");
      return;
    }

    const waterAdd = e.target.closest("#water-add");
    if (waterAdd) {
      addWater(0.25);
      return;
    }

    if (window.MeMyWardrobe && MeMyWardrobe.onClick(e)) return;

    const exFilter = e.target.closest("#bc-ex-filters [data-ex-tag]");
    if (exFilter) {
      bodyExFilter = exFilter.dataset.exTag;
      document.querySelectorAll("#bc-ex-filters .ward-chip").forEach((b) => {
        b.classList.toggle("active", b === exFilter);
      });
      renderBodyExercises();
      return;
    }

    const qp = e.target.closest("[data-prompt]");
    if (qp) {
      sendChat(qp.dataset.prompt);
      return;
    }
  });

  function setInlineError(id, msg) {
    const el = document.getElementById(id);
    if (!el) return;
    if (msg) {
      el.hidden = false;
      el.textContent = msg;
    } else {
      el.hidden = true;
      el.textContent = "";
    }
  }

  document.getElementById("tx-save").addEventListener("click", () => {
    setInlineError("tx-error", "");
    const raw = document.getElementById("tx-amount").value;
    const amount = Number(raw);
    if (!Number.isFinite(amount) || amount <= 0) {
      setInlineError("tx-error", "Enter a valid amount greater than 0");
      return;
    }
    const catSel = document.getElementById("tx-category");
    const catName = (catSel && catSel.value) || "Other";
    const map = {
      "Food & Dining": "Food",
      Transport: "Transport",
      Shopping: "Shopping",
      Bills: "Bills",
      Other: "Others",
    };
    const key = map[catName] || "Others";
    if (txType === "expense") {
      D.finance.expenses += amount;
      D.finance.balance -= amount;
      const cat = D.finance.categories.find((c) => c.name === key);
      if (cat) cat.amt += amount;
      const total = D.finance.categories.reduce((s, c) => s + c.amt, 0) || 1;
      D.finance.categories.forEach((c) => {
        c.pct = Math.round((c.amt / total) * 100);
      });
    } else {
      D.finance.income += amount;
      D.finance.balance += amount;
    }
    renderFinance();
    showToast((txType === "expense" ? "Expense" : "Income") + " of " + D.formatPKR(amount) + " saved");
    go("finance");
  });

  const goalSave = document.getElementById("goal-save");
  if (goalSave) {
    goalSave.addEventListener("click", () => {
      setInlineError("goal-error", "");
      const name = ((document.getElementById("goal-name") || {}).value || "").trim();
      const target = ((document.getElementById("goal-target") || {}).value || "").trim();
      const deadline = ((document.getElementById("goal-deadline") || {}).value || "").trim();
      const notes = ((document.getElementById("goal-notes") || {}).value || "").trim();
      let progress = parseInt((document.getElementById("goal-progress") || {}).value, 10);
      const icon = ((document.getElementById("goal-category") || {}).value || "home");
      if (!name) {
        setInlineError("goal-error", "Goal name cannot be empty");
        return;
      }
      if (!Number.isFinite(progress) || progress < 0) progress = 0;
      if (progress > 100) progress = 100;
      const subtitle = target || deadline || notes || "New goal";
      const colors = { home: "#FF6B35", shield: "#22C55E", fitness: "#3B82F6", book: "#8B5CF6" };
      D.goals.unshift({
        id: "g" + Date.now(),
        title: name,
        subtitle,
        progress,
        status: progress >= 100 ? "completed" : "active",
        icon,
        color: colors[icon] || "#FF6A1A",
        notes: notes || undefined,
        deadline: deadline || undefined,
      });
      renderGoals();
      showToast("Goal added");
      go("goals");
    });
  }

  const eventSave = document.getElementById("event-save");
  if (eventSave) {
    eventSave.addEventListener("click", () => {
      setInlineError("event-error", "");
      const title = ((document.getElementById("event-title") || {}).value || "").trim();
      const start = ((document.getElementById("event-start") || {}).value || "").trim() || "10:00 AM";
      const end = ((document.getElementById("event-end") || {}).value || "").trim() || "11:00 AM";
      const place = ((document.getElementById("event-place") || {}).value || "").trim() || "Anywhere";
      const notes = ((document.getElementById("event-notes") || {}).value || "").trim();
      const reminder = ((document.getElementById("event-reminder") || {}).value || "");
      if (!title) {
        setInlineError("event-error", "Event title cannot be empty");
        return;
      }
      const palette = ["#34C759", "#E8501F", "#3B82F6", "#FF6A1A", "#8B5CF6"];
      D.calendar.agenda.push({
        start,
        end,
        title,
        place: notes ? place + " · " + notes : place,
        color: palette[D.calendar.agenda.length % palette.length],
        reminder: reminder || undefined,
      });
      renderCalendar();
      showToast(reminder ? "Event saved · reminder set" : "Event saved");
      go("calendar");
    });
  }

  const mealSave = document.getElementById("meal-save");
  if (mealSave) {
    mealSave.addEventListener("click", () => {
      setInlineError("meal-error", "");
      const name = ((document.getElementById("meal-name") || {}).value || "").trim();
      const kcal = parseInt((document.getElementById("meal-kcal") || {}).value, 10);
      const time = ((document.getElementById("meal-time") || {}).value || "").trim() || "Now";
      if (!name) {
        setInlineError("meal-error", "Meal name cannot be empty");
        return;
      }
      if (!Number.isFinite(kcal) || kcal <= 0) {
        setInlineError("meal-error", "Enter a valid calorie amount");
        return;
      }
      const empty = D.meals.find((m) => !m.logged);
      if (empty) {
        empty.logged = true;
        empty.name = name;
        empty.tags = "Logged · " + time;
        empty.kcal = kcal;
        empty.time = time;
        empty.img = "assets/meal.png?v=14";
      } else {
        D.meals.unshift({
          id: "m" + Date.now(),
          slot: "Meal",
          name,
          tags: time,
          kcal,
          time,
          img: "assets/meal.png?v=14",
          logged: true,
        });
      }
      D.health.calories = (D.health.calories || 0) + kcal;
      renderMeals();
      showToast("Meal logged");
      go("nutrition");
    });
  }

  document.getElementById("ecg-pause").addEventListener("click", () => {
    ecgPaused = !ecgPaused;
  });

  document.getElementById("chat-send").addEventListener("click", () => {
    sendChat(document.getElementById("chat-input").value);
  });
  document.getElementById("chat-input").addEventListener("keydown", (e) => {
    if (e.key === "Enter") sendChat(e.target.value);
  });

  const chatMic = document.getElementById("chat-mic");
  if (chatMic) {
    chatMic.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();
      toggleVoiceListening();
    });
  }

  document.getElementById("reset-btn").addEventListener("click", () => {
    showToast("Reset link sent");
    setTimeout(() => go("signin"), 900);
  });

  if (window.MeMyWardrobe) {
    MeMyWardrobe.init({ data: D, go: go, showToast: showToast });
  }

  if (window.MeMyContextualActions) {
    MeMyContextualActions.init({
      data: D,
      go: go,
      showToast: showToast,
      addWater: addWater,
      saveWeight: saveWeight,
      saveHeartRate: saveHeartRate,
      addCalories: addCalories,
      generateInsight: generateInsight,
      analyzeWeek: analyzeWeek,
      compareProgress: compareProgress,
    });
  }

  if (window.AICoachSphere) {
    try {
      AICoachSphere.autoMount(document);
    } catch (err) {
      console.error("AICoachSphere autoMount failed", err);
    }
  }

  renderGoals();
  renderFinance();
  renderHealthSparks();
  renderHrvPlot();
  renderWater();
  renderMacros();
  renderMeals();
  renderNutritionExtras();
  renderCalendar();
  renderBodyComp();
  updateTodoCount();

  const hash = (location.hash || "").replace("#", "");
  if (hash === "apps") go("dashboard");
  else if (hash && document.querySelector(`.screen[data-screen="${hash}"]`)) go(hash);
  else go("signin");
})();
