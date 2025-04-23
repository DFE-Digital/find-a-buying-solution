module ApplicationHelper
  include MarkdownHelper
  include SvgHelper
  require "date"

  def safe_url(url)
    return "#" unless url.is_a?(String)
    return url if internal_path?(url)
    return "#" unless valid_uri?(url)
    return url if same_host?(url)

    # We're using this redirector so that we can track external link clicks
    # in dfe-analytics automatically without having to write custom JavaScript.
    # Even with custom JS, we'd still need to redirect the user after tracking
    # the event. So this is a cleaner approach with less code.
    token = REDIRECT_VERIFIER.generate(url)
    external_redirect_path(token: token)
  rescue URI::InvalidURIError
    "#"
  end

  def external_link_attributes(url)
    return {} unless url.is_a?(String)

    uri = URI.parse(url)
    if (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && uri.host != request.host
      { target: "_blank", rel: "noopener noreferrer" }
    else
      {}
    end
  rescue URI::InvalidURIError
    {}
  end

  def format_date(date_string)
    return "" if date_string.blank?

    I18n.l(Date.parse(date_string), format: :standard)
  end

private

  def internal_path?(url)
    url.start_with?("/")
  end

  def valid_uri?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  end

  def same_host?(url)
    uri = URI.parse(url)
    uri.host == request.host
  end
end
