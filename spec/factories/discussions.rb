# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :discussion do
    sequence :subject do |n|
      "Subject #{n}"
    end

    sequence :body do |n|
      "Body #{n}"
    end

    category 'general'

    association :member

    ignore do
      last_post_at { Time.now }
    end

    after(:create) do |discussion, evaluator|
      discussion.last_post_at = evaluator.last_post_at if evaluator.last_post_at.present?
      discussion.save!
    end
  end
end
