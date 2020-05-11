require 'spec_helper'

describe Repository do
  context 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:host) }
    it { is_expected.to validate_inclusion_of(:host).to_allow(Repository::HOSTS) }
  end

  it 'should create a Repository' do
    project = FactoryGirl.create(:project)
    repository = FactoryGirl.create(:repository, project: project)
    expect(repository).to be_valid
  end

  it 'should not create a Repository' do
    repository = FactoryGirl.build(:repository)
    repository.save
    expect(repository).to be_invalid
    expect(repository.errors.full_messages).to eq(["Project can't be blank"])
  end

  it 'should not create a Repository with invalid host' do
    project = FactoryGirl.create(:project)
    repository = FactoryGirl.build(:repository, project: project)
    repository.host = 'invalid_string'
    repository.save
    expect(repository).to be_invalid
    expect(repository.errors.full_messages).to eq(["Host is not included in the list"])
  end
end
