class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def show
    @category = Category.find_by_slug(params[:slug])
  rescue ContentfulRecordNotFoundError
    render plain: "Category not found", status: :not_found
  end
end
