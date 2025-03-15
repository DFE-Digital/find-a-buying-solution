class CategoriesController < ApplicationController
  before_action :enable_search_in_header, except:  %i[index, all]

  def index
    @categories = Category.all
    render layout: "homepage"
  end

  def show
    @category = Category.find_by_slug!(params[:slug])
    @subcategories = @category.subcategories
    @selected_subcategories = @subcategories.select { params[:subcategory_slugs]&.include?(it.slug) }
    @solutions = @category.filtered_solutions(subcategory_slugs: params[:subcategory_slugs]&.compact_blank)
  end

  def all
    @categories = Category.all
    render layout: "all_frameworks"
  end
end
