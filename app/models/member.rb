class Member < ActiveRecord::Base
  attr_accessible :admin, :email, :image_url, :name, :slug, :soundcloud_id, :soundcloud_access_token

  has_many :tracks, :dependent => :destroy

  validates :soundcloud_id, :presence => true, :uniqueness => true
  validates :name, :presence => true
  validates :slug, :presence => true, :uniqueness => true
  validates :image_url, :presence => true
  validates :soundcloud_access_token, :presence => true
end
