class ElasticsearchClient
  include Singleton
  extend Forwardable

  def_delegators :@client, :get, :delete, :index, :search

  def initialize
    @client = build_client
  end

private

  def build_client
    url = %w[ELASTICSEARCH_URL FOUNDELASTICSEARCH_URL]
      .map { ENV[it] }.find { it }
    return DummyClient.new unless url

    ::Elasticsearch::Client.new(
      url: url,
      api_key: ENV["ELASTICSEARCH_API_KEY"],
      verify_elasticsearch_product: false
    )
  end

  class DummyClient
    NotConfigured = Class.new(StandardError)

    def get(*, **, &) = raise_not_configured
    def delete(*, **, &) = raise_not_configured
    def index(*, **, &) = raise_not_configured
    def search(*, **, &) = raise_not_configured

  private

    def raise_not_configured(*, **)
      raise NotConfigured, "Elastic search client is not configured"
    end
  end
end
