class Response < ActiveRecord::Base
  attr_accessible :disucssion_id, :body, :member_id

  belongs_to :discussion
  belongs_to :member

  validates :discussion, :presence => true
  validates :body, :presence => true
  validates :member, :presence => true

  auto_html_for :body do
    html_escape
    image
    soundcloud
    vimeo
    youtube
    link :target => "_blank", :rel => "nofollow"
    simple_format
  end
end
