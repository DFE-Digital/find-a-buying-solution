class ContentfulWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    result = SolutionIndexer.new(id: id).create_index

    if result
      render json: { message: "Webhook received successfully" }, status: :ok
    else
      render json: { error: "The id #{id} is missing." }, status: :bad_request
    end
  end

  def destroy
    result = SolutionIndexer.new(id: id).delete_index

    if result
      render json: { message: "Webhook received successfully" }, status: :ok
    else
      render json: { error: "The id #{id} is missing." }, status: :bad_request
    end
  end

private

  def id
    params["entityId"]
  end
end
