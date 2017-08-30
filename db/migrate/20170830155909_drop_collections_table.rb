class DropCollectionsTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :collections
  end
end
