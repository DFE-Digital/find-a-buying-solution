class Solution
  include ActiveModel::Model

  attr_reader :id, :title, :description, :summary, :slug, :provider_name, :url, :category

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @summary = entry.fields[:summary]
    @description = entry.fields[:description]
    @slug = entry.fields[:slug]
    @provider_name = entry.fields[:provider_name]
    @url = entry.fields[:url]
    @category = entry.fields[:category]
  end
end
