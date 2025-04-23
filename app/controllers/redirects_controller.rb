class RedirectsController < ApplicationController
  before_action :verify_external_url, only: :external

  def external
    redirect_to @verified_url, allow_other_host: true
  end

private

  def verify_external_url
    @verified_url = REDIRECT_VERIFIER.verify(params[:token])
    uri = URI.parse(@verified_url)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      redirect_to(root_path) and return
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature, URI::InvalidURIError
    redirect_to(root_path) and return
  end
end
