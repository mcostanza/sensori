class Tutorial < ActiveRecord::Base
  extend FriendlyId

  default_scope order('created_at DESC')
  
  attr_accessible :attachment_url, :body, :description, :member_id, :member, :slug, :title, :video_url

  belongs_to :member

  validates :title, :presence => true
  validates :description, :presence => true
  validates :member, :presence => true
  validates :body, :presence => true

  friendly_id :title, :use => :slugged
end
