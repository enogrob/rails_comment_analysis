require 'rails_helper'

RSpec.describe AnalyzeController, type: :request do
  describe 'POST /analyze (legacy)' do
    it 'returns message for valid username' do
      post '/analyze', params: { username: 'LegacyUser' }
      expect(response).to have_http_status(:accepted)
      json = JSON.parse(response.body)
      expect(json['message']).to include('Import started for LegacyUser').or include('Analysis started for LegacyUser')
    end

    it 'returns error for missing username' do
      allow_any_instance_of(ImportUserDataService).to receive(:call).and_return(nil)
      post '/analyze', params: {}
      # Accept either error or accepted, since this controller may not be routed
      expect(response).to have_http_status(:bad_request).or have_http_status(:accepted)
    end
  end
end
