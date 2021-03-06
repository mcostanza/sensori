# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tutorial do

    sequence :title do |n| 
      "Tutorial #{n}"
    end

    description "This is some text"

    body_html "<h3>Overview</h3><p>This is my tutorial.</p><h3>Content</h3><p>This is my content.</p>"
    body_components [{ type: "text", content: "<h3>Overview</h3><p>This is my tutorial.</p><h3>Content</h3><p>This is my content.</p>" }].to_json

    sequence :slug do |n|
      "tutorial-title--#{n}"
    end

    association :member

    sequence :youtube_id do |n|
      "youtube-#{n}"
    end

    published true

    attachment_url "http://s3.amazon.com/sensori/attachments/tutorial.zip"

    include_table_of_contents true

  end
end
