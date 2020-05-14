require 'spec_helper'

describe RepositoriesController do
  before(:each) do
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
  end

  describe 'Overview Index' do
    it 'Should render overview_index view' do
      get :overview_index
      should render_template(:overview_index)
    end
  end

  describe 'Repository Issues Index' do
    it 'Should render repository_issues view' do
      get :repository_issues
      should render_template(:repository_issues)
    end
  end
end
