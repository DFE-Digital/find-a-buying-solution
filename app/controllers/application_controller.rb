class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  rescue_from ContentfulRecordNotFoundError, with: :record_not_found

private

  def record_not_found(exception)
    @message = exception.message || "Record not found"
    render template: "errors/not_found", status: :not_found
  end
end
