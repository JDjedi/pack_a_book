require 'rubygems'
require 'nokogiri'
require 'json'
require 'neatjson'
require 'pry'


#main class and parser
class Locator
	def initialize
		@parsed_content_array = []
		@data_source = Dir.glob("data/*")
		@next_step = Sort
	end

	def main_menu
		loop do
			puts 
			puts "***********************************************************************"
			puts "Welcome to Pack-A-Book!"
			puts "Please select an option: "
			puts "Enter the word 'execute' to locate books relevant to your specifications, and pack them for export."
			puts "Enter the word 'exit' to exit"
			puts "***********************************************************************"

			answer = gets.chomp
			answer.downcase!

			if answer == 'execute'
				page_loader
			elsif answer == 'exit'
				puts "Goodbye!"
				puts "***********************************************************************"
				puts
				exit
			else
				puts "***********************************************************************"
				"Please select a valid option"
			end
		end
	end

	def page_loader													
		input_data = @data_source
		input_data.each do |x|
			file = File.open(x)
			page_parser(file)
		end
		send_to_sort
	end

	def page_parser(file)											
		detail_parsed_array = []
		product_info_hash = Hash.new

		parsed_data_object = File.open(file) { |f| Nokogiri::HTML(f) }
		
		product_info_hash[:title] = parsed_data_object.css("#btAsinTitle").text
		product_info_hash[:author] = parsed_data_object.css("#handleBuy > div.buying > span").text.strip.gsub(/\s+/, " ")

		price_query = parsed_data_object.css("#actualPriceValue > b").text
		if price_query == "" or price_query == nil
			price_query = parsed_data_object.css("#hardcover_meta_binding_winner > tr > td.price").text.strip.gsub(/\s+/, " ")
			product_info_hash[:price] = price_query.delete("^0-9.").to_f
		else
			product_info_hash[:price] = price_query.delete("^0-9.").to_f
		end

		parsed_data_object.css("#productDetailsTable div ul li").each do |x|
			detail_parsed_array << x.text
			detail_parsed_array.compact
		end

		detail_parsed_array.each do |query|
			if query.include?('Shipping Weight:')
				weight_query = query.delete("^0-9.").to_f							
				product_info_hash[:weight] = weight_query
			elsif query.include?('ISBN-10')
				isbn_query = query 
				product_info_hash[:isbn] = isbn_query
			end
		end
		@parsed_content_array << product_info_hash
	end

	def send_to_sort
		puts "Array of books compiled...."
		puts
		sorter_exe = @next_step.new(@parsed_content_array)
		sorter_exe.sorter
	end
end

































#Sort books class
class Sort
	attr_accessor :parsed_content_array

	def initialize(parsed_content_array)
		@parsed_content_array = parsed_content_array
		@packing_array = []
		@package_array = []
		@next_step = FinalProduct
	end

	def sorter
		answer = []
		array = [1.2, 4.1, 7.8, 2.6, 2.8, 7.6, 2.2, 9.4, 8.8, 1.4, 3.6, 3.2, 4.9, 6.4, 2.2, 3.6, 4.4, 1.4, 1.4, 5.6]
		weight_target = 10.0

		while weight_target > 0 do

			example = (1..array.size).each_with_object([]) { |n,arr|
				array.combination(n).each { |a|
					 arr << a if a.reduce(:+) == weight_target } }

			weight_target = (weight_target - 0.1).round(1)
			answer << example.reverse
		end
		p answer



		exit







#		send_to_final
	end

	def send_to_final
		puts "Books sorted and packed...."
		puts
		final_product = @next_step.new(@package_array)
		final_product.final_output_generator
	end
end







































#arrange, package, and save data to file in JSON format
class FinalProduct
	attr_accessor :package_array

	def initialize(package_array)
		@package_array = package_array
		@final_order = []
		@time = Time.now.strftime('%e %b %Y - %H:%M:%S')
	end

	def final_output_generator
		final_order_hash = Hash.new
		box = Hash.new
		count = 0
		weight = 0

		@package_array.each do |box_content|
			count += 1
			box[:id] = count
			box_content.each do |x|
				weight = weight + x[:weight] 
			end
			box[:weight] = weight
			box[:contents] = box_content
			final_order_hash[:box] = box
			weight = 0
			@final_order << final_order_hash
			final_order_hash = Hash.new
			box = Hash.new
		end

		File.open('output/completed_order(' + @time.to_s + ').json.', 'w') do |f|
			@final_order.each do |x|
				f.puts JSON.neat_generate(x,wrap:40)
			end
		end

		puts "Processing complete!"
		puts "Output JSON file placed in folder output/..."
		puts
		puts "Goodbye!"
		puts "***********************************************************************"
		puts
		exit
	end
end


run_program = Locator.new
run_program.main_menu










