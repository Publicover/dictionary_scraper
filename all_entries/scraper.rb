require 'httparty'
require 'nokogiri'
require 'rubygems'
require 'mechanize'

class SJScraper
  BASE_URL = 'http://johnsonsdictionaryonline.com/'.freeze
  EXTENSION = '?page_id=50&whichLetter='
  LETTERS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N',
             'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'W', 'X', 'Y', 'Z'].freeze
  start_time = Time.now
  definitions = Hash.new('Not found')

  def get_noko_page(base_url, extension)
    page = HTTParty.get("#{base_url}/#{extension}")
    Nokogiri::HTML(page)
  end

  def get_mech_page(base_url, extension)
    agent = Mechanize.new
    agent.get("#{base_url}/#{extension}")
  end

  def get_link_names(parsed_html_page)
    link_names = parsed_hmml_page.xpath('//td/a')
    link_names.each do |tag|
      links << tag.text
    end
  end

  def click_page_links(mech_page, link_names)
    link_names.each do |link|
      next_page = mech_page.link_with(text: "#{link}").click
      definitions["#{link}"] = next_page.parser.css('//*[@id="storycontent"]/div').text.strip
    end
  end

  def output_defitions
    definitions.each do |key, value|
      text_file << "\n#{key}"
      text_file << "#{value}\n"
    end
    text_file.close
  end

# LETTERS.each do |letter|
#   noko_page = HTTParty.get("#{BASE_URL}/?page_id=50&whichLetter=#{letter}")
#   parse_page = Nokogiri::HTML(noko_page)
#   agent = Mechanize.new
#   mech_page = agent.get("#{BASE_URL}/?page_id=50&whichLetter=#{letter}")
#   definitions = Hash.new('Not found')
#   links = []
#
#   link_names = parse_page.xpath('//td/a')
#   link_names.each do |tag|
#     links << tag.text
#   end
#
#   links.each do |link|
#     next_page = mech_page.link_with(text: "#{link}").click
#     definitions["#{link}"] = next_page.parser.css('//*[@id="storycontent"]/div').text.strip
#   end
#
#   text_file = File.open("#{letter[0]}", 'a')
#   definitions.each do |key, value|
#     text_file << "\n#{key}"
#     text_file << "#{value}\n"
#   end
#   text_file.close
# end
#
# puts "MADE IT! It took #{(Time.now - start_time)/60.0} minutes."
