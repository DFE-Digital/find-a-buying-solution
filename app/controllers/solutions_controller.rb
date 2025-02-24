class SolutionsController < ApplicationController
  def show
    @solution = Solution.find_by_slug(params[:slug])
    @category = Category.find_by_slug(params[:category_slug])

    raise ContentfulRecordNotFoundError, "Category > Solution not found" unless @solution && @category
  end
end
