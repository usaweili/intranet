include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :schedule do
    users { [FactoryGirl.create(:user)] }
    interview_time { Time.at(Random.new.rand(1234675678)) }
    interview_date { Date.tomorrow }
    candidate_details do
      {
        email: Faker::Internet.email,
        telephone: Faker::Number.number,
        skype: Faker::Lorem.characters(10)
      }
    end
    public_profile do
      {
        git: 'http://github.com/candidate1',
        linkedin: 'http://in.linkedin.com/pub/test-candidate/82/7b3/a17/'
      }
    end
    interview_type { 'Telephonic' }
    file { fixture_file_upload('spec/fixtures/files/sample1.pdf') }
  end
end
