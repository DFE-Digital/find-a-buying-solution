module MarkdownHelper
  def render_markdown_to_html(markdown_content)
    return "" if markdown_content.blank?

    Kramdown::Document.new(markdown_content).to_html.html_safe
  end
end
