FactoryGirl.define do
  factory :repository do
    name { Faker::App.name }
    url { Faker::Internet.url }
    host { 'GitHub' }
    code_climate_id { Faker::String.random }
    maintainability_badge { Faker::String.random }
    test_coverage_badge { Faker::String.random }
  end
end
