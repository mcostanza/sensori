class Tutorial < ActiveRecord::Base
  extend FriendlyId

  default_scope order('created_at DESC')
  
  attr_accessible :attachment, :body, :description, :member_id, :member, :slug, :title, :youtube_id

  belongs_to :member

  validates :title, :presence => true
  validates :description, :presence => true
  validates :member, :presence => true
  validates :body, :presence => true

  friendly_id :title, :use => :slugged

  mount_uploader :attachment, FileUploader

  def youtube_image_url
    "http://img.youtube.com/vi/#{self.youtube_id}/0.jpg"
  end

  def youtube_embed_url
    "http://www.youtube.com/embed/#{self.youtube_id}"
  end

  def youtube_video_url
    "http://www.youtube.com/watch?v=#{self.youtube_id}"
  end
end
