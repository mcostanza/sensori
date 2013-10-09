require "spec_helper"

describe NotificationMailer do

  describe ".default_params" do
    it "should have from => 'Sensori Collective <info@sensoricollective.com>'" do
      NotificationMailer.default_params[:from].should == "Sensori Collective <info@sensoricollective.com>"
    end
  end

  describe "#discussion_notification(params = {})" do
    before(:each) do
      @member_1 = double(Member, :email => "slim@mail.com", :name => "Slim James")
      @member_2 = double(Member, :email => "phil@mail.com", :name => "Five05")
      @member_3 = double(Member, :email => "will@mail.com", :name => "William")

      @discussion = double(Discussion, :subject => "check out my neat beat", :member => @member_1)
      @response   = double(Response, :member => @member_2, :discussion => @discussion)
    end
    it "should send an email to the member passed with the correct subject" do
      email = NotificationMailer.discussion_notification(:member => @member_1, :response => @response).deliver
      ActionMailer::Base.deliveries.should_not be_empty

      email.to.should == ["slim@mail.com"]
      email.subject.should == "Five05 posted in a discussion on Sensori"
    end
    it "should format the text correctly when the member receiving the notification created the discussion" do
      email = NotificationMailer.discussion_notification(:member => @member_1, :response => @response).deliver
      email.to.should == ["slim@mail.com"]
      email.subject.should == "Five05 posted in a discussion on Sensori"
      email.encoded.should include("Hey Slim James, Five05 just commented on your post titled \"check out my neat beat\" in Discussions.")
    end
    it "should format the text correctly when the member who created the response also created the discussion" do
      @response.stub(:member).and_return(@member_1)
      email = NotificationMailer.discussion_notification(:member => @member_2, :response => @response).deliver
      email.to.should == ["phil@mail.com"]
      email.subject.should == "Slim James posted in a discussion on Sensori"
      email.encoded.should include("Hey Five05, Slim James just commented on their post titled \"check out my neat beat\" in Discussions.")
    end
    it "should format the text correctly when the member receiving the notification did not create the discussion" do
      @discussion.stub(:member).and_return(@member_3)
      email = NotificationMailer.discussion_notification(:member => @member_1, :response => @response).deliver
      email.to.should == ["slim@mail.com"]
      email.subject.should == "Five05 posted in a discussion on Sensori"
      email.encoded.should include("Hey Slim James, Five05 just commented on William&#x27;s post titled \"check out my neat beat\" in Discussions.")
    end
  end

end

