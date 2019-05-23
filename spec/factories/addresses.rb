FactoryGirl.define do
  factory :address do
    address { Faker::Address.full_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    landline_no { Faker::PhoneNumber.cell_phone }
    pin_code { Faker::Address.postcode }
    company
  end
end
