class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def not_found
    @message ||= "Page not found"
    render "not_found", status: :not_found
  end

  def internal_server_error
    render status: :internal_server_error
  end
end
