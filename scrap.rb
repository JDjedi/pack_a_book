def sorter
	weight_limit = 0.0
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




1.2,
4.1,
7.8,
2.6,
2.8,
7.6,
2.2,
9.4,
8.8,
1.4,
3.6,
3.2,
4.9,
6.4,
2.2,
3.6,
4.4,
1.4,
1.4,
5.6