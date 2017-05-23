class AddDeactivatedByAndDeactivatedDateToNode < ActiveRecord::Migration[5.0]
  def change
    add_reference :nodes, :deactivated_by, references: :users, index: true
    add_foreign_key :nodes, :users, column: :deactivated_by_id
    add_column :nodes, :deactivated_datetime, :datetime
  end
end
