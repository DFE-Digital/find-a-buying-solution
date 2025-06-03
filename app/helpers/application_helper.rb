module ApplicationHelper
  include MarkdownHelper
  include SvgHelper
  require "date"

  def fabs_govuk_link_to(text, url, **options)
    safe_url = safe_url(url)
    external_attrs = external_link_attributes(url)
    govuk_link_to(text, safe_url, **options.merge(external_attrs))
  end

  def is_external_link?(url)
    return false unless url.is_a?(String)

    begin
      uri = URI.parse(url)
      return false unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

      uri.host != request.host
    rescue URI::InvalidURIError
      false
    end
  end

  def external_link_attributes(url)
    is_external_link?(url) ? { target: "_blank", rel: "noopener noreferrer" } : {}
  end

  def safe_url(url)
    return "#" unless url.is_a?(String)

    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS) ? url : "#"
  rescue URI::InvalidURIError => e
    Rollbar.error(e, url: url)
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
  rescue Date::Error => e
    Rollbar.error(e, date_string: date_string)
    ""
  end
end
