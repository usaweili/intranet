FactoryGirl.define do
  factory :contact_person do
    relation { Faker::Job.position }
    role { Faker::Job.title }
    name { Faker::Name.name }
    phone_no { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }
  end
end
