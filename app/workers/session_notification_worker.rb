class SessionNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(session_id)
  	session = Session.find(session_id)
  	Member.find_each do |member|
  		next if member == session.member
  		NotificationMailer.session_notification(:member => member, :session => session).deliver
  	end
  end
end
