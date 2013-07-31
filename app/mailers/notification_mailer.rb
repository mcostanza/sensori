class NotificationMailer < ActionMailer::Base
  default :from => "sensoricollective@gmail.com"

  def discussion_notification(params = {})
    @member = params[:member]
    @response = params[:response]
    mail(:to => @member.email, :subject => "#{@response.member.name} posted in a discussion on Sensori")
  end
end
