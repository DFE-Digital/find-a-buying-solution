class ContentfulWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  INDEXERS = {
    "solution" => SolutionIndexer,
    "page" => PageIndexer,
    "category" => CategoryIndexer,
  }.freeze

  def create
    unless valid_signature?
      Rollbar.error("Contentful webhook signature validation failed", {
        headers: contentful_headers,
        has_secret: secret.present?
      })
      return head :unauthorized
    end

    return head :ok unless indexer_class

    if id.present?
      result = indexer_class.new(id: id).index_document

      if result
        render json: { message: "Webhook for entry #{id} processed successfully." }, status: :ok
      else
        Rollbar.error("Failed to index document in OpenSearch", {
          entry_id: id,
          content_type: content_type,
          webhook_topic: request.headers["X-Contentful-Topic"],
          webhook_name: request.headers["X-Contentful-Webhook-Name"]
        })
        render json: { error: "Failed to index the document for id #{id}." }, status: :unprocessable_content
      end
    else
      Rollbar.error("Contentful webhook missing entity ID", {
        params_keys: params.keys,
        content_type: content_type,
        webhook_topic: request.headers["X-Contentful-Topic"],
        webhook_name: request.headers["X-Contentful-Webhook-Name"]
      })
      render json: { error: "The entity ID is missing from the request." }, status: :bad_request
    end
  rescue StandardError => e
    Rollbar.error(e, {
      entry_id: id,
      content_type: content_type,
      webhook_topic: request.headers["X-Contentful-Topic"],
      action: "create"
    })
    render json: { error: "Internal server error processing webhook." }, status: :internal_server_error
  end

  def destroy
    unless valid_signature?
      Rollbar.error("Contentful webhook signature validation failed (delete)", {
        headers: contentful_headers,
        has_secret: secret.present?
      })
      return head :unauthorized
    end

    return head :ok unless indexer_class

    if id.present?
      result = indexer_class.new(id: id).delete_document

      if result
        render json: { message: "Webhook for entry #{id} deletion processed successfully." }, status: :ok
      else
        Rollbar.error("Failed to delete document from OpenSearch", {
          entry_id: id,
          content_type: content_type,
          webhook_topic: request.headers["X-Contentful-Topic"],
          webhook_name: request.headers["X-Contentful-Webhook-Name"]
        })
        render json: { error: "Failed to delete the document for id #{id}." }, status: :unprocessable_content
      end
    else
      Rollbar.error("Contentful webhook missing entity ID (delete)", {
        params_keys: params.keys,
        content_type: content_type,
        webhook_topic: request.headers["X-Contentful-Topic"]
      })
      render json: { error: "The entity ID is missing from the request." }, status: :bad_request
    end
  rescue StandardError => e
    Rollbar.error(e, {
      entry_id: id,
      content_type: content_type,
      webhook_topic: request.headers["X-Contentful-Topic"],
      action: "destroy"
    })
    render json: { error: "Internal server error processing webhook." }, status: :internal_server_error
  end

private

  def id
    params.dig("sys", "id") || params.dig(:sys, :id) || params["entityId"]
  end

  def content_type
    params.dig("sys", "contentType", "sys", "id") ||
      params.dig(:sys, :contentType, :sys, :id)
  end

  def indexer_class
    INDEXERS[content_type]
  end

  def valid_signature?
    secret == signature
  end

  def secret
    ENV["CONTENTFUL_WEBHOOK_SECRET"]
  end

  def signature
    request.headers["X-Contentful-Webhook-Signature"]
  end

  def contentful_headers
    request.headers.to_h.select { |k, _| k.to_s.start_with?("X-Contentful", "HTTP_X_CONTENTFUL") }
  end
end
