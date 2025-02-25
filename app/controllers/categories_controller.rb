class CategoriesController < ApplicationController
  def index
    @categories = Category.all
    render layout: "homepage"
  end

  def show
    @category = Category.find_by_slug!(params[:slug])
    @subcategories = @category.subcategories
    @solutions = @category.filtered_solutions(subcategory_slugs: params[:subcategory_slugs]&.compact_blank)
  end
end
