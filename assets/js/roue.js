/* AXION — Roue des métiers · logique d'interaction (vanilla) */
(function () {
  "use strict";
  var M = window.AXION_METIERS;
  var reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* ---------- util ---------- */
  function el(tag, cls, html) { var e = document.createElement(tag); if (cls) e.className = cls; if (html != null) e.innerHTML = html; return e; }
  function mix(hex, pct) { // hex over dark, returns rgba-ish via color-mix fallback
    return hex;
  }

  /* ---------- build wheel ---------- */
  var stage = document.getElementById("wheelStage");
  var nodesWrap = document.getElementById("nodes");
  var spokesWrap = document.getElementById("spokes");
  var R = 38; // svg radius units (matches viewBox 100)
  var Rp = 38; // percent radius for nodes

  function pos(i) {
    var a = (-90 + i * (360 / M.length)) * Math.PI / 180;
    return { x: 50 + Rp * Math.cos(a), y: 50 + Rp * Math.sin(a), sx: 50 + R * Math.cos(a), sy: 50 + R * Math.sin(a) };
  }

  M.forEach(function (m, i) {
    var p = pos(i);
    // spoke
    var ln = document.createElementNS("http://www.w3.org/2000/svg", "line");
    ln.setAttribute("class", "spoke pre");
    ln.setAttribute("x1", "50"); ln.setAttribute("y1", "50");
    ln.setAttribute("x2", p.sx); ln.setAttribute("y2", p.sy);
    ln.setAttribute("stroke", m.color);
    ln.style.opacity = ".35";
    ln.style.animationDelay = (0.2 + i * 0.05) + "s";
    ln.dataset.idx = i;
    spokesWrap.appendChild(ln);

    // node
    var node = el("button", "node pre");
    node.style.setProperty("--mc", m.color);
    node.style.left = p.x + "%";
    node.style.top = p.y + "%";
    node.style.animationDelay = (0.15 + i * 0.06) + "s";
    node.setAttribute("aria-label", m.name);
    node.dataset.idx = i;
    node.innerHTML =
      '<span class="disc"><svg viewBox="0 0 24 24">' + m.icon + '</svg></span>' +
      '<span class="lbl"><b>' + m.name + '</b><span>' + m.phase + '</span></span>';
    node.addEventListener("mouseenter", function () { hot(i, true); });
    node.addEventListener("mouseleave", function () { hot(i, false); });
    node.addEventListener("click", function () { openDrawer(i); });
    nodesWrap.appendChild(node);
  });

  var nodeEls = Array.prototype.slice.call(nodesWrap.children);
  var spokeEls = Array.prototype.slice.call(spokesWrap.children);

  function hot(i, on) {
    if (spokeEls[i]) {
      spokeEls[i].classList.toggle("hot", on);
      spokeEls[i].style.opacity = on ? "1" : ".35";
    }
  }

  /* ---------- entrance on scroll ---------- */
  var revealed = false;
  function fireWheel() {
    if (revealed) return;
    var r = stage.getBoundingClientRect();
    var vh = window.innerHeight || document.documentElement.clientHeight;
    if (r.top < vh * 0.82 && r.bottom > 0) {
      revealed = true;
      nodeEls.forEach(function (n) { n.classList.remove("pre"); n.classList.add("show"); });
      spokeEls.forEach(function (s) { s.classList.remove("pre"); s.classList.add("show"); });
      window.removeEventListener("scroll", fireWheel);
    }
  }
  if (reduce) {
    nodeEls.forEach(function (n) { n.classList.remove("pre"); });
    spokeEls.forEach(function (s) { s.classList.remove("pre"); });
    revealed = true;
  } else {
    window.addEventListener("scroll", fireWheel, { passive: true });
    fireWheel();
  }

  /* ---------- generic reveal-on-scroll ---------- */
  var reveals = Array.prototype.slice.call(document.querySelectorAll(".reveal"));
  reveals.forEach(function (e) { if (!reduce) e.classList.add("pre"); });
  function fireReveals() {
    var vh = window.innerHeight || document.documentElement.clientHeight;
    reveals.forEach(function (e) {
      if (e.classList.contains("in")) return;
      var r = e.getBoundingClientRect();
      if (r.top < vh * 0.88 && r.bottom > 0) { e.classList.remove("pre"); e.classList.add("in"); }
    });
  }
  if (!reduce) { window.addEventListener("scroll", fireReveals, { passive: true }); fireReveals(); }

  /* ---------- drawer ---------- */
  var scrim = document.getElementById("scrim");
  var drawer = document.getElementById("drawer");
  var current = null;

  function closeDrawer() {
    drawer.classList.remove("show");
    scrim.classList.remove("show");
    drawer.setAttribute("aria-hidden", "true");
    document.body.style.overflow = "";
    if (current != null) { nodeEls[current].classList.remove("active"); }
    nodeEls.forEach(function (n) { n.classList.remove("dim"); });
    spokeEls.forEach(function (s) { hotReset(s); });
    current = null;
  }
  function hotReset(s) { s.classList.remove("hot"); s.style.opacity = ".35"; }

  function openDrawer(i) {
    var m = M[i];
    current = i;
    nodeEls.forEach(function (n, j) { n.classList.toggle("dim", j !== i); n.classList.toggle("active", j === i); });
    spokeEls.forEach(function (s, j) { s.classList.toggle("hot", j === i); s.style.opacity = j === i ? "1" : ".15"; });

    var c = m.color;
    var soft = "color-mix(in srgb, " + c + " 12%, transparent)";
    var line = "color-mix(in srgb, " + c + " 38%, transparent)";
    drawer.innerHTML =
      '<div class="drawer-head">' +
        '<div class="glow" style="background:radial-gradient(circle,' + c + ',transparent 70%)"></div>' +
        '<button class="close" aria-label="Fermer" id="drawerClose"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 6l12 12M18 6 6 18" stroke-linecap="round"/></svg></button>' +
        '<span class="d-phase" style="color:' + c + ';background:' + soft + ';border:1px solid ' + line + '">Phase · ' + m.phase + '</span>' +
        '<div class="d-icon" style="background:' + soft + ';border:1px solid ' + line + '"><svg viewBox="0 0 24 24" style="stroke:' + c + '">' + m.icon + '</svg></div>' +
        '<h3>' + m.name + '</h3>' +
        '<div class="d-sub">' + m.subtitle + '</div>' +
      '</div>' +
      '<div class="drawer-body">' +
        '<p class="desc">' + m.desc + '</p>' +
        '<h4>Missions clés</h4>' +
        '<ul class="missions">' +
          m.missions.map(function (x) {
            return '<li><span class="ck" style="background:' + soft + ';border:1px solid ' + line + '"><svg viewBox="0 0 24 24" style="stroke:' + c + '"><path d="m5 12 5 5L20 6" stroke-linecap="round" stroke-linejoin="round"/></svg></span>' + x + '</li>';
          }).join("") +
        '</ul>' +
      '</div>' +
      '<div class="drawer-foot">' +
        '<a class="btn-azure" href="' + m.link + '">' +
          'Voir les entreprises' +
          '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 12h14M13 5l7 7-7 7" stroke-linecap="round" stroke-linejoin="round"/></svg>' +
        '</a>' +
        '<p class="hint">→ Annuaire AXION filtré sur ce métier</p>' +
      '</div>';

    drawer.classList.add("show");
    scrim.classList.add("show");
    drawer.setAttribute("aria-hidden", "false");
    document.body.style.overflow = "hidden";
    document.getElementById("drawerClose").addEventListener("click", closeDrawer);
  }

  scrim.addEventListener("click", closeDrawer);
  document.addEventListener("keydown", function (e) { if (e.key === "Escape") closeDrawer(); });

  /* ---------- demo firms (aperçu annuaire) ---------- */
  var firmsWrap = document.getElementById("demoFirms");
  if (firmsWrap) {
    function initials(n) { var p = (n || "").trim().split(/\s+/); return (((p[0] || "")[0] || "") + ((p[1] || "")[0] || "")).toUpperCase() || "?"; }
    (window.AXION_DEMO_FIRMS.entreprise || []).slice(0, 4).forEach(function (f) {
      var col = f.color;
      var card = el("div", "glass rounded-xl p-3");
      card.innerHTML =
        '<div class="flex items-start gap-2.5">' +
          '<div class="w-9 h-9 flex-none rounded-lg grid place-items-center font-display text-[12px]" style="background:' + col + '1f;border:1px solid ' + col + '55;color:' + col + '">' + initials(f.name) + '</div>' +
          '<div class="min-w-0 flex-1">' +
            '<div class="flex items-center gap-1.5"><span class="font-display text-white text-[13px] truncate min-w-0">' + f.name + '</span>' +
              (f.lot ? '<span class="chip font-mono flex-none" style="font-size:9px;padding:1px 7px;color:' + col + ';border-color:' + col + '55;background:' + col + '14">Lot ' + f.lot + '</span>' : '') +
            '</div>' +
            '<div class="text-[11px] mt-0.5" style="color:' + col + '">' + f.trade + '</div>' +
            '<div class="font-mono text-[9px] tracking-[0.12em] uppercase text-slate2-500 mt-1">' + f.ville + '</div>' +
          '</div>' +
        '</div>';
      firmsWrap.appendChild(card);
    });
  }
})();
