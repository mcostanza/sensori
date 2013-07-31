class DiscussionNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(response_id)
    response = Response.find(response_id)
    response.discussion.notifications.each do |notification|
      NotificationMailer.discussion_notification(:member => notification.member, :response => response).deliver
    end
  end

end
