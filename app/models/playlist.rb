class Playlist < ActiveRecord::Base
  attr_accessible :link, :title, :bandcamp_id

  validates :title, presence: true
  validates :link, presence: true, url: true

  def soundcloud?
  	URI.parse(link).host.include?("soundcloud.com")
  end

  def bandcamp?
  	URI.parse(link).host.include?("bandcamp.com")
  end
end
