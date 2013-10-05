class Discussion < ActiveRecord::Base
  extend FriendlyId

  CATEGORIES = ['general', 'production', 'music-recs', 'collabs', 'events']

  attr_accessible :subject, :body, :member_id, :member, :members_only, :attachment_url, :category
  default_scope order('last_post_at DESC')

  belongs_to :member
  has_many :responses, :include => :member, :dependent => :destroy
  has_many :notifications, :class_name => "DiscussionNotification", :include => :member

  validates :member, :presence => true
  validates :subject, :presence => true
  validates :body, :presence => true
  validates :category, :inclusion => { :in => CATEGORIES }

  before_create { |discussion| discussion.last_post_at = Time.now }

  after_commit :setup_discussion_notification, :on => :create

  friendly_id :subject, :use => :slugged

  auto_html_for :body do
    html_escape
    image
    soundcloud
    vimeo
    youtube
    link :target => "_blank", :rel => "nofollow"
    simple_format
  end

  def editable?(member)
    return false if member.blank?
    return true if member.admin?
    self.responses.blank? && self.member == member
  end

  def setup_discussion_notification
    self.notifications.create(:member => self.member)
  end

  def attachment_name
    self.attachment_url.to_s.split("/").last
  end

  # extend the default json representation of a discussion to include attachment_name and member attributes
  def as_json(options = {})
    super(:methods => :attachment_name, :include => { :member => { :only => [:name, :slug, :image_url] } })
  end
end
