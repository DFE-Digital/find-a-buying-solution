class ContentfulTranslationService
  def translate(key, options = {})
    translation = fetch_translation(key)
    return nil if translation.nil?

    result = if options.any?
               begin
                 translation % options
               rescue KeyError, ArgumentError
                 translation
               end
             else
               translation
             end

    # Marking the result as HTML safe if the key ends with _html
    key.to_s.end_with?("_html") ? result.html_safe : result
  end

private

  def fetch_translation(key)
    entries = ContentfulClient.entries(
      content_type: "translation",
      'fields.key': key,
      limit: 1
    )

    entry = entries.first
    entry&.fields&.[](:value)
  end
end
