FactoryGirl.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    program
  end
end
