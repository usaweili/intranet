require 'rails_helper'

RSpec.describe HolidayListsController, type: :controller do
  context '#create' do
    it 'create holiday' do
      params = FactoryGirl.attributes_for(:holiday)
      post :create, {:holiday_list => params}
      expect(flash[:success]).to eq('Holiday created Succesfully')
    end
  end

  context '#index' do 
    it 'show list of holidays' do
      get :index
      expect(response).to have_http_status(200)
      expect(response).to render_template :index
    end
  end

  context '#destroy' do
    it 'delete hoilday' do
      holiday = FactoryGirl.create(:holiday)
      delete :destroy, id: holiday.id
      expect(HolidayList.count).to eq(0)
      expect(response).to redirect_to(holiday_lists_path)
    end
  end

  context '#update' do
    let!(:holiday) { FactoryGirl.create(:holiday) } 
    it 'update holiday' do
     params  = {
      holiday_date: '05/09/2019',
      reason: 'test' 
     }   
     put :update, id: holiday.id, holiday_list: params
     expect(flash[:success]).to eq('Holiday updated Succesfully')
    end
  end
end
