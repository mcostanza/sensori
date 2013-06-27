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

    sequence :youtube_id do |n|
      "youtube-#{n}"
    end

    attachment { fixture_file_upload(Rails.root.join('spec/data/beat-kit.zip'), 'application/zip') }

  end
end
