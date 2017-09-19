class DropUsersTable < ActiveRecord::Migration[5.0]
  def change
    add_column :nodes, :owner_email, :string
    add_column :nodes, :deactivated_by, :string

    Node.where.not(owner_id: nil).each do |node|
      node.update_attributes(owner_email: User.find(node.owner_id).email)
    end
    Node.where.not(deactivated_by_id: nil).each do |node|
      node.update_attributes(deactivated_by: User.find(node.deactivated_by_id).email)
    end
    Node.where(owner_email: nil).update_all(owner_email: 'aker')

    remove_column :nodes, :owner_id
    remove_column :nodes, :deactivated_by_id
    drop_table :users

    add_index :nodes, :owner_email
  end
end
