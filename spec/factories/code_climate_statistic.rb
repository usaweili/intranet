FactoryGirl.define do
  factory :code_climate_statistic do
    timestamp { Faker::Time.backward }
    gpa { Faker::Number.number }
    test_coverage { Faker::Number.number }
    loc { { Ruby: Faker::Number.number } }
    maintainability { Faker::Number.number }
    remediation_minutes { Faker::Number.number }
    technical_debt_ratio { Faker::Number.number }
    diff_coverage { Faker::Number.number }
    ratings { { A: Faker::Number.number } }
  end
end
