FactoryGirl.define do
  factory :user_project do
    start_date { DateTime.now - 1 }
    end_date { nil }
    user
    project
  end
end
