require "rails_helper"

RSpec.describe "Solutions", :vcr, type: :request do
  describe "GET /solutions/:slug" do
    before do
      get solution_path("it-hardware")
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "sets correct HTML title tag" do
      expect(response.body).to include("<title>IT Hardware - #{I18n.t('service.name')}</title>")
    end
  end

  describe "GET /solutions" do
    before do
      get solutions_path
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "sets correct HTML title tag" do
      expect(response.body).to include("<title>#{I18n.t('solutions.index.all_buying_options_title')} - #{I18n.t('service.name')}</title>")
    end
  end
end
