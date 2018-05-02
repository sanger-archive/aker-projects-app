require 'ostruct'

FactoryBot.define do
  factory :user, class: OpenStruct do
    email "ab12@sanger.ac.uk"
    groups ["world"]
  end
end