class SamplePack < ActiveRecord::Base
  attr_accessible :name, :session_id, :url

  belongs_to :session

  validates :name, presence: true
  validates :url, presence: true
  validates :session, presence: true
end
