class CategoriesController < ApplicationController
  def index
    @categories = Category.all
    render layout: "homepage"
  end

  def show
    @category = Category.find_by_slug(params[:slug])
    raise ContentfulRecordNotFoundError, "Category not found" unless  @category
  end
end
