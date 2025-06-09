require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#fabs_govuk_link_to" do
    it "adds external link attributes for external URLs" do
      result = helper.fabs_govuk_link_to("External", "https://example.com")
      expect(result).to include('rel="noopener noreferrer"')
      expect(result).to include('target="_blank"')
    end

    it "does not add external link attributes for internal URLs" do
      result = helper.fabs_govuk_link_to("Internal", "/internal-path")
      expect(result).not_to include('rel="noopener noreferrer"')
      expect(result).not_to include('target="_blank"')
    end

    it "preserves additional options" do
      result = helper.fabs_govuk_link_to("Link", "/path", class: "custom-class")
      expect(result).to include('class="govuk-link custom-class"')
    end
  end

  describe "#page_title" do
    context "when page_title is nil" do
      it "returns just the service name" do
        expect(helper.page_title(nil)).to eq(I18n.t("service.name"))
      end
    end

    context "when page_title is blank" do
      it "returns just the service name" do
        expect(helper.page_title("")).to eq(I18n.t("service.name"))
      end
    end

    context "when page_title is present" do
      it "returns page title with service name" do
        expect(helper.page_title("Custom Page")).to eq("Custom Page - #{I18n.t('service.name')}")
      end
    end
  end
end
