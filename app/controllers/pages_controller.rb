class PagesController < ApplicationController
  def show
    @page = Page.find_by_slug!(params[:slug])
    @page_back_link = request.referer || root_path
    @page_title = @page.title
  end
end
