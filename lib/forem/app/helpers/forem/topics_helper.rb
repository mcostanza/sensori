module Forem
  module TopicsHelper
    def link_to_latest_post(topic)
      post = relevant_posts(topic).last
      text = "#{time_ago_in_words(post.created_at)} #{t("ago_by")} #{post.user}"
      link_to text, forem.forum_topic_path(post.topic.forum, post.topic, :anchor => "post-#{post.id}", :page => topic.last_page)
    end

    def new_since_last_view_text(topic)
      if forem_user
        topic_view = topic.view_for(forem_user)
        forum_view = topic.forum.view_for(forem_user)

        if forum_view
          if topic_view.nil? && topic.created_at > forum_view.past_viewed_at
            content_tag :super, "New"
          end
        end
      end
    end

    def relevant_posts(topic)
      posts = topic.posts.by_created_at.scoped
      if forem_admin_or_moderator?(topic.forum)
        posts
      elsif topic.user == forem_user
        posts.visible.approved_or_pending_review_for(topic.user)
      else
        posts.approved
      end
    end

  end
end
