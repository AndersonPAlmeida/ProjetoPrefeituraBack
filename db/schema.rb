# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160901141211) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "provider",               default: "cpf", null: false
    t.string   "uid",                    default: "",    null: false
    t.json     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree
    t.index ["uid"], name: "index_accounts_on_uid", unique: true, using: :btree
  end

  create_table "accounts_service_places", id: false, force: :cascade do |t|
    t.integer "account_id",       null: false
    t.integer "service_place_id", null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string   "ibge_code",  null: false
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "state_id"
    t.index ["state_id"], name: "index_cities_on_state_id", using: :btree
  end

  create_table "citizens", force: :cascade do |t|
    t.date     "birth_date"
    t.string   "name"
    t.string   "rg"
    t.string   "address_complement"
    t.string   "address_number"
    t.string   "address_street"
    t.string   "cep"
    t.string   "cpf"
    t.string   "email"
    t.string   "neighborhood"
    t.string   "note"
    t.string   "pcd"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "photo_content_type"
    t.string   "photo_file_name"
    t.integer  "photo_file_size"
    t.datetime "photo_update_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "account_id"
    t.boolean  "active"
    t.index ["account_id"], name: "index_citizens_on_account_id", using: :btree
  end

  create_table "city_halls", force: :cascade do |t|
    t.integer  "city_id"
    t.boolean  "active"
    t.string   "address_number",     limit: 10,                null: false
    t.string   "address_street",                               null: false
    t.text     "block_text",                                   null: false
    t.string   "cep",                limit: 10,                null: false
    t.boolean  "citizen_access",                default: true, null: false
    t.boolean  "citizen_register",              default: true, null: false
    t.string   "name",                                         null: false
    t.string   "neighborhood",                                 null: false
    t.integer  "previous_notice",               default: 48,   null: false
    t.integer  "schedule_period",               default: 90,   null: false
    t.string   "address_complement"
    t.text     "description"
    t.string   "email"
    t.string   "logo_content_type"
    t.string   "logo_file_name"
    t.integer  "logo_file_size"
    t.date     "logo_updated_at"
    t.string   "phone1",             limit: 14
    t.string   "phone2",             limit: 14
    t.string   "support_email"
    t.boolean  "show_professional"
    t.string   "url"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  create_table "professionals", force: :cascade do |t|
    t.string   "registration"
    t.boolean  "active",       default: true, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "account_id"
    t.index ["account_id"], name: "index_professionals_on_account_id", using: :btree
  end

  create_table "professionals_service_places", id: false, force: :cascade do |t|
    t.integer "professional_id",                 null: false
    t.integer "service_place_id",                null: false
    t.string  "role",                            null: false
    t.boolean "active",           default: true, null: false
  end

  create_table "service_places", force: :cascade do |t|
    t.string   "name",                                         null: false
    t.string   "cep",                limit: 10
    t.string   "neighborhood",                                 null: false
    t.string   "address_street",                               null: false
    t.string   "address_number",     limit: 10,                null: false
    t.string   "address_complement"
    t.string   "phone1",             limit: 13
    t.string   "phone2",             limit: 13
    t.string   "email"
    t.string   "url"
    t.boolean  "active",                        default: true, null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "city_hall_id"
    t.index ["city_hall_id"], name: "index_service_places_on_city_hall_id", using: :btree
  end

  create_table "states", force: :cascade do |t|
    t.string   "abbreviation", limit: 2, null: false
    t.string   "ibge_code",              null: false
    t.string   "name",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_foreign_key "cities", "states"
  add_foreign_key "citizens", "accounts"
end
