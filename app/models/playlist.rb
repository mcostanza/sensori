class Playlist < ActiveRecord::Base
  attr_accessible :link, :title, :bandcamp_album_id

  validates :title, presence: true
  validates :link, presence: true, url: true

  before_save :reset_bandcamp_album_id_if_necessary
  after_save :sync_bandcamp_album_id_if_necessary

  def soundcloud?
  	URI.parse(self.link).host.include?("soundcloud.com")
  end

  def bandcamp?
  	URI.parse(self.link).host.include?("bandcamp.com")
  end

  private

  def reset_bandcamp_album_id_if_necessary
  	if link_changed? && !bandcamp?
  		self.bandcamp_album_id = nil
  	end
  end

  def sync_bandcamp_album_id_if_necessary
  	if link_changed? && bandcamp?
  		BandcampPlaylistWorker.perform_async(self.id)
  	end
  end
end