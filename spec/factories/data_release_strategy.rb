require 'data_release_strategy_client'

FactoryGirl.define do
  factory :data_release_strategy do 
    name { |n| "Node" }
  end
end