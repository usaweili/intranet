require 'rails_helper'

RSpec.describe ResourceCategorisationService do
  context 'Resource Categorisation Report - ' do
    before(:each) do
      @emp_one = FactoryGirl.create(:user, status: STATUS[2])
      @emp_two = FactoryGirl.create(:user, status: STATUS[2])

      @active_project = FactoryGirl.create(:project, name: 'Brand Scope')
      @active_project_two = FactoryGirl.create(:project, name: 'Quick Insure')
      @devops_project = FactoryGirl.create(:project, name: 'DevOps Work')
      @free_project = FactoryGirl.create(
        :project,
        name: 'Intranet',
        type_of_project: 'Free'
      )
      @investment_project = FactoryGirl.create(
        :project,
        name: 'Hunger Terminal',
        type_of_project: 'Investment'
      )

      @user_project_one = FactoryGirl.create(
        :user_project,
        user: @emp_one,
        project: @active_project,
        allocation: 80
      )

      @user_project_two = FactoryGirl.create(
        :user_project,
        active: true,
        billable: false,
        allocation: 100,
        user: @emp_two,
        project: @active_project_two
      )

      @service = ResourceCategorisationService.new(@emp_one.email)
    end

    it 'should pass if response contains two reports' do
      response = @service.generate_resource_report
      expect(response.count).to eq(2)
    end

    it 'Billable Allocation - should return total allocation of billable projects' do
      total_allocation = @emp_one.user_projects.map(&:allocation).sum
      response = @service.billable_projects_allocation(@emp_one)

      expect(@active_project.type_of_project).to eq('T&M')
      expect(response).to eq(total_allocation)
    end

    it 'Non-Billable Allocation - should return total allocation of non-billable projects' do
      FactoryGirl.create(
        :user_project,
        active: true,
        billable: false,
        user: @emp_two,
        project: @free_project,
        allocation: 50
      )
      response = @service.non_billable_projects_allocation(@emp_two)

      expect(response).to eq(150)
    end

    it 'Investment Allocation - should return total allocation of investment projects' do
      FactoryGirl.create(
        :user_project,
        user: @emp_one,
        project: @investment_project,
        allocation: 90
      )
      response = @service.investment_projects_allocation(@emp_one)

      expect(@investment_project.type_of_project).to eq('Investment')
      expect(response).to eq(90)
    end

    it 'Get Technical Skills - should return atmost three techinal skills' do
      response = @service.get_technical_skills(@emp_one)
      expect(response.count).to eq(3)
    end

    it 'should generate resource report as expected' do
      @emp_three = FactoryGirl.create(:user, status: STATUS[2])
      @user_project_three = FactoryGirl.create(
        :user_project,
        active: true,
        allocation: 160,
        user: @emp_three,
        project: @devops_project
      )
      project_name_one = @emp_one.project_details.map { |i| i.values[1] }
      project_name_two = @emp_two.project_details.map { |i| i.values[1] }
      project_name_three = @emp_three.project_details.map { |i| i.values[1] }
      technical_skills_one = @service.get_technical_skills(@emp_one)
      technical_skills_two = @service.get_technical_skills(@emp_two)
      technical_skills_three = @service.get_technical_skills(@emp_three)
      report = [
        {
          name: @emp_one.name,
          location: @emp_one.location,
          designation: @emp_one.designation.try(:name),
          total_allocation: 80,
          billable: @user_project_one.allocation,
          non_billable: 0,
          investment: 0,
          bench: 80,
          technical_skills: technical_skills_one,
          projects: project_name_one
        },
        {
          name: @emp_two.name,
          location: @emp_two.location,
          designation: @emp_two.designation.try(:name),
          total_allocation: 100,
          billable: 0,
          non_billable: @user_project_two.allocation,
          investment: 0,
          bench: 60,
          technical_skills: technical_skills_two,
          projects: project_name_two
        }
      ]
      report = report.sort_by { |k| k[:name] }
      report << {
        name: @emp_three.name,
        location: @emp_three.location,
        designation: @emp_three.designation.try(:name),
        total_allocation: 160,
        billable: 0,
        non_billable: @user_project_three.allocation,
        investment: 0,
        bench: 0,
        technical_skills: technical_skills_three,
        projects: project_name_three
      }

      response = @service.generate_resource_report
      expect(response[:resource_report]).to eq(report)
    end

    it 'should generate project wise resource report as expected' do
      project_name_one = @emp_one.project_details.map { |i| i.values[1] }.join(', ')
      project_name_two = @emp_two.project_details.map { |i| i.values[1] }.join(', ')

      report = [
        {
          name: @emp_one.name,
          location: @emp_one.location,
          designation: @emp_one.designation.try(:name),
          billable: @user_project_one.allocation,
          non_billable: 0,
          investment: 0,
          project: project_name_one
        },
        {
          name: @emp_two.name,
          location: @emp_two.location,
          designation: @emp_two.designation.try(:name),
          billable: 0,
          non_billable: @user_project_two.allocation,
          investment: 0,
          project: project_name_two
        }
      ]
      report = report.sort_by { |k| k[:project] }
      response = @service.generate_resource_report
      expect(response[:project_wise_resource_report]).to eq(report)
    end

    it 'should send mail' do
      @service.call
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.subject).to eq("Resource Categorisation Report - #{Date.today}")
    end
  end
end