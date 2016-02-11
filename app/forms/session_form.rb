class SessionForm
	attr_reader :session

	def initialize(session:, session_params:, sample_pack_params:)
		@session            = session
		@session_params     = session_params
		@sample_pack_params = sample_pack_params
	end

	def save
		begin
			ActiveRecord::Base.transaction do
				@session.update_attributes!(@session_params)

				@session.sample_packs.each do |sample_pack|
					if !sample_pack_urls.include?(sample_pack.url)
						sample_pack.deleted = true
						sample_pack.save!
					end
				end

				@sample_pack_params.each { |hash| create_or_update_sample_pack!(hash) }
			end

			true
		rescue ActiveRecord::RecordInvalid
			false
		end
	end

	private

	def create_or_update_sample_pack!(attributes)
		sample_pack = @session.sample_packs.where(url: attributes[:url]).first || @session.sample_packs.build
		sample_pack.update_attributes!(attributes)
	end

	def sample_pack_urls
		@_sample_pack_urls ||= @sample_pack_params.map { |hash| hash[:url] }
	end
end