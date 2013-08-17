require 'spec_helper'

describe SessionsController do

  include LoginHelper

  describe "GET 'index'" do
    before do
      @session = mock(Session)
      @scope = mock('paginated sessions', :per => [@session])
      Session.stub!(:page).and_return(@scope)
    end
    it "should return http success" do
      get 'index'
      response.should be_success
    end
    it "should load 6 sessions and assign them to @sessions" do
      Session.should_receive(:page).with(1).and_return(@scope)
      @scope.should_receive(:per).with(6).and_return([@session])
      get 'index'
      assigns[:sessions].should == [@session]
    end
    it "should load 6 sessions with pagination" do
      Session.should_receive(:page).with(2).and_return(@scope)
      @scope.should_receive(:per).with(6).and_return([@session])
      get 'index', :page => 2
      assigns[:sessions].should == [@session]
    end
    it "should not allow a page less than 1" do
      Session.should_receive(:page).with(1).and_return(@scope)
      @scope.should_receive(:per).with(6).and_return([@session])
      get 'index', :page => 0
      assigns[:sessions].should == [@session]
    end
  end

  describe "GET 'show'" do
    before do
      @session = mock(Session)
      Session.stub!(:find).and_return(@session)
    end
    it "should return http success" do
      get 'show', :id => 1
      response.should be_success
    end
    it "should find the session by id and assign it to @session" do
      Session.should_receive(:find).with("1").and_return(@session)
      get 'show', :id => 1
      assigns[:session].should == @session
    end
  end

  describe "GET 'new'" do
    before do
      controller.stub!(:ensure_admin)
    end

    describe "before filters" do
      it "should have the ensure_admin before filter" do
        controller.should_receive(:ensure_admin)
        get 'new'
      end
    end

    it "should initialize a new session and assign it to @session" do
      session = Session.new
      Session.should_receive(:new).and_return(session)
      get 'new'
      assigns[:session].should == session
    end
  end

  describe "POST 'create'" do
    before do
      login_user(:admin => true)
      @params = { :session => { :title => "Title", :description => "Desc" } }
      @session = Session.new
      @session.stub!(:id).and_return(10)
      @session.stub!(:save).and_return(true)
      Session.stub!(:new).and_return(@session)
    end

    describe "before filters" do
      it "should have the ensure_admin before filter" do
        controller.should_receive(:ensure_admin)
        post 'create', @params
      end
    end

    it "should initialize a new session with the passed params and the member id and assign it to @session" do
      Session.should_receive(:new).with(@params[:session].merge(:member_id => @member.id).stringify_keys).and_return(@session)
      post 'create', @params
      assigns[:session].should == @session
    end
    it "should save the new session" do
      @session.should_receive(:save).and_return(true)
      post 'create', @params
    end
    it "should redirect to the created session with a notice that the session was created successfully" do
      post 'create', @params
      response.should redirect_to(@session)
      flash[:notice].should == 'Session was successfully created.'
    end
    it "should render the new action if the session fails to save" do
      @session.stub!(:save).and_return(false)
      post 'create', @params
      response.should render_template(:new)
    end
  end

  describe "PUT 'update'" do
    before do
      login_user(:admin => true)
      @params = { :id => 10, :session => { :title => "Title", :description => "Desc" } }
      @session = Session.new
      @session.id = 10
      @session.stub!(:update_attributes).and_return(true)
      Session.stub!(:find).and_return(@session)
    end

    describe "before filters" do
      it "should have the ensure_admin before filter" do
        controller.should_receive(:ensure_admin)
        put 'update', @params
      end
    end

    it "should find the session from params[:id]" do
      Session.should_receive(:find).with("10").and_return(@session)
      put 'update', @params
    end
    it "should update the session with the passed params and assign to @session" do
      @session.should_receive(:update_attributes).with("title" => "Title", "description" => "Desc")
      put 'update', @params
      assigns[:session].should == @session
    end
    it "should redirect to the session with a notice that the session was updated successfully" do
      put 'update', @params
      response.should redirect_to(@session)
      flash[:notice].should == 'Session was successfully updated.'
    end
    it "should render the edit action if the session fails to save" do
      @session.stub!(:update_attributes).and_return(false)
      put 'update', @params
      response.should render_template(:edit)
    end
  end
end
