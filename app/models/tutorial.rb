class Tutorial < ActiveRecord::Base
  extend FriendlyId

  default_scope order('featured DESC, created_at DESC')
  
  attr_accessible :attachment_url, :body_html, :body_components, :description, :include_table_of_contents, :member_id, :member, :published, :slug, :title, :youtube_id

  belongs_to :member

  validates :title, :presence => true
  validates :description, :presence => true
  validates :member, :presence => true
  validates :body_html, :presence => true
  validates :body_components, :presence => true

  friendly_id :title, :use => :slugged

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
    self.body_html = Formatters::Tutorial::TableOfContents.new(self).format if self.include_table_of_contents?
  end

  def body_components
    attributes["body_components"] || [{ "type" => "text", "content" => "" }, { "type" => "gallery", "content" => [] }]
  end

  def prepare_preview(params)
    [:title, :description, :body_html, :youtube_id, :attachment_url].each do |attribute|
      self.send("#{attribute}=", params[attribute])
    end
    format_table_of_contents if params[:include_table_of_contents].to_s == "true"
  end
end
