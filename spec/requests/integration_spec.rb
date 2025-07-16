require 'rails_helper'

RSpec.describe 'Integration', type: :request do
  describe 'POST /analyze' do
    it 'triggers import and returns metrics' do
      # Create keywords for approval logic
      Keyword.create!(word: 'foo')
      Keyword.create!(word: 'bar')
      post '/analyze', params: { username: 'TestUser' }.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
      expect(response).to have_http_status(:accepted).or have_http_status(:ok)
      expect(JSON.parse(response.body)).to include('job_id', 'message')
    end
  end

  describe 'CRUD /keywords' do
    it 'creates, shows, updates, and deletes a keyword' do
      # Create
      post '/keywords', params: { keyword: { word: 'integration' } }
      expect(response).to have_http_status(:created)
      id = JSON.parse(response.body)['id']
      # Show
      get "/keywords/#{id}"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['word']).to eq('integration')
      # Update
      patch "/keywords/#{id}", params: { keyword: { word: 'updated' } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['word']).to eq('updated')
      # Delete
      delete "/keywords/#{id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
