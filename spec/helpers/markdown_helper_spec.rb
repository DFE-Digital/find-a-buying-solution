require "rails_helper"

RSpec.describe MarkdownHelper, type: :helper do
  describe "#render_markdown_to_html" do
    it "adds external link attributes to links" do
      markdown = "[Internal](/internal) [External](https://example.com)"
      html = helper.render_markdown_to_html(markdown)
      expect(html).to include('<a href="/internal" class="govuk-link govuk-body-s">Internal</a>')
      expect(html).to include('<a href="https://example.com" target="_blank" rel="noopener noreferrer" class="govuk-link govuk-body-s">External</a>')
    end

    it "add the correct css class for h2 and paragraph tags" do
      markdown = "## This a heading\nThis is a random paragraph"
      html = helper.render_markdown_to_html(markdown)
      expect(html).to include('<h2 id="this-a-heading" class="govuk-heading-m">This a heading</h2>')
      expect(html).to include('<p class="govuk-body">This is a random paragraph</p>')
    end

    it "add no css class for h1 heading" do
      markdown = "# H1 heading"
      html = helper.render_markdown_to_html(markdown)
      expect(html).to include('<h1 id="h1-heading">H1 heading</h1>')
    end
  end
end
