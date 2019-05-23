FactoryGirl.define do
  factory :company do
    name { Faker::Company.name }
    gstno { Faker::Bank.swift_bic }
    website { Faker::Internet.url }
    logo nil
  end

  factory :company_with_contact_person, class: Company do
    name { Faker::Company.name }
    gstno { Faker::Bank.swift_bic }
    website { Faker::Internet.url }
    logo nil
    contact_persons_attributes {
      {
        '0' => FactoryGirl.attributes_for(:contact_person)
      }
    }
  end

end
