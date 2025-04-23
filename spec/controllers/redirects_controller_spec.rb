require "rails_helper"

RSpec.describe RedirectsController, type: :controller do
  describe "GET #external" do
    def perform_request_for(url)
      token = REDIRECT_VERIFIER.generate(url)
      get :external, params: { token: token }
    end

    it "redirects to the verified URL" do
      url = "https://foo.example.com/bar"
      perform_request_for(url)
      expect(response).to redirect_to(url)
    end

    it "escapes the URL properly" do
      url = "https://external.com/path?q=1&t=2"
      perform_request_for(url)
      expect(response).to redirect_to(url)
    end

    it "handles URLs with existing query params and special chars" do
      url = "https://external.com/path?q=hello world&t=test+this"
      perform_request_for(url)
      expect(response).to redirect_to(url)
    end

    it "rejects an invalid token" do
      get :external, params: { token: "bogus" }
      expect(response).to redirect_to(root_path)
    end
  end
end
