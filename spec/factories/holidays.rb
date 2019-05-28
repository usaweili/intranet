FactoryGirl.define do
  factory :holiday, class: HolidayList do
    holiday_date { Date.tomorrow }
    reason { Faker::Lorem.sentence(4) }
  end
end
