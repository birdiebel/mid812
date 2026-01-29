$(document).ready(function () {
  const $buttons = $(".menu-event-button")
  if ($buttons.length === 0) return

  const sections = ["#entries", "#rounds", "#player-categories", "#event-details"]

  function showSection(target) {
    sections.forEach((selector) => {
      if (selector === target) {
        $(selector).show()
      } else {
        $(selector).hide()
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

  const initial = sections.find((selector) => $(selector).is(":visible")) || sections[0]
  showSection(initial)
  setActive(initial)
})
