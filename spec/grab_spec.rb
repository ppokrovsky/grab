require 'spec_helper'
require 'nokogiri'

describe Grab do
  after{ Dir.foreach('./tmp') {|f| fn = File.join('./tmp', f); File.delete(fn) if f != '.' && f != '..'} }

  context ".runner" do
    before do
      doc = Nokogiri::HTML(open('http://www.fun-box.ru'))
      @images_on_page = doc.css('img').map{ |i| i['src'] }.uniq.count
    end
    it "saves all images from page to directory" do
      Grab.new.runner('www.fun-box.ru', './tmp')
      Dir.entries('./tmp').count.should == @images_on_page + 2
    end
  end

  context ".fetch" do
    it "fetches image to Tempfile" do
      Grab.new.fetch('http://www.fun-box.ru/logo.png').should be_kind_of(Tempfile)
    end
  end

  context ".save" do
    before{ @image = Grab.new.fetch('http://www.fun-box.ru/logo.png') }
    it "saves image to directory" do
      Grab.new.save(@image, "logo.png", "./tmp")
      File.open("./tmp/logo.png").should be_kind_of(File)
    end
  end

  context ".rel_to_abs" do
    before{ @img_srcs = %w(http://www.domain.com/image.png /image.png) }
    context "with absolute url" do
      it "does nothing" do
        Grab.new.rel_to_abs("www.domain.com", @img_srcs)[0].should == "http://www.domain.com/image.png"
      end
    end
    context "with relative url" do
      it "prepends url with domain name and http" do
        Grab.new.rel_to_abs("www.domain.com", @img_srcs)[1].should == "http://www.domain.com//image.png"
      end
    end
  end
end
