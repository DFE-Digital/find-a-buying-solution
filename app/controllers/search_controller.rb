class SearchController < ApplicationController
  # These are the limits for the Contentful search API
  MAX_QUERY_LENGTH = 2000
  MAX_WORDS = 25

  before_action :disable_search_in_header

  def index
    @solutions = []
    @categories = []
    @results_count = 0

    unless invalid_query?(params[:query])
      query = params[:query].strip
      @solutions = Solution.search(query: query)
      @categories = Category.search(query: query)
      @results_count = @solutions.count + @categories.count
    end
  rescue Contentful::BadRequest
    @validation_error = :contentful_error
  end

private

  def disable_search_in_header
    @show_search_in_header = false
  end

  def invalid_query?(query)
    if query.blank?
      @validation_error = :empty
      true
    elsif query.length > MAX_QUERY_LENGTH
      @validation_error = :too_long
      true
    elsif query.split(/\s+/).size > MAX_WORDS
      @validation_error = :too_many_words
      true
    else
      false
    end
  end
end
