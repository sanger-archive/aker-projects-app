module WebSocketsNotification

  extend ActiveSupport::Concern

  def notify_changes_with_websockets
    org_chart = OrgChart::Builder.build.to_json
    Rails.cache.write("org_chart", org_chart, expires_in: 7.days)
    ActionCable.server.broadcast(TreeStatusChannel.GLOBAL_TREE, { treeData: org_chart })
  end

end