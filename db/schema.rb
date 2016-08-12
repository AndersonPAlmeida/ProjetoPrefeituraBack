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

ActiveRecord::Schema.define(version: 20160812124055) do

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
    t.index ["account_id"], name: "index_citizens_on_account_id", using: :btree
  end

  create_table "professionals", force: :cascade do |t|
    t.string   "registration"
    t.boolean  "active",       default: true, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "citizen_id"
    t.index ["citizen_id"], name: "index_professionals_on_citizen_id", using: :btree
  end

  add_foreign_key "citizens", "accounts"
end
