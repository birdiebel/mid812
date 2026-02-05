# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_05_033712) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.string "namespace"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "agecats", force: :cascade do |t|
    t.integer "age_high", default: 99
    t.integer "age_low", default: 0
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "short", null: false
    t.datetime "updated_at", null: false
    t.integer "year", default: 2026
  end

  create_table "agecats_playercats", id: false, force: :cascade do |t|
    t.bigint "agecat_id", null: false
    t.bigint "playercat_id", null: false
  end

  create_table "agecats_resultcats", id: false, force: :cascade do |t|
    t.bigint "agecat_id", null: false
    t.bigint "resultcat_id", null: false
    t.index ["agecat_id", "resultcat_id"], name: "index_agecats_resultcats_on_agecat_id_and_resultcat_id"
    t.index ["resultcat_id", "agecat_id"], name: "index_agecats_resultcats_on_resultcat_id_and_agecat_id"
  end

  create_table "clubs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_clubs_on_name", unique: true
  end

  create_table "config_teetimes", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.bigint "formula_id"
    t.integer "hcp_pc"
    t.integer "nb_slots"
    t.integer "nb_teams"
    t.bigint "round_id", null: false
    t.integer "start_hole"
    t.time "start_time", default: "2000-01-01 08:00:00"
    t.integer "step", default: 10
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_config_teetimes_on_course_id"
    t.index ["formula_id"], name: "index_config_teetimes_on_formula_id"
    t.index ["round_id"], name: "index_config_teetimes_on_round_id"
  end

  create_table "courses", force: :cascade do |t|
    t.bigint "club_id"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "nb_hole", default: 18, null: false
    t.datetime "updated_at", null: false
    t.string "version", null: false
    t.index ["club_id"], name: "index_courses_on_club_id"
    t.index ["name"], name: "index_courses_on_name", unique: true
  end

  create_table "courses_events", id: false, force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "event_id"], name: "index_courses_events_on_course_id_and_event_id"
    t.index ["event_id", "course_id"], name: "index_courses_events_on_event_id_and_course_id"
  end

  create_table "entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.decimal "hcp", precision: 3, scale: 1
    t.bigint "licence_id"
    t.bigint "player_id", null: false
    t.bigint "playercat_id"
    t.integer "playing_hcp"
    t.integer "status", default: 0, null: false
    t.bigint "team_id"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_entries_on_event_id"
    t.index ["licence_id"], name: "index_entries_on_licence_id"
    t.index ["player_id"], name: "index_entries_on_player_id"
    t.index ["playercat_id"], name: "index_entries_on_playercat_id"
    t.index ["team_id"], name: "index_entries_on_team_id"
  end

  create_table "events", force: :cascade do |t|
    t.boolean "actif", default: true
    t.integer "actif_round"
    t.datetime "created_at", null: false
    t.date "date_close", default: -> { "CURRENT_DATE" }
    t.date "date_event", default: -> { "CURRENT_DATE" }
    t.date "date_open", default: -> { "CURRENT_DATE" }
    t.decimal "fee", precision: 8, scale: 2
    t.decimal "fee_member", precision: 8, scale: 2
    t.integer "format", default: 0
    t.integer "max_players", default: 1
    t.integer "min_players", default: 1
    t.string "name", null: false
    t.integer "nb_rounds", default: 1
    t.integer "scoring", default: 0
    t.integer "status", default: 0
    t.bigint "tour_id"
    t.datetime "updated_at", null: false
    t.index ["tour_id"], name: "index_events_on_tour_id"
  end

  create_table "events_playercats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.bigint "playercat_id", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "playercat_id"], name: "index_events_playercats_on_event_id_and_playercat_id", unique: true
    t.index ["event_id"], name: "index_events_playercats_on_event_id"
    t.index ["playercat_id"], name: "index_events_playercats_on_playercat_id"
  end

  create_table "events_resultcats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.bigint "resultcat_id", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "resultcat_id"], name: "index_events_resultcats_on_event_id_and_resultcat_id", unique: true
    t.index ["event_id"], name: "index_events_resultcats_on_event_id"
    t.index ["resultcat_id"], name: "index_events_resultcats_on_resultcat_id"
  end

  create_table "events_teamcats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.bigint "teamcat_id", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_events_teamcats_on_event_id"
    t.index ["teamcat_id"], name: "index_events_teamcats_on_teamcat_id"
  end

  create_table "flights", force: :cascade do |t|
    t.bigint "config_teetime_id", null: false
    t.datetime "created_at", null: false
    t.integer "num"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["config_teetime_id"], name: "index_flights_on_config_teetime_id"
  end

  create_table "formulas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "format", default: 0
    t.integer "max_players", default: 1
    t.integer "min_players", default: 1
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "licences", force: :cascade do |t|
    t.boolean "actif", default: true
    t.string "club"
    t.datetime "created_at", null: false
    t.decimal "hcp", precision: 3, scale: 1
    t.string "num"
    t.bigint "player_id"
    t.datetime "updated_at", null: false
    t.index ["num"], name: "index_licences_on_num", unique: true
    t.index ["player_id"], name: "index_licences_on_player_id"
  end

  create_table "playercats", force: :cascade do |t|
    t.boolean "actif", default: true
    t.datetime "created_at", null: false
    t.integer "format", default: 0
    t.decimal "hcp_max", precision: 3, scale: 1
    t.decimal "hcp_min", precision: 3, scale: 1
    t.string "name", null: false
    t.integer "priority", default: 0
    t.integer "sexe", default: 0
    t.integer "teebox", default: 0
    t.datetime "updated_at", null: false
    t.string "version", null: false
  end

  create_table "playercats_teamcats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "playercat_id", null: false
    t.bigint "teamcat_id", null: false
    t.datetime "updated_at", null: false
    t.index ["playercat_id"], name: "index_playercats_teamcats_on_playercat_id"
    t.index ["teamcat_id"], name: "index_playercats_teamcats_on_teamcat_id"
  end

  create_table "players", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "dob", default: "1970-01-01", null: false
    t.string "firstname", null: false
    t.integer "lang", default: 0
    t.string "lastname", null: false
    t.integer "sexe", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "resultcats", force: :cascade do |t|
    t.boolean "actif", default: true
    t.datetime "created_at", null: false
    t.decimal "hcp_max", precision: 3, scale: 1
    t.decimal "hcp_min", precision: 3, scale: 1
    t.string "name", null: false
    t.integer "priority", default: 0
    t.integer "scoring", default: 0
    t.integer "sexe", default: 0
    t.datetime "updated_at", null: false
    t.string "version", null: false
  end

  create_table "rounds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.bigint "event_id", null: false
    t.integer "hcp_pc", default: 100
    t.integer "num"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_rounds_on_event_id"
    t.check_constraint "hcp_pc >= 0 AND hcp_pc <= 100", name: "hcp_pc_range"
  end

  create_table "scores", force: :cascade do |t|
    t.string "brut_str"
    t.datetime "created_at", null: false
    t.bigint "entry_id", null: false
    t.integer "hole_played"
    t.string "net_str"
    t.string "recu_str"
    t.bigint "round_id", null: false
    t.bigint "slot_id", null: false
    t.integer "start_hole"
    t.integer "status"
    t.string "stb_str"
    t.datetime "updated_at", null: false
    t.index ["entry_id"], name: "index_scores_on_entry_id"
    t.index ["round_id"], name: "index_scores_on_round_id"
    t.index ["slot_id"], name: "index_scores_on_slot_id"
  end

  create_table "slots", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "flight_id", null: false
    t.integer "num"
    t.decimal "playing_hcp", precision: 4, scale: 1
    t.bigint "team_id"
    t.datetime "updated_at", null: false
    t.index ["flight_id"], name: "index_slots_on_flight_id"
    t.index ["team_id"], name: "index_slots_on_team_id"
  end

  create_table "teamcats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "scoring"
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.string "name", null: false
    t.integer "num"
    t.bigint "resultcat_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "num"], name: "index_teams_on_event_id_and_num", unique: true
    t.index ["event_id"], name: "index_teams_on_event_id"
    t.index ["resultcat_id"], name: "index_teams_on_resultcat_id"
  end

  create_table "tees", force: :cascade do |t|
    t.bigint "course_id"
    t.datetime "created_at", null: false
    t.string "dist_str", null: false
    t.string "par_str", null: false
    t.decimal "rating", precision: 3, scale: 1, default: "72.0"
    t.integer "slope", default: 121, null: false
    t.string "stroke_str", null: false
    t.integer "teebox", default: 1
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_tees_on_course_id"
  end

  create_table "tours", force: :cascade do |t|
    t.boolean "actif", default: true
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.integer "year", default: 2026, null: false
  end

  create_table "users", force: :cascade do |t|
    t.boolean "actif", default: true
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "config_teetimes", "courses"
  add_foreign_key "config_teetimes", "formulas"
  add_foreign_key "config_teetimes", "rounds"
  add_foreign_key "entries", "events"
  add_foreign_key "entries", "playercats"
  add_foreign_key "entries", "players"
  add_foreign_key "entries", "teams", on_delete: :cascade
  add_foreign_key "events_playercats", "events"
  add_foreign_key "events_playercats", "playercats"
  add_foreign_key "events_resultcats", "events"
  add_foreign_key "events_resultcats", "resultcats"
  add_foreign_key "events_teamcats", "events"
  add_foreign_key "events_teamcats", "teamcats"
  add_foreign_key "flights", "config_teetimes"
  add_foreign_key "playercats_teamcats", "playercats"
  add_foreign_key "playercats_teamcats", "teamcats"
  add_foreign_key "rounds", "events"
  add_foreign_key "scores", "entries"
  add_foreign_key "scores", "rounds"
  add_foreign_key "scores", "slots"
  add_foreign_key "slots", "flights"
  add_foreign_key "slots", "teams"
  add_foreign_key "teams", "events"
  add_foreign_key "teams", "resultcats"
end
