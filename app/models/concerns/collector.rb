require 'active_support/concern'

module Collector
  extend ActiveSupport::Concern

  included do
    has_one :collection, as: :collector
    after_create :create_collection!
  end
end