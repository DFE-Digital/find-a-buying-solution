class SearchController < ApplicationController
  before_action :disable_search_in_header

  def index
    # @search_results = ContentfulClient.entries(
    #   'query': params[:query]
    # ).select { |entry| %w[solution category].include?(entry.content_type.id) }
    @solutions = Solution.search(query: params[:query])
    @categories = Category.search(query: params[:query])
    @show_search_in_header = false
  end

private

  def disable_search_in_header
    @show_search_in_header = false
  end
end
