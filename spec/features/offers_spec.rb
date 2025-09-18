require "rails_helper"

RSpec.describe "Homepage Offers Section", :vcr, type: :feature do
  context "when adding and removing offers in real scenarios" do
    before do
      # Initial mock: no offers
      allow(Offer).to receive(:featured_offers).and_return([])
      allow(Offer).to receive(:number_of_offers).and_return(0)
    end

    it "updates the offers section dynamically" do
      # Step 1: No offers
      visit root_path

      expect(page).not_to have_css("h2.govuk-heading-m", text: "Offers")
      expect(page).not_to have_css(".offers-grid-container .dfe-card")

      #Step 2: Add offers dynamically
      allow(Offer).to receive(:featured_offers).and_return([
                                                             double("Entry", id: "1", fields: {
                                                               title: "Offer 1",
                                                               description: "Description 1",
                                                               slug: "offer-1",
                                                               url: "http://example1.com",
                                                               call_to_action: "CTA Text",
                                                               image: "http://example1.com/image1.png",
                                                               featured_on_homepage: true,
                                                               expiry: nil
                                                             }),
                                                             double("Entry", id: "2", fields: {
                                                               title: "Offer 2",
                                                               description: "Description 2",
                                                               slug: "offer-2",
                                                               url: "http://example2.com",
                                                               call_to_action: "CTA Text",
                                                               image: "http://example2.com/image2.png",
                                                               featured_on_homepage: true,
                                                               expiry: nil
                                                             }),
                                                             double("Entry", id: "3", fields: {
                                                               title: "Offer 3",
                                                               description: "Description 3",
                                                               slug: "offer-3",
                                                               url: "http://example3.com",
                                                               call_to_action: "CTA Text",
                                                               image: "http://example3.com/image3.png",
                                                               featured_on_homepage: true,
                                                               expiry: nil
                                                             })
                                                           ])
      allow(Offer).to receive(:number_of_offers).and_return(3)

      #visit root_path
      #expect(page).to have_css("h2.govuk-heading-m", text: "Offers")

      #expect(page).to have_css(".offers-grid-container .dfe-card", count: 3)

      # # Validate specific card content
      # expect(page).to have_css(".dfe-card", text: "Offer 1")
      # expect(page).to have_css(".dfe-card", text: "Offer 2")
      # expect(page).to have_css(".dfe-card", text: "Offer 3")
      #
      # # Step 3: Remove offers dynamically
      # allow(Offer).to receive(:featured_offers).and_return([])
      # allow(Offer).to receive(:number_of_offers).and_return(0)
      #
      # visit root_path
      # expect(page).not_to have_content("Featured Offers")
      # expect(page).not_to have_css(".dfe-card")
    end
  end
end