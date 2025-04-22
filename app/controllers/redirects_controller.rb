class RedirectsController < ApplicationController
  def external
    target_url = params[:url]
    uri = URI.parse(target_url)

    if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      redirect_to target_url, allow_other_host: true
    else
      redirect_to root_path
    end
  rescue URI::InvalidURIError
    redirect_to root_path
  end
end
