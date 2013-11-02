class Member < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :admin, :email, :image_url, :name, :slug, :soundcloud_id, :soundcloud_access_token, :full_name, :city, :country, :bio

  has_many :tracks, :dependent => :destroy
  has_many :tutorials, :dependent => :destroy
  has_many :submissions, :dependent => :destroy

  validates :soundcloud_id, :presence => true, :uniqueness => true
  validates :name, :presence => true
  validates :slug, :presence => true, :uniqueness => true
  validates :image_url, :presence => true
  validates :soundcloud_access_token, :presence => true  

  after_commit :sync_soundcloud_tracks_in_background, :on => :create

  attr_accessor :soundcloud_tracks

  friendly_id :slug

  auto_html_for :bio do
    html_escape
    link :target => "_blank", :rel => "nofollow"
    simple_format
  end

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
      artwork_url = soundcloud_track.artwork_url.gsub(/-\w+\.jpg/, "-t500x500.jpg") if soundcloud_track.artwork_url.present?
      track.update_attributes({
        :title => soundcloud_track.title,
        :permalink_url => soundcloud_track.permalink_url,
        :artwork_url => artwork_url || self.image_url,
        :stream_url => soundcloud_track.stream_url,
        :posted_at => Time.parse(soundcloud_track.created_at)
      })
    end
  end

  def sync_soundcloud_profile
    soundcloud_profile = Sensori::Soundcloud.app_client.get("/users/#{self.soundcloud_id}")
    image_url = soundcloud_profile.avatar_url.gsub(/-\w+\.jpg/, "-t500x500.jpg")
    self.update_attributes({
      :name => soundcloud_profile.username,
      :slug => soundcloud_profile.permalink,
      :image_url => image_url,
      :full_name => soundcloud_profile.full_name,
      :bio => soundcloud_profile.description,
      :city => soundcloud_profile.city,
      :country => soundcloud_profile.country
    })
  end

  def sync_soundcloud_tracks_in_background
    MemberTrackSyncWorker.perform_async(self.id)
  end

  def image(size = :large)
    case size
    when :small
      image_url.gsub("t500x500", "t50x50")
    when :medium
      image_url.gsub("t500x500", "large")
    else
      image_url
    end
  end

  def profile_url
    "https://soundcloud.com/#{self.slug}"
  end

  def self.sync_from_soundcloud(access_token)
    return unless access_token.present?
    soundcloud_profile = ::Soundcloud.new(:access_token => access_token).get("/me")
    
    image_url = soundcloud_profile.avatar_url.gsub(/-\w+\.jpg/, "-t500x500.jpg")

    member = Member.find_or_initialize_by_soundcloud_id({
      :soundcloud_id => soundcloud_profile.id,
      :name => soundcloud_profile.username,
      :slug => soundcloud_profile.permalink,
      :image_url => image_url,
      :full_name => soundcloud_profile.full_name,
      :bio => soundcloud_profile.description,
      :city => soundcloud_profile.city,
      :country => soundcloud_profile.country,
      :soundcloud_access_token => access_token
    })
    member.save

    member
  end
end
