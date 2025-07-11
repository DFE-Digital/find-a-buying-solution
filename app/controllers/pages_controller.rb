class PagesController < ApplicationController
  def show
    @page = Page.find_by_slug!(params[:slug])
    @page_title = @page.title
    add_breadcrumb :home_breadcrumb_name, :home_breadcrumb_path
  end
end
