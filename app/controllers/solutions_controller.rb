class SolutionsController < ApplicationController
  before_action :enable_search_in_header

  def index
    @solutions = Solution.all
    @sorted_categories = @solutions.each_with_object({}) { |solution, hash|
      solution.categories.each do |category|
        hash[category.title] ||= { slug: category.title, description: category.description, solutions: [] }
        hash[category.title][:solutions] << solution
      end
    }.sort_by { |category_slug, _category_data| category_slug }.to_h
    @page_section_title = ct("solutions.index.all_buying_options_section_title")
    @page_title = ct("solutions.index.all_buying_options_title")
    @page_description = ct("solutions.index.all_buying_options_description")
    @page_back_link = request.referer
    render layout: "all_buying_options"
  end

  def show
    @solution = Solution.find_by_slug!(params[:slug])
    @category = Category.find_by_slug!(params[:category_slug])
    @page_section_title = ct("categories.show.section_title")
    @page_title = @solution.title
    @page_description = @solution.description
    @page_back_link = request.referer || category_path(@category)
  end
end
