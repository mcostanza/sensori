class NotificationMailer < ActionMailer::Base
	layout 'notifications'

	helper :discussions

  default :from => "Sensori Collective <info@sensoricollective.com>"

  def discussion_notification(params = {})
    @member = params[:member]
    @response = params[:response]
    mail(:to => @member.email, :subject => "#{@response.member.name} posted in a discussion on Sensori")
  end

  def tutorial_notification(params = {})
    @member = params[:member]
    @tutorial = params[:tutorial]
    mail(:to => @member.email, :subject => "#{@tutorial.member.name} published a tutorial on Sensori")
  end
end
