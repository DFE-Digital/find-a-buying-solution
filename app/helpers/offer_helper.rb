module OfferHelper
  def offer_cta(offer)
    offer.call_to_action.presence || t("offers.show.cta", title: offer.title)
  end
end
