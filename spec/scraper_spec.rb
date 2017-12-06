require 'spec_helper'

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
end

RSpec.describe 'Scraper' do
  let(:page) {
    HTTParty.get('http://johnsonsdictionaryonline.com/?page_id=50&whichLetter=Q')
  }
  let(:parse_page) { Nokogiri::HTML(page) }
  let(:agent) { Mechanize.new }
  let(:mech_page) {
    agent.get('http://johnsonsdictionaryonline.com/?page_id=50&whichLetter=Q')
  }
  let(:definitions) { Hash.new('Not found') }

  it 'should be true' do
    the_truth = true
    expect(the_truth).to be true
  end

  it 'should allow VCR gem' do
    VCR.use_cassette('synopsis') do
      response = Net::HTTP.get_response(URI('http://johnsonsdictionaryonline.com/?page_id=50&whichLetter=Q'))
      expect(response.code).to eq('200')
    end
  end

  it 'should return text of HTML element' do
    VCR.use_cassette('title') do
      title = parse_page.xpath('//title').text
      expect(title).to eq(
        ' » Alphabetical List of Entries - A Dictionary of the English Language - Samuel Johnson - 1755'
      )
    end
  end

  it 'should allow mechanize' do
    VCR.use_cassette('use_mechanize') do
      expect(mech_page).to be_truthy
    end
  end

  it 'should store definitions with default value' do
    expect(definitions['flunk']).to eq('Not found')
  end

  it 'should store links from table data' do
    VCR.use_cassette('get_links') do
      links = parse_page.xpath('//td/a')
      expect(links).not_to be_empty
    end
  end
end
