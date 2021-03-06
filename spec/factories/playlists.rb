# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :playlist do
    sequence(:title) { |n| "Playlist #{n}" }
    sequence(:link) { "http://music.com/playlist/1" }

    trait :soundcloud do
    	sequence(:link) { |n| "https://soundcloud.com/sensori-collective/sets/playlist-#{n}" }
      sequence(:soundcloud_uri) { |n| "https://api.soundcloud.com/playlists/#{n}" }
    end

    trait :bandcamp do
    	sequence(:link) { |n| "http://sensoricollective.bandcamp.com/album/album-#{n}" }
     	sequence(:bandcamp_album_id) { |n| n.to_s }
    end
  end
end
