/**
 * AICoachSphere — reusable interactive glass orb for MeMy AI Coach.
 *
 * Usage:
 *   const sphere = AICoachSphere.mount(el, { state: "idle", size: 160, interactive: true });
 *   sphere.setState("thinking");
 *   sphere.setAmplitude(0.4); // 0–1, for future voice input
 *   sphere.destroy();
 *
 * Or auto-mount:
 *   <div data-ai-coach-sphere data-state="idle" data-size="160" data-interactive="true"></div>
 */
(function (global) {
  const STATES = ["idle", "pressed", "thinking", "responding", "listening"];
  const PRESS_MS = 680;

  function clamp(n, min, max) {
    return Math.min(max, Math.max(min, n));
  }

  function buildMarkup(uid) {
    return `
      <span class="ai-sphere__bloom" aria-hidden="true"></span>
      <span class="ai-sphere__shadow" aria-hidden="true"></span>
      <span class="ai-sphere__body" aria-hidden="true">
        <span class="ai-sphere__core"></span>
        <span class="ai-sphere__core-glow"></span>
        <span class="ai-sphere__light"></span>
        <span class="ai-sphere__glass"></span>
        <span class="ai-sphere__rim"></span>
        <span class="ai-sphere__spec"></span>
        <span class="ai-sphere__refract"></span>
        <span class="ai-sphere__ripple" data-r="1"></span>
        <span class="ai-sphere__ripple" data-r="2"></span>
        <span class="ai-sphere__ripple" data-r="3"></span>
        <span class="ai-sphere__particles" id="${uid}-parts">
          <i></i><i></i><i></i><i></i><i></i><i></i>
        </span>
      </span>
    `.trim();
  }

  function createInstance(root, options) {
    const opts = Object.assign(
      {
        state: "idle",
        size: 160,
        interactive: true,
        amplitude: 0,
        onTap: null,
        label: "AI Coach",
      },
      options || {}
    );

    let state = STATES.includes(opts.state) ? opts.state : "idle";
    let amplitude = clamp(Number(opts.amplitude) || 0, 0, 1);
    let pressTimer = null;
    let listenSim = null;
    let destroyed = false;

    const uid = "acs-" + Math.random().toString(36).slice(2, 9);
    const tag = opts.interactive ? "button" : "div";
    const btn = document.createElement(tag);
    if (opts.interactive) btn.type = "button";
    btn.className = "ai-sphere";
    btn.setAttribute(opts.interactive ? "aria-label" : "aria-hidden", opts.interactive ? opts.label : "true");
    btn.dataset.state = state;
    btn.style.setProperty("--acs-size", opts.size + "px");
    btn.style.setProperty("--acs-amp", String(amplitude));
    btn.innerHTML = buildMarkup(uid);

    if (!opts.interactive) {
      btn.classList.add("is-static");
    }

    root.innerHTML = "";
    root.appendChild(btn);
    root.classList.add("ai-sphere-host");

    function setState(next) {
      if (destroyed) return api;
      if (!STATES.includes(next)) return api;
      if (pressTimer && next !== "pressed") {
        clearTimeout(pressTimer);
        pressTimer = null;
      }
      state = next;
      btn.dataset.state = next;
      root.dataset.state = next;
      if (next === "listening") startListenSim();
      else stopListenSim();
      return api;
    }

    function setAmplitude(value) {
      if (destroyed) return api;
      amplitude = clamp(Number(value) || 0, 0, 1);
      btn.style.setProperty("--acs-amp", String(amplitude));
      return api;
    }

    function setSize(px) {
      if (destroyed) return api;
      btn.style.setProperty("--acs-size", Number(px) + "px");
      return api;
    }

    function setInteractive(on) {
      if (destroyed) return api;
      opts.interactive = !!on;
      btn.classList.toggle("is-static", !on);
      btn.tabIndex = on ? 0 : -1;
      return api;
    }

    function triggerPress() {
      if (destroyed || !opts.interactive) return api;
      const prev = state === "pressed" ? "idle" : state;
      setState("pressed");
      if (typeof opts.onTap === "function") opts.onTap(api);
      clearTimeout(pressTimer);
      pressTimer = setTimeout(() => {
        pressTimer = null;
        if (state === "pressed") setState(prev === "listening" ? "idle" : prev);
      }, PRESS_MS);
      return api;
    }

    function startListenSim() {
      stopListenSim();
      let t = 0;
      listenSim = setInterval(() => {
        t += 0.16;
        const wave = 0.35 + Math.sin(t) * 0.22 + Math.sin(t * 2.4) * 0.12;
        setAmplitude(wave);
      }, 80);
    }

    function stopListenSim() {
      if (listenSim) {
        clearInterval(listenSim);
        listenSim = null;
      }
      if (state !== "listening") setAmplitude(0);
    }

    function onPointerDown(e) {
      if (!opts.interactive || destroyed) return;
      if (e.pointerType === "mouse" && e.button !== 0) return;
      triggerPress();
    }

    function onKey(e) {
      if (!opts.interactive || destroyed) return;
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        triggerPress();
      }
    }

    if (opts.interactive) {
      btn.addEventListener("pointerdown", onPointerDown);
      btn.addEventListener("keydown", onKey);
    }

    function destroy() {
      destroyed = true;
      clearTimeout(pressTimer);
      stopListenSim();
      btn.removeEventListener("pointerdown", onPointerDown);
      btn.removeEventListener("keydown", onKey);
      if (root._aiCoachSphere === api) delete root._aiCoachSphere;
      root.classList.remove("ai-sphere-host");
      root.innerHTML = "";
    }

    const api = {
      el: btn,
      host: root,
      getState: () => state,
      setState,
      setAmplitude,
      setSize,
      setInteractive,
      triggerPress,
      destroy,
    };

    root._aiCoachSphere = api;
    return api;
  }

  function mount(target, options) {
    const el = typeof target === "string" ? document.querySelector(target) : target;
    if (!el) throw new Error("AICoachSphere.mount: target not found");
    if (el._aiCoachSphere) el._aiCoachSphere.destroy();
    return createInstance(el, options);
  }

  function autoMount(scope) {
    const root = scope || document;
    const nodes = root.querySelectorAll("[data-ai-coach-sphere]");
    const instances = [];
    nodes.forEach((node) => {
      if (node._aiCoachSphere) return;
      const size = Number(node.dataset.size) || 160;
      const interactive = node.dataset.interactive !== "false";
      const state = node.dataset.state || "idle";
      instances.push(
        mount(node, {
          size,
          interactive,
          state,
          label: node.dataset.label || "AI Coach",
        })
      );
    });
    return instances;
  }

  const AICoachSphere = { mount, autoMount, STATES };
  global.AICoachSphere = AICoachSphere;
})(typeof window !== "undefined" ? window : globalThis);
