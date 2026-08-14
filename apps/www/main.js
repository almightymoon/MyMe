/**
 * MeMy experience — Lusion-inspired motion layer
 * Canvas field + native scroll + GSAP ScrollTrigger
 */
(function () {
  'use strict';

  var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var coarse = window.matchMedia('(pointer: coarse)').matches;
  var isHome = !!document.getElementById('hero');
  var yearEl = document.getElementById('year');
  if (yearEl) yearEl.textContent = String(new Date().getFullYear());

  function $(sel, ctx) {
    return (ctx || document).querySelector(sel);
  }
  function $$(sel, ctx) {
    return Array.prototype.slice.call((ctx || document).querySelectorAll(sel));
  }
  function clamp(n, a, b) {
    return Math.max(a, Math.min(b, n));
  }
  function lerp(a, b, t) {
    return a + (b - a) * t;
  }

  /* —— Ember world (theme through the whole site) —— */
  var Field = {
    canvas: document.getElementById('field'),
    ctx: null,
    w: 0,
    h: 0,
    dpr: 1,
    particles: [],
    orbs: [],
    mouse: { x: 0.5, y: 0.38, tx: 0.5, ty: 0.38 },
    scroll: 0,
    t: 0,
    running: false,

    init: function () {
      if (!this.canvas || reduced) {
        if (this.canvas) this.canvas.style.display = 'none';
        return;
      }
      this.ctx = this.canvas.getContext('2d', { alpha: true });
      this.orbs = [
        { x: 0.28, y: 0.22, r: 340, s: 0.11 },
        { x: 0.78, y: 0.58, r: 420, s: 0.08 },
        { x: 0.48, y: 0.88, r: 280, s: 0.14 },
      ];
      this.resize();
      this.spawn();
      window.addEventListener('resize', this.resize.bind(this), { passive: true });
      window.addEventListener(
        'pointermove',
        function (e) {
          Field.mouse.tx = e.clientX / Field.w;
          Field.mouse.ty = e.clientY / Field.h;
        },
        { passive: true }
      );
      this.running = true;
      this.loop();
    },

    resize: function () {
      if (!this.canvas || !this.ctx) return;
      this.dpr = Math.min(window.devicePixelRatio || 1, 2);
      this.w = window.innerWidth;
      this.h = window.innerHeight;
      this.canvas.width = this.w * this.dpr;
      this.canvas.height = this.h * this.dpr;
      this.canvas.style.width = this.w + 'px';
      this.canvas.style.height = this.h + 'px';
      this.ctx.setTransform(this.dpr, 0, 0, this.dpr, 0, 0);
      if (!this.particles.length) this.spawn();
    },

    spawn: function () {
      var n = coarse ? 42 : 96;
      this.particles = [];
      for (var i = 0; i < n; i++) {
        this.particles.push({
          x: Math.random() * this.w,
          y: Math.random() * this.h,
          vx: 0,
          vy: 0,
          life: Math.random(),
          size: 0.7 + Math.random() * 2.4,
          hue: Math.random(),
        });
      }
    },

    noise: function (x, y, t) {
      return Math.sin(x * 0.0022 + t * 0.18) + Math.cos(y * 0.0018 - t * 0.14 + x * 0.0004);
    },

    loop: function () {
      if (!this.running) return;
      this.t += 0.016;
      this.mouse.x = lerp(this.mouse.x, this.mouse.tx, 0.055);
      this.mouse.y = lerp(this.mouse.y, this.mouse.ty, 0.055);
      this.draw();
      requestAnimationFrame(this.loop.bind(this));
    },

    draw: function () {
      var ctx = this.ctx;
      var w = this.w;
      var h = this.h;
      var scroll = this.scroll;
      ctx.globalCompositeOperation = 'source-over';
      ctx.fillStyle = 'rgba(0,0,0,0.22)';
      ctx.fillRect(0, 0, w, h);

      var mx = this.mouse.x * w;
      var my = this.mouse.y * h;
      var pulse = 0.62 + Math.sin(this.t * 0.65) * 0.14 + scroll * 0.22;
      var i;

      ctx.globalCompositeOperation = 'lighter';
      for (i = 0; i < this.orbs.length; i++) {
        var o = this.orbs[i];
        var ox = (o.x + Math.sin(this.t * o.s + i) * 0.08) * w;
        var oy = (o.y + Math.cos(this.t * o.s * 0.8 + i) * 0.06 + scroll * 0.12) * h;
        var og = ctx.createRadialGradient(ox, oy, 0, ox, oy, o.r);
        var a0 = (0.11 + pulse * 0.05).toFixed(3);
        og.addColorStop(0, i === 1 ? 'rgba(255,179,71,' + a0 + ')' : 'rgba(255,106,26,' + a0 + ')');
        og.addColorStop(0.45, 'rgba(255,80,20,0.035)');
        og.addColorStop(1, 'rgba(0,0,0,0)');
        ctx.fillStyle = og;
        ctx.fillRect(ox - o.r, oy - o.r, o.r * 2, o.r * 2);
      }

      var mg = ctx.createRadialGradient(mx, my, 0, mx, my, Math.max(w, h) * 0.42);
      mg.addColorStop(0, 'rgba(255,106,26,' + (0.22 * pulse).toFixed(3) + ')');
      mg.addColorStop(0.4, 'rgba(255,80,20,0.06)');
      mg.addColorStop(1, 'rgba(0,0,0,0)');
      ctx.fillStyle = mg;
      ctx.fillRect(0, 0, w, h);

      var p, a, n, mag, dx, dy, dist, speed;
      speed = 1.05 + scroll * 0.55;
      for (i = 0; i < this.particles.length; i++) {
        p = this.particles[i];
        n = this.noise(p.x, p.y, this.t);
        a = n * Math.PI;
        p.vx = lerp(p.vx, Math.cos(a) * speed, 0.045);
        p.vy = lerp(p.vy, Math.sin(a) * speed, 0.045);

        dx = mx - p.x;
        dy = my - p.y;
        dist = Math.sqrt(dx * dx + dy * dy) + 36;
        mag = 48 / dist;
        p.vx += dx * mag * 0.014;
        p.vy += dy * mag * 0.014;

        p.x += p.vx;
        p.y += p.vy;
        p.life += 0.004;
        if (p.x < -20) p.x = w + 20;
        if (p.x > w + 20) p.x = -20;
        if (p.y < -20) p.y = h + 20;
        if (p.y > h + 20) p.y = -20;

        var alpha = 0.22 + Math.sin(p.life * 4 + i) * 0.14;
        ctx.beginPath();
        ctx.fillStyle =
          p.hue > 0.7
            ? 'rgba(255,179,71,' + alpha.toFixed(3) + ')'
            : 'rgba(255,106,26,' + alpha.toFixed(3) + ')';
        ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
        ctx.fill();
      }

      if (!coarse) {
        ctx.strokeStyle = 'rgba(255,106,26,0.09)';
        ctx.lineWidth = 1;
        var j, q, d2;
        for (i = 0; i < this.particles.length; i += 3) {
          p = this.particles[i];
          for (j = i + 7; j < this.particles.length; j += 13) {
            q = this.particles[j];
            d2 = (p.x - q.x) * (p.x - q.x) + (p.y - q.y) * (p.y - q.y);
            if (d2 < 16000) {
              ctx.globalAlpha = 1 - d2 / 16000;
              ctx.beginPath();
              ctx.moveTo(p.x, p.y);
              ctx.lineTo(q.x, q.y);
              ctx.stroke();
            }
          }
        }
        ctx.globalAlpha = 1;
      }
    },
  };

  /* —— Magnetic buttons —— */
  var Magnetic = {
    init: function () {
      if (coarse || reduced) return;
      $$('[data-magnetic]').forEach(function (el) {
        el.addEventListener('pointermove', function (e) {
          var r = el.getBoundingClientRect();
          var x = e.clientX - r.left - r.width / 2;
          var y = e.clientY - r.top - r.height / 2;
          el.style.transform = 'translate3d(' + x * 0.22 + 'px,' + y * 0.28 + 'px,0)';
        });
        el.addEventListener('pointerleave', function () {
          el.style.transform = '';
        });
      });
    },
  };

  /* —— Split characters —— */
  function splitText(el) {
    if (!el || el.dataset.splitDone) return;
    var html = el.innerHTML
      .replace(/<br\s*\/?>/gi, '{{BR}}')
      .replace(/\s+/g, ' ')
      .trim();
    html = html.replace(/<[^>]+>/g, function (m) {
      if (/^<span class="text-gradient"/.test(m) || m === '</span>') return m;
      return '';
    });
    var out = '';
    var i;
    var ch;
    var delay = 0;
    for (i = 0; i < html.length; i++) {
      if (html.slice(i, i + 6) === '{{BR}}') {
        out += '<br>';
        i += 5;
        continue;
      }
      if (html.slice(i, i + 6) === '<span ') {
        var close = html.indexOf('</span>', i);
        var inner = html.slice(html.indexOf('>', i) + 1, close);
        out += '<span class="text-gradient">';
        for (var j = 0; j < inner.length; j++) {
          if (inner[j] === ' ') {
            out += ' ';
            continue;
          }
          out +=
            '<span class="char" style="--d:' +
            delay * 0.018 +
            's"><span>' +
            inner[j] +
            '</span></span>';
          delay++;
        }
        out += '</span>';
        i = close + 6;
        continue;
      }
      ch = html[i];
      if (ch === ' ') {
        out += ' ';
        continue;
      }
      out +=
        '<span class="char" style="--d:' + delay * 0.018 + 's"><span>' + ch + '</span></span>';
      delay++;
    }
    el.innerHTML = out;
    el.dataset.splitDone = '1';
  }

  /* —— Loader —— */
  var Loader = {
    el: document.getElementById('loader'),
    bar: document.getElementById('loader-bar'),
    count: document.getElementById('loader-count'),
    run: function (done) {
      if (!this.el || reduced) {
        if (this.el) this.el.classList.add('is-done');
        document.body.classList.add('is-ready');
        document.body.classList.remove('is-loading');
        done();
        return;
      }
      var n = 0;
      var self = this;
      var id = setInterval(function () {
        n += Math.random() * 11 + 4;
        if (n >= 100) {
          n = 100;
          clearInterval(id);
          self.count.textContent = '100';
          self.bar.style.transform = 'scaleX(1)';
          setTimeout(function () {
            self.el.classList.add('is-done');
            document.body.classList.add('is-ready');
            document.body.classList.remove('is-loading');
            done();
          }, 280);
        } else {
          self.count.textContent = String(Math.floor(n)).padStart(2, '0');
          self.bar.style.transform = 'scaleX(' + n / 100 + ')';
        }
      }, 42);
    },
  };

  /* —— Nav (works with or without GSAP) —— */
  var Nav = {
    nav: document.getElementById('nav'),
    toggle: document.getElementById('nav-toggle'),
    menu: document.getElementById('nav-menu'),
    init: function () {
      if (!this.nav) return;
      var self = this;
      if (this.toggle && this.menu) {
        this.toggle.addEventListener('click', function () {
          var open = self.nav.classList.toggle('is-open');
          document.body.classList.toggle('nav-open', open);
          self.toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
          self.menu.setAttribute('aria-hidden', open ? 'false' : 'true');
        });
        $$('.nav__menu-link, .nav__menu-cta').forEach(function (a) {
          a.addEventListener('click', function () {
            self.nav.classList.remove('is-open');
            document.body.classList.remove('nav-open');
          });
        });
        document.addEventListener('keydown', function (e) {
          if (e.key === 'Escape') {
            self.nav.classList.remove('is-open');
            document.body.classList.remove('nav-open');
          }
        });
      }
    },
    onScroll: function (y) {
      if (this.nav) this.nav.classList.toggle('is-scrolled', y > 40);
    },
  };

  function bindTilt(el, strength) {
    if (!el || coarse || reduced) return;
    var s = strength || 12;
    el.addEventListener('pointermove', function (e) {
      var r = el.getBoundingClientRect();
      var x = (e.clientX - r.left) / r.width - 0.5;
      var y = (e.clientY - r.top) / r.height - 0.5;
      el.style.transform =
        'rotateY(' + (x * s).toFixed(2) + 'deg) rotateX(' + (-y * s).toFixed(2) + 'deg) translateZ(12px)';
    });
    el.addEventListener('pointerleave', function () {
      el.style.transform = '';
    });
  }

  function bootMotion() {
    if (!isHome) {
      window.addEventListener(
        'scroll',
        function () {
          Nav.onScroll(window.scrollY);
        },
        { passive: true }
      );
      Nav.onScroll(window.scrollY);
      return;
    }

    $$('[data-split]').forEach(splitText);
    $$('[data-tilt]').forEach(function (el) {
      bindTilt(el, 10);
    });

    var gsapOk = typeof gsap !== 'undefined';
    var stOk = typeof ScrollTrigger !== 'undefined';

    if (gsapOk && stOk) gsap.registerPlugin(ScrollTrigger);

    window.addEventListener(
      'scroll',
      function () {
        Nav.onScroll(window.scrollY);
        var max = document.documentElement.scrollHeight - window.innerHeight;
        var p = max > 0 ? window.scrollY / max : 0;
        Field.scroll = p;
        var bar = document.getElementById('scroll-progress');
        if (bar) bar.style.transform = 'scaleX(' + p + ')';
      },
      { passive: true }
    );

    $$('a[href^="#"]').forEach(function (a) {
      a.addEventListener('click', function (e) {
        var id = a.getAttribute('href');
        var target = id && id !== '#' ? document.querySelector(id) : null;
        if (!target) return;
        e.preventDefault();
        target.scrollIntoView({ behavior: reduced ? 'auto' : 'smooth' });
      });
    });

    if (!gsapOk) {
      document.body.classList.add('is-ready');
      $$('.reveal, .hero').forEach(function (el) {
        el.classList.add('is-visible', 'is-loaded');
      });
      return;
    }

    /* Hero intro */
    var hero = document.getElementById('hero');
    if (hero) {
      var chars = $$('.hero__title .char span');
      gsap.set(chars, { yPercent: 110, rotate: 8 });
      gsap.set('.hero__eyebrow, .hero__lead, .hero__actions, .hero__visual', { y: 40, opacity: 0 });
      gsap.set('.float-chip', { opacity: 0 });
      gsap.set('.hero__scroll', { opacity: 0 });
      hero.classList.add('is-loaded');
      gsap.to(chars, {
        yPercent: 0,
        rotate: 0,
        duration: 1.15,
        ease: 'power4.out',
        stagger: 0.02,
        delay: 0.04,
      });
      gsap.to('.hero__eyebrow, .hero__lead, .hero__actions, .hero__visual', {
        y: 0,
        opacity: 1,
        duration: 1.05,
        ease: 'power3.out',
        stagger: 0.09,
        delay: 0.32,
      });
      gsap.to('.float-chip', {
        opacity: 1,
        duration: 0.9,
        ease: 'power3.out',
        stagger: 0.12,
        delay: 0.7,
      });
      gsap.to('.hero__scroll', {
        opacity: 1,
        duration: 0.8,
        delay: 1.15,
        onComplete: function () {
          gsap.set('.hero__scroll', { clearProps: 'opacity' });
        },
      });
      if (stOk) {
        gsap.to('.hero__visual', {
          y: 40,
          ease: 'none',
          scrollTrigger: { trigger: hero, start: 'top top', end: 'bottom top', scrub: true },
        });
        gsap.to('.hero__content', {
          y: -20,
          opacity: 0.72,
          ease: 'none',
          scrollTrigger: { trigger: hero, start: 'top top', end: '80% top', scrub: true },
        });
        gsap.to('.hero__scroll', {
          opacity: 0,
          ease: 'none',
          scrollTrigger: { trigger: hero, start: '8% top', end: '30% top', scrub: true },
        });
      }
    }

    /* Device tilt */
    var stack = document.getElementById('device-stack');
    if (stack && !coarse && !reduced) {
      var front = stack.querySelector('.device--front');
      var back = stack.querySelector('.device--back');
      stack.addEventListener('pointermove', function (e) {
        var r = stack.getBoundingClientRect();
        var x = (e.clientX - r.left) / r.width - 0.5;
        var y = (e.clientY - r.top) / r.height - 0.5;
        if (front) {
          gsap.to(front, {
            rotateY: 8 + x * 16,
            rotateX: 4 - y * 12,
            duration: 0.5,
            ease: 'power2.out',
            overwrite: 'auto',
          });
        }
        if (back) {
          gsap.to(back, {
            rotateY: -16 + x * 12,
            rotateX: 6 - y * 9,
            duration: 0.55,
            ease: 'power2.out',
            overwrite: 'auto',
          });
        }
      });
      stack.addEventListener('pointerleave', function () {
        if (front) gsap.to(front, { rotateY: 6, rotateX: 3, duration: 0.8, ease: 'power3.out' });
        if (back) gsap.to(back, { rotateY: -16, rotateX: 5, duration: 0.8, ease: 'power3.out' });
      });
    }

    /* Reveals */
    $$('.reveal').forEach(function (el) {
      gsap.fromTo(
        el,
        { y: 56, opacity: 0 },
        {
          y: 0,
          opacity: 1,
          duration: 1.05,
          ease: 'power3.out',
          scrollTrigger: { trigger: el, start: 'top 86%', once: true },
        }
      );
    });

    $$('[data-split]:not(.hero__title)').forEach(function (el) {
      var spans = $$('.char span', el);
      if (!spans.length) return;
      gsap.from(spans, {
        yPercent: 110,
        duration: 0.95,
        ease: 'power4.out',
        stagger: 0.016,
        scrollTrigger: { trigger: el, start: 'top 82%', once: true },
      });
    });

    /* Statement scale */
    $$('.statement__text').forEach(function (el) {
      gsap.fromTo(
        el,
        { scale: 0.82, opacity: 0.2, filter: 'blur(8px)' },
        {
          scale: 1,
          opacity: 1,
          filter: 'blur(0px)',
          ease: 'none',
          scrollTrigger: {
            trigger: el.parentElement,
            start: 'top 85%',
            end: 'center center',
            scrub: true,
          },
        }
      );
    });

    /* Sticky features */
    var scene = document.getElementById('sticky-features');
    if (scene && stOk) {
      var features = $$('.sticky-feature');
      var visuals = $$('.sticky-visual');
      var fill = $('.sticky-progress__fill');
      var label = $('.sticky-progress__label');
      var count = features.length;
      ScrollTrigger.create({
        trigger: scene,
        start: 'top top+=52',
        end: 'bottom bottom',
        onUpdate: function (self) {
          var p = self.progress;
          var raw = p * count;
          var index = Math.min(count - 1, Math.floor(raw + 0.001));
          var local = raw - index;
          features.forEach(function (f, i) {
            var on = i === index;
            f.classList.toggle('is-active', on);
            f.setAttribute('aria-selected', on ? 'true' : 'false');
            f.style.setProperty('--text-open', on ? clamp(local * 2.2, 0, 1).toFixed(3) : i < index ? '1' : '0');
          });
          visuals.forEach(function (v, i) {
            var on = i === index;
            v.classList.toggle('is-active', on);
          });
          if (fill) fill.style.transform = 'scaleX(' + p.toFixed(4) + ')';
          if (label) label.textContent = String(index + 1).padStart(2, '0') + ' / 0' + count;
        },
      });
    }

    /* Filmstrip — pinned horizontal on desktop */
    var track = $('.filmstrip__track');
    var strip = $('.filmstrip');
    if (track && strip && stOk) {
      var mm = gsap.matchMedia();
      mm.add('(min-width: 901px)', function () {
        var tween = gsap.to(track, {
          x: function () {
            return Math.min(0, window.innerWidth - track.scrollWidth - 48);
          },
          ease: 'none',
          scrollTrigger: {
            trigger: strip,
            start: 'top top+=52',
            end: function () {
              return '+=' + Math.max(window.innerHeight, track.scrollWidth - window.innerWidth + 200);
            },
            pin: true,
            scrub: 1,
            invalidateOnRefresh: true,
          },
        });
        return function () {
          tween.kill();
        };
      });
      mm.add('(max-width: 900px)', function () {
        gsap.to(track, {
          x: function () {
            return Math.min(0, window.innerWidth - track.scrollWidth - 24);
          },
          ease: 'none',
          scrollTrigger: {
            trigger: strip,
            start: 'top 70%',
            end: 'bottom top',
            scrub: 1.1,
          },
        });
      });
      $$('.filmstrip img').forEach(function (img) {
        if (!img.complete) img.addEventListener('load', function () { ScrollTrigger.refresh(); });
      });
    }

    /* Chapter stages */
    $$('.chapter__stage, .duo-card').forEach(function (el) {
      gsap.fromTo(
        el,
        { y: 80, scale: 0.94, opacity: 0 },
        {
          y: 0,
          scale: 1,
          opacity: 1,
          duration: 1.15,
          ease: 'power3.out',
          scrollTrigger: { trigger: el, start: 'top 88%', once: true },
        }
      );
    });

    $$('.filmstrip__item').forEach(function (el, i) {
      gsap.fromTo(
        el,
        { y: 40, opacity: 0 },
        {
          y: 0,
          opacity: 1,
          duration: 0.9,
          delay: i * 0.06,
          ease: 'power3.out',
          scrollTrigger: { trigger: strip || el, start: 'top 80%', once: true },
        }
      );
    });

    /* Privacy rows stagger */
    gsap.from('.privacy-row', {
      x: -28,
      opacity: 0,
      duration: 0.9,
      stagger: 0.14,
      ease: 'power3.out',
      scrollTrigger: { trigger: '#privacy', start: 'top 75%', once: true },
    });
  }

  /* —— Boot —— */
  Nav.init();
  Field.init();
  Magnetic.init();

  function start() {
    function go() {
      if (isHome) Loader.run(bootMotion);
      else {
        document.body.classList.add('is-ready');
        document.body.classList.remove('is-loading');
        bootMotion();
      }
    }
    if (!isHome || reduced || typeof gsap !== 'undefined') {
      go();
      return;
    }
    var n = 0;
    var id = setInterval(function () {
      n += 1;
      if (typeof gsap !== 'undefined' || n > 50) {
        clearInterval(id);
        go();
      }
    }, 40);
  }

  if (document.readyState === 'complete') start();
  else window.addEventListener('load', start);
})();
