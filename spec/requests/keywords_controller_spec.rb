require 'rails_helper'

RSpec.describe KeywordsController, type: :request do
  let(:keyword) { Keyword.create!(word: 'testword') }

  describe 'GET /keywords' do
    it 'returns all keywords' do
      keyword
      get '/keywords'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).first['word']).to eq('testword')
    end
  end

  describe 'GET /keywords/:id' do
    it 'returns a keyword' do
      get "/keywords/#{keyword.id}"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['word']).to eq('testword')
    end
    it 'returns 404 for missing keyword' do
      get '/keywords/999999'
      expect(response).to have_http_status(:not_found).or have_http_status(:bad_request)
    end
  end

  describe 'POST /keywords' do
    it 'creates a keyword' do
      post '/keywords', params: { keyword: { word: 'newword' } }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['word']).to eq('newword')
    end
    it 'returns error for missing word' do
      post '/keywords', params: { keyword: { word: '' } }
      expect(response).to have_http_status(:unprocessable_entity).or have_http_status(:bad_request)
    end
  end

  describe 'PATCH /keywords/:id' do
    it 'updates a keyword' do
      patch "/keywords/#{keyword.id}", params: { keyword: { word: 'updated' } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['word']).to eq('updated')
    end
    it 'returns 404 for missing keyword' do
      patch '/keywords/999999', params: { keyword: { word: 'fail' } }
      expect(response).to have_http_status(:not_found).or have_http_status(:bad_request)
    end
  end

  describe 'DELETE /keywords/:id' do
    it 'deletes a keyword' do
      delete "/keywords/#{keyword.id}"
      expect(response).to have_http_status(:no_content)
    end
    it 'returns 404 for missing keyword' do
      delete '/keywords/999999'
      expect(response).to have_http_status(:not_found).or have_http_status(:bad_request)
    end
  end
end
