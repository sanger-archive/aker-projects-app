module WebSocketsNotification

  extend ActiveSupport::Concern

  def notify_changes_with_websockets
    Rails.cache.write('org_chart', OrgChart::Builder.build.to_json)
    ActionCable.server.broadcast(TreeStatusChannel.GLOBAL_TREE, { treeData: true })
  end

end