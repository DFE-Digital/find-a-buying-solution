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

  def usability_survey_url(url)
    base_url = "https://www.get-help-buying-for-schools.service.gov.uk/usability_surveys/new"
    safe_url = safe_url(url)
    return_url = safe_url == "#" ? request.original_url : safe_url

    params = {
      service: "find_a_buying_solution",
      return_url: UrlVerifier.generate(return_url),
    }
    "#{base_url}?#{params.to_query}"
  end

  def format_date(date_string)
    return "" if date_string.blank?

    I18n.l(Date.parse(date_string), format: :standard)
  end
end
