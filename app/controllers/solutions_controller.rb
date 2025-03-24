class SolutionsController < ApplicationController
  before_action :enable_search_in_header, except: :index

  def index
    @solutions = Solution.all
    @sorted_categories = @solutions.each_with_object({}) { |solution, hash|
      solution.categories.each do |category|
        hash[category.title] ||= { slug: category.title, description: category.description, solutions: [] }
        hash[category.title][:solutions] << solution
      end
    }.sort_by { |category_slug, _category_data| category_slug }.to_h
    render layout: "all_buying_options"
  end

  def show
    @solution = Solution.find_by_slug!(params[:slug])
    @category = Category.find_by_slug!(params[:category_slug])
  end
end
