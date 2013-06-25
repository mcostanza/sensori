# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tutorial do

    sequence :title do |n| 
      "Tutorial #{n}"
    end

    description "This is some text"

    body "tutorial body (html)"

    sequence :slug do |n|
      "tutorial-title--#{n}"
    end

    association :member

    sequence :video_url do |n|
      "http://youtube.com/sensoricollective-tutorial-#{n}"
    end

    sequence :attachment_url do |n|
      "http://s3.aws.com/sensoricollective-#{n}.zip"
    end
  end
end
