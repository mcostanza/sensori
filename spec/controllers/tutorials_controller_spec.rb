require 'spec_helper'

describe TutorialsController do

  include LoginHelper

  describe "GET 'index'" do
    before(:each) do
      @tutorial = mock(Tutorial)
      @scope = mock('paginated Tutorials', :per => [@tutorial])
      Tutorial.stub!(:page).and_return(@scope)
    end
    it "should return http success" do
      get 'index'
      response.should be_success
    end
    it "should return the index template" do
      get 'index'
      response.should render_template("tutorials/index")
    end
    it "should load 6 tutorials and assign them to @tutorials" do
      Tutorial.should_receive(:page).with(1).and_return(@scope)
      @scope.should_receive(:per).with(6).and_return([@tutorial])
      get 'index'
      assigns[:tutorials].should == [@tutorial]
    end
    it "should load 6 tutorials with pagination" do
      Tutorial.should_receive(:page).with(2).and_return(@scope)
      @scope.should_receive(:per).with(6).and_return([@tutorial])
      get 'index', :page => 2
      assigns[:tutorials].should == [@tutorial]
    end
    it "should not allow a page less than 1" do
      Tutorial.should_receive(:page).with(1).and_return(@scope)
      @scope.should_receive(:per).with(6).and_return([@tutorial])
      get 'index', :page => 0
      assigns[:tutorials].should == [@tutorial]
    end
  end

  describe "GET 'show'" do
    before(:each) do
      @tutorial = mock(Tutorial)
      Tutorial.stub!(:find).and_return(@tutorial)
    end
    it "should return http success" do
      get 'show', :id => '123'
      response.should be_success
    end
    it "should render the show template" do
      get 'show', :id => '123'
      response.should render_template("tutorials/show")
    end
    it "should find the tutorial from params[:id] and assign to @tutorial" do
      Tutorial.should_receive(:find).with('123').and_return(@tutorial)
      get 'show', id: '123'
      assigns[:tutorial].should == @tutorial
    end
  end

  describe "GET 'new'" do
    describe "when logged in as an admin" do
      before(:each) do
        login_user(:admin => true)
      end
      it "should return http success" do
        get 'new'
        response.should be_success
      end
      it "should render the new template" do
        get 'new'
        response.should render_template("tutorials/new")
      end
      it "should initialize a Tutorial and assign to @tutorial" do
        tutorial = mock(Tutorial)
        Tutorial.should_receive(:new).with(member: @member).and_return(tutorial)
        get 'new'
        assigns[:tutorial].should == tutorial
      end
    end
    describe "when logged in as a non-admin" do
      before(:each) do
        login_user
      end 
      it "should redirect to the root path" do
        get 'new'
        response.should redirect_to(root_path)
      end
    end
    describe "when not logged in" do
      it "should redirect to the root path" do
        get 'new'
        response.should redirect_to(root_path)
      end
    end
  end

  describe "POST 'create'" do
    before(:each) do
      @tutorial_params = {
        :title => "Tutorial",
        :description => "Show u how to do this",
        :body => "lots of text with some html",
        :attachment_url => "http://s3.amazon.com/tutorial.zip",
        :youtube_id => "10110"
      }
      @tutorial = Tutorial.new
      @tutorial.stub!(:id).and_return(10)
      @tutorial.stub!(:save).and_return(true)
      Tutorial.stub!(:new).and_return(@tutorial)
    end
    describe "when logged in as an admin" do
      before(:each) do 
        login_user(:admin => true)
      end
      it "should initialize a tutorial from params[:tutorial] and the current member" do
        expected_args = @tutorial_params.merge(:member => @member).stringify_keys
        Tutorial.should_receive(:new).with(expected_args).and_return(@tutorial)
        post 'create', :tutorial => @tutorial_params
      end
      it "should attempt to save the tutorial" do
        @tutorial.should_receive(:save)
        post 'create', :tutorial => @tutorial_params
      end
      describe "valid params given" do
        it "should redirect to the tutorial with a flash notice" do
          post 'create', :tutorial => @tutorial_params
          response.should redirect_to(@tutorial)
          flash[:notice].should_not be_nil 
        end
      end
      describe "invalid params given" do
        before(:each) do
          @tutorial.stub!(:save).and_return(false)

          # Not called directly but needed for correct test behavior when using respond_with
          @tutorial.stub!(:valid?).and_return(false)
          @tutorial.stub!(:errors).and_return('errors!')
        end
        it "should render the new template with a flash error" do
          post 'create', :tutorial => @tutorial_params
          response.should render_template("tutorials/new")
          flash[:error].should_not be_nil 
        end
      end
    end
    describe "when logged in as a non-admin" do
      before(:each) do
        login_user
      end 
      it "should not initialize a tutorial" do
        Tutorial.should_not_receive(:new)
        post 'create', :tutorial => @tutorial_params
      end
      it "should redirect to the root path" do
        post 'create', :tutorial => @tutorial_params
        response.should redirect_to(root_path)
      end
    end
    describe "when not logged in" do
      it "should not initialize a tutorial" do
        Tutorial.should_not_receive(:new)
        post 'create', :tutorial => @tutorial_params
      end
      it "should redirect to the root path" do
        post 'create', :tutorial => @tutorial_params
        response.should redirect_to(root_path)
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      @tutorial = mock(Tutorial)
      Tutorial.stub!(:find).and_return(@tutorial)
    end
    describe "when logged in as an admin" do
      before(:each) do
        login_user(:admin => true)
      end
      it "should return http success" do
        get 'edit', id: '123'
        response.should be_success
      end
      it "should render the edit template" do
        get 'edit', id: '123'
        response.should render_template("tutorials/edit")
      end
      it "should find the tutorial from params[:id] and assign to @tutorial" do
        Tutorial.should_receive(:find).with('123').and_return(@tutorial)
        get 'edit', id: '123'
        assigns[:tutorial].should == @tutorial
      end
    end
    describe "when logged in as a non-admin" do
      before(:each) do
        login_user
      end 
      it "should redirect to the root path" do
        get 'edit', id: '123'
        response.should redirect_to(root_path)
      end
    end
    describe "when not logged in" do
      it "should redirect to the root path" do
        get 'edit', id: '123'
        response.should redirect_to(root_path)
      end
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @tutorial_params = {
        :title => "Tutorial",
        :description => "Show u how to do this",
        :body => "lots of text with some html",
        :attachment => 'uploaded file',
        :video_url => "http://www.youtube.com/tutorial"
      }
      @tutorial = Tutorial.new
      @tutorial.stub!(:id).and_return(123)
      @tutorial.stub!(:update_attributes).and_return(true)
      Tutorial.stub!(:find).and_return(@tutorial)
    end
    describe "when logged in as an admin" do
      before(:each) do 
        login_user(:admin => true)
      end
      it "should find the tutorial from params" do
        Tutorial.should_receive(:find).with('123').and_return(@tutorial)
        put 'update', :id => '123', :tutorial => @tutorial_params
      end
      it "should update tutorial attributes" do
        @tutorial.should_receive(:update_attributes).with(@tutorial_params.stringify_keys).and_return(true)
        put 'update', :id => '123', :tutorial => @tutorial_params
      end
      describe "valid params given" do
        it "should redirect to the tutorial with a flash notice" do
          put 'update', :id => '123', :tutorial => @tutorial_params
          response.should redirect_to(@tutorial)
          flash[:notice].should_not be_nil 
        end
      end
      describe "invalid params given" do
        before(:each) do
          @tutorial.stub!(:update_attributes).and_return(false)

          # Not called directly but needed for correct test behavior when using respond_with
          @tutorial.stub!(:valid).and_return(false)
          @tutorial.stub!(:errors).and_return('errors')
        end
        it "should render the edit template with a flash error" do
          put 'update', :id => '123', :tutorial => @tutorial_params
          response.should render_template("tutorials/edit")
          flash[:error].should_not be_nil 
        end
      end
    end
    describe "when logged in as a non-admin" do
      before(:each) do
        login_user
      end 
      it "should not find a tutorial" do
        Tutorial.should_not_receive(:find)
        put 'update', :id => '123', :tutorial => @tutorial_params
      end
      it "should redirect to the root path" do
        put 'update', :id => '123', :tutorial => @tutorial_params
        response.should redirect_to(root_path)
      end
    end
    describe "when not logged in" do
      it "should not find a tutorial" do
        Tutorial.should_not_receive(:find)
        put 'update', :id => '123', :tutorial => @tutorial_params
      end
      it "should redirect to the root path" do
        put 'update', :id => '123', :tutorial => @tutorial_params
        response.should redirect_to(root_path)
      end
    end
  end
end
