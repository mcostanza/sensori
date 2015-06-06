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

    transient do
      last_post_at { Time.now }
      response_count 0
    end

    trait :any_category do
      category { Discussion::CATEGORIES.sample }
    end

    after(:create) do |discussion, evaluator|
      discussion.last_post_at = evaluator.last_post_at if evaluator.last_post_at.present?
      discussion.save!

      create_list(:response, evaluator.response_count, discussion: discussion) if evaluator.response_count.present?
    end
  end
end
