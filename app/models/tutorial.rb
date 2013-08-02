class Tutorial < ActiveRecord::Base
  extend FriendlyId

  default_scope order('featured DESC, created_at DESC')
  
  attr_accessible :attachment, :body_html, :body_components, :description, :member_id, :member, :slug, :title, :youtube_id

  belongs_to :member

  validates :title, :presence => true
  validates :description, :presence => true
  validates :member, :presence => true
  validates :body_html, :presence => true
  validates :body_components, :presence => true

  friendly_id :title, :use => :slugged

  mount_uploader :attachment, FileUploader

  serialize :body_components, JSON

  before_save :format_table_of_contents

  def youtube_image_url
    "http://img.youtube.com/vi/#{self.youtube_id}/0.jpg"
  end

  def youtube_embed_url
    "http://www.youtube.com/embed/#{self.youtube_id}"
  end

  def youtube_video_url
    "http://www.youtube.com/watch?v=#{self.youtube_id}"
  end

  def format_table_of_contents
    self.body_html = Formatters::Tutorial::TableOfContents.new(self).format
  end

  def body_components
    attributes["body_components"] || []
  end
end
