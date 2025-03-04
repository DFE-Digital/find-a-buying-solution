class CategoriesController < ApplicationController
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
end
