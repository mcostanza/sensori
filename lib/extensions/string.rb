class String

	# "Mike".possessive => "Mike's"
	# "Jones".possessive => "Jones'"
	#
	def possessive
		suffix = self[-1] == "s" ? "'" : "'s"
		"#{self}#{suffix}"
	end

end
