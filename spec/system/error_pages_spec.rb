require "rails_helper"

RSpec.describe "Error pages" do
  let(:rendered_footer) do
    controller = ApplicationController.new
    controller.request = ActionDispatch::TestRequest.create
    controller.render_to_string(
      partial: "shared/dfe_footer",
      layout: false
    ).squish
  end

  let(:error_pages) do
    {
      "404" => File.read(Rails.root.join("public/404.html")),
      "500" => File.read(Rails.root.join("public/500.html")),
    }
  end

  it "ensures error pages have identical footer to the application footer" do
    error_pages.each do |error_code, content|
      error_page_footer = content.match(/<footer.*?<\/footer>/m).to_s.squish

      expect(error_page_footer).to eq(rendered_footer), "#{error_code}.html footer differs from application footer partial. Run `rake footer:update_static_pages` to update it automatically."
    end
  end
end
