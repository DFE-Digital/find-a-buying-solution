class SolutionsController < ApplicationController
  def show
    @solution = Solution.find_by_slug(params[:slug])
    @category = Category.find_by_slug(params[:category_slug])
  rescue ContentfulRecordNotFoundError
    @message = "Category > Solution not found"
    render template: "errors/not_found", status: :not_found
  end
end
