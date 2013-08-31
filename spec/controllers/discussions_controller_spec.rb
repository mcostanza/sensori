require 'spec_helper'

describe DiscussionsController do
  describe "GET 'index'" do
    before do
      @discussion = double(Discussion)
      @scope = double('paginated discussions', :per => [@discussion])
      Discussion.stub(:page).and_return(@scope)
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
      @responses = [double(Response)]
      @discussion = double(Discussion, :responses => @responses)
      Discussion.stub(:find).and_return(@discussion)
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
      controller.stub(:ensure_signed_in)
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
      controller.stub(:ensure_signed_in)
      @member = double(Member, :id => 41)
      controller.instance_variable_set(:@member, @member)
      @params = { :discussion => { :subject => "hello", :body => "body" } }
      @discussion = Discussion.new
      @discussion.stub(:id).and_return(10)
      @discussion.stub(:save).and_return(true)
      Discussion.stub(:new).and_return(@discussion)
    end

    describe "before filters" do
      it "should have the ensure_signed_in before filter" do
        controller.should_receive(:ensure_signed_in)
        post 'create', @params
      end
    end

    it "should initialize a new discussion with the passed params and the member id and assign it to @discussion" do
      Discussion.should_receive(:new).with(@params[:discussion].merge(:member => @member).stringify_keys).and_return(@discussion)
      post 'create', @params
      assigns[:discussion].should == @discussion
    end
    it "should save the new discussion" do
      @discussion.should_receive(:save).and_return(true)
      post 'create', @params
    end
    it "should redirect to the created discussion" do
      post 'create', @params
      response.should redirect_to(@discussion)
    end
    it "should render the new action if the discussion fails to save" do
      @discussion.stub(:save).and_return(false)
      @discussion.stub(:errors).and_return({ :error => true })
      post 'create', @params
      response.should render_template(:new)
    end
  end

  describe "DELETE 'destroy'" do
    before do
      controller.stub(:ensure_signed_in)
      @discussion = Discussion.new
      @discussion.stub(:id).and_return(10)
      @discussion.stub(:destroy).and_return(true)
      @discussion.stub(:editable?).and_return(true)
      Discussion.stub(:find).and_return(@discussion)
      @params = { :id => '10' }
    end

    describe "before filters" do
      it "should have the ensure_signed_in before filter" do
        controller.should_receive(:ensure_signed_in)
        delete 'destroy', @params
      end
    end

    it "should find a discussion and destroy it" do
      Discussion.should_receive(:find).with(@params[:id]).and_return(@discussion)
      @discussion.should_receive(:destroy)
      delete 'destroy', @params
    end
    it "should redirect to the discussions index" do
      delete 'destroy', @params
      response.should redirect_to(discussions_url)
      flash[:notice].should == 'Discussion was successfully deleted.'
    end
    it "should not destroy the discussion if it is not editable" do
      @discussion.stub(:editable?).and_return(false)
      @discussion.should_not_receive(:destroy)
      delete 'destroy', @params  
    end
    it "should redirect to the discussion with an alert message if it is not editable" do
      @discussion.stub(:editable?).and_return(false)
      delete 'destroy', @params  
      response.should redirect_to(@discussion)
      flash[:alert].should == 'Discussion is no longer editable.'
    end
  end

  describe "GET 'edit'" do
    before do
      controller.stub(:ensure_signed_in)
      @discussion = Discussion.new
      @discussion.stub(:id).and_return(10)
      @discussion.stub(:destroy).and_return(true)
      @discussion.stub(:editable?).and_return(true)
      Discussion.stub(:find).and_return(@discussion)
      @params = { :id => '10' }
    end

    describe "before filters" do
      it "should have the ensure_signed_in before filter" do
        controller.should_receive(:ensure_signed_in)
        get 'edit', @params
      end
    end

    it "should find a discussion" do
      Discussion.should_receive(:find).with(@params[:id]).and_return(@discussion)
      get 'edit', @params
    end
    it "should redirect to the discussion with an alert message if it is not editable" do
      @discussion.stub(:editable?).and_return(false)
      get 'edit', @params
      response.should redirect_to(@discussion)
      flash[:alert].should == 'Discussion is no longer editable.'
    end
  end

  describe "PUT 'update'" do
    before do
      controller.stub(:ensure_signed_in)
      @discussion = Discussion.new
      @discussion.stub(:id).and_return(10)
      @discussion.stub(:update_attributes).and_return(true)
      @discussion.stub(:editable?).and_return(true)
      Discussion.stub(:find).and_return(@discussion)
      @params = { :id => '10', :discussion => { :title => 'test' } }
    end

    describe "before filters" do
      it "should have the ensure_signed_in before filter" do
        controller.should_receive(:ensure_signed_in)
        put 'update', @params
      end
    end

    it "should find a discussion" do
      Discussion.should_receive(:find).with(@params[:id]).and_return(@discussion)
      put 'update', @params
    end
    it "should redirect to the discussion" do
      put 'update', @params
      response.should redirect_to(@discussion)
    end
    it "should redirect to the discussion with an alert message if the update fails" do
      @discussion.stub(:update_attributes).and_return(false)
      @discussion.stub(:errors).and_return({ :error => true })
      put 'update', @params
      response.should render_template("edit")
    end
    it "should not update and should redirect to the discussion with an alert message if the discussion is not editable" do
      @discussion.stub(:editable?).and_return(false)
      @discussion.should_not_receive(:update_attributes)
      put 'update', @params
      response.should redirect_to(@discussion)
      flash[:alert].should == 'Discussion is no longer editable.'
    end
    
  end
end
