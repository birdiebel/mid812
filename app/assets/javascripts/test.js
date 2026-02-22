function initMenuButtons() {
  const $buttons = $(".menu-event-button")
  if ($buttons.length === 0) return

  const callMenu = $buttons.parent().attr("name")
  let sections = []

  if (callMenu == "event-menu") {
    sections = ["#event-entries", "#rounds", "#courses", "#player-categories", "#event-status", "#event-details"]
  }
  if (callMenu == "round-menu") {
    sections = [ "#config-times", "#scores-round", "#status", "#round-details"]
  }

  if (sections.length === 0) return

  function normalizeMenuTarget(rawTarget) {
    if (!rawTarget) return null

    const aliases = {
      config_times: "config-times",
      config_teetime: "config-times",
      round_details: "round-details",
      scores_round: "scores-round",
      event_entries: "event-entries",
      player_categories: "player-categories",
      event_status: "event-status",
      event_details: "event-details"
    }

    let target = String(rawTarget).trim().replace(/^#/, "")
    target = aliases[target] || target.replace(/_/g, "-")
    return `#${target}`
  }

  function showSection(target) {
    sections.forEach((selector) => {
      if (selector === target) {
        $(selector).removeAttr("hidden").css("display", "block")
      } else {
        $(selector).attr("hidden", true).css("display", "none")
      }
    })
  }

  function setActive(target) {
    $buttons.removeClass("is-active")
    $buttons.filter(`[data-target="${target}"]`).addClass("is-active")
  }

  $buttons.off("click.menu").on("click.menu", function (event) {
    const target = $(this).data("target")
    if (!target) return

    event.preventDefault()

    showSection(target)
    setActive(target)
  })

  // Check if there's a hash in the URL, otherwise use the first section
  let initial = sections[0]

  const pageCall =
    $("#round_menu_page_call").data("page_call") ||
    $("#event_menu_page_call").data("page_call")
  const pageCallTarget = normalizeMenuTarget(pageCall)

  if (pageCallTarget && sections.includes(pageCallTarget)) {
    initial = pageCallTarget
  }
  
  if (window.location.hash && sections.includes(window.location.hash)) {
    initial = window.location.hash
  }
  
  showSection(initial)
  setActive(initial)
}

$(document).ready(initMenuButtons)
$(document).on("turbo:load", initMenuButtons)

// Filter playercats checkboxes by event format
$(document).ready(function() {
  // console.log('=== Playercats filter starting ===');
  
  // Try multiple selectors to find the format select
  let $formatSelect = $('select[id*="format"]');
  
  if ($formatSelect.length === 0) {
    $formatSelect = $('select[name*="format"]');
  }
  
  if ($formatSelect.length === 0) {
    const $formatLabel = $('label').filter(function() {
      return $(this).text().toLowerCase().includes('format');
    });
    $formatSelect = $formatLabel.next('select');
    if ($formatSelect.length === 0) {
      $formatSelect = $formatLabel.siblings('select');
    }
  }
  
  // console.log('Format select found:', $formatSelect.length, $formatSelect.attr('id'));
  
  // Find playercats checkboxes with data-format attribute
  const $playercatsCheckboxes = $('input[type="checkbox"][data-format]');
  // console.log('Playercats checkboxes found:', $playercatsCheckboxes.length);
  
  if ($formatSelect.length === 0 || $playercatsCheckboxes.length === 0) {
    // console.log('Early return - missing select or checkboxes. Select:', $formatSelect.length, 'Checkboxes:', $playercatsCheckboxes.length);
    return;
  }
  
  function filterPlayercats() {
    const selectedFormat = $formatSelect.val();
    // console.log('Filtering by format:', selectedFormat);
    
    $playercatsCheckboxes.each(function() {
      const $checkbox = $(this);
      const $label = $checkbox.closest('label');
      const pcFormat = $checkbox.attr('data-format');
      
      // console.log('Checking playercat format:', pcFormat, 'vs selected event format:', selectedFormat);
      
      if (selectedFormat && pcFormat && pcFormat !== selectedFormat) {
        $label.hide();
        $checkbox.prop('checked', false);
      } else {
        $label.show();
      }
    });
  }
  
  // Trigger filter on format change
  $formatSelect.on('change', filterPlayercats);
  
  // Initial filter when page loads
  filterPlayercats();
  // console.log('=== Playercats filter initialized ===');
})
