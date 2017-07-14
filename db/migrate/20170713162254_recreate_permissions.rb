class RecreatePermissions < ActiveRecord::Migration[5.0]
  def change
    drop_table :permissions

    create_table :permissions do |t|
      t.string :permitted, null: false, index: true
      t.string :permission_type, null: false
      t.references :accessible, null: false, polymorphic: true, type: accessible_id_type, index: true
      t.timestamps
    end
    add_index :permissions, [:permitted, :permission_type, :accessible_id, :accessible_type], unique: true, name: :index_permissions_on_various
  end

  def accessible_id_type
    return 'int' unless Rails.configuration.respond_to? :accessible_id_type
    Rails.configuration.accessible_id_type
  end
end
