require "rails_helper"

RSpec.describe MarkdownHelper, type: :helper do
  describe "#render_markdown_to_html" do
    it "adds external link attributes to links" do
      markdown = "[Internal](/internal) [External](https://example.com)"
      html = helper.render_markdown_to_html(markdown)
      expect(html).to include('<a href="/internal">Internal</a>')
      expect(html).to include('<a href="https://example.com" target="_blank" class="govuk-body-s govuk-body-s" rel="noopener noreferrer">External</a>')
    end
  end
end
