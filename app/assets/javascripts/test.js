$(document).ready(function () {
  const $buttons = $(".menu-event-button")
  if ($buttons.length === 0) return

  CallMenu = $buttons.parent().attr("name")

  if (CallMenu == "event-menu") {
    sections = ["#event-entries", "#rounds", "#courses", "#player-categories", "#event-status", "#event-details"]
  }
  if (CallMenu == "round-menu") {
    sections = [ "#config-times", "#start-list", "#scores", "#status", "#round-details"]
  }

  function showSection(target) {
    sections.forEach((selector) => {
      if (selector === target) {
        $(selector).css('display', 'block')
      } else {
        $(selector).css('display', 'none')
      }
    })
  }

  function setActive(target) {
    $buttons.removeClass("is-active")
    $buttons.filter(`[data-target="${target}"]`).addClass("is-active")
  }

  $buttons.on("click", function (event) {
    event.preventDefault()
    const target = $(this).data("target")
    if (!target) return

    showSection(target)
    setActive(target)
  })

  // Check if there's a hash in the URL, otherwise use the first section
  let initial = sections[0]
  
  if (window.location.hash && sections.includes(window.location.hash)) {
    initial = window.location.hash
  }
  
  showSection(initial)
  setActive(initial)
})

// Filter playercats checkboxes by event format
$(document).ready(function() {
  console.log('=== Playercats filter starting ===');
  
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
  
  console.log('Format select found:', $formatSelect.length, $formatSelect.attr('id'));
  
  // Find playercats checkboxes with data-format attribute
  const $playercatsCheckboxes = $('input[type="checkbox"][data-format]');
  console.log('Playercats checkboxes found:', $playercatsCheckboxes.length);
  
  if ($formatSelect.length === 0 || $playercatsCheckboxes.length === 0) {
    console.log('Early return - missing select or checkboxes. Select:', $formatSelect.length, 'Checkboxes:', $playercatsCheckboxes.length);
    return;
  }
  
  function filterPlayercats() {
    const selectedFormat = $formatSelect.val();
    console.log('Filtering by format:', selectedFormat);
    
    $playercatsCheckboxes.each(function() {
      const $checkbox = $(this);
      const $label = $checkbox.closest('label');
      const pcFormat = $checkbox.attr('data-format');
      
      console.log('Checking playercat format:', pcFormat, 'vs selected event format:', selectedFormat);
      
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
  console.log('=== Playercats filter initialized ===');
})
