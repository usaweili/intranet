FactoryGirl.define do
  factory :leave_application do |l|
    start_at { Date.today + 2 }
    end_at { Date.today + 3 }
    number_of_days { 2 }
    reason { "Sick" }
    contact_number { Faker::Number.number(10) }
    user
  end
end
