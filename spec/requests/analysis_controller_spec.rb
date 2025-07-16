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

  describe 'POST /analysis' do
    let(:username) { 'TestUser' }

    it 'returns error for missing username' do
      post '/analysis', params: {}.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to include('error' => 'Missing username')
    end

    it 'starts analysis and returns job_id and message' do
      allow(AnalyzeUserWorker).to receive(:perform_async).and_return('fake-job-id')
      post '/analysis', params: { username: username }.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
      expect(response).to have_http_status(:accepted)
      body = JSON.parse(response.body)
      expect(body['job_id']).to eq('fake-job-id')
      expect(body['message']).to include(username)
    end
  end
end
