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
        project: @active_project,
        allocation: 80
      )
      
      @user_project_two = FactoryGirl.create(
        :user_project,
        active: true,
        billable: false,
        allocation: 100,
        user: @employee_two,
        project: @active_project
      )  

      @service = ResourceCategorisationService.new(@employee_one.email)
    end
  
    it 'should pass if response contains two reports' do
      location = @employee_one.location
      response = @service.generate_resource_report

      expect(response.count).to eq(2)
    end

    it 'should pass if report contains the location of employee' do
      location = @employee_one.location
      response = @service.generate_resource_report

      expect(response[:resource_report][0][:location]).to eq(location)
    end

    it 'Billable Allocation - should return total allocation of billable projects' do
      total_allocation = @employee_one.user_projects.map(&:allocation).sum
      response = @service.billable_projects_allocation(@employee_one)

      expect(@active_project.type_of_project).to eq('T&M')
      expect(response).to eq(total_allocation)
    end

    it 'Non-Billable Allocation - should return total allocation of non-billable projects' do
      free_project = FactoryGirl.create(
        :project,
        name: 'Brand Scope',
        type_of_project: 'Free'
      )
      FactoryGirl.create(
        :user_project,
        active: true,
        billable: false,
        user: @employee_two,
        project: free_project,
        allocation: 50
      )
      response = @service.non_billable_projects_allocation(@employee_two)

      expect(response).to eq(150)
    end

    it 'Investment Allocation - should return total allocation of investment projects' do
      investment_project = FactoryGirl.create(
        :project,
        name: 'Brand Scope',
        type_of_project: 'Investment'
      )
      
      FactoryGirl.create(
        :user_project,
        user: @employee_one,
        project: investment_project,
        allocation: 90
      )
      response = @service.investment_projects_allocation(@employee_one)

      expect(investment_project.type_of_project).to eq('Investment')
      expect(response).to eq(90)
    end

    it 'should generate resource report as expected' do
      project_name_one = @employee_one.project_details.map { |i| i.values[1] }.join(', ')
      project_name_two = @employee_two.project_details.map { |i| i.values[1] }.join(', ')
      report = [
        { name: @employee_one.name, location: @employee_one.location, total_allocation: 80, billable: @user_project_one.allocation, non_billable: 0, investment: 0, bench: 80, projects: project_name_one },
        { name: @employee_two.name, location: @employee_two.location, total_allocation: 100, billable: 0, non_billable: @user_project_two.allocation, investment: 0, bench: 60, projects: project_name_two }
      ]
      report = report.sort_by { |k| k[:name] }
      response = @service.generate_resource_report
      expect(response[:resource_report]).to eq(report)
    end    

    it 'should generate project wise resource report as expected' do
      project_name_one = @employee_one.project_details.map { |i| i.values[1] }.join(', ')
      project_name_two = @employee_two.project_details.map { |i| i.values[1] }.join(', ')
      report = [
        { name: @employee_one.name, location: @employee_one.location, billable: @user_project_one.allocation, non_billable: 0, investment: 0, project: project_name_one },
        { name: @employee_two.name, location: @employee_two.location, billable: 0, non_billable: @user_project_two.allocation, investment: 0, project: project_name_two }
      ]
      report = report.sort_by { |k| k[:name] }
      response = @service.generate_resource_report
      expect(response[:project_wise_resource_report]).to eq(report)
    end    

    it 'should generate project wise resource report without total allocation column' do
      response = @service.generate_resource_report

      expect(response[:project_wise_resource_report][0].has_key?(:total_allocation)).to eq(false)
    end    

    it 'should generate project wise resource report without bench column' do
      response = @service.generate_resource_report

      expect(response[:project_wise_resource_report][0].has_key?(:bench)).to eq(false)
    end    

    it 'should send mail' do
      @service.call
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.subject).to eq("Resource Categorisation Report - #{Date.today}")
    end
  end
end