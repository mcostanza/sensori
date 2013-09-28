class DiscussionNotification < ActiveRecord::Base
  attr_accessible :member_id, :member, :discussion_id, :discussion

  belongs_to :member
  belongs_to :discussion

  validates :member, :presence => true
  validates :discussion, :presence => true
end
