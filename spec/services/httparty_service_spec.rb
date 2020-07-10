require 'rails_helper'

RSpec.describe HttpartyService do
  context 'Valid request' do
    it 'google' do
      response = HttpartyService.new(url: 'https://intranet.joshsoftware.com').get
      expect(response).not_to be_nil
      expect(response.class).to eq(HTTParty::Response)
    end
    it 'timeouts' do
      response = HttpartyService.new(url: 'https://www.google.com', timeout: 0).get
      expect(response[:error]).not_to be_nil
      expect(response[:error].class).to eq(Net::ReadTimeout)
    end
  end

  context 'Invalid request to' do
    it 'unknown url' do
      response = HttpartyService.new(url: nil).get
      expect(response[:error]).not_to be_nil
      expect(response[:error].class).to eq(ArgumentError)
    end
    it 'invalid url' do
      response = HttpartyService.new(url: 'https://intranet').get
      expect(response[:error]).not_to be_nil
      expect(response[:error].class).to eq(SocketError)
    end
  end
end
