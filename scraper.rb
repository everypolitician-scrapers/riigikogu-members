
# Fetch member information from riigikogu.ee

require 'json'
require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '/tmp/open-uri'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def member_urls
  page = 'http://www.riigikogu.ee/index.php?id=34625&op2=print'
  noko = noko_for(page)
  noko.css('.DDW_Body ol li a').reject { |a| a.text == 'CV' }.map { |a| a['href'] + '&op2=print' }
end

def epost(txt)
  txt.gsub(' dot ','.').gsub(' at ','@')
end

def member_info(url)
  noko = noko_for(url)
  name = noko.css("div.category").text.split(':').last.strip
  img  = noko.css("img.Picture").attr('src')
  faction = noko.xpath("//div[contains(@class, 'Label') and normalize-space(text()) = 'Fraktsioon:']/following-sibling::div/a").text.strip
  area = noko.xpath("//div[contains(@class, 'Label') and normalize-space(text()) = 'Valimisringkond:']/following-sibling::div").text.strip
  email = epost(noko.xpath("//div[contains(@class, 'Label') and normalize-space(text()) = 'E-post:']/following-sibling::div/a").text.strip)
  puts "#{name} : #{faction} : #{area} : #{email} : #{img}"
end

member_urls.each do |u|
  member_info(u)
end
