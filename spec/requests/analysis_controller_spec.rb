require 'rails_helper'

RSpec.describe AnalysisController, type: :request do
  describe 'POST /analyze' do
    it 'returns job_id and message for valid username' do
      post '/analyze', params: { username: 'TestUser' }
      expect(response).to have_http_status(:accepted)
      json = JSON.parse(response.body)
      expect(json).to include('job_id', 'message')
    end

    it 'returns error for missing username' do
      post '/analyze', params: {}
      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Missing username')
    end
  end
end
