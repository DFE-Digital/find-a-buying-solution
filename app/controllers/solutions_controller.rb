class SolutionsController < ApplicationController
  before_action :enable_search_in_header, except: :index

  def index
    @solutions = Solution.all
    render layout: "all_buying_options"
  end

  def show
    @solution = Solution.find_by_slug!(params[:slug])
    @category = Category.find_by_slug!(params[:category_slug])
  end
end
