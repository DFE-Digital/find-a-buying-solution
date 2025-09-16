require "rails_helper"

RSpec.describe "Offers", :vcr, type: :request do
  describe "GET /offers" do
    before do
      get offers_path
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "sets correct HTML title tag" do
      expect(response.body).to include("<title>#{I18n.t('offers.index.title')} - #{I18n.t('service.name')}</title>")
    end

    it "sets correct breadcrumb" do
      expect(response.body).to include('<a class="govuk-breadcrumbs__link" href="/">Home</a>')
    end

    it "displays offers list" do
      expect(response.body).to include("provider-expires chevron-card-list")
    end
  end
end
