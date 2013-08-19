class Response < ActiveRecord::Base
  attr_accessible :discussion_id, :body, :member_id, :member, :notifications

  # Used to setup notifications when creating a response (pass :notifications => true)
  attr_accessor :notifications


  belongs_to :discussion
  belongs_to :member

  validates :discussion, :presence => true
  validates :body, :presence => true
  validates :member, :presence => true

  after_commit :update_discussion_notification, :deliver_discussion_notifications, :on => :create

  auto_html_for :body do
    html_escape
    image
    soundcloud
    vimeo
    youtube
    link :target => "_blank", :rel => "nofollow"
    simple_format
  end

  def deliver_discussion_notifications
    DiscussionNotificationWorker.perform_async(self.id)
  end

  def update_discussion_notification
    conditions = { :member_id => self.member_id, :discussion_id => self.discussion_id }
    if self.notifications
      DiscussionNotification.find_or_create_by_member_id_and_discussion_id(conditions)
    else
      DiscussionNotification.where(conditions).delete_all
    end
  end
end
