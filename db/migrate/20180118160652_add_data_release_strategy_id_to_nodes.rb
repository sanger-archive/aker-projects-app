class AddDataReleaseStrategyIdToNodes < ActiveRecord::Migration[5.0]
  def change
    add_column :nodes, :data_release_strategy_id, :uuid, null: true
  end
end
