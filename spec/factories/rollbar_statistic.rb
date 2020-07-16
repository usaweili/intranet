FactoryGirl.define do
  factory :rollbar_statistic do
    date { Date.today }
    total_issues { Faker::Number.digit }
    active_issue_count { Faker::Number.digit }
    resolved_issue_count { Faker::Number.digit }
    new_issue_count { Faker::Number.digit }
  end
end
