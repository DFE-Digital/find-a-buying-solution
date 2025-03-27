class CategoriesController < ApplicationController
  before_action :enable_search_in_header, except: :index

  def index
    @categories = Category.all
    render layout: "homepage"
  end

  def show
    @category = Category.find_by_slug!(params[:slug])
    @subcategories = @category.subcategories
    @selected_subcategories = @subcategories.select { params[:subcategory_slugs]&.include?(it.slug) }
    @solutions = @category.filtered_solutions(subcategory_slugs: params[:subcategory_slugs]&.compact_blank)
    @page_section_title = t(".section_title")
    @page_title = @category.title
    @page_description = @category.description
    @page_back_link = root_path

  end
end
