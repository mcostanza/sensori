# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :submission do
    association :session
    association :member
    sequence :title do |n|
    	"submission #{n}"
    end

    sequence :attachment_url do |n|
    	"http://s3.amazon.com/sensori/submissions/#{n}.mp3"
    end
  end
end