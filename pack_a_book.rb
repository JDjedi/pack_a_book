require 'rubygems'
require 'nokogiri'
require 'json'
require 'neatjson'
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
			puts "Enter 1 to locate books relevant to your specifications, and pack them for export."
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
		send_to_sort
	end

	def page_parser(file)											#Parse through each page send from page_loader()
		detail_parsed_array = []
		book_info_hash = Hash.new

		read_html_doc = File.open(file) { |f| Nokogiri::HTML(f) }	#use Nokogirl parser
		
		book_info_hash[:title] = read_html_doc.css("#btAsinTitle").text
		book_info_hash[:author] = read_html_doc.css("#handleBuy > div.buying > span").text.strip.gsub(/\s+/, " ")

		price_query = read_html_doc.css("#actualPriceValue > b").text
		if price_query == "" or price_query == nil
			price_query = read_html_doc.css("#hardcover_meta_binding_winner > tr > td.price").text.strip.gsub(/\s+/, " ")
			book_info_hash[:price] = price_query.delete("^0-9.").to_f
		else
			book_info_hash[:price] = price_query.delete("^0-9.").to_f
		end

		read_html_doc.css("#productDetailsTable div ul li").each do |x|
			detail_parsed_array << x.text
			detail_parsed_array.compact
		end
		detail_parsed_array.each do |query|
			if query.include?('Shipping Weight:')
				weight_query = query.delete("^0-9.").to_f							
				book_info_hash[:weight] = weight_query
			elsif query.include?('ISBN-10')
				isbn_query = query 
				book_info_hash[:isbn] = isbn_query
			end
		end
		@work_array << book_info_hash
	end

	def send_to_sort
		puts "Array of books compiled!"
		puts
		sorter_exe = Sorter.new(@work_array)
		sorter_exe.sort
	end
end

class Sorter
	attr_accessor :work_array

	def initialize(work_array)
		@work_array = work_array
		@packing_array = []
		@box_array = []
	end

	def sort
		box = 0.0
		@work_array = @work_array.sort! { |x, y| x[:weight] <=> y[:weight] }

		while @work_array.length > 0 do
			if (@work_array[0][:weight].to_f + box) < 10.0
				box += @work_array[0][:weight].to_f
				@packing_array << @work_array.shift
			else
				box = 0.0
				@box_array << @packing_array
				@packing_array = []
			end
		end
		send_to_final
	end

	def send_to_final
		puts "Books sorted and packed!"
		puts
		final_product = FinalProduct.new(@box_array)
		final_product.output
	end
end

class FinalProduct
	attr_accessor :box_array

	def initialize(box_array)
		@final_order = []
		@box_array = box_array
		@time = Time.now.strftime('%e %b %Y - %H:%M:%S')
	end

	def output
		puts "Final Output:"
		puts
		box = Hash.new
		count = 0
		weight = 0

		@box_array.each do |box_content|
			count += 1
			box[:id] = count
			box_content.each do |x|
				weight = weight + x[:weight] 
			end
			box[:weight] = weight
			box[:contents] = box_content

			weight = 0
			@final_order << box 
			box = Hash.new
		end

		File.open('output/completed_order(' + @time.to_s + ').json.', 'w') do |f|
			@final_order.each do |x|
				f.puts JSON.neat_generate(x,wrap:50)
			end
		end
		puts "Processing complete!"
	end

end





















run_program = Locator.new
run_program.main_menu

