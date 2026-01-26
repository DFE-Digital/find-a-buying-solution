require "rails_helper"

RSpec.describe "ContentfulWebhooks", :vcr, type: :request do
  let(:entity_id) { "some_contentful_entry_id" }
  let(:secret) { "a_valid_mocked_signature" }
  let(:valid_headers) do
    {
      "X-Contentful-Webhook-Signature" => secret,
    }
  end

  # Contentful sends webhooks with sys.id and sys.contentType.sys.id
  let(:solution_params) do
    {
      "sys" => {
        "id" => entity_id,
        "contentType" => {
          "sys" => {
            "id" => "solution"
          }
        }
      }
    }
  end

  let(:page_params) do
    {
      "sys" => {
        "id" => entity_id,
        "contentType" => {
          "sys" => {
            "id" => "page"
          }
        }
      }
    }
  end

  let(:category_params) do
    {
      "sys" => {
        "id" => entity_id,
        "contentType" => {
          "sys" => {
            "id" => "category"
          }
        }
      }
    }
  end

  let(:unknown_content_type_params) do
    {
      "sys" => {
        "id" => "some_other_id",
        "contentType" => {
          "sys" => {
            "id" => "banner"
          }
        }
      }
    }
  end

  # Legacy format for backward compatibility
  let(:legacy_params) { { "entityId" => entity_id } }

  let(:solution_indexer_mock) { instance_double(SolutionIndexer) }
  let(:page_indexer_mock) { instance_double(PageIndexer) }
  let(:category_indexer_mock) { instance_double(CategoryIndexer) }

  before do
    allow(SolutionIndexer).to receive(:new).and_return(solution_indexer_mock)
    allow(PageIndexer).to receive(:new).and_return(page_indexer_mock)
    allow(CategoryIndexer).to receive(:new).and_return(category_indexer_mock)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("CONTENTFUL_WEBHOOK_SECRET").and_return(secret)
    allow(Rollbar).to receive(:error)
  end

  describe "POST #create" do
    context "when indexing a solution" do
      before do
        allow(solution_indexer_mock).to receive(:index_document).and_return(true)
      end

      it "returns a 200 OK status" do
        post contentful_webhooks_path, params: solution_params, headers: valid_headers
        expect(response).to have_http_status(:ok)
      end

      it "returns a success message" do
        post contentful_webhooks_path, params: solution_params, headers: valid_headers
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Webhook for entry #{entity_id} processed successfully.")
      end

      it "uses the SolutionIndexer" do
        post contentful_webhooks_path, params: solution_params, headers: valid_headers
        expect(SolutionIndexer).to have_received(:new).with(id: entity_id)
      end
    end

    context "when indexing a page" do
      before do
        allow(page_indexer_mock).to receive(:index_document).and_return(true)
      end

      it "returns a 200 OK status" do
        post contentful_webhooks_path, params: page_params, headers: valid_headers
        expect(response).to have_http_status(:ok)
      end

      it "uses the PageIndexer" do
        post contentful_webhooks_path, params: page_params, headers: valid_headers
        expect(PageIndexer).to have_received(:new).with(id: entity_id)
      end
    end

    context "when indexing a category" do
      before do
        allow(category_indexer_mock).to receive(:index_document).and_return(true)
      end

      it "returns a 200 OK status" do
        post contentful_webhooks_path, params: category_params, headers: valid_headers
        expect(response).to have_http_status(:ok)
      end

      it "uses the CategoryIndexer" do
        post contentful_webhooks_path, params: category_params, headers: valid_headers
        expect(CategoryIndexer).to have_received(:new).with(id: entity_id)
      end
    end

    context "when using legacy entityId format" do
      before do
        allow(solution_indexer_mock).to receive(:index_document).and_return(true)
      end

      it "returns a 200 OK status without content type (backward compatibility)" do
        post contentful_webhooks_path, params: legacy_params, headers: valid_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the document fails to index" do
      before do
        allow(solution_indexer_mock).to receive(:index_document).and_return(false)
      end

      it "returns a 422 Unprocessable Entity status" do
        post contentful_webhooks_path, params: solution_params, headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message" do
        post contentful_webhooks_path, params: solution_params, headers: valid_headers
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Failed to index the document for id #{entity_id}.")
      end

      it "logs the error to Rollbar" do
        post contentful_webhooks_path, params: solution_params, headers: valid_headers
        expect(Rollbar).to have_received(:error).with("Failed to index document in OpenSearch", hash_including(entry_id: entity_id))
      end
    end

    context "when the entity ID is missing" do
      let(:params_without_id) do
        {
          "sys" => {
            "contentType" => {
              "sys" => {
                "id" => "solution"
              }
            }
          }
        }
      end

      it "returns a 400 Bad Request status" do
        post contentful_webhooks_path, params: params_without_id, headers: valid_headers
        expect(response).to have_http_status(:bad_request)
      end

      it "returns an error message" do
        post contentful_webhooks_path, params: params_without_id, headers: valid_headers
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("The entity ID is missing from the request.")
      end

      it "logs the error to Rollbar" do
        post contentful_webhooks_path, params: params_without_id, headers: valid_headers
        expect(Rollbar).to have_received(:error).with("Contentful webhook missing entity ID", hash_including(:params_keys))
      end
    end

    context "when content type is not indexed" do
      it "returns 200 OK without indexing" do
        post contentful_webhooks_path, params: unknown_content_type_params, headers: valid_headers
        expect(response).to have_http_status(:ok)
        expect(SolutionIndexer).not_to have_received(:new)
        expect(PageIndexer).not_to have_received(:new)
        expect(CategoryIndexer).not_to have_received(:new)
      end
    end

    context "when signature is invalid" do
      it "returns 401 Unauthorized" do
        post contentful_webhooks_path, params: solution_params, headers: { "X-Contentful-Webhook-Signature" => "invalid" }
        expect(response).to have_http_status(:unauthorized)
      end

      it "logs the error to Rollbar" do
        post contentful_webhooks_path, params: solution_params, headers: { "X-Contentful-Webhook-Signature" => "invalid" }
        expect(Rollbar).to have_received(:error).with("Contentful webhook signature validation failed", hash_including(:has_secret))
      end
    end
  end

  describe "POST #destroy" do
    context "when deleting a solution" do
      before do
        allow(solution_indexer_mock).to receive(:delete_document).and_return(true)
      end

      it "returns a 200 OK status" do
        post delete_contentful_entry_path, params: solution_params, headers: valid_headers
        expect(response).to have_http_status(:ok)
      end

      it "returns a success message" do
        post delete_contentful_entry_path, params: solution_params, headers: valid_headers
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Webhook for entry #{entity_id} deletion processed successfully.")
      end

      it "uses the SolutionIndexer" do
        post delete_contentful_entry_path, params: solution_params, headers: valid_headers
        expect(SolutionIndexer).to have_received(:new).with(id: entity_id)
      end
    end

    context "when deleting a page" do
      before do
        allow(page_indexer_mock).to receive(:delete_document).and_return(true)
      end

      it "returns a 200 OK status" do
        post delete_contentful_entry_path, params: page_params, headers: valid_headers
        expect(response).to have_http_status(:ok)
      end

      it "uses the PageIndexer" do
        post delete_contentful_entry_path, params: page_params, headers: valid_headers
        expect(PageIndexer).to have_received(:new).with(id: entity_id)
      end
    end

    context "when deleting a category" do
      before do
        allow(category_indexer_mock).to receive(:delete_document).and_return(true)
      end

      it "returns a 200 OK status" do
        post delete_contentful_entry_path, params: category_params, headers: valid_headers
        expect(response).to have_http_status(:ok)
      end

      it "uses the CategoryIndexer" do
        post delete_contentful_entry_path, params: category_params, headers: valid_headers
        expect(CategoryIndexer).to have_received(:new).with(id: entity_id)
      end
    end

    context "when using legacy entityId format" do
      before do
        allow(solution_indexer_mock).to receive(:delete_document).and_return(true)
      end

      it "returns a 200 OK status without content type (backward compatibility)" do
        post delete_contentful_entry_path, params: legacy_params, headers: valid_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the document fails to delete" do
      before do
        allow(solution_indexer_mock).to receive(:delete_document).and_return(false)
      end

      it "returns a 422 Unprocessable Entity status" do
        post delete_contentful_entry_path, params: solution_params, headers: valid_headers
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns an error message" do
        post delete_contentful_entry_path, params: solution_params, headers: valid_headers
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Failed to delete the document for id #{entity_id}.")
      end

      it "logs the error to Rollbar" do
        post delete_contentful_entry_path, params: solution_params, headers: valid_headers
        expect(Rollbar).to have_received(:error).with("Failed to delete document from OpenSearch", hash_including(entry_id: entity_id))
      end
    end

    context "when the entity ID is missing" do
      let(:params_without_id) do
        {
          "sys" => {
            "contentType" => {
              "sys" => {
                "id" => "solution"
              }
            }
          }
        }
      end

      it "returns a 400 Bad Request status" do
        post delete_contentful_entry_path, params: params_without_id, headers: valid_headers
        expect(response).to have_http_status(:bad_request)
      end

      it "returns an error message" do
        post delete_contentful_entry_path, params: params_without_id, headers: valid_headers
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("The entity ID is missing from the request.")
      end
    end

    context "when content type is not indexed" do
      it "returns 200 OK without deleting" do
        post delete_contentful_entry_path, params: unknown_content_type_params, headers: valid_headers
        expect(response).to have_http_status(:ok)
        expect(SolutionIndexer).not_to have_received(:new)
        expect(PageIndexer).not_to have_received(:new)
        expect(CategoryIndexer).not_to have_received(:new)
      end
    end

    context "when signature is invalid" do
      it "returns 401 Unauthorized" do
        post delete_contentful_entry_path, params: solution_params, headers: { "X-Contentful-Webhook-Signature" => "invalid" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
