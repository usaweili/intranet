FactoryGirl.define do
  factory :policy do
    title { Faker::Dessert.topping }
    content { Faker::Lorem.paragraph(5, false, 4) }
    is_published { Faker::Boolean.boolean }
  end
end
