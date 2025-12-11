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

ActiveRecord::Schema[8.0].define(version: 2025_12_10_082626) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "case_actions", force: :cascade do |t|
    t.bigint "dispute_id", null: false
    t.bigint "user_id", null: false
    t.string "action"
    t.text "note"
    t.jsonb "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dispute_id"], name: "index_case_actions_on_dispute_id"
    t.index ["user_id"], name: "index_case_actions_on_user_id"
  end

  create_table "charges", force: :cascade do |t|
    t.string "external_id"
    t.integer "amount_cents"
    t.string "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_charges_on_external_id", unique: true
  end

  create_table "disputes", force: :cascade do |t|
    t.bigint "charge_id", null: false
    t.string "external_id", null: false
    t.string "status"
    t.datetime "opened_at"
    t.datetime "closed_at"
    t.integer "amount_cents"
    t.string "currency"
    t.jsonb "external_payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["charge_id"], name: "index_disputes_on_charge_id"
    t.index ["external_id"], name: "index_disputes_on_external_id", unique: true
  end

  create_table "evidences", force: :cascade do |t|
    t.bigint "dispute_id", null: false
    t.string "kind"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dispute_id"], name: "index_evidences_on_dispute_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "role"
    t.string "time_zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "case_actions", "disputes"
  add_foreign_key "case_actions", "users"
  add_foreign_key "evidences", "disputes"
end
