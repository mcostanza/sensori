class TutorialNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(tutorial_id)
  	tutorial = Tutorial.find(tutorial_id)
  	Member.find_each do |member|
  		next if member == tutorial.member
  		NotificationMailer.tutorial_notification(:member => member, :tutorial => tutorial).deliver
  	end
  end
end
