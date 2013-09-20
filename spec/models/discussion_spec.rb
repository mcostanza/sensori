require 'spec_helper'

describe Discussion do
  before(:each) do
    @discussion = FactoryGirl.build(:discussion)
  end

  describe "validations" do
    it "should be valid given valid attributes" do
      @discussion.should be_valid
    end
    it "should be invalid without a member" do
      @discussion.member = nil
      @discussion.should_not be_valid
    end
    it "should be invalid without a subject" do
      @discussion.subject = ' '
      @discussion.should_not be_valid
    end
    it "should be invalid without a body" do
      @discussion.body = ' '
      @discussion.should_not be_valid
    end
  end

  describe "associations" do
    it "should have a member association" do
      @discussion.should respond_to(:member)
    end
    it "should have a responses association" do
      @discussion.should respond_to(:responses)
    end
    it "should have a notifications association" do
      @discussion.should respond_to(:notifications)
    end
  end

  describe "callbacks" do
    it "should call setup_discussion_notification" do
      @discussion.should_receive(:setup_discussion_notification)
      @discussion.save
    end
  end

  it "should set slug from the subject when saving" do
    @discussion.slug.should be_nil
    @discussion.save
    @discussion.slug.should == @discussion.subject.parameterize
  end
  
  it "should store an html version of the body text when set" do
    @discussion = Discussion.new(:body => 'test')
    @discussion.body_html.should_not be_blank
  end

  describe "#editable?(member)" do
    before do
      @owner = double(Member, :admin? => false)
      @non_owner = double(Member, :admin? => false)
      @admin = double(Member, :admin? => true)
      @discussion.stub(:member).and_return(@owner)
      @discussion.stub(:responses).and_return([])
    end
    it "should return true if the passed member is the owner" do
      @discussion.editable?(@owner).should be_true
    end
    it "should return false if the passed member is not the owner" do
      @discussion.editable?(@non_owner).should be_false
    end
    it "should return true if the passed member is not the owner and is an admin" do
      @discussion.editable?(@admin).should be_true
    end
    it "should return false if the passed member is the owner but the discussion has responses" do
      @discussion.stub(:responses).and_return(['response'])
      @discussion.editable?(@owner).should be_false
    end
    it "should return true if the discussion has responses and the passed member is an admin" do
      @discussion.stub(:responses).and_return(['response'])
      @discussion.editable?(@admin).should be_true
    end
    it "should return false if the passed member is nil" do
      @discussion.editable?(nil).should be_false
    end
  end

  describe "#setup_discussion_notification" do
    before do
      @notifications = double('notifications')
      @discussion.stub(:notifications).and_return(@notifications)
    end
    it "should find or create a discussion notification for the member creating the discussion" do
      @discussion.notifications.should_receive(:create).with({ :member => @discussion.member })
      @discussion.setup_discussion_notification
    end
  end

  describe "#attachment_name" do
    it "should return the filename of the attachment_url" do
      @discussion.attachment_url = "http://s3.amazon.com/sensori/uploads/audio.wav"
      @discussion.attachment_name.should == "audio.wav"
    end
    it "should return nil without shitting if attachment_url is nil" do
      @discussion.attachment_url = nil
      lambda { @discussion.attachment_name }.should_not raise_error
      @discussion.attachment_name.should be_nil
    end
  end
end
