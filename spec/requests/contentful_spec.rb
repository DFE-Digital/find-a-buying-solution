require 'contentful'
require 'dotenv/load'
require 'rspec'

# Needs the following ENV variables to be set before running the RSpec
ENV['CONTENTFUL_SPACE_ID']
ENV['CONTENTFUL_ACCESS_TOKEN']
ENV['CONTENTFUL_ENTRY_ID']

RSpec.describe 'Contentful Entry through Contentful Delivery API' do
    let(:client) { Contentful::Client.new(space: ENV['CONTENTFUL_SPACE_ID'], access_token: ENV['CONTENTFUL_ACCESS_TOKEN']) }
    let(:entry) { instance_double(Contentful::Entry, fields: { title: 'FABS Title', desc: 'FABS Description' }) }

    before do
        allow(client).to receive(:entry).with(ENV['CONTENTFUL_ENTRY_ID']).and_return(entry)
    end

  it 'retrieves the title of the FABS entry' do
    expect(client.entry(ENV['CONTENTFUL_ENTRY_ID']).fields[:title]).to eq('FABS Title')
  end

  it 'retrieves the description of the FABS entry' do
    expect(client.entry(ENV['CONTENTFUL_ENTRY_ID']).fields[:desc]).to eq('FABS Description')
  end
end

