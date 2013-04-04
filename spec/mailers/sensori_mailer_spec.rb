require "spec_helper"

describe SensoriMailer do

  describe ".default_params" do
    it "should have from => sensoricollective@gmail.com" do
      SensoriMailer.default_params[:from].should == "sensoricollective@gmail.com"
    end
  end

  describe "#contact_us(params = {})" do
    it "should send an email with contact name, email, and message" do
      params = {
        :name => "DJ Berg",
        :email => "dj.berg@hotmail.com",
        :message => "This music space is perfect, its just the thing I need."
      }
      email = SensoriMailer.contact_us(params).deliver

      ActionMailer::Base.deliveries.should_not be_empty

      email.encoded.should include("Subject: Feedback")
      email.encoded.should include("DJ Berg (dj.berg@hotmail.com) says:")
      email.encoded.should include(params[:message])
    end
  end

end
