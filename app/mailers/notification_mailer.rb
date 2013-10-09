class NotificationMailer < ActionMailer::Base
	helper :discussions

  default :from => "Sensori Collective <info@sensoricollective.com>"

  def discussion_notification(params = {})
    @member = params[:member]
    @response = params[:response]
    mail(:to => @member.email, :subject => "#{@response.member.name} posted in a discussion on Sensori")
  end
end
