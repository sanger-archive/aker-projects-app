FactoryGirl.define do
  factory :program do
    sequence(:name) { |n| "Program #{n}" }
  end
end
