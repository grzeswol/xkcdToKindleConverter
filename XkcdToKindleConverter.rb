require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'

XKCD_URL = 'http://xkcd.com/'
XKCD_FILE = 'temp/xkcd.html'

def main

	puts 'Type number of the first comic that you want to download:'
	first_num = gets.to_i

	puts 'Now type number of the last one:'
	sec_num = gets.to_i


	create_directories
	create_files(first_num, sec_num)

	while first_num <= sec_num do
		number = first_num
		page_url = "#{XKCD_URL}#{number}"
		picture_source, text, title = extract_pic_info(page_url)
		print %'Downloading #{number} comic... '
		download_picture(picture_source, "#{number}")
		xkcd_file_chunk = %!<h2>#{number}.#{title}</h2><p><img src="img/#{number}.png" /></p><p>#{text}</p><mbp:pagebreak />\n!
		append_to_file(XKCD_FILE, xkcd_file_chunk)
		puts %'Done!\n'
		first_num += 1
	end
	xkcd_end_chunk = %!<mbp:pagebreak /></body></html>!
	append_to_file(XKCD_FILE, xkcd_end_chunk)
end

def append_to_file(file, text)
	File.open(file, 'a') do |fo|
		fo.write(text)
	end
end


def create_files(first_comic, last_comic)
	File.open(XKCD_FILE, 'wb') do |fo|
		fo.write("<html><head><title>XKCD Comic #{first_comic} - #{last_comic}</title><body>")
	end
end


def create_directories
	Dir.mkdir('temp')
	Dir.mkdir('temp/img')
end


def download_picture(url, name)
	File.open("temp/img/#{name}.png", 'wb') do |fo|
		fo.write open(url).read 
	end
end

def extract_pic_info(page_url)
	page = Nokogiri::HTML(open(page_url))
	div =  page.css('div#comic img')
	temp = div.css('img')
	picture_source = temp[0]['src']
	text = temp[0]['title']
	title = temp[0]['alt']
	return picture_source, text, title
end


main
system(`start /wait kindlegen.exe #{XKCD_FILE} -o xkcd.mobi`)
FileUtils.cp('temp/xkcd.mobi', File.expand_path(File.dirname(__FILE__)))
FileUtils.rm_r('temp')
puts 'All done!'
