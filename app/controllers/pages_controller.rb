class PagesController < ApplicationController
  def show
    @page = Page.find_by_slug!(params[:slug])
    @page_title = @page.title
    add_breadcrumb :home_breadcrumb_name, :home_breadcrumb_path

    # Traverse parent_page_path upwards to build breadcrumbs
    parent_path = @page.parent_page_path
    visited = []
    trail = []
    while parent_path.present? && !visited.include?(parent_path)
      visited << parent_path
      begin
        route = Rails.application.routes.recognize_path(parent_path)
      rescue ActionController::RoutingError
        break
      end

      case [route[:controller], route[:action]]
      when ["categories", "show"]
        category = Category.find_by_slug!(route[:slug])
        @category = category
        trail << { type: :category, category: category }
        break
      when ["pages", "show"]
        parent_page = Page.find_by_slug!(route[:slug])
        trail << { type: :page, page: parent_page }
        parent_path = parent_page.parent_page_path
      else
        break
      end
    end

    # Add crumbs in root-to-leaf order
    trail.reverse_each do |crumb|
      if crumb[:type] == :category
        @category = crumb[:category]
        add_breadcrumb :category_breadcrumb_name, :category_breadcrumb_path
      else
        add_breadcrumb crumb[:page].title, page_path(crumb[:page].slug)
      end
    end
  end
end
