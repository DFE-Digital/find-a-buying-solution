module ApplicationHelper
  include MarkdownHelper
  include SvgHelper
  require "date"

  def safe_url(url)
    return "#" unless url.is_a?(String)

    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS) ? url : "#"
  rescue URI::InvalidURIError
    "#"
  end

  def format_date(date_string)
    return "" if date_string.nil? || date_string.strip.empty?

    Date.parse(date_string).strftime("%d/%m/%Y")
  end
end
