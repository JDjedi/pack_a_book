require 'rubygems'
require 'nokogiri'
require 'sqlite3'
require 'pry'

class Startup
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
					new_locator = Locator.new
					new_locator.page_loader
				when '2'
					puts "***********************************************************************"
					sorter_exe = Sorter.new
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
end

class Locator
	def initialize
		@final_array = []
	end

	def page_loader													#load pages from directory
		foo = Dir.glob("data/*")
		foo.each do |x|
			file = File.open(x)
			page_parser(file)
		end
		puts "Array of books compiled!"
		create_books_table
		puts "Table made!"
	end

	def page_parser(file)											#Parse through each page send from page_loader()
		work_array = []
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
			work_array << x.text
			work_array.compact
		end
		work_array.each do |query|
			if query.include?('Shipping Weight:')
				weight_query = query.delete("^0-9.").to_f							#.chomp(" (View shipping rates and policies)")
				package_array << weight_query
			elsif query.include?('ISBN-10')
				isbn_query = query 
				package_array << isbn_query
			end
		end

		@final_array << package_array
	end

	def create_books_table
		puts "What would you like you book information file to be called?"
		book_info_title = gets.chomp
		puts "Creating table..."
		db = SQLite3::Database.new('db/' + book_info_title + '.db')
		db.execute %q{
			CREATE TABLE bookstack (
			Id INTEGER PRIMARY KEY,
			title VARCHAR(255),
			author VARCHAR(255),
			price DECIMAl(10,2),
			isbn VARCHAR(255),
			weight DECIMAl(10, 2) )
		}
		puts "Would you like to commit your current book information to the database?"
		puts "Enter 1 to confirm and 2 to abort."
		case gets.chomp
			when '1'
				update_books_table
			when '2'
				puts "Aborting, table has been made but not populated"
			else
				"Please select a valid option"
		end
	end

	def update_books_table
		puts "***************************************************************************************************************"
		puts "Please select the file you would like the book information to be populated with..."
		files = Dir.glob('db/*')
		files.each do |x|
			puts x
		end

		request = gets.chomp

		# begin
		# 	bank_db = SQLite3::Database.open "db_bank_file"
		# 	bank_db.transaction
		# 	bank_db.execute("UPDATE bookstack SET balance = ? WHERE account_number = ?", arg, @selected_account['account_number'])
		# 	bank_db.commit

		# rescue SQLite3::Exception => e 
		# 	puts "Exception occurred"
	 #   		puts e
	 #    	bank_db.rollback
	    
		# ensure
	 #    	bank_db.close if bank_db
		# end
	end

end
























class Sorter
	attr_reader :final_array

	def initalize(final_array)
		@array_of_books = final_array
	end

	def hello
		puts "Hello World!"
	end
end

run_program = Startup.new
run_program.main_menu



