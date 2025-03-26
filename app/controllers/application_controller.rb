class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  rescue_from ContentfulRecordNotFoundError, with: :record_not_found
  before_action :enable_search_in_header, :set_default_back_link

private

  def record_not_found(exception)
    @message = exception.message || "Record not found"
    render template: "errors/not_found", status: :not_found
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
