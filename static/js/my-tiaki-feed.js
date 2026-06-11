/* ════════════════════════════════════════════════════════════
   my-tiaki-feed.js — feed tab filtering on /my-tiaki
   The feed is fully server-rendered; this only toggles card
   visibility per the selected tab (all / catch / bait / mine).
   ════════════════════════════════════════════════════════════ */
(function () {
  "use strict";

  var tabs = document.querySelectorAll(".feed-tabs .feed-tab");
  var feed = document.getElementById("feedList");
  if (!tabs.length || !feed) return; // empty-membership / empty-feed render

  var cards = feed.querySelectorAll("li.feed-card");
  var filterEmpty = document.getElementById("feedFilterEmpty");

  function applyFilter(filter) {
    var visible = 0;
    cards.forEach(function (card) {
      var show = filter === "all"
        || (filter === "mine" && card.dataset.mine === "1")
        || card.dataset.kind === filter;
      card.hidden = !show;
      if (show) visible++;
    });
    if (filterEmpty) filterEmpty.hidden = visible > 0;
  }

  tabs.forEach(function (tab) {
    tab.addEventListener("click", function () {
      tabs.forEach(function (t) {
        var active = t === tab;
        t.classList.toggle("is-active", active);
        t.setAttribute("aria-selected", active ? "true" : "false");
      });
      applyFilter(tab.dataset.filter);
    });
  });
})();
