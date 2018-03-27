class TreeStatusChannel < ApplicationCable::Channel
  def self.GLOBAL_TREE
    "TheBigTree"
  end

  def subscribed
    stream_from TreeStatusChannel.GLOBAL_TREE
  end  
end