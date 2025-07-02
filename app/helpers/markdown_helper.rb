module MarkdownHelper
  def render_markdown_to_html(markdown_content)
    return "" if markdown_content.blank?

    html = Kramdown::Document.new(markdown_content).to_html

    doc = Nokogiri::HTML.fragment(html)
    doc = update_class(doc, "h2", "govuk-heading-s")
    doc = update_class(doc, "p", "govuk-body")

    return doc.to_html.html_safe unless html.include?("href")

    doc.css("a[href]").each do |link|
      external_link_attributes(link["href"]).each do |key, value|
        link[key] = value
      end
    end

    doc = update_class(doc, "a[href]", "govuk-body-s")
    doc.to_html.html_safe
  end

  def update_class(doc, tag_type, class_name)
    doc.css(tag_type).each do |tag|
      unless tag["class"] && tag["class"].include?(class_name)
        tag["class"] = [tag["class"], class_name].compact.join(" ")
      end
    end

    doc
  end
end
