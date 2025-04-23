REDIRECT_VERIFIER = ActiveSupport::MessageVerifier.new(
  Rails.application.secret_key_base, digest: "SHA256"
)
