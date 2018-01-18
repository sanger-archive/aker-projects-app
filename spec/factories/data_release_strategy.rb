require 'data_release_strategy_client'

FactoryGirl.define do
  factory :data_release_strategy, class: DataReleaseStrategyClient::DataReleaseStrategy do 
    uuid { SecureRandom.uuid }
    name { |n| "Node" }
  end
end