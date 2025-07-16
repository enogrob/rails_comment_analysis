require 'rails_helper'

RSpec.describe ProgressController, type: :request do
  describe 'GET /progress/:job_id' do
    it 'returns 100% progress for any job_id' do
      get '/progress/abc123'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['job_id']).to eq('abc123')
      expect(json['progress']).to eq('100%')
    end

    it 'returns valid JSON structure' do
      get '/progress/xyz789'
      expect(response.content_type).to include('application/json')
      json = JSON.parse(response.body)
      expect(json).to include('job_id', 'progress')
    end
  end
end
