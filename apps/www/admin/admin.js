(function () {
  'use strict';

  var TOKEN_KEY = 'memy_admin_token';
  var API =
    window.MEMY_ADMIN_API ||
    (location.hostname === 'memy.athariqbal.com' ||
    location.hostname === 'api.memy.athariqbal.com'
      ? 'https://api.memy.athariqbal.com/api/v1'
      : 'http://127.0.0.1:3000/api/v1');

  var state = { view: 'overview', token: localStorage.getItem(TOKEN_KEY) || '' };

  function $(id) {
    return document.getElementById(id);
  }

  function money(minor, currency) {
    var n = Number(minor || 0) / 100;
    try {
      return new Intl.NumberFormat(undefined, {
        style: 'currency',
        currency: currency || 'PKR',
        maximumFractionDigits: 0,
      }).format(n);
    } catch {
      return (currency || 'PKR') + ' ' + n.toFixed(0);
    }
  }

  function badge(status) {
    var cls = 'badge';
    if (status === 'active' || status === 'trialing') cls += ' badge--ok';
    else if (status === 'disabled' || status === 'canceled' || status === 'expired')
      cls += ' badge--bad';
    else cls += ' badge--warn';
    return '<span class="' + cls + '">' + status + '</span>';
  }

  function when(value) {
    if (!value) return '—';
    return new Date(value).toLocaleString();
  }

  async function api(path, options) {
    var opts = options || {};
    var headers = Object.assign({ 'Content-Type': 'application/json' }, opts.headers || {});
    if (state.token) headers.Authorization = 'Bearer ' + state.token;
    var res = await fetch(API + path, Object.assign({}, opts, { headers: headers }));
    if (res.status === 204) return null;
    var body = await res.json().catch(function () {
      return {};
    });
    if (!res.ok) {
      var err = new Error(body.message || 'Request failed');
      err.code = body.code;
      throw err;
    }
    return body;
  }

  function showApp(on) {
    $('login').hidden = on;
    $('app').hidden = !on;
  }

  async function boot() {
    if (!state.token) {
      showApp(false);
      return;
    }
    try {
      var me = await api('/admin/auth/me');
      $('who').textContent = me.email;
      showApp(true);
      render();
    } catch {
      state.token = '';
      localStorage.removeItem(TOKEN_KEY);
      showApp(false);
    }
  }

  $('login-form').addEventListener('submit', async function (e) {
    e.preventDefault();
    $('login-error').hidden = true;
    try {
      var out = await api('/admin/auth/login', {
        method: 'POST',
        body: JSON.stringify({
          email: $('login-email').value.trim(),
          password: $('login-password').value,
        }),
      });
      state.token = out.accessToken;
      localStorage.setItem(TOKEN_KEY, out.accessToken);
      await boot();
    } catch (err) {
      $('login-error').hidden = false;
      $('login-error').textContent = err.message;
    }
  });

  $('logout').addEventListener('click', function () {
    state.token = '';
    localStorage.removeItem(TOKEN_KEY);
    showApp(false);
  });

  document.querySelectorAll('.side nav button').forEach(function (btn) {
    btn.addEventListener('click', function () {
      document.querySelectorAll('.side nav button').forEach(function (b) {
        b.classList.toggle('is-active', b === btn);
      });
      state.view = btn.getAttribute('data-view');
      render();
    });
  });

  async function render() {
    var main = $('main');
    main.innerHTML = '<p class="muted">Loading…</p>';
    try {
      if (state.view === 'overview') await overview(main);
      else if (state.view === 'users') await users(main);
      else if (state.view === 'subscriptions') await subscriptions(main);
      else if (state.view === 'plans') await plans(main);
      else if (state.view === 'revenue') await revenue(main);
      else if (state.view === 'audit') await audit(main);
      else if (state.view === 'operators') await operators(main);
    } catch (err) {
      main.innerHTML = '<p class="error">' + err.message + '</p>';
    }
  }

  async function overview(main) {
    var data = await api('/admin/overview');
    main.innerHTML =
      '<h2>Overview</h2><div class="kpis">' +
      kpi('Users', data.users.total) +
      kpi('Active', data.users.active) +
      kpi('Disabled', data.users.disabled) +
      kpi('Signups 7d', data.users.signups7d) +
      kpi('Signed in 24h', data.users.signedIn24h) +
      kpi('Devices', data.devices.active) +
      kpi('MRR', money(data.revenue.mrrMinor, data.revenue.currency)) +
      kpi('ARR', money(data.revenue.arrMinor, data.revenue.currency)) +
      '</div>' +
      '<div class="panel"><h3>Recent users</h3>' +
      table(
        ['Name', 'Email', 'Status', 'Joined'],
        data.recentUsers.map(function (u) {
          return [
            '<button class="linkish" data-user="' +
              u.id +
              '">' +
              esc(u.displayName) +
              '</button>',
            esc(u.email || '—'),
            badge(u.status),
            when(u.createdAt),
          ];
        }),
      ) +
      '</div>';
    bindUserLinks(main);
  }

  function kpi(label, value) {
    return (
      '<div class="kpi"><span>' +
      label +
      '</span><b>' +
      value +
      '</b></div>'
    );
  }

  async function users(main, q) {
    var query = q ? '?q=' + encodeURIComponent(q) : '';
    var data = await api('/admin/users' + query);
    main.innerHTML =
      '<h2>Users</h2><div class="toolbar"><input id="user-q" placeholder="Search name, email, id" /><button class="btn" id="user-search">Search</button></div>' +
      table(
        ['Name', 'Email', 'Plan', 'Status', 'Joined', 'Last sign-in'],
        data.items.map(function (u) {
          return [
            '<button class="linkish" data-user="' +
              u.id +
              '">' +
              esc(u.displayName) +
              '</button>',
            esc(u.email || '—'),
            esc((u.subscription && u.subscription.plan) || 'Free / none'),
            badge(u.status),
            when(u.createdAt),
            when(u.lastSignedInAt),
          ];
        }),
      ) +
      '<p class="muted">' +
      data.total +
      ' total</p>';
    $('user-search').onclick = function () {
      users(main, $('user-q').value);
    };
    bindUserLinks(main);
  }

  function bindUserLinks(root) {
    root.querySelectorAll('[data-user]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        showUser(btn.getAttribute('data-user'));
      });
    });
  }

  async function showUser(id) {
    var main = $('main');
    var user = await api('/admin/users/' + id);
    var planOptions = (await api('/admin/plans'))
      .filter(function (p) {
        return p.active;
      })
      .map(function (p) {
        return '<option value="' + p.id + '">' + esc(p.name) + '</option>';
      })
      .join('');
    main.innerHTML =
      '<button class="btn btn--ghost" id="back-users">← Users</button>' +
      '<div class="panel"><h3>' +
      esc(user.displayName) +
      ' ' +
      badge(user.status) +
      '</h3><p>' +
      esc(user.email || 'no email') +
      ' · ' +
      user.timezone +
      ' · ' +
      user.currencyCode +
      '</p><p>Goals ' +
      user.counts.goals +
      ' · Sync records ' +
      user.counts.syncRecords +
      ' · Assets ' +
      user.counts.assets +
      '</p><div class="row">' +
      (user.status === 'active'
        ? '<button class="btn btn--danger" id="disable-user">Disable</button>'
        : '<button class="btn" id="enable-user">Enable</button>') +
      '<button class="btn btn--ghost" id="logout-user">Force logout</button></div>' +
      '<h3>Assign plan</h3><div class="row"><select id="plan-id">' +
      planOptions +
      '</select><button class="btn" id="assign-plan">Assign</button></div>' +
      '<h3>Devices</h3>' +
      table(
        ['Label', 'Platform', 'Last seen', ''],
        user.devices.map(function (d) {
          return [
            esc(d.deviceLabel || d.clientGeneratedDeviceId),
            esc(d.platform + ' ' + d.appVersion),
            when(d.lastSeenAt) + (d.revokedAt ? ' (revoked)' : ''),
            d.revokedAt
              ? '—'
              : '<button class="linkish" data-revoke="' + d.id + '">Revoke</button>',
          ];
        }),
      ) +
      '<h3>Subscriptions</h3>' +
      table(
        ['Plan', 'Status', 'Amount', 'Period end', ''],
        user.subscriptions.map(function (s) {
          return [
            esc(s.plan.name),
            badge(s.status),
            money(s.amountMinor, s.currencyCode),
            when(s.currentPeriodEnd),
            s.status === 'active' || s.status === 'trialing'
              ? '<button class="linkish" data-cancel="' + s.id + '">Cancel</button>'
              : '—',
          ];
        }),
      ) +
      '</div>';
    $('back-users').onclick = function () {
      state.view = 'users';
      document.querySelectorAll('.side nav button').forEach(function (b) {
        b.classList.toggle('is-active', b.getAttribute('data-view') === 'users');
      });
      render();
    };
    var disable = document.getElementById('disable-user');
    var enable = document.getElementById('enable-user');
    if (disable)
      disable.onclick = async function () {
        await api('/admin/users/' + id, {
          method: 'PATCH',
          body: JSON.stringify({ status: 'disabled' }),
        });
        showUser(id);
      };
    if (enable)
      enable.onclick = async function () {
        await api('/admin/users/' + id, {
          method: 'PATCH',
          body: JSON.stringify({ status: 'active' }),
        });
        showUser(id);
      };
    document.getElementById('logout-user').onclick = async function () {
      await api('/admin/users/' + id + '/logout-all', { method: 'POST' });
      showUser(id);
    };
    document.getElementById('assign-plan').onclick = async function () {
      await api('/admin/users/' + id + '/subscription', {
        method: 'POST',
        body: JSON.stringify({ planId: document.getElementById('plan-id').value }),
      });
      showUser(id);
    };
    main.querySelectorAll('[data-revoke]').forEach(function (btn) {
      btn.onclick = async function () {
        await api(
          '/admin/users/' + id + '/devices/' + btn.getAttribute('data-revoke') + '/revoke',
          { method: 'POST' },
        );
        showUser(id);
      };
    });
    main.querySelectorAll('[data-cancel]').forEach(function (btn) {
      btn.onclick = async function () {
        await api('/admin/subscriptions/' + btn.getAttribute('data-cancel'), {
          method: 'PATCH',
          body: JSON.stringify({ status: 'canceled' }),
        });
        showUser(id);
      };
    });
  }

  async function subscriptions(main) {
    var data = await api('/admin/subscriptions');
    main.innerHTML =
      '<h2>Subscriptions</h2>' +
      table(
        ['User', 'Plan', 'Status', 'Amount', 'Started'],
        data.items.map(function (s) {
          return [
            esc(s.user.displayName),
            esc(s.plan.name),
            badge(s.status),
            money(s.amountMinor, s.currencyCode),
            when(s.startedAt),
          ];
        }),
      );
  }

  async function plans(main) {
    var data = await api('/admin/plans');
    main.innerHTML =
      '<h2>Plans</h2>' +
      table(
        ['Code', 'Name', 'Interval', 'Price', 'Active subs', ''],
        data.map(function (p) {
          return [
            esc(p.code),
            esc(p.name),
            esc(p.interval),
            money(p.amountMinor, p.currencyCode),
            String(p.activeSubscriptions),
            p.active ? 'Live' : 'Off',
          ];
        }),
      ) +
      '<div class="panel"><h3>Create or update plan</h3>' +
      '<div class="row"><input id="p-code" placeholder="code" /><input id="p-name" placeholder="name" />' +
      '<select id="p-interval"><option value="none">none</option><option value="month">month</option><option value="year">year</option></select>' +
      '<input id="p-amount" placeholder="amount minor units" /><input id="p-currency" value="PKR" maxlength="3" />' +
      '<button class="btn" id="p-save">Save</button></div></div>';
    $('p-save').onclick = async function () {
      await api('/admin/plans', {
        method: 'POST',
        body: JSON.stringify({
          code: $('p-code').value.trim(),
          name: $('p-name').value.trim(),
          interval: $('p-interval').value,
          amountMinor: $('p-amount').value.trim(),
          currencyCode: $('p-currency').value.trim(),
          active: true,
        }),
      });
      plans(main);
    };
  }

  async function revenue(main) {
    var data = await api('/admin/revenue');
    main.innerHTML =
      '<h2>Revenue</h2><div class="kpis">' +
      kpi('MRR', money(data.mrrMinor, (data.byPlan[0] && data.byPlan[0].currencyCode) || 'PKR')) +
      kpi('ARR', money(data.arrMinor, (data.byPlan[0] && data.byPlan[0].currencyCode) || 'PKR')) +
      kpi('Active subscriptions', data.activeSubscriptions) +
      '</div><div class="panel"><h3>By plan</h3>' +
      table(
        ['Plan', 'Count', 'MRR'],
        data.byPlan.map(function (row) {
          return [esc(row.plan), String(row.count), money(row.mrrMinor, row.currencyCode)];
        }),
      ) +
      '</div><p class="muted">Manual entitlements until App Store / Play Billing is wired. Amounts are whole minor units.</p>';
  }

  async function audit(main) {
    var data = await api('/admin/audit');
    main.innerHTML =
      '<h2>Audit log</h2>' +
      table(
        ['When', 'Admin', 'Action', 'Target'],
        data.items.map(function (e) {
          return [
            when(e.createdAt),
            esc((e.adminUser && e.adminUser.email) || '—'),
            esc(e.action),
            esc((e.targetType || '') + ' ' + (e.targetId || '')),
          ];
        }),
      );
  }

  async function operators(main) {
    var data = await api('/admin/operators');
    main.innerHTML =
      '<h2>Operators</h2>' +
      table(
        ['Name', 'Email', 'Status', 'Last login'],
        data.map(function (a) {
          return [esc(a.displayName), esc(a.email), badge(a.status), when(a.lastLoginAt)];
        }),
      ) +
      '<div class="panel"><h3>Invite operator</h3><div class="row">' +
      '<input id="o-name" placeholder="Name" /><input id="o-email" placeholder="Email" type="email" />' +
      '<input id="o-pass" placeholder="Password (12+ chars)" type="password" />' +
      '<button class="btn" id="o-save">Create</button></div></div>';
    $('o-save').onclick = async function () {
      await api('/admin/operators', {
        method: 'POST',
        body: JSON.stringify({
          displayName: $('o-name').value.trim(),
          email: $('o-email').value.trim(),
          password: $('o-pass').value,
        }),
      });
      operators(main);
    };
  }

  function table(headers, rows) {
    return (
      '<table><thead><tr>' +
      headers.map(function (h) {
        return '<th>' + h + '</th>';
      }).join('') +
      '</tr></thead><tbody>' +
      (rows.length
        ? rows
            .map(function (row) {
              return (
                '<tr>' +
                row
                  .map(function (cell) {
                    return '<td>' + cell + '</td>';
                  })
                  .join('') +
                '</tr>'
              );
            })
            .join('')
        : '<tr><td colspan="' + headers.length + '">None yet</td></tr>') +
      '</tbody></table>'
    );
  }

  function esc(value) {
    return String(value == null ? '' : value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/"/g, '&quot;');
  }

  boot();
})();
