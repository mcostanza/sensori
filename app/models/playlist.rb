class Playlist < ActiveRecord::Base
  attr_accessible :link, :title, :bandcamp_album_id, :souncloud_uri

  attr_accessor :skip_external_id_sync

  validates :title, presence: true
  validates :link, presence: true, url: true

  before_save :reset_external_ids_if_necessary
  after_save :sync_external_ids_if_necessary

  def soundcloud?
  	URI.parse(self.link).host.include?("soundcloud.com")
  end

  def bandcamp?
  	URI.parse(self.link).host.include?("bandcamp.com")
  end

  def self.latest
    where('soundcloud_uri IS NOT NULL OR bandcamp_album_id IS NOT NULL').order('id DESC').limit(1).first
  end

  private

  def reset_external_ids_if_necessary
  	if link_changed?
      self.bandcamp_album_id = nil unless bandcamp?
      self.soundcloud_uri = nil unless soundcloud?
  	end
  end

  def sync_external_ids_if_necessary
  	if link_changed? && sync_external_id?
  		PlaylistWorker.perform_async(self.id)
  	end
  end

  def sync_external_id?
    if self.skip_external_id_sync
      false
    else
      soundcloud? || bandcamp?
    end
  end
end