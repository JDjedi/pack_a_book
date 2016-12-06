require 'rubygems'
require 'nokogiri'
require 'pry'

class Locator
	def main_menu
		loop do
			puts ""
			puts "***********************************************************************"
			puts "Welcome to Pack-a-back!"
			puts "Please select an option: "
			puts "Enter 1 to locate books relevant to your specifications."
			puts "Enter 9 to exit"
			puts "***********************************************************************"

			case gets.chomp
				when '1'
					puts "***********************************************************************"
					page_loader
				when '9'
					puts "***********************************************************************"
					puts "Goodbye!"
					puts "***********************************************************************"
					exit
				else
					puts "***********************************************************************"
					"Please select a valid option"
			end
		end
	end

	def page_loader													#load pages from directory
		foo = Dir.glob("data/*")
		foo.each do |x|
			file = File.open(x)
			page_parser(file)
		end
	end

	def page_parser(file)											#Parse through each page send from page_loader()
		work_array = []
		final_array = []
		read_html_doc = File.open(file) { |f| Nokogiri::HTML(f) }	#use Nokogirl parser
		
		final_array << title_query = read_html_doc.css("#btAsinTitle").text
		final_array << author_query = read_html_doc.css("#handleBuy > div.buying > span").text.strip.gsub(/\s+/, " ")

		price_query = read_html_doc.css("#actualPriceValue > b").text
		if price_query == ""
			price_query = read_html_doc.css("#hardcover_meta_binding_winner tr td.price").text.strip.gsub(/\s+/, " ")
			final_array << price_query
		else
			final_array << price_query
		end

		read_html_doc.css("#productDetailsTable div ul li").each do |x|
			work_array << x.text
			work_array.compact
		end
		work_array.each do |query|
			if query.include?('Shipping Weight:')
				weight_query = query.chomp(" (View shipping rates and policies)")
				final_array << weight_query
			elsif query.include?('ISBN-10')
				isbn_query = query 
				final_array << isbn_query
			end
		end

		final_array.each do |output|
			p output
		end
		puts ""
	end
end

test1 = Locator.new
test1.main_menu



