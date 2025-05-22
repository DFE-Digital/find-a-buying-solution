require "rails_helper"

RSpec.describe "BFYS Solutions API", :vcr, type: :request do
  describe "GET /bfys/solutions" do
    context "when solutions exist" do
      before do
        get "/bfys/solutions"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns JSON in the correct format" do
        json = JSON.parse(response.body)

        expect(json).to be_an(Array)
        expect(json.first).to include(
          "provider" => hash_including(
            "initials" => be_a(String),
            "title" => be_a(String)
          ),
          "cat" => hash_including(
            "title" => be_a(String),
            "ref" => be_a(String)
          ),
          "links" => be_an(Array),
          "ref" => be_a(String),
          "title" => be_a(String),
          "url" => be_a(String),
          "descr" => be_a(String),
          "expiry" => be_a(String),
          "body" => be_a(String)
        )
      end
    end
  end
end
