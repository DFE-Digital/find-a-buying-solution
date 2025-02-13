class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def show
    @category = Category.find_by_slug(params[:slug])
  rescue ContentfulRecordNotFoundError
    @message = "Category not found"
    render template: "errors/not_found", status: :not_found
  end
end
