require 'rails_helper'

RSpec.describe TranslateService do
  describe '.translate' do
    let(:text) { 'hello' }
    let(:target_lang) { 'pt' }
    let(:response_double) { double(parsed_response: { 'translatedText' => 'olá' }, body: '') }

    before do
      allow(TranslateService).to receive(:post).and_return(response_double)
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:warn)
      allow(Rails.logger).to receive(:error)
    end

    it 'returns translated text on success' do
      expect(TranslateService.translate(text, target_lang)).to eq('olá')
    end

    it 'retries on rate limit error and then returns translation' do
      error_response = double(parsed_response: { 'error' => 'Verlangsamung' }, body: '')
      expect(TranslateService).to receive(:post).and_return(error_response, response_double)
      expect(TranslateService).to receive(:sleep).with(3)
      expect(TranslateService.translate(text, target_lang)).to eq('olá')
    end

    it 'returns nil on StandardError' do
      allow(TranslateService).to receive(:post).and_raise(StandardError.new('fail'))
      expect(TranslateService.translate(text, target_lang)).to be_nil
    end
  end
end
