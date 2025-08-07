class ApplicationController < ActionController::Base
  include DfE::Analytics::Requests
  include Breadcrumbs
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  rescue_from ContentfulRecordNotFoundError, with: :record_not_found
  before_action :enable_search_in_header, :set_default_back_link, :canonical_url
  before_action :reload_translations

private

  def record_not_found
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end

  def enable_search_in_header
    @show_search_in_header = true
  end

  # rubocop:disable Naming/MemoizedInstanceVariableName
  def set_default_back_link
    @page_back_link ||= root_path
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName

  def reload_translations
    # Reload the backend if Contentful translations cache has expired
    unless Rails.cache.exist?(I18n::Backend::Contentful::CACHE_KEY)
      Rails.logger.info "Cache expired. Reloading translations..."
      I18n.backend.reload!
    end
  end

  def canonical_url
    @canonical_url ||= request.url
  end
end
