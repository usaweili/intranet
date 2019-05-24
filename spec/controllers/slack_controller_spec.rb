require 'rails_helper'

RSpec.describe SlackController do
  context 'projects' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:project1) { FactoryGirl.create(:project) }
    let!(:project2) { FactoryGirl.create(:project) }

    before do
      FactoryGirl.create(:user_project,
        user: user,
        project: project1,
        start_date: DateTime.now
      )
      FactoryGirl.create(:user_project,
        user: user,
        project: project2,
        start_date: DateTime.now
      )
      user.public_profile.slack_handle = USER_ID
      user.save
    end

    it 'should have status code 200' do
      params = { user_id: USER_ID, channel_id: CHANNEL_ID }
      slack_params = {
        'token' => SLACK_API_TOKEN,
        'channel' => CHANNEL_ID,
        'text' => "1. #{project1.name}\n2. #{project2.name}"
      }
      post :projects, params

      resp = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(resp['text']).to eq("1. #{project1.name}\n2. #{project2.name}")
    end

    it 'Should give the managed projects name' do
      user = FactoryGirl.create(:user, role: 'Manager')
      params = { user_id: USER_ID, channel_id: CHANNEL_ID }
      project1.managers << user
      project2.managers << user
      post :projects, params
      resp = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(resp['text']).to eq("1. #{project1.name}\n2. #{project2.name}")
    end

    it 'Should give message : You are not working on any project' do
      user.projects.destroy_all
      params = { user_id: USER_ID, channel_id: CHANNEL_ID }

      post :projects, params
      resp = JSON.parse(response.body)
      expect(resp['text']).to eq('You are not working on any project')
    end
  end

  context 'Check user is exists' do
    let!(:user) { FactoryGirl.create(:user) }

    before do
      project = FactoryGirl.create(:project)
      UserProject.create(user: user, project: project, start_date: DateTime.now)
      user.save
      stub_request(:post, "https://slack.com/api/chat.postMessage")
    end

    it 'Associate slack id to user' do
      params = {
        'token' => SLACK_API_TOKEN,
        'channel' => CHANNEL_ID,
        'user_id' => USER_ID,
        'text' => "#{project.name} #{Date.yesterday}  6 7 abcd efghigk lmnop"
      }

      post :projects, params
      expect(response).to have_http_status(:ok)
    end
  end

end
