def sorter
	weight_limit 10.0
	@parsed_content_array = @parsed_content_array.sort! { |x, y| x[:weight] <=> y[:weight] }


	while @parsed_content_array.length > 0 do
		if (@parsed_content_array[0][:weight].to_f + weight_limit) < 10.0
			weight_limit += @parsed_content_array[0][:weight].to_f
			@packing_array << @parsed_content_array.shift
		else
			weight_limit = 0.0
			@package_array << @packing_array
			@packing_array = []
		end
	end
	send_to_final
end


	array = [1.2, 4.1, 7.8, 2.6, 2.8, 7.6, 2.2, 9.4, 8.8, 1.4, 3.6, 3.2, 4.9, 6.4, 2.2, 3.6, 4.4, 1.4, 1.4, 5.6]
	weight_target = 10.0

	example = (1..array.size).each_with_object([]) { |n,arr|
		array.combination(n).each { |a|
			 arr << a if a.reduce(:+) == weight_target } }

	example.reverse.each do |x|
		p x
		puts
	end

1.4
3.6
2.2
1.4
1.4
1.2
3.2
5.6
6.4
3.6
7.8
2.2
4.1  
2.6  
2.8  
7.6  
9.4  
8.8  
4.9  
4.4  
