require 'spec_helper'

describe DiscussionsController do
  describe "GET 'index'" do
    before do
      @discussion = mock(Discussion)
      @scope = mock('paginated discussions', :per => [@discussion])
      Discussion.stub!(:page).and_return(@scope)
    end
    it "should return http success" do
      get 'index'
      response.should be_success
    end
    it "should load 10 discussions and assign them to @discussions" do
      Discussion.should_receive(:page).with(1).and_return(@scope)
      @scope.should_receive(:per).with(10).and_return([@discussion])
      get 'index'
      assigns[:discussions].should == [@discussion]
    end
    it "should load 10 discussions with pagination" do
      Discussion.should_receive(:page).with(2).and_return(@scope)
      @scope.should_receive(:per).with(10).and_return([@discussion])
      get 'index', :page => 2
      assigns[:discussions].should == [@discussion]
    end
    it "should not allow a page less than 1" do
      Discussion.should_receive(:page).with(1).and_return(@scope)
      @scope.should_receive(:per).with(10).and_return([@discussion])
      get 'index', :page => 0
      assigns[:discussions].should == [@discussion]
    end
  end

  describe "GET 'show'" do
    before do
      @responses = [mock(Response)]
      @discussion = mock(Discussion, :responses => @responses)
      Discussion.stub!(:find).and_return(@discussion)
    end
    it "should return http success" do
      get 'show', :id => 1
      response.should be_success
    end
    it "should find the discussion by id and assign it to @discussion" do
      Discussion.should_receive(:find).with("1").and_return(@discussion)
      get 'show', :id => 1
      assigns[:discussion].should == @discussion
    end
    it "should load the responses and assign them to @responses" do
      @discussion.should_receive(:responses).and_return(@responses)
      get 'show', :id => 1
      assigns[:responses].should == @responses
    end
  end

  describe "GET 'new'" do
    before do
      controller.stub!(:ensure_signed_in)
    end

    describe "before filters" do
      it "should have the ensure_signed_in before filter" do
        controller.should_receive(:ensure_signed_in)
        get 'new'
      end
    end

    it "should initialize a new discussion and assign it to @discussion" do
      discussion = Discussion.new
      Discussion.should_receive(:new).and_return(discussion)
      get 'new'
      assigns[:discussion].should == discussion
    end
  end

  describe "POST 'create'" do
    before do
      controller.stub!(:ensure_signed_in)
      @member = mock(Member, :id => 41)
      controller.instance_variable_set(:@member, @member)
      @params = { :discussion => { :subject => "hello", :body => "body" } }
      @discussion = Discussion.new
      @discussion.stub!(:id).and_return(10)
      @discussion.stub!(:save).and_return(true)
      Discussion.stub!(:new).and_return(@discussion)
    end

    describe "before filters" do
      it "should have the ensure_signed_in before filter" do
        controller.should_receive(:ensure_signed_in)
        post 'create', @params
      end
    end

    it "should initialize a new discussion with the passed params and the member id and assign it to @discussion" do
      Discussion.should_receive(:new).with(@params[:discussion].merge(:member_id => @member.id).stringify_keys).and_return(@discussion)
      post 'create', @params
      assigns[:discussion].should == @discussion
    end
    it "should save the new discussion" do
      @discussion.should_receive(:save).and_return(true)
      post 'create', @params
    end
    it "should redirect to the created discussion with a notice that the discussion was created successfully" do
      post 'create', @params
      response.should redirect_to(@discussion)
      flash[:notice].should == 'Discussion was successfully created.'
    end
    it "should render the new action if the discussion fails to save" do
      @discussion.stub!(:save).and_return(false)
      post 'create', @params
      response.should render_template(:new)
    end
  end

  describe "POST 'response'" do
    before do
      controller.stub!(:ensure_signed_in)
      @member = mock(Member, :id => 41)
      controller.instance_variable_set(:@member, @member)
      @resp = mock('response', :valid? => true)
      @responses = mock('responses', :create => @resp)
      @discussion = Discussion.new
      @discussion.stub!(:id).and_return(41)
      @discussion.stub!(:responses).and_return(@responses)
      Discussion.stub!(:find).and_return(@discussion)
      @params = { :id => 41, :response => { :body => 'body' } }
    end

    describe "before filters" do
      it "should have the ensure_signed_in before filter" do
        controller.should_receive(:ensure_signed_in)
        post 'respond', @params
      end
    end
    
    it "should find the discussion by id and assign it to @discussion" do
      Discussion.should_receive(:find).with("41").and_return(@discussion)
      post 'respond', @params
      assigns[:discussion].should == @discussion
    end
    it "should create a new response on the discussion with the response body and the member id" do
      @discussion.responses.should_receive(:create).with(:body => @params[:response][:body], :member_id => @member.id).and_return(@resp)
      post 'respond', @params
    end
    it "should redirect back to the discussion if the response was created successfully" do
      post 'respond', @params
      response.should redirect_to(@discussion)
      flash[:alert].should be_blank
    end
    it "should redirect back to the discussion with an alert message if the response was not created" do
      @resp.stub!(:valid?).and_return(false)
      post 'respond', @params
      response.should redirect_to(@discussion)
      flash[:alert].should == 'Sorry something went wrong, please try again.'
    end
  end
end
