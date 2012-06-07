require 'open-uri'
require 'nokogiri'

class Grab
  def runner(url, path)
    threads = []
    doc = Nokogiri::HTML(open("http://#{url}"))
    img_srcs = doc.css('img').map{ |i| i['src'] }.uniq
    img_srcs = rel_to_abs(url, img_srcs)
    img_srcs.each do |img_src|
      threads << Thread.new(img_src) do
        name = img_src.match(/^http:\/\/.*\/(.*)$/)[1]
        image = fetch img_src
        save(image, name, path)
      end
    end
    threads.each{ |thread| thread.join }
  end

  def fetch(img_src)
    puts "Fetching #{img_src}\n"
    image = open(img_src)
  end

  def save(image, name, path)
    File.open("#{path}/#{name}", "wb") do |file|
      file.write(image.read)
    end
  end

  def rel_to_abs(url, img_srcs)
    img_srcs.each_with_index do |img_src, index|
      img_srcs[index] = "http://#{url}/#{img_src}" unless img_src.match(/http:\/\//)
    end
    img_srcs
  end
end
