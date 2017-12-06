require 'httparty'
require 'nokogiri'
require 'rubygems'
require 'mechanize'

BASE_URL = 'http://johnsonsdictionaryonline.com'.freeze
LETTERS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N',
           'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'W', 'X', 'Y', 'Z'].freeze
start_time = Time.now

LETTERS.each do |letter|
  noko_page = HTTParty.get("#{BASE_URL}/?page_id=50&whichLetter=#{letter}")
  parse_page = Nokogiri::HTML(noko_page)
  agent = Mechanize.new
  mech_page = agent.get("#{BASE_URL}/?page_id=50&whichLetter=#{letter}")
  definitions = Hash.new('Not found')
  links = []

  link_names = parse_page.xpath('//td/a')
  link_names.each do |tag|
    links << tag.text unless tag =~ /.~/
  end

  links.each do |link|
    next_page = mech_page.link_with(text: "#{link}").click
    definitions["#{link}"] = next_page.parser.css('//*[@id="storycontent"]/div').text.strip
  end

  text_file = File.open("all_entries/#{letter[0]}", 'a')
  definitions.each do |key, value|
    text_file << "\n#{key}"
    text_file << "#{value}\n"
  end
  text_file.close
end

puts "MADE IT! It took #{((Time.now - start_time) / 60.0).round(2)} minutes."
