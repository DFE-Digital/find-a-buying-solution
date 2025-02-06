class Category
  # include ActiveModel::Model
  # include ActiveModel::Conversion
  # include ActiveModel::Serialization
  # include ActiveModel::Naming

  attr_reader :id, :title, :summary, :description, :slug

  def self.all
    ContentfulClient.entries(content_type: 'category')
  end
end
