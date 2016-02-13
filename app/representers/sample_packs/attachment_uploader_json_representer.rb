module SamplePacks
	class AttachmentUploaderJSONRepresenter
		def initialize(sample_pack)
			@sample_pack = sample_pack
		end

		def to_hash
			{
				attachment_url: @sample_pack.url,
				attachment_name: @sample_pack.name
			}
		end

		def to_json
			to_hash.to_json
		end
	end
end
