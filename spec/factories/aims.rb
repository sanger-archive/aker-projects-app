FactoryGirl.define do
  factory :aim do
    sequence(:name) { |n| "Aim #{n}" }
    project
  end
end
