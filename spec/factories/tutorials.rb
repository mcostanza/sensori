# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tutorial do

    sequence :title do |n| 
      "Tutorial #{n}"
    end

    description "This is some text"

    body_html "<h3>Overview</h3><p>This is my tutorial.</p>"
    body_components [{ type: "text", content: "<h3>Overview</h3><p>This is my tutorial.</p>" }].to_json

    sequence :slug do |n|
      "tutorial-title--#{n}"
    end

    association :member

    sequence :youtube_id do |n|
      "youtube-#{n}"
    end

    published true

    attachment { fixture_file_upload(Rails.root.join('spec/data/beat-kit.zip'), 'application/zip') }

  end
end
