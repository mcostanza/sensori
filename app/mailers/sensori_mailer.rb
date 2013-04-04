class SensoriMailer < ActionMailer::Base
  default :from => "sensoricollective@gmail.com"

  def contact_us(params = {})
    @name    = params[:name]
    @email   = params[:email]
    @message = params[:message]
    mail(:to => "sensoricollective@gmail.com", :subject => "Feedback")
  end

end
