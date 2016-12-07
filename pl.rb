require 'rubygems'
require 'nokogiri'
require 'pry'

class Locator
	def initialize
		@work_array = []
	end

	def main_menu
		loop do
			puts ""
			puts "***********************************************************************"
			puts "Welcome to Pack-A-Book!"
			puts "Please select an option: "
			puts "Enter 1 to locate books relevant to your specifications."
			puts "Enter 2 to sort the books into [X] amount of boxes for shipping."
			puts "Enter 9 to exit"
			puts "***********************************************************************"

			case gets.chomp
				when '1'
					puts "***********************************************************************"
					page_loader
				when '2'
					puts "***********************************************************************"
					sorter_exe = Sorter.new(@work_array)
					sorter_exe.hello
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
		puts "Array of books compiled!"
	end

	def page_parser(file)											#Parse through each page send from page_loader()
		detail_parsed_array = []
		package_array = []

		read_html_doc = File.open(file) { |f| Nokogiri::HTML(f) }	#use Nokogirl parser
		
		package_array << title_query = read_html_doc.css("#btAsinTitle").text
		package_array << author_query = read_html_doc.css("#handleBuy > div.buying > span").text.strip.gsub(/\s+/, " ")

		price_query = read_html_doc.css("#actualPriceValue > b").text.delete("^0-9.").to_f
		if price_query == ""
			price_query = read_html_doc.css("#hardcover_meta_binding_winner tr td.price").text.delete("^0-9.").to_f
			package_array << price_query
		else
			package_array << price_query
		end

		read_html_doc.css("#productDetailsTable div ul li").each do |x|
			detail_parsed_array << x.text
			detail_parsed_array.compact
		end
		detail_parsed_array.each do |query|
			if query.include?('Shipping Weight:')
				weight_query = query.delete("^0-9.").to_f							
				package_array << weight_query
			elsif query.include?('ISBN-10')
				isbn_query = query 
				package_array << isbn_query
			end
		end

		@work_array << package_array
	end

	def final_output
		weight_sorted_array = @work_array.sort { |a, b| a[4] <=> b[4] }
		puts weight_sorted_array
	end
end

class Sorter
	attr_accessor :work_array

	def initalize(work_array)
		@array_of_books = work_array
	end

	def hello
		puts "Hello World!"
		@array_of_books.each do |x|
			puts x
		end
	end
end

run_program = Locator.new
run_program.main_menu

