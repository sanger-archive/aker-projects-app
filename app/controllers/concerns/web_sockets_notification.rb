module WebSocketsNotification

  extend ActiveSupport::Concern

  def notify_changes_with_websockets
    ActionCable.server.broadcast(TreeStatusChannel.GLOBAL_TREE, { notifyChanges: true })
  end

end