module MarkdownHelper
  def render_markdown_to_html(markdown_content)
    return "" if markdown_content.blank?

    html = Kramdown::Document.new(markdown_content).to_html
    doc = Nokogiri::HTML.fragment(html)

    doc.css("a").each do |link|
      external_link_attributes(link["href"]).each do |key, value|
        link[key] = value
      end
    end

    doc.to_html.html_safe
  end
end
