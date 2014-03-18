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
      @response   = double(Response, :member => @member_2, :discussion => @discussion, :body => "that beat is dope")
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
      email.encoded.should include("Hey Slim James, Five05 just commented on your post titled \"check out my neat beat\" in Discussions:")
      email.encoded.should include("that beat is dope")
    end
    it "should format the text correctly when the member who created the response also created the discussion" do
      @response.stub(:member).and_return(@member_1)
      email = NotificationMailer.discussion_notification(:member => @member_2, :response => @response).deliver
      email.to.should == ["phil@mail.com"]
      email.subject.should == "Slim James posted in a discussion on Sensori"
      email.encoded.should include("Hey Five05, Slim James just commented on their post titled \"check out my neat beat\" in Discussions:")
      email.encoded.should include("that beat is dope")
    end
    it "should format the text correctly when the member receiving the notification did not create the discussion" do
      @discussion.stub(:member).and_return(@member_3)
      email = NotificationMailer.discussion_notification(:member => @member_1, :response => @response).deliver
      email.to.should == ["slim@mail.com"]
      email.subject.should == "Five05 posted in a discussion on Sensori"
      email.encoded.should include("Hey Slim James, Five05 just commented on William&#x27;s post titled \"check out my neat beat\" in Discussions:")
      email.encoded.should include("that beat is dope")
    end
  end

  describe "#tutorial_notification(params = {})" do
    before(:each) do
      @member_1 = double(Member, :email => "slim@mail.com", :name => "Slim James")
      @tutorial = double(Tutorial, :title => "Creating a Sampled Bass", :description => "How 2 make 1", :member => double(Member, :name => "Buddy Boy"))
    end
    it "should send an email to the member passed with the correct subject and body" do
      email = NotificationMailer.tutorial_notification(:member => @member_1, :tutorial => @tutorial).deliver
      ActionMailer::Base.deliveries.should_not be_empty

      email.to.should == ["slim@mail.com"]
      email.subject.should == "Buddy Boy published a tutorial on Sensori"
      email.encoded.should include("Hey Slim James, Buddy Boy just published a tutorial:")
      email.encoded.should include("Creating a Sampled Bass")
      email.encoded.should include("How 2 make 1")
    end
  end

  describe "#session_notification(params = {})" do
    before(:each) do
      @member_1 = double(Member, :email => "slim@mail.com", :name => "Slim James")
      @session = double(Session, :title => "Bobby Bland", :description => "Make a beat please!!!", :member => double(Member, :name => "Buddy Boy"), :end_date => Time.parse('2014-05-05'))
    end
    it "should send an email to the member passed with the correct subject and body" do
      email = NotificationMailer.session_notification(:member => @member_1, :session => @session).deliver
      ActionMailer::Base.deliveries.should_not be_empty

      email.to.should == ["slim@mail.com"]
      email.subject.should == "New Session posted on Sensori!"
      email.encoded.should include("Hey Slim James,")
      email.encoded.should include("NEW SESSION POSTED")
      email.encoded.should include("Bobby Bland")
      email.encoded.should include("Submission Deadline: May 5, 23:59 PST")
    end
  end

end

