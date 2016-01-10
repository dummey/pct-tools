require 'anemone'
require 'nokogiri'
require 'csv'

def skip?(url)
  return true if url =~ /\.php/
  
  return true if 
    %w(
      http://planyourhike.com/planning/resup/
      http://planyourhike.com/planning/resup/_notes
      http://planyourhike.com/planning/resup/_notes/
      http://planyourhike.com/planning/resup/css/
      http://planyourhike.com/planning/resup/kmls/
      http://planyourhike.com/planning/resup/redsmeadow.pdf
      http://planyourhike.com/planning/
      http://planyourhike.com/planning/resup/null.html
      http://planyourhike.com/planning/resup/nullbc.html
      http://planyourhike.com/planning/resup/nullca.html
      http://planyourhike.com/planning/resup/nullcca.html
      http://planyourhike.com/planning/resup/nullnca.html
      http://planyourhike.com/planning/resup/nullor.html
      http://planyourhike.com/planning/resup/nullwa.html
    ).include? url

    return false
end

def _extract_from_core(html_doc, string)
  begin 
    html_doc.xpath("//*[contains(text(),'#{string}')]").first.parent.children.last.to_s.lstrip.gsub("\n", '').gsub("\t", '')
  rescue
    "ERROR"
  end
end

def parse_page(page)
  data = {}

  data[:url] = page.url.to_s

  html_doc = Nokogiri::HTML(page.body)

  data[:name] = html_doc.xpath("//h2").first.children.to_s
  data[:distance_from_trail] = _extract_from_core(html_doc, 'Distance from Trail')
  data[:distance_from_mexico] = _extract_from_core(html_doc, 'Distance from Mexico').gsub('Aproximately ', '').gsub(' trail miles', ' miles')
  data[:cheap_resupply] = _extract_from_core(html_doc, 'Inexpensive Trail Food Available')
  data[:post_office] = _extract_from_core(html_doc, 'Post Office')
  data[:other_info] = _extract_from_core(html_doc, 'Other Info')

  return data
end

def pretty_print(data)
  csv_string = CSV.generate({:force_quotes => true, :col_sep => "\t"}) do |csv|
    #cheating by relying on ruby hashes being ordered
    csv << data.first.keys.map(&:to_s)

    data.each do |entry|
      csv << entry.values
    end
  end

  puts csv_string
end

data = []
Anemone.crawl("http://planyourhike.com/planning/resup/", :depth_limit => 1) do |anemone|
  anemone.on_every_page do |page|
      #skip the root page
      next if skip? page.url.to_s

      data << parse_page(page)
  end
end

pretty_print(data)