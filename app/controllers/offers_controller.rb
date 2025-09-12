class OffersController < ApplicationController
  before_action :enable_search_in_header

  def index
    @offers = Offer.all

    @page_section_title = t(".section_title")
    @page_title = t(".title")
    @page_description = t(".description")
    @page_back_link = request.referer

    add_breadcrumb :home_breadcrumb_name, :home_breadcrumb_path
    render layout: "all_buying_options"
  end
end


