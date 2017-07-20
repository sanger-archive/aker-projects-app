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

ActiveRecord::Schema.define(version: 20170713162254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "collections", force: :cascade do |t|
    t.string   "set_id"
    t.string   "collector_type"
    t.integer  "collector_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["collector_type", "collector_id"], name: "index_collections_on_collector_type_and_collector_id", using: :btree
  end

  create_table "nodes", force: :cascade do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.text     "description"
    t.string   "cost_code"
    t.integer  "deactivated_by_id"
    t.datetime "deactivated_datetime"
    t.string   "node_uuid"
    t.integer  "owner_id"
    t.index ["cost_code"], name: "index_nodes_on_cost_code", using: :btree
    t.index ["deactivated_by_id"], name: "index_nodes_on_deactivated_by_id", using: :btree
    t.index ["name"], name: "index_nodes_on_name", using: :btree
    t.index ["owner_id"], name: "index_nodes_on_owner_id", using: :btree
    t.index ["parent_id"], name: "index_nodes_on_parent_id", using: :btree
  end

  create_table "permissions", force: :cascade do |t|
    t.string   "permitted",       null: false
    t.string   "permission_type", null: false
    t.string   "accessible_type", null: false
    t.integer  "accessible_id",   null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["accessible_type", "accessible_id"], name: "index_permissions_on_accessible_type_and_accessible_id", using: :btree
    t.index ["permitted", "permission_type", "accessible_id", "accessible_type"], name: "index_permissions_on_various", unique: true, using: :btree
    t.index ["permitted"], name: "index_permissions_on_permitted", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",               default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "remember_token"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
  end

  add_foreign_key "nodes", "nodes", column: "parent_id"
  add_foreign_key "nodes", "users", column: "deactivated_by_id"
  add_foreign_key "nodes", "users", column: "owner_id"
end
