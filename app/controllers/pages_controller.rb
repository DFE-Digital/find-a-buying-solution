class PagesController < ApplicationController
  def show
    @page = Page.find_by_slug!(params[:slug])
    @page_title = @page.title
    add_breadcrumb :home_breadcrumb_name, :home_breadcrumb_path

    build_page_breadcrumbs(@page)
  end

  private

  def build_page_breadcrumbs(page)
    parent_path = page.parent_page_path
    visited_paths = []
    trail = []

    while parent_path.present? && !visited_paths.include?(parent_path)
      visited_paths << parent_path
      route = (Rails.application.routes.recognize_path(parent_path) rescue nil)
      break unless route

      if route[:controller] == "categories" && route[:action] == "show"
        category = Category.find_by_slug!(route[:slug])
        @category = category
        trail << [:category, category]
        break
      elsif route[:controller] == "pages" && route[:action] == "show"
        parent_page = Page.find_by_slug!(route[:slug])
        trail << [:page, parent_page]
        parent_path = parent_page.parent_page_path
      else
        break
      end
    end

    trail.reverse_each do |type, node|
      if type == :category
        @category = node
        add_breadcrumb :category_breadcrumb_name, :category_breadcrumb_path
      else
        add_breadcrumb node.title, page_path(node.slug)
      end
    end
  end
end
