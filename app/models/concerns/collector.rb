require 'active_support/concern'

module Collector
  extend ActiveSupport::Concern

  included do
    has_one :collection, as: :collector, dependent: :destroy
  end
end