class ApplicationController < ActionController::Base
  include DfE::Analytics::Requests
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  rescue_from ContentfulRecordNotFoundError, with: :handle_contentful_record_not_found
  before_action :enable_search_in_header, :set_default_back_link

private

  def handle_contentful_record_not_found(exception)
    details = {
      message: exception.message,
      slug: exception.slug,
    }
    Rollbar.error(exception, details)
    record_not_found
  end

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
end
