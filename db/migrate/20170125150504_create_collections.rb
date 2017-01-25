class CreateCollections < ActiveRecord::Migration[5.0]
  def change
    create_table :collections do |t|
      t.string :set_id
      t.references :collector, polymorphic: true

      t.timestamps
    end
  end
end
