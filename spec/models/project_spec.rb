require 'spec_helper'

describe Project do
  it {should validate_presence_of(:name)}
  # it {should accept_nested_attributes_for(:users)}

  it 'must return all the tags' do
    project = FactoryGirl.create(:project)
    expect(project.tags.count).to eq(4)
  end


  it "should use existing product code of company" do
    company = FactoryGirl.create(:company)
    project = FactoryGirl.create(:project, company: company)
    new_project = FactoryGirl.build(:project,
                    code: project.code,
                    company: company
                  )
    expect(new_project).to be_valid
  end

  it "should not use existing product code of other company" do
    company = FactoryGirl.create(:company)
    project = FactoryGirl.create(:project, company: company)
    new_project = FactoryGirl.build(:project, code: project.code)
    expect(new_project).to be_invalid
  end

  context 'validation - display name' do
    let!(:project) { FactoryGirl.create(:project) }

    it 'Should success' do
      expect(project.errors.count).to eq(0)
    end

    it 'should fail beacause display name contain white space' do
      project.display_name = 'The pediatric network'
      project.save

      expect(project.errors.full_messages).to eq(
        ["Display name Name should not contain white space"]
      )
      expect(project.errors.count).to eq(1)
    end

    it 'should update display name when project name is change' do
      project.name = 'Deal signal'
      project.display_name = ''
      project.save

      expect(project.display_name).to eq("Deal_signal")
      expect(project.errors.count).to eq(0)
    end

    it 'Should not trigger validation because display name is correct' do
      project.display_name = 'tpn'

      expect(project.errors.count).to eq(0)
    end
  end

  context 'manager name and employee name' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:project) { FactoryGirl.create(:project) }

    it 'Should match manager name' do
      manager = FactoryGirl.create(:user)
      project = FactoryGirl.create(:project)
      project.managers << user
      project.managers << manager
      manager_names = Project.manager_names(project)
      expect(manager_names).to eq("#{user.name} | #{manager.name}")
    end

    it 'Should match employee name' do
      FactoryGirl.create(:user_project, user: user, project: project)
      employee_names = Project.employee_names(project)
      expect(employee_names).to eq("#{user.name}")
    end
  end

  context 'add or remove team member' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:project) { FactoryGirl.build(:project) }

    it 'Should add team member' do
      user_ids = []
      user_ids << user.id
      project.save
      params = { "project" => { "user_ids" => user_ids } }
      project.add_or_remove_team_member(params)
      user_project = UserProject.find_by(
                      user_id: user.id,
                      project_id: project.id
                    )
      expect(user_project.start_date).to eq(Date.today)
    end

    describe 'Should remove team member' do
      it 'member count greater than two' do
        user_ids = []
        first_team_member = FactoryGirl.create(:user)
        second_team_member = FactoryGirl.create(:user)
        FactoryGirl.create(:user_project,
          user: first_team_member,
          project: project
        )
        FactoryGirl.create(:user_project,
          user: second_team_member,
          project: project
        )
        user_project = FactoryGirl.create(:user_project,
                          user: user,
                          project: project
                        )
        user_ids << first_team_member.id
        user_ids << second_team_member.id

        params = { "project" => { "user_ids" => user_ids } }
        project.add_or_remove_team_member(params)
        expect(user_project.reload.end_date).to eq(Date.today)
      end

      it 'Member count is one' do
        user_project = FactoryGirl.create(:user_project,
                          user: user,
                          project: project
                        )
        params = { "project" => { "user_ids" => [] } }
        project.add_or_remove_team_member(params)
        expect(user_project.reload.end_date).to eq(Date.today)
      end
    end

    it 'Add team member : should return false because user id nil' do
      user_ids = []
      user_ids << nil
      return_value = project.add_team_member(user_ids)
      expect(return_value).to eq(false)
    end

    it 'Remove team member : should return false because user id nil' do
      user_ids = []
      user_ids << nil
      return_value = project.remove_team_member(user_ids)
      expect(return_value).to eq(false)
    end
  end

  context 'Users' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:project) { FactoryGirl.create(:project) }
    it 'Should give users report' do
      FactoryGirl.create(:user_project,
        user: user,
        project: project,
        start_date: DateTime.now - 2
      )
      users = project.users
      expect(users.present?).to eq(true)
    end
  end
  
  context 'Get user project from project' do
    before {
              @users = []
              [1, 2, 3, 4, 5, 6, 7, 8].each do |n|
                @users << FactoryGirl.create(:user,
                  email: "user#{n}@#{ORGANIZATION_DOMAIN}",
                  status: STATUS[2])
              end
           }
    let!(:project) { FactoryGirl.create(:project) }

    it 'Should give users record between from date and to date' do
      FactoryGirl.create(:user_project,
        user: @users[0],
        project: project,
        start_date: '01/08/2018'.to_date
      )
      FactoryGirl.create(:user_project,
        user: @users[1],
        project: project,
        start_date: '06/09/2018'.to_date
      )
      FactoryGirl.create(:user_project,
        user: @users[2],
        project: project,
        start_date: '05/09/2018'.to_date,
        end_date: '15/09/2018'.to_date
      )
      FactoryGirl.create(:user_project,
        user: @users[3],
        project: project,
        start_date: '08/09/2018'.to_date,
        end_date: '23/09/2018'.to_date
      )
      FactoryGirl.create(:user_project,
        user: @users[4],
        project: project,
        start_date: '05/08/2018'.to_date,
        end_date: '10/09/2018'.to_date
      )
      FactoryGirl.create(:user_project,
        user: @users[5],
        project: project,
        start_date: '01/08/2018'.to_date,
        end_date: '10/10/2018'.to_date
      )
      FactoryGirl.create(:user_project,
        user: @users[6],
        project: project,
        start_date: '25/09/2018'.to_date,
        end_date: '30/09/2018'.to_date
      )
      FactoryGirl.create(:user_project,
        user: @users[7],
        project: project,
        start_date: '01/08/2018'.to_date,
        end_date: '25/08/2018'.to_date
      )
      from_date = '01/09/2018'.to_date
      to_date = '20/09/2018'.to_date
      user_projects = project.get_user_projects_from_project(from_date, to_date)
      expect(user_projects.count).to eq(6)
      [0, 1, 2, 3, 4, 5].each do |n|
        expect(user_projects[n].email).to eq("user#{n+1}@#{ORGANIZATION_DOMAIN}")
      end
    end

    it 'Should not give the user record, Its less than from date and to date' do
      FactoryGirl.create(:user_project,
        user: @users[5],
        project: project,
        start_date: '01/08/2018'.to_date,
        end_date: '25/08/2018'.to_date
      )
      from_date = '01/09/2018'.to_date
      to_date = '20/09/2018'.to_date
      user_projects = project.get_user_projects_from_project(from_date, to_date)
      expect(user_projects.count).to eq(0)
    end

    it 'Should not give user record, Its greater than from date and to date' do
      FactoryGirl.create(:user_project,
        user: @users[6],
        project: project,
        start_date: '25/09/2018'.to_date,
        end_date: '30/09/2018'.to_date
      )
      from_date = '01/09/2018'.to_date
      to_date = '20/09/2018'.to_date
      user_projects = project.get_user_projects_from_project(from_date, to_date)
      expect(user_projects.count).to eq(0)
    end

    it "Should give the record if user's project start date is less than from date and end date is nil" do
      FactoryGirl.create(:user_project,
        user: @users[0],
        project: project,
        start_date: '01/08/2018'.to_date
      )
      from_date = '01/09/2018'.to_date
      to_date = '20/09/2018'.to_date
      user_projects = project.get_user_projects_from_project(from_date, to_date)
      expect(user_projects.count).to eq(1)
      expect(user_projects[0].email).to eq("user1@#{ORGANIZATION_DOMAIN}")
    end

    it "Should give the record if user's project start date is greater than from date and end date is nil" do
      FactoryGirl.create(:user_project,
        user: @users[1],
        project: project,
        start_date: '06/09/2018'.to_date,
        end_date: '20/09/2018'.to_date
      )
      from_date = '01/09/2018'.to_date
      to_date = '20/09/2018'.to_date
      user_projects = project.get_user_projects_from_project(from_date, to_date)
      expect(user_projects.count).to eq(1)
      expect(user_projects[0].email).to eq("user2@#{ORGANIZATION_DOMAIN}")
    end

    it "Should give the record if user's project start date is greater than from date and end date is less than to date" do
      FactoryGirl.create(:user_project,
        user: @users[2],
        project: project,
        start_date: '05/09/2018'.to_date,
        end_date: '15/09/2018'.to_date
      )
      from_date = '01/09/2018'.to_date
      to_date = '20/09/2018'.to_date
      user_projects = project.get_user_projects_from_project(from_date, to_date)
      expect(user_projects.count).to eq(1)
      expect(user_projects[0].email).to eq("user3@#{ORGANIZATION_DOMAIN}")
    end

    it "Should give the record if user's project start date is greater than from date and end date is greater than to date " do
      FactoryGirl.create(:user_project,
        user: @users[3],
        project: project,
        start_date: '08/09/2018'.to_date,
        end_date: '23/09/2018'.to_date
      )
      from_date = '01/09/2018'.to_date
      to_date = '20/09/2018'.to_date
      user_projects = project.get_user_projects_from_project(from_date, to_date)
      expect(user_projects.count).to eq(1)
      expect(user_projects[0].email).to eq("user4@#{ORGANIZATION_DOMAIN}")
    end

    it "Should give the record if user's project start date less than from date and end date less than to date" do
      FactoryGirl.create(:user_project,
        user: @users[4],
        project: project,
        start_date: '05/08/2018'.to_date,
        end_date: '10/09/2018'.to_date
      )
      from_date = '01/09/2018'.to_date
      to_date = '20/09/2018'.to_date
      user_projects = project.get_user_projects_from_project(from_date, to_date)
      expect(user_projects.count).to eq(1)
      expect(user_projects[0].email).to eq("user5@#{ORGANIZATION_DOMAIN}")
    end

    it "Should give the record if user's project start date is less than from date and end date is greater than to date" do
      FactoryGirl.create(:user_project,
        user: @users[7],
        project: project,
        start_date: '01/08/2018'.to_date,
        end_date: '10/10/2018'.to_date
      )
      from_date = '01/09/2018'.to_date
      to_date = '20/09/2018'.to_date
      user_projects = project.get_user_projects_from_project(from_date, to_date)
      expect(user_projects.count).to eq(1)
      expect(user_projects[0].email).to eq("user8@#{ORGANIZATION_DOMAIN}")
    end

    it "Should not give the record because user's project start date and end date is not between from date and to date" do
      FactoryGirl.create(:user_project,
        user: @users[5],
        project: project,
        start_date: '01/08/2018'.to_date,
        end_date: '25/08/2018'.to_date
      )
      from_date = '01/09/2018'.to_date
      to_date = '20/09/2018'.to_date
      user_projects = project.get_user_projects_from_project(from_date, to_date)
      expect(user_projects.count).to eq(0)
      expect(user_projects.present?).to eq(false)
    end

    it "Should not give the record because user's project start date and end date is not between from date and to date" do
      FactoryGirl.create(:user_project,
        user: @users[6],
        project: project,
        start_date: '25/09/2018'.to_date,
        end_date: '30/09/2018'.to_date
      )
      from_date = '01/09/2018'.to_date
      to_date = '20/09/2018'.to_date
      user_projects = project.get_user_projects_from_project(from_date, to_date)
      expect(user_projects.count).to eq(0)
      expect(user_projects.present?).to eq(false)
    end
  end
end
