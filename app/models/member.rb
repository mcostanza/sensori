class Member < ActiveRecord::Base
  attr_accessible :admin, :email, :image_url, :name, :slug, :soundcloud_id, :soundcloud_access_token

  has_many :tracks, :dependent => :destroy

  validates :soundcloud_id, :presence => true, :uniqueness => true
  validates :name, :presence => true
  validates :slug, :presence => true, :uniqueness => true
  validates :image_url, :presence => true
  validates :soundcloud_access_token, :presence => true  

  attr_accessor :soundcloud_tracks

  def soundcloud_tracks(reload = false)
    if reload
      @soundcloud_tracks = Sensori::Soundcloud.app_client.get("/users/#{self.soundcloud_id}/tracks")
    else
      @soundcloud_tracks ||= Sensori::Soundcloud.app_client.get("/users/#{self.soundcloud_id}/tracks")
    end
  end

  def sync_soundcloud_tracks
    self.soundcloud_tracks(:reload).each do |soundcloud_track|
      track = self.tracks.find_or_initialize_by_soundcloud_id(soundcloud_track.id)
      track.update_attributes({
        :title => soundcloud_track.title,
        :permalink_url => soundcloud_track.permalink_url,
        :artwork_url => soundcloud_track.artwork_url,
        :stream_url => soundcloud_track.stream_url,
        :posted_at => Time.parse(soundcloud_track.created_at)
      })
    end
  end
end
