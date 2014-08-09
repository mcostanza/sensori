class Feature < ActiveRecord::Base
  attr_accessible :title, :description, :image, :member_id, :link
  default_scope order('id DESC')

  belongs_to :member

  validates :member, :presence => true
  validates :title, :presence => true
  validates :description, :presence => true
  validates :image, :presence => true
  validates :link, :presence => true

  mount_uploader :image, ImageUploader
end
