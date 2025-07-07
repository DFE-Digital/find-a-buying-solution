module Breadcrumbs
  extend ActiveSupport::Concern

  included do
    def home_breadcrumb_name
      "Home"
    end
    helper_method :home_breadcrumb_name

    def home_breadcrumb_path
      root_path
    end
    helper_method :home_breadcrumb_path

    def category_breadcrumb_name
      @category.title
    end
    helper_method :category_breadcrumb_name

    def category_breadcrumb_path
      category_path(@category)
    end
    helper_method :category_breadcrumb_path

    def solution_breadcrumb_path
      solution_path(slug: @solution.slug)
    end
    helper_method :solution_breadcrumb_path

    def solution_breadcrumb_name
      @solution.title
    end
    helper_method :solution_breadcrumb_name
  end
end
