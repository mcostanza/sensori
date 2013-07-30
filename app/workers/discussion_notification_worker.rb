class DiscussionNotificationWorker
  include Sidekiq::Worker

  def perform(response_id)
    response = Response.find(response_id)
    response.discussion.notifications.each do |notification|
      DiscussionNotificationMailer.deliver(notification.member, response)
    end
  end

end

