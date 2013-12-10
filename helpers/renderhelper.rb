module RenderHelper
	#
	#=== <p></p>内の改行を有効にします
	# 条件：<p>は入れ子にならない
	#
	def self.enableBR(in_str)
		pos = 0
		result = ""
		while index = in_str.index('<p>', pos)
			if pos == 0
				result << in_str[0, index]
			end
			next_index = in_str.index('<p>', index + 1)
			if next_index.nil?
				next_index = in_str.size
			end
			substr = in_str[index, next_index - index]

			p_end = substr.index('</p>')
			target_str = p_end.nil? ? substr : substr[0, p_end]
			result << target_str.gsub(/\n/, "<br>\n")
			unless p_end.nil?
				result << substr[p_end, substr.size - p_end]
			end

			pos = index + 1
		end
		if pos == 0
			result << in_str
		end
		return result
	end
end # Bookdown