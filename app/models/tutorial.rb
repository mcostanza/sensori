class Tutorial < ActiveRecord::Base
  attr_accessible :attachment_url, :body, :description, :member_id, :slug, :title, :video_url
end
