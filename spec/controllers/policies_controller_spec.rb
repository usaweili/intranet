require 'spec_helper'

RSpec.describe PoliciesController, :type => :controller do
  context "As an Admin" do
    before(:each) do
      @admin = FactoryGirl.create(:admin)
      sign_in @admin
    end

    it 'renders new template' do
      get :new
      expect(response).to render_template(:new)
    end

    describe '#create' do
      it 'creates new policy (is_published: true)' do
        policy = FactoryGirl.build(:policy, is_published: true)
        post :create, { policy: policy.attributes }
        expect(Policy.last.is_published).to eq(true)
        expect(Policy.last.title).to eq(policy.title)
        expect(response).to redirect_to(attachments_path)
      end

      it 'creates new policy (is_published: false)' do
        policy = FactoryGirl.build(:policy, is_published: false)
        post :create, { policy: policy.attributes }
        expect(Policy.last.is_published).to eq(false)
        expect(Policy.last.title).to eq(policy.title)
        expect(response).to redirect_to(attachments_path)
      end
    end

    it 'displays policy' do
      policy = FactoryGirl.create(:policy)
      get :show, id: policy.id
      expect(response).to be_success
    end

    it 'renders edit template' do
      policy = FactoryGirl.create(:policy)
      get :edit, id: policy.id
      expect(response).to be_success
    end

    describe '#update' do
      before(:each) do
        @policy = FactoryGirl.create(:policy)
      end

      it 'make is_published false' do
        @policy.is_published = true
        post :update, {
          id: @policy.id,
          policy: { is_published: false }
        }
        expect(@policy.reload.is_published).to eq(false)
      end

      it 'make is_published true' do
        @policy.is_published = false
        post :update, {
          id: @policy.id,
          policy: { is_published: true }
        }
        expect(@policy.reload.is_published).to eq(true)
      end

      it 'redirects to attachments_path' do
        post :update, {
          id: @policy.id,
          policy: { is_published: true }
        }
        expect(response).to redirect_to(attachments_path)
      end
    end

    it 'destroys policy' do
      @policy = FactoryGirl.create(:policy)
      post :destroy, { id: @policy.id }
      expect(Policy.count).to eq(0)
      expect(response).to redirect_to(attachments_path)
    end
  end
end
