class SolutionsController < ApplicationController
  def show
    @solution = Solution.find_by_slug!(params[:slug])
    @category = Category.find_by_slug!(params[:category_slug])
  end
end
