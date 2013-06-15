class Track < ActiveRecord::Base
  attr_accessible :artwork_url, :member_id, :permalink_url, :posted_at, :soundcloud_id, :stream_url, :title

  belongs_to :member

  validates :member, :presence => true
  validates :soundcloud_id, :presence => true, :uniqueness => true
  validates :title, :presence => true
  validates :permalink_url, :presence => true, :uniqueness => true
  validates :stream_url, :presence => true
  validates :artwork_url, :presence => true
  validates :posted_at, :presence => true
end
