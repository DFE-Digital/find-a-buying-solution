require "rails_helper"

RSpec.describe MarkdownHelper, type: :helper do
  describe "#render_markdown_to_html" do
    it "adds external link attributes to links" do
      markdown = "[Internal](/internal) [External](https://example.com)"
      html = helper.render_markdown_to_html(markdown)
      expect(html).to include('<a href="/internal" class="govuk-body-s">Internal</a>')
      expect(html).to include('<a href="https://example.com" target="_blank" rel="noopener noreferrer" class="govuk-body-s">External</a>')
    end
  end
end
