class SolutionsController < ApplicationController
  before_action :enable_search_in_header, except: :index

  def index
    @categories = Category.all
    render layout: "all_frameworks"
  end

  def show
    @solution = Solution.find_by_slug!(params[:slug])
    @category = Category.find_by_slug!(params[:category_slug])
  end
end
