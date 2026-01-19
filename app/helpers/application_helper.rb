module ApplicationHelper
  include MarkdownHelper
  require "date"

  def fabs_govuk_link_to(link_text, url, **options)
    safe_url = safe_url(url)
    external_attrs = external_link_attributes(url)
    if is_external_link?(url)
      link_text = "#{h(link_text)}<span class=\"govuk-visually-hidden\"> #{h(t('shared.external_link.opens_in_new_tab'))}</span>".html_safe
    end

    govuk_link_to(link_text, safe_url, **options.merge(external_attrs))
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

  def customer_satisfaction_survey_url(source)
    uri = URI.join(ENV["GHBS_SERVER_URL"], "/customer_satisfaction_surveys/new")
    uri.query = {
      service: "find_a_buying_solution",
      source: source,
    }.to_query
    safe_url(uri.to_s)
  end

  def format_date(date_string)
    return "" if date_string.blank?

    I18n.l(Date.parse(date_string), format: :standard)
  rescue Date::Error => e
    Rollbar.error(e, date_string: date_string)
    ""
  end

  def page_title(page_title = nil)
    page_title.present? ? "#{h(page_title.strip)} - #{t('service.name')}" : t("service.name")
  end

  def service_navigation_items
    items = []
    items << { path: "/about-this-service", text: t("service.navigation.about") }
    items
  end

private

  def service_navigation_active?(path)
    request.path == path
  end

  def service_navigation_any_active?
    service_navigation_items.any? { |item| service_navigation_active?(item[:path]) }
  end
end
