class ConvertSessionAttachmentsToSamplePacks < ActiveRecord::Migration
  def up
  	Session.find_each do |session|
  		session.sample_packs.create(
  			url: session.attachment_url,
  			name: "Samples for #{session.title}"
  		)
  	end
  end
end
