require "spec_helper"

describe NotificationMailer do

  describe ".default_params" do
    it "should have from => sensoricollective@gmail.com" do
      NotificationMailer.default_params[:from].should == "sensoricollective@gmail.com"
    end
  end

  describe "#discussion_notification(params = {})" do
    it "should send an email to the member passed with the correct subject" do
      @member = mock(Member, :email => "phil@mail.com", :name => "Slim James")
      @response = mock(Response, :member => mock(Member, :name => "Five05"), :body => "just checking in bud", :body_html => "<p>just checking in bud</p>")
      params = { :member => @member, :response => @response }

      email = NotificationMailer.discussion_notification(params).deliver

      ActionMailer::Base.deliveries.should_not be_empty

      email.to.should == [@member.email]
      email.subject.should == "Five05 posted in a discussion on Sensori"
      email.encoded.should include("Five05 wrote:")
      email.encoded.should include("just checking in bud")
    end
  end

end

