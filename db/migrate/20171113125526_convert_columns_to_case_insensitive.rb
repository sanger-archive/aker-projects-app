class ConvertColumnsToCaseInsensitive < ActiveRecord::Migration[5.0]
  def up
    enable_extension "citext"

    change_column :nodes, :name, :citext, null: false
    change_column :nodes, :owner_email, :citext, null: false
    change_column :nodes, :deactivated_by, :citext
    change_column :permissions, :permitted, :citext
    change_column :tree_layouts, :user_id, :citext, null: false

    add_index :tree_layouts, :user_id, unique: true

    Node.find_each { |n| n.save! if [n.sanitise_name, n.sanitise_owner, n.sanitise_deactivated_by].any? } # non-short-circuiting OR
    AkerPermissionGem::Permission.find_each { |p| p.save! if p.sanitise_permitted }
    TreeLayout.find_each { |tl| tl.save! if tl.sanitise_user }
  end

  def down
    change_column :nodes, :name, :string, null: true
    change_column :nodes, :owner_email, :string, null: true
    change_column :nodes, :deactivated_by, :string
    change_column :permissions, :permitted, :string
    change_column :tree_layouts, :user_id, :string, null: true

    remove_index :tree_layouts, :user_id
  end
end
