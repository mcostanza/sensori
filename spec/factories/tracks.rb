# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :track do
    sequence :soundcloud_id
    
    sequence :title do |n| 
      "Track #{n}"
    end

    sequence :permalink_url do |n| 
      "http://www.soundcloud.com/tracks/#{n}"
    end

    sequence :stream_url do |n| 
      "http://www.soundcloud.com/tracks/#{n}/stream"
    end

    posted_at { Time.now }

    sequence :artwork_url do |n| 
      "http://soundcloud.com/tracks/#{n}/artwork.png"
    end

    association :member
  end
end
