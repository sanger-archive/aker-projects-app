class DropUsersTable < ActiveRecord::Migration[5.0]
  def change
    add_column :nodes, :owner_email, :string
    add_column :nodes, :deactivated_by, :string

    Node.where(owner_email: nil).update_all(owner_email: 'aker')

    remove_column :nodes, :owner_id
    remove_column :nodes, :deactivated_by_id
    drop_table :users

    add_index :nodes, :owner_email
  end
end
