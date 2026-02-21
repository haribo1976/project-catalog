(function () {
  var cards = Array.from(document.querySelectorAll(".project-card"));
  var searchInput = document.getElementById("search");
  var resultsCount = document.getElementById("results-count");

  var activeDomain = "all";
  var activeCategory = "all";
  var searchTerm = "";

  function applyFilters() {
    var visible = 0;
    cards.forEach(function (card) {
      var matchDomain = activeDomain === "all" || card.dataset.domain === activeDomain;
      var matchCategory = activeCategory === "all" || card.dataset.category === activeCategory;
      var matchSearch = !searchTerm ||
        card.dataset.name.includes(searchTerm) ||
        card.dataset.description.includes(searchTerm);
      var show = matchDomain && matchCategory && matchSearch;
      card.hidden = !show;
      if (show) visible++;
    });
    resultsCount.textContent = visible === cards.length
      ? "Showing all " + visible + " projects"
      : "Showing " + visible + " of " + cards.length + " projects";
  }

  document.querySelectorAll(".filter-pills").forEach(function (group) {
    group.addEventListener("click", function (e) {
      var pill = e.target.closest(".pill");
      if (!pill) return;
      group.querySelectorAll(".pill").forEach(function (p) {
        p.classList.remove("active");
      });
      pill.classList.add("active");

      if (pill.dataset.filterDomain !== undefined) {
        activeDomain = pill.dataset.filterDomain;
      } else if (pill.dataset.filterCategory !== undefined) {
        activeCategory = pill.dataset.filterCategory;
      }
      applyFilters();
    });
  });

  searchInput.addEventListener("input", function () {
    searchTerm = searchInput.value.toLowerCase().trim();
    applyFilters();
  });

  applyFilters();
})();
