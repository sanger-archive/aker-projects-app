class DropDataReleaseStrategies < ActiveRecord::Migration[5.2]
  def change
    remove_column :nodes, :data_release_strategy_id
    drop_table :data_release_strategies
  end
end
