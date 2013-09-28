class Response < ActiveRecord::Base
  attr_accessible :discussion_id, :body, :member_id, :member

  belongs_to :discussion
  belongs_to :member

  validates :discussion, :presence => true
  validates :body, :presence => true
  validates :member, :presence => true

  after_commit :setup_discussion_notification, :deliver_discussion_notifications, :update_discussion_stats, :on => :create

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

  def setup_discussion_notification
    conditions = { :member_id => self.member_id, :discussion_id => self.discussion_id }
    DiscussionNotification.find_or_create_by_member_id_and_discussion_id(conditions)
  end

  def update_discussion_stats
    discussion = self.discussion
    discussion.increment(:response_count)
    discussion.last_post_at = self.created_at
    discussion.save
  end
end
