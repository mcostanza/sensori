class Session < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :title, :description, :image, :member_id, :facebook_event_id, :end_date, :attachment
  default_scope order('id DESC')

  belongs_to :member

  validates :member, :presence => true
  validates :title, :presence => true
  validates :description, :presence => true
  validates :image, :presence => true
  validates :end_date, :presence => true

  friendly_id :title, :use => :slugged

  mount_uploader :image, ImageUploader
  mount_uploader :attachment, FileUploader
end
