class Discussion < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :subject, :body, :member_id, :members_only
  default_scope order('id DESC')

  belongs_to :member
  has_many :responses

  validates :member, :presence => true
  validates :subject, :presence => true
  validates :body, :presence => true

  friendly_id :subject, :use => :slugged

  auto_html_for :body do
    html_escape
    image
    soundcloud
    vimeo
    youtube
    link :target => "_blank", :rel => "nofollow"
    simple_format
  end

  def editable?(member)
    return false if member.blank?
    return true if member.admin?
    self.responses.blank? && self.member == member
  end
end
