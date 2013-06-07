class Member < ActiveRecord::Base
  attr_accessible :admin, :email, :image_url, :name, :slug, :soundcloud_id

  validates :soundcloud_id, :presence => true, :uniqueness => true
  validates :name, :presence => true
  validates :slug, :presence => true, :uniqueness => true
  validates :image_url, :presence => true

end
