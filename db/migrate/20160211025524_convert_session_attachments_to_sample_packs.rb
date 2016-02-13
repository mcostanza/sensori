class ConvertSessionAttachmentsToSamplePacks < ActiveRecord::Migration
  def up
  	Session.find_each do |session|
  		if session.attachment_url.present?
	  		session.sample_packs.create(
	  			url: session.attachment_url,
	  			name: File.basename(URI.unescape(session.attachment_url))
	  		)
	  	end
  	end
  end
end
