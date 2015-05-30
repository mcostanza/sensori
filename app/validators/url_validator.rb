class UrlValidator < ActiveModel::EachValidator
	def validate_each(record, attribute, value)
		begin
			URI.parse(value)
		rescue URI::InvalidURIError
			record.errors[attribute] << (options[:message] || 'is not a valid URL')
    end
	end
end