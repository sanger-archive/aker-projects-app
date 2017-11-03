class AddTreeLayout < ActiveRecord::Migration[5.0]
  def change
    create_table :tree_layouts do |t|
      t.string :user_id
      t.text :layout

      t.timestamps
    end    
  end
end
