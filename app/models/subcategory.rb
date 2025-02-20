class Subcategory
  include ActiveModel::Model

  attr_reader :id, :title, :slug, :category

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @slug = entry.fields[:slug]
  end
end
