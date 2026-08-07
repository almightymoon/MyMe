/**
 * MeMy Wardrobe 2.0 — premium AI personal stylist UI + logic
 */
(function (global) {
  let D = null;
  let api = null;
  let wardCatFilter = "all";
  let wardHistTab = "recent";
  let wardCurrent = null;
  let wardRemixing = false;
  let wardWearing = false;
  let selectedPieceId = null;
  let pieceDraft = {
    cat: "top",
    color: "#1C1C1E",
    colorName: "Black",
    vibe: "smart",
    season: "all",
  };

  function escapeHtml(s) {
    return String(s || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
  }

  function styleOf(p) {
    return p.style || p.vibe || "smart";
  }

  function pieceById(id) {
    return D.wardrobe.pieces.find((p) => p.id === id);
  }

  function weatherBucket(temp) {
    if (temp >= 26) return "warm";
    if (temp <= 16) return "cool";
    return "mild";
  }

  function targetFormality() {
    const W = D.wardrobe;
    const styleTarget = (W.styleTargets && W.styleTargets[W.style]) || 0.6;
    return styleTarget * 0.7 + (W.event.formality || 0.6) * 0.3;
  }

  function scoreCombo(pieces) {
    const W = D.wardrobe;
    const bucket = weatherBucket(W.weather.temp);
    const target = targetFormality();
    let score = 52;
    const reasons = [];

    const cats = {};
    pieces.forEach((p) => {
      cats[p.cat] = (cats[p.cat] || 0) + 1;
    });
    if (cats.top && cats.bottom && cats.shoes) {
      score += 14;
      reasons.push("complete look");
    } else score -= 10;

    const avg =
      pieces.reduce((s, p) => s + (p.formality || 0.5), 0) / Math.max(pieces.length, 1);
    const delta = Math.abs(avg - target);
    score += Math.round((1 - delta) * 28);
    if (delta < 0.15) reasons.push("matches " + (W.style || "smart") + " vibe");
    else if (avg < target - 0.2) reasons.push("a touch more casual");
    else reasons.push("aligned with your day");

    const weatherHits = pieces.filter((p) => (p.weather || []).includes(bucket)).length;
    score += Math.round((weatherHits / Math.max(pieces.length, 1)) * 12);
    if (weatherHits >= Math.ceil(pieces.length * 0.55)) {
      reasons.push(W.weather.temp + "°C comfort");
    }

    const styleHits = pieces.filter((p) => styleOf(p) === W.style || styleOf(p) === "minimal").length;
    score += Math.round((styleHits / Math.max(pieces.length, 1)) * 10);

    if (W.style === "smart" || W.style === "formal") {
      pieces.forEach((p) => {
        if (p.cat === "shoes" && (p.formality || 0) < 0.55) score -= 10;
      });
    }
    if (W.style === "casual" || W.style === "workout") {
      pieces.forEach((p) => {
        if (p.cat === "shoes" && (p.formality || 0) >= 0.85) score -= 6;
      });
    }

    // Prefer leaner outfits unless weather is cool
    if (bucket !== "cool" && cats.layer) score -= 2;

    return {
      score: Math.max(58, Math.min(99, Math.round(score))),
      why: reasons.slice(0, 2).join(" · "),
      avgFormality: avg,
      delta,
    };
  }

  function titleFor(avg, style) {
    if (style === "workout") return "Move-Ready Kit";
    if (style === "date") return "Date Night Look";
    if (style === "minimal") return "Quiet Luxury";
    if (style === "casual") return avg >= 0.45 ? "Easy Smart Casual" : "Relaxed Day Look";
    if (style === "formal") return avg >= 0.75 ? "Boardroom Sharp" : "Polished Day";
    if (avg >= 0.8) return "Polished Day";
    if (avg >= 0.6) return "Smart Meeting Look";
    if (avg >= 0.4) return "Easy Smart Casual";
    return "Relaxed Day Look";
  }

  function explain(decision) {
    const W = D.wardrobe;
    return (
      "Your " +
      W.event.title.toLowerCase() +
      " is at " +
      W.event.time +
      " and it's " +
      W.weather.temp +
      "°C. " +
      (decision.pieces.length
        ? "This combination keeps you comfortable while looking " +
          (W.style === "formal" ? "sharp" : W.style === "casual" || W.style === "workout" ? "relaxed" : W.style === "date" ? "intentional" : "professional") +
          "."
        : "MeMy is still learning your closet.")
    );
  }

  function buildCombos() {
    const pieces = D.wardrobe.pieces;
    const tops = pieces.filter((p) => p.cat === "top");
    const bottoms = pieces.filter((p) => p.cat === "bottom");
    const shoes = pieces.filter((p) => p.cat === "shoes");
    const layers = pieces.filter((p) => p.cat === "layer");
    const accessories = pieces.filter((p) => p.cat === "accessory");
    const combos = [];
    tops.forEach((top) => {
      bottoms.forEach((bottom) => {
        shoes.forEach((shoe) => {
          const base = [top, bottom, shoe];
          combos.push(base);
          layers.forEach((layer) => combos.push(base.concat(layer)));
          accessories.forEach((acc) => combos.push(base.concat(acc)));
        });
      });
    });
    return combos;
  }

  function decide() {
    const combos = buildCombos();
    if (!combos.length) return null;
    let best = null;
    combos.forEach((pieces) => {
      const result = scoreCombo(pieces);
      const better =
        !best ||
        result.score > best.score ||
        (result.score === best.score && result.delta < best.delta);
      if (better) {
        best = {
          pieces,
          score: result.score,
          why: result.why,
          title: titleFor(result.avgFormality, D.wardrobe.style),
          mode: "decision",
          style: D.wardrobe.style,
          delta: result.delta,
        };
      }
    });
    if (best) best.explanation = explain(best);
    return best;
  }

  function remix() {
    const pieces = D.wardrobe.pieces;
    const pick = (cat) => {
      const pool = pieces.filter((p) => {
        if (p.cat !== cat) return false;
        if (D.wardrobe.style === "workout") return styleOf(p) === "casual" || styleOf(p) === "minimal";
        if (D.wardrobe.style === "formal") return (p.formality || 0) >= 0.55;
        return true;
      });
      const use = pool.length ? pool : pieces.filter((p) => p.cat === cat);
      if (!use.length) return null;
      return use[Math.floor(Math.random() * use.length)];
    };
    const combo = [pick("top"), pick("bottom"), pick("shoes")].filter(Boolean);
    if (Math.random() > 0.4) {
      const layer = pick("layer");
      if (layer) combo.push(layer);
    }
    if (Math.random() > 0.55) {
      const acc = pick("accessory");
      if (acc) combo.push(acc);
    }
    const scored = scoreCombo(combo);
    const decision = {
      pieces: combo,
      score: scored.score,
      why: "Fresh remix · " + scored.why,
      title: titleFor(scored.avgFormality, D.wardrobe.style),
      mode: "remix",
      style: D.wardrobe.style,
    };
    decision.explanation = explain(decision);
    return decision;
  }

  function heroImage(decision) {
    const map = D.wardrobe.styleImages || {};
    return map[decision.style || D.wardrobe.style] || map.smart || "assets/outfit-flat.png?v=13";
  }

  function renderDecision(decision, animate) {
    if (!decision) return;
    wardCurrent = decision;
    const pill = document.getElementById("ward-pill");
    const title = document.getElementById("ward-pick-title");
    const score = document.getElementById("ward-score-n");
    const why = document.getElementById("ward-why");
    const combo = document.getElementById("ward-combo");
    const img = document.getElementById("ward-hero-img");
    const swatches = document.getElementById("ward-hero-swatches");
    const hero = document.getElementById("ward-decision");
    const wearBtn = document.getElementById("ward-wear");

    if (pill) pill.textContent = wardWearing ? "Wearing today" : decision.mode === "remix" ? "Remix pick" : "Today's pick";
    if (title) title.textContent = decision.title;
    if (score) score.textContent = String(decision.score);
    if (why) why.textContent = decision.explanation || decision.why;
    if (img) {
      img.src = heroImage(decision);
      img.alt = decision.title;
    }
    if (swatches) {
      swatches.innerHTML = decision.pieces
        .slice(0, 5)
        .map((p) => "<i style=\"background:" + p.color + "\"></i>")
        .join("");
    }
    if (combo) {
      const meta = D.wardrobe.catMeta;
      combo.innerHTML = decision.pieces
        .map((p) => {
          const label = (meta[p.cat] && meta[p.cat].label) || p.cat;
          return (
            "<li><span class=\"dot\" style=\"background:" +
            p.color +
            "\"></span><span>" +
            escapeHtml(p.name) +
            "</span><span class=\"cat\">" +
            escapeHtml(label) +
            "</span></li>"
          );
        })
        .join("");
    }
    if (hero) {
      hero.classList.toggle("is-wearing", !!wardWearing);
      if (animate) {
        hero.classList.add("is-remixing");
        setTimeout(() => hero.classList.remove("is-remixing"), 420);
      }
    }
    if (wearBtn) {
      wearBtn.textContent = wardWearing ? "✓ Wearing today" : "Wear this";
      wearBtn.classList.toggle("is-wearing", !!wardWearing);
    }
  }

  function renderContext() {
    const W = D.wardrobe;
    const temp = document.getElementById("ward-temp");
    const weatherLabel = document.getElementById("ward-weather-label");
    const eventTitle = document.getElementById("ward-event-title");
    const eventTime = document.getElementById("ward-event-time");
    if (temp) temp.textContent = W.weather.temp + "°C";
    if (weatherLabel) weatherLabel.textContent = W.weather.label;
    if (eventTitle) eventTitle.textContent = W.event.title;
    if (eventTime) eventTime.textContent = W.event.time;
  }

  function renderStyles() {
    document.querySelectorAll("#ward-styles .ward-style").forEach((btn) => {
      btn.classList.toggle("active", btn.dataset.wardStyle === D.wardrobe.style);
    });
  }

  function renderGrid() {
    const grid = document.getElementById("ward-grid");
    if (!grid) return;
    const meta = D.wardrobe.catMeta;
    const list = D.wardrobe.pieces.filter((p) => wardCatFilter === "all" || p.cat === wardCatFilter);
    if (!list.length) {
      grid.innerHTML =
        '<p class="muted" style="grid-column:1/-1;padding:8px 2px">Your closet is empty. Add a piece to unlock Wear Decisions.</p>';
      return;
    }
    grid.innerHTML = list
      .map((p) => {
        const cat = (meta[p.cat] && meta[p.cat].label) || p.cat;
        const style = styleOf(p);
        const visual = p.image
          ? '<img src="' + p.image + '" alt="" />'
          : '<span style="background:' + p.color + '"></span>';
        return (
          '<button type="button" class="ward-tile" data-piece-id="' +
          p.id +
          '">' +
          '<div class="ward-tile-visual">' +
          visual +
          "</div>" +
          '<p class="ward-tile-name">' +
          escapeHtml(p.name) +
          "</p>" +
          '<p class="ward-tile-meta">' +
          escapeHtml(cat) +
          " · " +
          escapeHtml(style.charAt(0).toUpperCase() + style.slice(1)) +
          "</p>" +
          '<p class="ward-tile-stats">Worn ' +
          (p.wearCount || 0) +
          " times" +
          (p.lastWorn ? "<br>Last worn " + escapeHtml(p.lastWorn) : "") +
          "</p>" +
          "</button>"
        );
      })
      .join("");
  }

  function renderInsights() {
    const host = document.getElementById("ward-insights");
    if (!host) return;
    const pieces = D.wardrobe.pieces.slice().sort((a, b) => (b.wearCount || 0) - (a.wearCount || 0));
    const most = pieces[0];
    const stale = pieces.filter((p) => (p.wearCount || 0) <= 3 && (!p.lastWorn || /May|Jun|Apr/.test(p.lastWorn))).length;
    host.innerHTML = `
      <div class="ward-insight"><p class="k">Most worn</p><p class="t">${escapeHtml(most ? most.name : "—")}</p><p class="s">${most ? most.wearCount + " wears" : ""}</p></div>
      <div class="ward-insight"><p class="k">Needs attention</p><p class="t">${stale} items need a comeback</p><p class="s">Haven't been worn in 60+ days.</p></div>
      <div class="ward-insight"><p class="k">Style pattern</p><p class="t">Navy + white combinations</p><p class="s">You reach for clean contrast looks most often.</p></div>`;
  }

  function renderMissing() {
    const host = document.getElementById("ward-missing");
    if (!host) return;
    const miss = (D.wardrobe.missing && D.wardrobe.missing[0]) || null;
    if (!miss) {
      host.classList.remove("is-on");
      host.innerHTML = "";
      return;
    }
    host.classList.add("is-on");
    host.innerHTML = `
      <p class="k">Complete your wardrobe</p>
      <p class="t">MeMy noticed you don't have:</p>
      <p class="s"><strong>${escapeHtml(miss.name)}</strong> — ${escapeHtml(miss.reason)}</p>
      <button type="button" class="ward-link" id="ward-explore-missing">Explore</button>`;
  }

  function renderHistory() {
    const host = document.getElementById("ward-history");
    if (!host) return;
    const source =
      wardHistTab === "saved"
        ? [].concat(D.wardrobe.looks || [], (D.wardrobe.history || []).filter((h) => h.saved))
        : D.wardrobe.history || [];
    if (!source.length) {
      host.innerHTML = '<p class="muted" style="padding:4px 2px 12px">No looks yet. Wear or save an outfit to build history.</p>';
      return;
    }
    host.innerHTML = source
      .map((look) => {
        const img = look.image || heroImage({ style: look.style || "smart" });
        return (
          '<button type="button" class="card ward-hist-card" data-hist-id="' +
          look.id +
          '" data-hist-kind="' +
          (look.saved && !look.worn ? "look" : "history") +
          '">' +
          '<div class="ward-hist-thumb"><img src="' +
          img +
          '" alt="" /></div>' +
          "<div><p class=\"ward-hist-title\">" +
          escapeHtml(look.title) +
          '</p><p class="ward-hist-meta">' +
          escapeHtml(look.date || "") +
          (look.occasion ? " · " + escapeHtml(look.occasion) : "") +
          "</p></div>" +
          '<span class="ward-hist-fit">' +
          (look.fitScore || look.score || "—") +
          " Fit</span></button>"
        );
      })
      .join("");
  }

  function render() {
    if (!D || !document.getElementById("ward-decision")) return;
    renderContext();
    renderStyles();
    if (!wardCurrent || wardCurrent.style !== D.wardrobe.style) {
      wardWearing = false;
      wardCurrent = decide();
    }
    renderDecision(wardCurrent, false);
    renderGrid();
    renderInsights();
    renderMissing();
    renderHistory();
  }

  function setStyle(style) {
    D.wardrobe.style = style;
    wardWearing = false;
    wardCurrent = decide();
    renderStyles();
    renderDecision(wardCurrent, true);
    api.showToast(style.charAt(0).toUpperCase() + style.slice(1) + " looks");
  }

  function runRemix() {
    if (wardRemixing) return;
    wardRemixing = true;
    wardWearing = false;
    let ticks = 0;
    const timer = setInterval(() => {
      renderDecision(remix(), true);
      ticks += 1;
      if (ticks >= 4) {
        clearInterval(timer);
        wardRemixing = false;
        api.showToast("Remix ready");
      }
    }, 160);
  }

  function wearCurrent() {
    if (!wardCurrent) return;
    wardWearing = true;
    const today = "Aug 7";
    wardCurrent.pieces.forEach((p) => {
      p.wearCount = (p.wearCount || 0) + 1;
      p.lastWorn = today;
    });
    D.wardrobe.history.unshift({
      id: "h" + Date.now(),
      title: wardCurrent.title,
      pieceIds: wardCurrent.pieces.map((p) => p.id),
      style: wardCurrent.style || D.wardrobe.style,
      fitScore: wardCurrent.score,
      date: today,
      occasion: D.wardrobe.event.title,
      saved: false,
      worn: true,
      image: heroImage(wardCurrent),
    });
    renderDecision(wardCurrent, false);
    renderGrid();
    renderInsights();
    renderHistory();
    api.showToast('Wearing "' + wardCurrent.title + '" today');
  }

  function saveLook() {
    if (!wardCurrent) return;
    D.wardrobe.looks.unshift({
      id: "l" + Date.now(),
      title: wardCurrent.title,
      pieceIds: wardCurrent.pieces.map((p) => p.id),
      note: "Saved from Wear Decision",
      style: wardCurrent.style || D.wardrobe.style,
      fitScore: wardCurrent.score,
      date: "Aug 7",
      saved: true,
      worn: false,
      image: heroImage(wardCurrent),
    });
    wardHistTab = "saved";
    document.querySelectorAll("#ward-hist-tabs .ward-chip").forEach((b) => {
      b.classList.toggle("active", b.dataset.histTab === "saved");
    });
    renderHistory();
    api.showToast("Look saved");
  }

  function openPiece(id) {
    const piece = pieceById(id);
    if (!piece) return;
    selectedPieceId = id;
    api.go("piece-detail");
    renderPieceDetail(piece);
  }

  function renderPieceDetail(piece) {
    const root = document.getElementById("piece-detail-root");
    if (!root || !piece) return;
    const meta = D.wardrobe.catMeta;
    const cat = (meta[piece.cat] && meta[piece.cat].label) || piece.cat;
    const pairs = (piece.pairsWith || []).map(pieceById).filter(Boolean);
    const styleLabel = styleOf(piece);
    const styleNice = styleLabel.charAt(0).toUpperCase() + styleLabel.slice(1);
    const seasonNice =
      !piece.season || piece.season === "all"
        ? "All year"
        : piece.season.charAt(0).toUpperCase() + piece.season.slice(1);
    const heroVisual = piece.image
      ? '<img src="' + piece.image + '" alt="' + escapeHtml(piece.name) + '" />'
      : '<span style="background:' + piece.color + '"></span>';
    root.innerHTML =
      '<div class="piece-hero">' +
      heroVisual +
      "</div>" +
      '<p class="piece-detail-title">' +
      escapeHtml(piece.name) +
      "</p>" +
      '<p class="piece-detail-meta">' +
      escapeHtml(cat) +
      " · " +
      escapeHtml(styleNice) +
      "</p>" +
      '<div class="piece-stats">' +
      '<div class="piece-stat"><p class="l">Color</p><p class="v">' +
      escapeHtml(piece.colorName || styleNice) +
      "</p></div>" +
      '<div class="piece-stat"><p class="l">Season</p><p class="v">' +
      escapeHtml(seasonNice) +
      "</p></div>" +
      '<div class="piece-stat"><p class="l">Worn</p><p class="v">' +
      (piece.wearCount || 0) +
      " times</p></div>" +
      '<div class="piece-stat"><p class="l">Last worn</p><p class="v">' +
      escapeHtml(piece.lastWorn || "—") +
      "</p></div></div>" +
      '<p class="h3" style="margin:4px 0 8px">Pairs well with</p>' +
      '<div class="piece-pairs">' +
      (pairs.length
        ? pairs
            .map(
              (p) =>
                '<div class="piece-pair"><i style="background:' +
                p.color +
                '"></i><span>' +
                escapeHtml(p.name) +
                "</span></div>"
            )
            .join("")
        : '<p class="muted">Add more pieces to unlock pairings.</p>') +
      "</div>" +
      '<div class="piece-actions">' +
      '<button type="button" class="btn-orange" id="piece-wear-btn">Wear</button>' +
      '<button type="button" class="ward-btn-ghost" id="piece-add-outfit-btn">Add to outfit</button>' +
      "</div>" +
      '<button type="button" class="ward-save-link" id="piece-edit-btn">Edit</button>';

    const wear = document.getElementById("piece-wear-btn");
    const add = document.getElementById("piece-add-outfit-btn");
    const edit = document.getElementById("piece-edit-btn");
    if (wear) {
      wear.onclick = () => {
        piece.wearCount = (piece.wearCount || 0) + 1;
        piece.lastWorn = "Aug 7";
        api.showToast('Marked "' + piece.name + '" as worn');
        renderPieceDetail(piece);
      };
    }
    if (add) {
      add.onclick = () => {
        if (!wardCurrent) wardCurrent = decide();
        if (wardCurrent && !wardCurrent.pieces.find((p) => p.id === piece.id)) {
          wardCurrent.pieces.push(piece);
          const scored = scoreCombo(wardCurrent.pieces);
          wardCurrent.score = scored.score;
          wardCurrent.why = scored.why;
          wardCurrent.explanation = explain(wardCurrent);
        }
        api.go("outfit");
        renderDecision(wardCurrent, true);
        api.showToast("Added to today's outfit");
      };
    }
    if (edit) {
      edit.onclick = () => api.showToast("Editing coming soon");
    }
  }

  function resetForm() {
    pieceDraft = {
      cat: "top",
      color: "#1C1C1E",
      colorName: "Black",
      vibe: "smart",
      season: "all",
    };
    const name = document.getElementById("piece-name");
    const brand = document.getElementById("piece-brand");
    if (name) name.value = "";
    if (brand) brand.value = "";
    document.querySelectorAll("#piece-cat .ward-cat").forEach((b) => {
      b.classList.toggle("active", b.dataset.cat === "top");
    });
    document.querySelectorAll("#piece-vibe .ward-cat").forEach((b) => {
      b.classList.toggle("active", b.dataset.vibe === "smart");
    });
    document.querySelectorAll("#piece-color .ward-swatch").forEach((b) => {
      b.classList.toggle("active", b.dataset.color === "#1C1C1E");
    });
    document.querySelectorAll("#piece-season .ward-chip").forEach((b) => {
      b.classList.toggle("active", b.dataset.season === "all");
    });
    const preview = document.getElementById("piece-photo-preview");
    if (preview) preview.style.background = "#1C1C1E";
  }

  function savePiece() {
    const nameEl = document.getElementById("piece-name");
    const brandEl = document.getElementById("piece-brand");
    const name = ((nameEl && nameEl.value) || "").trim();
    if (!name) {
      api.showToast("Give your piece a name");
      return;
    }
    const vibeFormality = { casual: 0.3, smart: 0.6, formal: 0.85, minimal: 0.5 };
    const piece = {
      id: "p" + Date.now(),
      name,
      cat: pieceDraft.cat,
      color: pieceDraft.color,
      colorName: pieceDraft.colorName,
      style: pieceDraft.vibe,
      season: pieceDraft.season,
      weather: ["mild", "warm", "cool"],
      formality: vibeFormality[pieceDraft.vibe] || 0.5,
      wearCount: 0,
      lastWorn: null,
      brand: ((brandEl && brandEl.value) || "").trim() || undefined,
      pairsWith: [],
    };
    D.wardrobe.pieces.unshift(piece);
    wardCurrent = decide();
    api.showToast("Added to closet");
    api.go("outfit");
  }

  function loadHistory(id) {
    const look =
      (D.wardrobe.history || []).find((h) => h.id === id) ||
      (D.wardrobe.looks || []).find((l) => l.id === id);
    if (!look) return;
    const pieces = (look.pieceIds || []).map(pieceById).filter(Boolean);
    if (!pieces.length) return;
    const scored = scoreCombo(pieces);
    wardWearing = !!look.worn;
    const decision = {
      pieces,
      score: look.fitScore || scored.score,
      why: look.note || scored.why,
      title: look.title,
      mode: look.saved ? "look" : "history",
      style: look.style || D.wardrobe.style,
    };
    decision.explanation = explain(decision);
    renderDecision(decision, true);
    api.showToast('Loaded "' + look.title + '"');
  }

  function onClick(e) {
    const styleBtn = e.target.closest("#ward-styles [data-ward-style]");
    if (styleBtn) {
      setStyle(styleBtn.dataset.wardStyle);
      return true;
    }

    const filter = e.target.closest("#ward-filters [data-ward-cat]");
    if (filter) {
      wardCatFilter = filter.dataset.wardCat;
      document.querySelectorAll("#ward-filters .ward-chip").forEach((b) => {
        b.classList.toggle("active", b === filter);
      });
      renderGrid();
      return true;
    }

    const histTab = e.target.closest("#ward-hist-tabs [data-hist-tab]");
    if (histTab) {
      wardHistTab = histTab.dataset.histTab;
      document.querySelectorAll("#ward-hist-tabs .ward-chip").forEach((b) => {
        b.classList.toggle("active", b === histTab);
      });
      renderHistory();
      return true;
    }

    const histCard = e.target.closest("[data-hist-id]");
    if (histCard) {
      loadHistory(histCard.dataset.histId);
      return true;
    }

    const tile = e.target.closest("#ward-grid [data-piece-id]");
    if (tile) {
      openPiece(tile.dataset.pieceId);
      return true;
    }

    const explore = e.target.closest("#ward-explore-missing");
    if (explore) {
      api.showToast("Navy Chinos would unlock more smart looks");
      return true;
    }

    const cat = e.target.closest("#piece-cat [data-cat]");
    if (cat) {
      pieceDraft.cat = cat.dataset.cat;
      document.querySelectorAll("#piece-cat .ward-cat").forEach((b) => b.classList.toggle("active", b === cat));
      return true;
    }

    const vibe = e.target.closest("#piece-vibe [data-vibe]");
    if (vibe) {
      pieceDraft.vibe = vibe.dataset.vibe;
      document.querySelectorAll("#piece-vibe .ward-cat").forEach((b) => b.classList.toggle("active", b === vibe));
      return true;
    }

    const swatch = e.target.closest("#piece-color [data-color]");
    if (swatch) {
      pieceDraft.color = swatch.dataset.color;
      pieceDraft.colorName = swatch.dataset.cname || "Color";
      document.querySelectorAll("#piece-color .ward-swatch").forEach((b) => b.classList.toggle("active", b === swatch));
      const preview = document.getElementById("piece-photo-preview");
      if (preview) preview.style.background = pieceDraft.color;
      return true;
    }

    const season = e.target.closest("#piece-season [data-season]");
    if (season) {
      pieceDraft.season = season.dataset.season;
      document.querySelectorAll("#piece-season .ward-chip").forEach((b) => b.classList.toggle("active", b === season));
      return true;
    }

    const photo = e.target.closest("#piece-photo");
    if (photo) {
      api.showToast("Using color preview for now");
      const preview = document.getElementById("piece-photo-preview");
      if (preview) preview.style.background = pieceDraft.color;
      return true;
    }

    return false;
  }

  function bindButtons() {
    const wear = document.getElementById("ward-wear");
    const remixBtn = document.getElementById("ward-remix");
    const save = document.getElementById("ward-save-look");
    const pieceSave = document.getElementById("piece-save");
    if (wear) wear.onclick = wearCurrent;
    if (remixBtn) remixBtn.onclick = runRemix;
    if (save) save.onclick = saveLook;
    if (pieceSave) pieceSave.onclick = savePiece;
  }

  function init(options) {
    D = options.data;
    api = {
      go: options.go,
      showToast: options.showToast,
    };
    // migrate legacy vibe -> style
    D.wardrobe.pieces.forEach((p) => {
      if (!p.style && p.vibe) p.style = p.vibe;
      if (!p.colorName) p.colorName = "Color";
      if (p.wearCount == null) p.wearCount = 0;
    });
    if (!D.wardrobe.style) D.wardrobe.style = "smart";
    if (!D.wardrobe.history) D.wardrobe.history = [];
    if (!D.wardrobe.missing) D.wardrobe.missing = [];
    bindButtons();
    render();
  }

  global.MeMyWardrobe = {
    init,
    render,
    resetForm,
    onClick,
    decide,
  };
})(typeof window !== "undefined" ? window : globalThis);
