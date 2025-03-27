namespace :footer do
  desc "Update footer content in static pages"
  task update_static_pages: :environment do
    footer_content = ApplicationController.renderer.render(
      partial: "shared/dfe_footer",
      layout: false
    ).gsub(/<!--.*?-->/m, "")
    %w[404 500].each do |page|
      file_path = Rails.public_path.join("#{page}.html")
      next unless File.exist?(file_path)

      content = File.read(file_path)
      updated_content = content.gsub(
        %r{<footer.*?</footer>}m,
        footer_content
      )
      File.write(file_path, updated_content)
    end
  end
end
