class SensoriMailer < ActionMailer::Base
  default :from => "Sensori Collective <info@sensoricollective.com>"

  def contact_us(params = {})
    @name    = params[:name]
    @email   = params[:email]
    @message = params[:message]
    mail(:to => "sensoricollective@gmail.com", :subject => "Feedback")
  end

end
