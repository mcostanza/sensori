class Tutorial < ActiveRecord::Base
  extend FriendlyId
  
  attr_accessible :attachment_url, :body, :description, :member_id, :slug, :title, :video_url

  belongs_to :member

  validates :title, :presence => true
  validates :description, :presence => true
  validates :member, :presence => true
  validates :body, :presence => true

  friendly_id :title, :use => :slugged
end
