(function () {
  function ensureTooltip() {
    var tooltip = document.querySelector(".arbor-tooltip");

    if (!tooltip) {
      tooltip = document.createElement("div");
      tooltip.className = "arbor-tooltip";
      tooltip.setAttribute("role", "tooltip");
      document.body.appendChild(tooltip);
    }

    return tooltip;
  }

  function showTooltip(target) {
    var text = target.getAttribute("data-tooltip");

    if (!text) {
      return;
    }

    var tooltip = ensureTooltip();
    tooltip.textContent = text;
    tooltip.hidden = false;

    var rect = target.getBoundingClientRect();
    var tooltipRect = tooltip.getBoundingClientRect();
    var left = rect.left + rect.width / 2 - tooltipRect.width / 2;
    var top = rect.top - tooltipRect.height - 12;

    left = Math.max(12, Math.min(left, window.innerWidth - tooltipRect.width - 12));

    if (top < 12) {
      top = rect.bottom + 12;
      tooltip.classList.add("arbor-tooltip--below");
    } else {
      tooltip.classList.remove("arbor-tooltip--below");
    }

    tooltip.style.left = left + "px";
    tooltip.style.top = top + "px";
  }

  function hideTooltip() {
    var tooltip = document.querySelector(".arbor-tooltip");

    if (tooltip) {
      tooltip.hidden = true;
    }
  }

  document.addEventListener("mouseover", function (event) {
    var target = event.target.closest(".arbor-type-link");

    if (target) {
      showTooltip(target);
    }
  });

  document.addEventListener("mouseout", function (event) {
    if (event.target.closest(".arbor-type-link")) {
      hideTooltip();
    }
  });

  document.addEventListener("focusin", function (event) {
    var target = event.target.closest(".arbor-type-link");

    if (target) {
      showTooltip(target);
    }
  });

  document.addEventListener("focusout", function (event) {
    if (event.target.closest(".arbor-type-link")) {
      hideTooltip();
    }
  });

  window.addEventListener("scroll", hideTooltip, true);
  window.addEventListener("resize", hideTooltip);
})();
