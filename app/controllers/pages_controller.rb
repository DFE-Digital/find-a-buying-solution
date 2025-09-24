class PagesController < ApplicationController
  def show
    @page = Page.find_by_slug!(params[:slug])
    @page_title = @page.title
    add_breadcrumb :home_breadcrumb_name, :home_breadcrumb_path

    build_page_breadcrumbs(@page)
  end

private

  def build_page_breadcrumbs(page)
    node = page.parent
    trail = []
    depth = 0
    max_depth = 4

    while node && depth < max_depth
      depth += 1

      trail << node

      case node
      when Category
        break
      when Page
        node = node.parent
      else
        break
      end
    end

    if (category = trail.find { |n| n.is_a?(Category) })
      @category = category
    end

    trail.reverse_each do |n|
      case n
      when Category
        add_breadcrumb :category_breadcrumb_name, :category_breadcrumb_path
      when Page
        add_breadcrumb n.title, page_path(n.slug)
      end
    end
  end
end
