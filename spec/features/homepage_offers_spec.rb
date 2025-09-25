require "rails_helper"

RSpec.describe "Homepage Offers Section", :vcr, type: :feature do
  context "when there are no offers" do
    before do
      # Assuming your VCR recordings include a state where there are no offers
      visit root_path
    end

    it "does not show the offers section" do
      expect(page).not_to have_css("h2.govuk-heading-m", text: "Offers")
    end

    it "does not show offers in the service navigation" do
      expect(page).not_to have_css(".govuk-service-navigation__item a", text: "Offers")
    end

    it "does not show the 'Browse all offers' link" do
      expect(page).not_to have_link("Browse all offers", href: "/offers")
    end
  end

  context "when there are exactly 3 offers with images" do
    before do
      visit root_path
    end

    it "shows the offers section" do
      expect(page).to have_css("h2.govuk-heading-m", text: "Offers")
      expect(page).to have_css(".offers-grid-container .dfe-card", count: 3)
    end

    it "does not show the 'Browse all offers' link" do
      expect(page).not_to have_link("Browse all offers", href: "/offers")
    end
  end

  context "when there are more than 3 offers but only 3 with images" do
    before do
      visit root_path
    end

    it "shows the offers section with 3 offer cards" do
      expect(page).to have_css(".offers-grid-container .dfe-card", count: 3)
    end

    it "shows the 'Browse all offers' link" do
      expect(page).to have_link("Browse all offers", href: "/offers")
    end
  end

  context "when there are 3 offers without images" do
    before do
      visit root_path
    end

    it "shows all offers as bullet points" do
      expect(page).to have_css(".offer-list .offer-list-item", count: 3)
    end

    it "does not show offer images" do
      expect(page).not_to have_css(".dfe-card img")
    end

    it "does not show the 'Browse all offers' link" do
      expect(page).not_to have_link("Browse all offers", href: "/offers")
    end
  end

  context "when there are more than 3 offers and less than 3 have images" do
    before do
      visit root_path
    end

    it "shows all offers as bullet points" do
      expect(page).to have_css(".offer-list .offer-list-item", count: 3)
    end

    it "shows the 'Browse all offers' link" do
      expect(page).to have_link("Browse all offers", href: "/offers")
    end
  end
end
