class SearchController < ApplicationController
  def index
    # @search_results = ContentfulClient.entries(
    #   'query': params[:query]
    # ).select { |entry| %w[solution category].include?(entry.content_type.id) }
    @solutions = Solution.search(query: params[:query])
    @categories = Category.search(query: params[:query])
  end
end
