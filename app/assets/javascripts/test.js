$(document).ready(function () {
  const $buttons = $(".menu-event-button")
  if ($buttons.length === 0) return

  CallMenu = $buttons.parent().attr("name")

  if (CallMenu == "event-menu") {
    sections = ["#entries", "#rounds", "#courses", "#player-categories", "#event-details"]
  }
  if (CallMenu == "round-menu") {
    sections = ["#start-list", "#scores", "#status", "#round-details"]
  }

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
