module ApplicationHelper
  include MarkdownHelper
  include SvgHelper
  require "date"

  def safe_url(url)
    return "#" unless url.is_a?(String)

    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS) ? url : "#"
  rescue URI::InvalidURIError => e
    Rollbar.error(e, url: url)
    "#"
  end

  def format_date(date_string)
    return "" if date_string.blank?

    I18n.l(Date.parse(date_string), format: :standard)
  rescue Date::Error => e
    Rollbar.error(e, date_string: date_string)
    ""
  end
end
