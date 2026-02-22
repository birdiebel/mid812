// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { createConsumer } from "@rails/actioncable"
import "@hotwired/turbo-rails"
import "controllers"
// import "admin/start_list_drag_drop"

window.App = window.App || {}
window.App.cable = window.App.cable || createConsumer()