require 'rails_helper'

RSpec.describe RollbarStatistic, type: :model do
  context 'Validations' do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:repository) }
  end

  it 'should create a RollbarStatistic' do
    project = FactoryGirl.create(:project)
    repository = FactoryGirl.create(:repository, project: project)
    expect(repository).to be_valid
    rollbar_statistic = FactoryGirl.create(:rollbar_statistic, repository: repository)
    expect(rollbar_statistic).to be_valid
  end

  it 'should not create a RollbarStatistic' do
    rollbar_statistic = FactoryGirl.build(:rollbar_statistic)
    rollbar_statistic.save
    expect(rollbar_statistic).to be_invalid
    expect(rollbar_statistic.errors.full_messages.join(',')).to eq("Repository can't be blank")
  end

  it 'on delete repository, its associated Rollbar statistic should get deleted' do
    project = create(:project)
    repository = create(:repository, project: project)
    rollbar_statistic = FactoryGirl.create(:rollbar_statistic, repository: repository)
    expect(repository.rollbar_statistics.count).to eq(1)
    repository.destroy
    expect(repository.rollbar_statistics.count).to eq(0)
  end
end
