class SolutionIndexer
  attr_reader :id

  INDEX = "solution-data".freeze

  def initialize(id:)
    @id = id
  end

  def create_index
    return false if entry.nil?

    response = index_document

    return true if index_created?(response["result"])

    false
  end

  def delete_index
    return false if entry.nil?

    response = delete_document

    return true if index_deleted?(response["result"])

    false
  end

private

  def index_created?(result)
    %w[created updated].include?(result)
  end

  def index_deleted?(result)
    result == "deleted"
  end

  def entry
    @entry ||= Solution.find_by_id!(id)
  end

  def index_document
    client.index(index: INDEX, id: id, body: body)
  end

  def delete_document
    client.delete(index: INDEX, id: id)
  end

  def body
    {
      id: entry.id,
      title: entry.title,
      description: entry.description,
      summary: entry.summary,
      slug: entry.slug,
      provider_reference: entry.provider_reference,
    }
  end

  def client
    @client ||= ELASTICSEARCH_CLIENT
  end
end
