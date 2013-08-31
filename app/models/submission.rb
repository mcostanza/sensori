class Submission < ActiveRecord::Base
  attr_accessible :attachment_url, :member_id, :session_id, :title

  validates :attachment_url, :presence => true
  validates :member, :presence => true
  validates :session, :presence => true
  validates :title, :presence => true

  belongs_to :session
  belongs_to :member
end
