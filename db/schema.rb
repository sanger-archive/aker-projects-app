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

ActiveRecord::Schema.define(version: 20180119101526) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"
  enable_extension "uuid-ossp"

  create_table "data_release_strategies", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.string   "study_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_data_release_strategies_on_id", unique: true, using: :btree
  end

  create_table "nodes", force: :cascade do |t|
    t.citext   "name",                     null: false
    t.integer  "parent_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "description"
    t.string   "cost_code"
    t.datetime "deactivated_datetime"
    t.string   "node_uuid"
    t.citext   "owner_email",              null: false
    t.citext   "deactivated_by"
    t.uuid     "data_release_strategy_id"
    t.index ["cost_code"], name: "index_nodes_on_cost_code", using: :btree
    t.index ["name"], name: "index_nodes_on_name", using: :btree
    t.index ["owner_email"], name: "index_nodes_on_owner_email", using: :btree
    t.index ["parent_id"], name: "index_nodes_on_parent_id", using: :btree
  end

  create_table "permissions", force: :cascade do |t|
    t.citext   "permitted",       null: false
    t.string   "permission_type", null: false
    t.string   "accessible_type", null: false
    t.integer  "accessible_id",   null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["accessible_type", "accessible_id"], name: "index_permissions_on_accessible_type_and_accessible_id", using: :btree
    t.index ["permitted", "permission_type", "accessible_id", "accessible_type"], name: "index_permissions_on_various", unique: true, using: :btree
    t.index ["permitted"], name: "index_permissions_on_permitted", using: :btree
  end

  create_table "tree_layouts", force: :cascade do |t|
    t.citext   "user_id",    null: false
    t.text     "layout"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tree_layouts_on_user_id", unique: true, using: :btree
  end

  add_foreign_key "nodes", "nodes", column: "parent_id"
end
