require "rails_helper"

RSpec.describe "Solutions pages", :vcr, type: :feature do
  describe "GET /solutions/:slug" do
    before do
      visit solution_path("it-hardware")
    end

    it "returns a successful response" do
      expect(page).to have_http_status(:success)
    end

    it "displays the solution title" do
      expect(page).to have_content("IT Hardware")
    end

    it "displays the solution description" do
      expect(page).to have_content("A full range of IT hardware including new, refurbished, and remanufactured.")
    end

    it "displays key solution detail sections" do
      expect(page).to have_content("What it offers")
      expect(page).to have_content("Benefits")
    end

    it "displays related content section" do
      expect(page).to have_content("Related content")
    end

    it "displays the related content link" do
      expect(page).to have_link("Things to consider when buying IT")
    end
  end

  context "when solution has no related content" do
    before do
      visit solution_path("ict-procurement")
    end

    it "does not display related content section" do
      expect(page).not_to have_content("Related content")
    end
  end

  context "when displaying call to action button" do
    it "displays the default CTA text when no custom CTA is provided" do
      visit solution_path("it-hardware")
      expect(page).to have_link(
        "Visit the IT Hardware website",
        href: "/external-redirect?token=BAhJIlpodHRwczovL3d3dy5wcm9jdXJlbWVudHNlcnZpY2VzLmNvLnVrL291ci1zb2x1dGlvbnMvZnJhbWV3b3Jrcy90ZWNobm9sb2d5L2l0LWhhcmR3YXJlBjoGRVQ%3D--722dd2ff79eeec7c2bd089af5855aef1c4295a21b99ece32d7d5f639c17ff975",
        class: "govuk-button"
      )
    end

    it "displays the custom CTA text when provided" do
      visit solution_path("ict-procurement")
      expect(page).to have_link(
        "Go to site",
        href: "/external-redirect?token=BAhJIiNodHRwczovL3d3dy5ldmVyeXRoaW5naWN0Lm9yZy8GOgZFVA%3D%3D--09ac77a9d080f743bdb863a8a05dd18c27c3fa7edfbf34599385b05c024df5c7",
        class: "govuk-button"
      )
    end
  end
end
