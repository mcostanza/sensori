require "spec_helper"

describe NotificationMailer do

  describe ".default_params" do
    it "should have from => sensoricollective@gmail.com" do
      NotificationMailer.default_params[:from].should == "sensoricollective@gmail.com"
    end
  end

  describe "#discussion_notification(params = {})" do
    it "should send an email to the member passed with the correct subject" do
      @member = double(Member, :email => "phil@mail.com", :name => "Slim James")
      @response = double(Response, :member => double(Member, :name => "Five05"), :discussion => double(Discussion, :subject => "check out my neat beat"))
      params = { :member => @member, :response => @response }

      email = NotificationMailer.discussion_notification(params).deliver

      ActionMailer::Base.deliveries.should_not be_empty

      email.to.should == [@member.email]
      email.subject.should == "Five05 posted in a discussion on Sensori"
      email.encoded.should include("Hey Slim James, Five05 just commented on your post titled \"check out my neat beat\" in Discussions.")
    end
  end

end

