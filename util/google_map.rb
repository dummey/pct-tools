#https://maps.googleapis.com/maps/api/place/textsearch/xml?query=acton post office on pacific crest trail&type=post_office&key=#{GOOGLE_MAP_API}
require 'rest-client'
require 'nokogiri'

require_relative '../supersecret.rb'

def lookup_post_office(text)
  place = lookup_place(text, 'post_office')
  lookup_details(place[:place_id])
end

def lookup_place(text, type)
  result = Nokogiri::XML(
    RestClient.get('https://maps.googleapis.com/maps/api/place/textsearch/xml', 
      {:params => {:query => text, :type => type, :key => GOOGLE_MAPS_API_KEY}}
    )
  )

  {
    :name => result.xpath('//result[1]/name').text,
    :address => result.xpath('//result[1]/formatted_address').text,
    :place_id =>result.xpath('//result[1]/place_id').text,
  }
end

def lookup_details(place_id)
  result = Nokogiri::XML(
    RestClient.get('https://maps.googleapis.com/maps/api/place/details/xml', 
      {:params => {:placeid => place_id, :key => GOOGLE_MAPS_API_KEY}}
    )
  )

  {
    :name => result.xpath('//result[1]/name').text,
    :formatted_phone_number => result.xpath('//result[1]/formatted_phone_number').text,
    :formatted_address => result.xpath('//result[1]/formatted_address').text,
    :weekday_text => result.xpath('//result[1]/opening_hours/weekday_text').children.map(&:to_s).join(", "),
  }
end

puts lookup_post_office("Ashland post office on pacific crest trail")