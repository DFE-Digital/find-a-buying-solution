class ApplicationController < ActionController::Base
  include DfE::Analytics::Requests
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  rescue_from ContentfulRecordNotFoundError, with: :record_not_found
  before_action :enable_search_in_header, :set_default_back_link

  helper_method :ct

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

  def ct(key, options = {})
    @translation_service ||= ContentfulTranslationService.new
    @translation_service.translate(key, options)
  end
end
