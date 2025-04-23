class Suffix
  include ActiveModel::Model

  attr_reader :title, :description

  def initialize(entry)
    @title = entry.fields[:title]
    @description = entry.fields[:description]
    super
  end

end
