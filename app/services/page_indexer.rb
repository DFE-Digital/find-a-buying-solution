require "opensearch/transport"

class PageIndexer
  attr_reader :id, :client

  INDEX = "page-data".freeze

  def initialize(id:)
    @client = SearchClient.instance
    @id = id
  end

  def index_document
    return false if entry.nil?

    response = client.index(index: INDEX, id: id, body: body)

    return true if index_created?(response["result"])

    false
  end

  def delete_document
    response = client.delete(index: INDEX, id: id)
    return true if index_deleted?(response["result"])

    false
  rescue OpenSearch::Transport::Transport::Errors::NotFound
    true
  end

  def find_document
    client.get(
      index: INDEX,
      id: id
    )
  rescue OpenSearch::Transport::Transport::Errors::NotFound
    nil
  end

private

  def index_created?(result)
    %w[created updated].include?(result)
  end

  def index_deleted?(result)
    result == "deleted"
  end

  def entry
    @entry ||= Page.find_by_id!(id)
  rescue ContentfulRecordNotFoundError
    nil
  end

  def body
    {
      id: entry.id,
      title: entry.title,
      description: entry.description,
      slug: entry.slug,
      body: entry.body,
    }
  end
end
