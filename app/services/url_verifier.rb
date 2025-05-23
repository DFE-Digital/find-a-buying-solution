class UrlVerifier
  def self.verifier
    @verifier ||= ActiveSupport::MessageVerifier.new(ENV.fetch("URL_VERIFIER_SECRET", "FAKE_SECRET"))
  end

  def self.verify_url(signed_url)
    verifier.verify(signed_url)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  def self.generate(url)
    verifier.generate(url)
  end
end
