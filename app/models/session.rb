class Session < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :title, :description, :image, :member_id, :facebook_event_id, :end_date, :attachment_url, :soundcloud_playlist_url, :bandcamp_album_id
  default_scope order('id DESC')

  belongs_to :member

  has_many :submissions

  validates :member, :presence => true
  validates :title, :presence => true
  validates :description, :presence => true
  validates :image, :presence => true
  validates :end_date, :presence => true

  friendly_id :title, :use => :slugged

  mount_uploader :image, ImageUploader

  after_commit :deliver_session_notifications, :on => :create

  def deliver_session_notifications
    SessionNotificationWorker.perform_async(self.id)
  end

  def active?
    return false unless self.end_date?
    Time.now.in_time_zone("Pacific Time (US & Canada)").to_date <= self.end_date.to_date
  end
end
