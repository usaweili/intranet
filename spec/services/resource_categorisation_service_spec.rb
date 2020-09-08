require 'rails_helper'

RSpec.describe ResourceCategorisationService do
  context 'Resource Categorisation Report - ' do 
    before(:each) do
      @employee_one = FactoryGirl.create(:user, status: STATUS[2])
      @employee_two = FactoryGirl.create(:user, status: STATUS[2])
      @active_project = FactoryGirl.create(:project, name: 'Brand Scope')
      @user_project_one = FactoryGirl.create(
        :user_project,
        user: @employee_one,
        project: @active_project
      )
      
      @user_project_two = FactoryGirl.create(
        :user_project,
        active: true,
        billable: false,
        end_date: Date.today,
        allocation: 1,
        user: @employee_two,
        project: @active_project
      )  

      @service = ResourceCategorisationService.new(@employee_one.email)
    end
  
    it 'Billable Resource - should search employees who are assigned to billable projects' do
      total_allocation = @employee_one.user_projects.map(&:allocation).sum
      response = @service.billable

      expect(@active_project.type_of_project).to eq('T&M')
      expect(response.keys.first).to eq(@employee_one.id.to_s)
      expect(response.values.first[:name]).to eq(@employee_one.name)
      expect(response.values.first[:allocation]).to eq(total_allocation)
    end

    it 'Non-Billable Resource - should search employees who are assigned to non-billable projects' do
      total_allocation = @employee_two.user_projects.map(&:allocation).sum
      response = @service.non_billable

      expect(@active_project.type_of_project).to eq('T&M')
      expect(response.keys.first).to eq(@employee_two.id.to_s)
      expect(response.values.first[:name]).to eq(@employee_two.name)
      expect(response.values.first[:allocation]).to eq(total_allocation)
    end

    it 'Investment Resource - should search employees who are assigned to investment projects' do
      investment_project = FactoryGirl.create(
        :project,
        name: 'Brand Scope',
        type_of_project: 'Investment'
      )
      user_project_three = FactoryGirl.create(
        :user_project,
        user: @employee_one,
        project: investment_project
      )
      response = @service.investment

      expect(investment_project.type_of_project).to eq('Investment')
      expect(response.keys.first).to eq(@employee_one.id.to_s)
      expect(response.values.first[:name]).to eq(@employee_one.name)
      expect(response.values.first[:allocation]).to eq(user_project_three.allocation)
    end

    it 'Free Resource - should search employees who are assigned to free projects' do
      free_project = FactoryGirl.create(
        :project,
        name: 'Brand Scope',
        type_of_project: 'Free'
      )
      user_project_three = FactoryGirl.create(
        :user_project,
        user: @employee_one,
        project: free_project
      )
      response = @service.free_project

      expect(free_project.type_of_project).to eq('Free')
      expect(response.keys.first).to eq(@employee_one.id.to_s)
      expect(response.values.first[:name]).to eq(@employee_one.name)
      expect(response.values.first[:allocation]).to eq(user_project_three.allocation)
    end

    it 'Bench Resource - should search employees who are not assigned to any project' do
      bench_user = FactoryGirl.create(:user, status: STATUS[2])
      response = @service.bench
      
      expect(response.first[:name]).to eq(bench_user.name)
    end

    it 'should send mail' do
      @service.call  
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.subject).to eq("Resource Categorisation Report - #{Date.today}")
    end
  end
end