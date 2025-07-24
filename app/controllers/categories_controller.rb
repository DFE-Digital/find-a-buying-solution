class CategoriesController < ApplicationController
  before_action :enable_search_in_header, except: :index

  def index
    @categories = Category.all
    @energy_banner = Banner.find_by_slug("energy-for-schools")
    render layout: "homepage"
  end

  def show
    add_breadcrumb :home_breadcrumb_name, :root_path

    @category = Category.find_by_slug!(params[:slug])
    @subcategories = @category.subcategories
    @selected_subcategories = @subcategories.select { params[:subcategory_slugs]&.include?(it.slug) }
    @solutions = @category.filtered_solutions(subcategory_slugs: params[:subcategory_slugs]&.compact_blank)
    @dfe_solutions, @other_solutions = @solutions.partition(&:buying_option_type)
    @page_section_title = t(".section_title")
    @page_header_class = "category-header"
    @page_title = @category.title
    @page_description = @category.description
    @category_slug = @category.slug
  end
end
