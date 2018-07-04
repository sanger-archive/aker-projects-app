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

ActiveRecord::Schema.define(version: 2018_05_29_135327) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "nodes", id: :serial, force: :cascade do |t|
    t.citext "name", null: false
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "cost_code"
    t.datetime "deactivated_datetime"
    t.string "node_uuid"
    t.citext "owner_email", null: false
    t.citext "deactivated_by"
    t.index ["cost_code"], name: "index_nodes_on_cost_code"
    t.index ["name"], name: "index_nodes_on_name"
    t.index ["owner_email"], name: "index_nodes_on_owner_email"
    t.index ["parent_id"], name: "index_nodes_on_parent_id"
  end

  create_table "permissions", id: :serial, force: :cascade do |t|
    t.citext "permitted", null: false
    t.string "permission_type", null: false
    t.string "accessible_type", null: false
    t.integer "accessible_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accessible_type", "accessible_id"], name: "index_permissions_on_accessible_type_and_accessible_id"
    t.index ["permitted", "permission_type", "accessible_id", "accessible_type"], name: "index_permissions_on_various", unique: true
    t.index ["permitted"], name: "index_permissions_on_permitted"
  end

  create_table "tree_layouts", id: :serial, force: :cascade do |t|
    t.citext "user_id", null: false
    t.text "layout"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tree_layouts_on_user_id", unique: true
  end

  add_foreign_key "nodes", "nodes", column: "parent_id"
end
