require 'rails_helper'

RSpec.describe 'Integration', type: :request do
  # ...existing tests...

  describe 'GET /progress/:job_id' do
    it 'returns job progress' do
      get '/progress/123'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include('job_id' => '123', 'progress' => '100%')
    end
  end

  describe 'POST /analyze with missing params' do
    it 'returns error for missing username' do
      post '/analyze', params: {}.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
      expect(response).to have_http_status(:bad_request).or have_http_status(:unprocessable_entity).or have_http_status(:not_found)
    end
  end

  describe 'Keyword approval integration' do
    it 'approves comments after keyword is added' do
      user = User.create!(username: 'IntegrationUser', external_id: 99)
      post = Post.create!(user: user, external_id: 99, title: 'Integration', body: 'Integration')
      comment = Comment.create!(post: post, external_id: 99, body: 'foo bar', state: 'new', approved: nil)
      expect(comment.approved).to be_nil

      post '/keywords', params: { keyword: { word: 'foo' } }
      post '/keywords', params: { keyword: { word: 'bar' } }
      comment.reload
      expect(comment.approved).to eq(true)
      expect(comment.state).to eq('approved')
    end
  end
end

class TranslateService
  include HTTParty
  base_uri 'https://de.libretranslate.com'

  def self.translate(text, target_lang = 'pt', retries = 3)
    response = post(
      '/translate',
      body: {
        q: text,
        source: 'en',
        target: target_lang,
        format: 'text'
        # api_key: 'YOUR_API_KEY' # Uncomment if you have an API key
      }.to_json,
      headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    )
    Rails.logger.info "LibreTranslate response: #{response.body}" # Debug line
    parsed = response.parsed_response
    if parsed.is_a?(Hash) && parsed['error']&.include?('Verlangsamung') && retries > 0
      Rails.logger.warn "Rate limit hit, retrying in 3 seconds... (#{retries} retries left)"
      sleep 3
      return translate(text, target_lang, retries - 1)
    end
    parsed['translatedText']
  rescue StandardError => e
    Rails.logger.error("Translation failed: #{e.message}")
    nil
  end
  
  # Mock translation method for testing purposes 
  # def self.translate(text, target_lang = 'pt', retries = 3)
  #   "[PT] #{text}" # Mock translation
  # end
end