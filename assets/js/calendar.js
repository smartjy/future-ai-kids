// 수업 달력 (/calendar/): 주·월·년 보기, 이전·다음, 공휴일 표시
// 데이터는 layouts/calendar.html이 #fk-cal-data에 넣는다. 글 제목 등은 모두 textContent로만 넣는다.
(function () {
  'use strict';

  var root = document.getElementById('fk-cal');
  var dataEl = document.getElementById('fk-cal-data');
  if (!root || !dataEl) return;

  var data = {};
  try { data = JSON.parse(dataEl.textContent) || {}; } catch (e) { data = {}; }
  var posts = data.posts || [];
  var byDay = {};
  posts.forEach(function (p) { (byDay[p.d] = byDay[p.d] || []).push(p); });
  var holiday = {};
  (data.holidays || []).forEach(function (h) { holiday[h.d] = h.n; });

  var WD = ['일', '월', '화', '수', '목', '금', '토'];
  var UNIT = { week: '주', month: '달', year: '해' };
  var now = new Date();
  var today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

  // 보던 보기·날짜는 이 탭에서만 기억한다 (글을 보고 돌아왔을 때 그대로)
  var view = 'month';
  var cur = new Date(today);
  try {
    var saved = JSON.parse(sessionStorage.getItem('fk-cal') || 'null');
    if (saved && UNIT[saved.v] && /^\d{4}-\d{2}-\d{2}$/.test(saved.d)) {
      view = saved.v;
      cur = parse(saved.d);
    }
  } catch (e) { /* 저장소를 못 쓰면 이번 달부터 */ }

  var titleEl = root.querySelector('.fk-cal-title');
  var body = root.querySelector('.fk-cal-body');

  function pad(n) { return (n < 10 ? '0' : '') + n; }
  function key(d) { return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate()); }
  function parse(s) { var a = s.split('-'); return new Date(+a[0], +a[1] - 1, +a[2]); }
  function addDays(d, n) { return new Date(d.getFullYear(), d.getMonth(), d.getDate() + n); }
  function same(a, b) { return a.getTime() === b.getTime(); }

  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
  }
  function dot(colour) {
    var s = el('span', 'fk-dot fk-' + colour);
    s.setAttribute('aria-hidden', 'true');
    return s;
  }
  function names(p) { return p.t.map(function (t) { return t.n; }).join(', '); }
  function md(d) { return (d.getMonth() + 1) + '월 ' + d.getDate() + '일'; }

  // ── 날짜 칸 ──
  function dayCell(d, opts) {
    var k = key(d);
    var list = byDay[k] || [];
    var hol = holiday[k];
    var cls = 'fk-cal-day';
    if (list.length) cls += ' fk-cal-has';
    if (hol || d.getDay() === 0) cls += ' fk-cal-red';
    if (same(d, today)) cls += ' fk-cal-today';
    if (opts.dim) cls += ' fk-cal-dim';
    var c = el('div', cls);
    c.setAttribute('role', 'gridcell');

    var head = el('div', 'fk-cal-dayhead');
    if (opts.weekday) head.appendChild(el('span', 'fk-cal-wdl', WD[d.getDay()]));
    var num = el('span', 'fk-cal-num', String(d.getDate()));
    if (same(d, today)) num.setAttribute('aria-label', '오늘 ' + d.getDate() + '일');
    head.appendChild(num);
    if (hol) head.appendChild(el('span', 'fk-cal-hol', hol));
    c.appendChild(head);

    list.forEach(function (p) {
      var a = el('a', 'fk-cal-link');
      a.href = p.url;
      a.setAttribute('aria-label', md(d) + ' ' + names(p) + ': ' + p.title);
      var row = el('span', 'fk-cal-teams');
      p.t.forEach(function (t) { row.appendChild(dot(t.c)); });
      row.appendChild(el('span', 'fk-cal-team', names(p)));
      a.appendChild(row);
      if (opts.titles) a.appendChild(el('span', 'fk-cal-ptitle', p.title));
      c.appendChild(a);
    });
    return c;
  }

  function headRow() {
    var r = el('div', 'fk-cal-row fk-cal-head');
    r.setAttribute('role', 'row');
    WD.forEach(function (w, i) {
      var s = el('span', 'fk-cal-wd' + (i === 0 ? ' fk-cal-red' : ''), w);
      s.setAttribute('role', 'columnheader');
      r.appendChild(s);
    });
    return r;
  }

  function grid(extra) {
    var g = el('div', 'fk-cal-grid' + (extra ? ' ' + extra : ''));
    g.setAttribute('role', 'grid');
    return g;
  }

  // ── 아래 목록 (기간 안의 수업) ──
  function postList(from, to) {
    var a = key(from), b = key(to);
    var items = posts.filter(function (p) { return p.d >= a && p.d <= b; });
    if (!items.length) return el('p', 'fk-cal-empty', '이 기간에는 수업 기록이 없어요.');
    var ul = el('ul', 'fk-cal-list');
    items.forEach(function (p) {
      var li = el('li');
      var link = el('a');
      link.href = p.url;
      link.appendChild(el('span', 'fk-cal-list-date', md(parse(p.d))));
      p.t.forEach(function (t) {
        var s = el('span', 'fk-cal-list-team');
        s.appendChild(dot(t.c));
        s.appendChild(document.createTextNode(t.n));
        link.appendChild(s);
      });
      link.appendChild(el('span', 'fk-cal-list-title', p.title));
      li.appendChild(link);
      ul.appendChild(li);
    });
    return ul;
  }

  // ── 보기 ──
  function renderMonth() {
    var y = cur.getFullYear(), m = cur.getMonth();
    var first = new Date(y, m, 1), last = new Date(y, m + 1, 0);
    titleEl.textContent = y + '년 ' + (m + 1) + '월';
    var g = grid('fk-cal-monthgrid');
    g.setAttribute('aria-label', titleEl.textContent);
    g.appendChild(headRow());
    var start = addDays(first, -first.getDay());
    var rows = Math.ceil((first.getDay() + last.getDate()) / 7);
    for (var r = 0; r < rows; r++) {
      var row = el('div', 'fk-cal-row');
      row.setAttribute('role', 'row');
      for (var c = 0; c < 7; c++) {
        var d = addDays(start, r * 7 + c);
        if (d.getMonth() !== m) {
          var b = el('div', 'fk-cal-day fk-cal-blank');
          b.setAttribute('role', 'gridcell');
          row.appendChild(b);
        } else {
          row.appendChild(dayCell(d, {}));
        }
      }
      g.appendChild(row);
    }
    body.appendChild(g);
    body.appendChild(postList(first, last));
  }

  function renderWeek() {
    var start = addDays(cur, -cur.getDay()), end = addDays(start, 6);
    var t = start.getFullYear() + '년 ' + md(start) + ' – ';
    if (end.getFullYear() !== start.getFullYear()) t += end.getFullYear() + '년 ';
    titleEl.textContent = t + (end.getMonth() === start.getMonth() ? end.getDate() + '일' : md(end));
    var g = grid('fk-cal-weekgrid');
    g.setAttribute('aria-label', titleEl.textContent);
    g.appendChild(headRow());
    var row = el('div', 'fk-cal-row');
    row.setAttribute('role', 'row');
    for (var i = 0; i < 7; i++) row.appendChild(dayCell(addDays(start, i), { weekday: true, titles: true }));
    g.appendChild(row);
    body.appendChild(g);
    body.appendChild(postList(start, end));
  }

  function renderYear() {
    var y = cur.getFullYear();
    titleEl.textContent = y + '년';
    var wrap = el('div', 'fk-cal-year');
    for (var m = 0; m < 12; m++) {
      var first = new Date(y, m, 1), last = new Date(y, m + 1, 0);
      var count = posts.filter(function (p) { return p.d >= key(first) && p.d <= key(last); }).length;
      var sec = el('section', 'fk-cal-mini');
      var btn = el('button', 'fk-cal-mini-title');
      btn.type = 'button';
      btn.appendChild(el('span', null, (m + 1) + '월'));
      if (count) btn.appendChild(el('span', 'fk-cal-mini-count', '수업 ' + count));
      btn.setAttribute('aria-label', (m + 1) + '월 달력 보기' + (count ? ', 수업 ' + count + '번' : ''));
      btn.dataset.month = String(m);
      sec.appendChild(btn);
      var g = grid('fk-cal-minigrid');
      g.setAttribute('aria-label', y + '년 ' + (m + 1) + '월');
      g.appendChild(headRow());
      var start = addDays(first, -first.getDay());
      var rows = Math.ceil((first.getDay() + last.getDate()) / 7);
      for (var r = 0; r < rows; r++) {
        var row = el('div', 'fk-cal-row');
        row.setAttribute('role', 'row');
        for (var c = 0; c < 7; c++) {
          var d = addDays(start, r * 7 + c);
          var k = key(d);
          if (d.getMonth() !== m) {
            var b = el('span', 'fk-cal-mday fk-cal-blank');
            b.setAttribute('role', 'gridcell');
            row.appendChild(b);
            continue;
          }
          var list = byDay[k] || [];
          var cls = 'fk-cal-mday';
          if (holiday[k] || d.getDay() === 0) cls += ' fk-cal-red';
          if (list.length) cls += ' fk-cal-has';
          if (same(d, today)) cls += ' fk-cal-today';
          var cell = el('span', cls);
          cell.setAttribute('role', 'gridcell');
          cell.appendChild(el('span', 'fk-cal-num', String(d.getDate())));
          var label = [];
          if (holiday[k]) label.push(holiday[k]);
          if (list.length) {
            var ds = el('span', 'fk-cal-mdots');
            list.forEach(function (p) {
              p.t.forEach(function (t) { ds.appendChild(dot(t.c)); });
              label.push(names(p) + ' 수업');
            });
            cell.appendChild(ds);
          }
          if (label.length) {
            cell.title = label.join(', ');
            cell.setAttribute('aria-label', md(d) + ' ' + label.join(', '));
          }
          row.appendChild(cell);
        }
        g.appendChild(row);
      }
      sec.appendChild(g);
      wrap.appendChild(sec);
    }
    body.appendChild(wrap);
  }

  function render() {
    body.textContent = '';
    if (view === 'week') renderWeek();
    else if (view === 'year') renderYear();
    else renderMonth();
    root.querySelectorAll('[data-view]').forEach(function (b) {
      b.setAttribute('aria-pressed', String(b.dataset.view === view));
    });
    root.querySelectorAll('[data-nav="-1"]').forEach(function (b) { b.setAttribute('aria-label', '이전 ' + UNIT[view]); });
    root.querySelectorAll('[data-nav="1"]').forEach(function (b) { b.setAttribute('aria-label', '다음 ' + UNIT[view]); });
    try { sessionStorage.setItem('fk-cal', JSON.stringify({ v: view, d: key(cur) })); } catch (e) { /* 무시 */ }
  }

  function go(dir) {
    if (dir === 0) cur = new Date(today);
    else if (view === 'week') cur = addDays(cur, 7 * dir);
    else if (view === 'year') cur = new Date(cur.getFullYear() + dir, cur.getMonth(), 1);
    else cur = new Date(cur.getFullYear(), cur.getMonth() + dir, 1);
    render();
  }

  // 다른 보기로 바꿀 때: 보던 기간 안에 오늘이 있으면 오늘을 기준으로
  function setView(v) {
    if (!UNIT[v] || v === view) return;
    if (cur.getFullYear() === today.getFullYear() && (view === 'year' || cur.getMonth() === today.getMonth())) cur = new Date(today);
    view = v;
    render();
  }

  root.addEventListener('click', function (e) {
    var t = e.target.closest('button');
    if (!t || !root.contains(t)) return;
    if (t.dataset.nav != null) go(+t.dataset.nav);
    else if (t.dataset.view) setView(t.dataset.view);
    else if (t.dataset.month != null) {
      cur = new Date(cur.getFullYear(), +t.dataset.month, 1);
      view = 'month';
      render();
      titleEl.focus({ preventScroll: true });
    }
  });

  document.addEventListener('keydown', function (e) {
    if (e.defaultPrevented || e.altKey || e.ctrlKey || e.metaKey || e.shiftKey) return;
    var t = e.target;
    if (t && (t.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(t.tagName))) return;
    if (e.key === 'ArrowLeft') { e.preventDefault(); go(-1); }
    else if (e.key === 'ArrowRight') { e.preventDefault(); go(1); }
  });

  titleEl.tabIndex = -1;
  root.hidden = false;
  document.documentElement.classList.add('fk-cal-js');
  render();
})();
