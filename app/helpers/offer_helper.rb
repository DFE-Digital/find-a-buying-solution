module OfferHelper
  def offer_cta(offer)
    offer.call_to_action.presence || t("offers.show.cta", title: offer.title)
  end

  def show_browse_all_offers_link?(number_of_offers, featured_offers)
    # Determines when to display the "Browse all offers" link.
    # The link is shown if:
    # 1. The total number of offers is greater than the size of the featured offers.
    # 2. There are more than 3 featured offers, and all offers are featured.
    number_of_offers > featured_offers.size ||
      (featured_offers.size > 3 && number_of_offers == featured_offers.size)
  end

  def show_offers_section?(number_of_offers)
    # Determines when to display the offers section.
    # The link is shown only when there are 1 or more offers
    number_of_offers.positive?
  end
end
