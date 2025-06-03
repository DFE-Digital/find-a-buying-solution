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
end
