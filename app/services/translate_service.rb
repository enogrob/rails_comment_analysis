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
end