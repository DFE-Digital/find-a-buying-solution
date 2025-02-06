class Category
  attr_reader :id, :title, :summary, :description, :slug

  def self.all
    ContentfulClient.entries(content_type: 'category')
  end
end
