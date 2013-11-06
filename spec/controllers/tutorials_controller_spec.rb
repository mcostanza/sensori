require 'spec_helper'

describe TutorialsController do

  include LoginHelper

  describe "GET 'index'" do
    before(:each) do
      @tutorial = double(Tutorial)
      @scope = double('paginated Tutorials', :per => [@tutorial])
      @scope.stub(:where).and_return(@scope)
      Tutorial.stub(:page).and_return(@scope)
    end
    it "should return http success" do
      get 'index'
      response.should be_success
    end
    it "should return the index template" do
      get 'index'
      response.should render_template("tutorials/index")
    end
    it "should load 6 published tutorials and assign them to @tutorials" do
      Tutorial.should_receive(:where).with(published: true).and_return(@scope)
      @scope.should_receive(:page).with(1).and_return(@scope)
      @scope.should_receive(:per).with(6).and_return([@tutorial])
      get 'index'
      assigns[:tutorials].should == [@tutorial]
    end
    it "should load 6 tutorials with pagination" do
      Tutorial.should_receive(:where).with(published: true).and_return(@scope)
      @scope.should_receive(:page).with(2).and_return(@scope)
      @scope.should_receive(:per).with(6).and_return([@tutorial])
      get 'index', :page => 2
      assigns[:tutorials].should == [@tutorial]
    end
    it "should not allow a page less than 1" do
      Tutorial.should_receive(:where).with(published: true).and_return(@scope)
      @scope.should_receive(:page).with(1).and_return(@scope)
      @scope.should_receive(:per).with(6).and_return([@tutorial])
      get 'index', :page => 0
      assigns[:tutorials].should == [@tutorial]
    end
    it "should load 6 tutorials that are published or created by the current member if logged in" do
      login_user
      Tutorial.should_receive(:where).with(["published = :true OR member_id = :member_id", { true: true, member_id: @member.id }]).and_return(@scope)
      @scope.should_receive(:page).with(1).and_return(@scope)
      @scope.should_receive(:per).with(6).and_return([@tutorial])
      get 'index'
      assigns[:tutorials].should == [@tutorial]
    end
  end

  describe "GET 'show'" do
    before(:each) do
      @tutorial = FactoryGirl.create(:tutorial)
      Tutorial.stub(:find).and_return(@tutorial)
    end
    describe "tutorial is published" do
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
    describe "tutorial is not published" do
      before(:each) do
        @tutorial.published = false
      end
      it "should redirect to the edit path if logged in as an admin" do
        login_user(:admin => true)
        get 'show', id: '123'
        response.should redirect_to("http://test.host/tutorials/#{@tutorial.slug}/edit")
      end
      it "should redirect to the edit path if the member is the owner of the tutorial (non-admin)" do
        login_user
        @tutorial.member = @current_member
        get 'show', id: '123'
        response.should redirect_to("http://test.host/tutorials/#{@tutorial.slug}/edit")
      end
      it "should redirect to the tutorials path the member is not an owner of the tutorial (non-admin)" do
        login_user
        get 'show', id: '123'
        response.should redirect_to("http://test.host/tutorials")
      end
      it "should redirect to the tutorials path if not logged in" do
        get 'show', id: '123'
        response.should redirect_to("http://test.host/tutorials")
      end
    end
  end

  describe "GET 'new'" do
    describe "when logged in" do
      before(:each) do
        login_user
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
        tutorial = double(Tutorial)
        Tutorial.should_receive(:new).with(member: @current_member).and_return(tutorial)
        get 'new'
        assigns[:tutorial].should == tutorial
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
        :body_html => "lots of text with some html",
        :body_components => [{ "type" => "text", "content" => "lots of text with some html" }],
        :attachment_url => "http://s3.amazon.com/tutorial.zip",
        :youtube_id => "10110"
      }
      @tutorial = Tutorial.new
      @tutorial.stub(:id).and_return(10)
      @tutorial.stub(:save).and_return(true)
      Tutorial.stub(:new).and_return(@tutorial)
    end
    describe "when logged in" do
      before(:each) do 
        login_user
      end
      it "should initialize a tutorial from params[:tutorial] and the current member" do
        expected_args = @tutorial_params.merge(:member => @current_member).stringify_keys
        Tutorial.should_receive(:new).with(expected_args).and_return(@tutorial)
        post 'create', :tutorial => @tutorial_params
      end
      it "should attempt to save the tutorial" do
        @tutorial.should_receive(:save)
        post 'create', :tutorial => @tutorial_params
      end
      describe "valid params given" do
        it "should redirect to the tutorial" do
          post 'create', :tutorial => @tutorial_params
          response.should redirect_to(@tutorial)
        end
      end
      describe "invalid params given" do
        before(:each) do
          @tutorial.stub(:save).and_return(false)

          # Not called directly but needed for correct test behavior when using respond_with
          @tutorial.stub(:valid?).and_return(false)
          @tutorial.stub(:errors).and_return('errors!')
        end
        it "should render the new template" do
          post 'create', :tutorial => @tutorial_params
          response.should render_template("tutorials/new")
        end
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
      @tutorial = FactoryGirl.build(:tutorial)
      Tutorial.stub(:find).and_return(@tutorial)
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
    describe "when logged in as a non-admin who created the tutorial" do
      before(:each) do
        login_user
        @tutorial.member = @current_member
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
    describe "when logged in as a non-admin who did not created the tutorial" do
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
        :body_html => "lots of text with some html",
        :body_components => [{ "type" => "text", "content" => "lots of text with some html" }],
        :attachment_url => "http://s3.amazon.com/tutorial.zip",
        :video_url => "http://www.youtube.com/tutorial"
      }
      @tutorial = Tutorial.new
      @tutorial.stub(:id).and_return(123)
      @tutorial.stub(:update_attributes).and_return(true)
      Tutorial.stub(:find).and_return(@tutorial)
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
        it "should redirect to the tutorial" do
          put 'update', :id => '123', :tutorial => @tutorial_params
          response.should redirect_to(@tutorial)
        end
      end
      describe "invalid params given" do
        before(:each) do
          @tutorial.stub(:update_attributes).and_return(false)

          # Not called directly but needed for correct test behavior when using respond_with
          @tutorial.stub(:valid).and_return(false)
          @tutorial.stub(:errors).and_return('errors')
        end
        it "should render the edit template" do
          put 'update', :id => '123', :tutorial => @tutorial_params
          response.should render_template("tutorials/edit")
        end
      end
    end
    describe "when logged in as a non-admin who created the tutorial" do
      before(:each) do 
        login_user
        @tutorial.member = @current_member
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
        it "should redirect to the tutorial" do
          put 'update', :id => '123', :tutorial => @tutorial_params
          response.should redirect_to(@tutorial)
        end
      end
      describe "invalid params given" do
        before(:each) do
          @tutorial.stub(:update_attributes).and_return(false)

          # Not called directly but needed for correct test behavior when using respond_with
          @tutorial.stub(:valid).and_return(false)
          @tutorial.stub(:errors).and_return('errors')
        end
        it "should render the edit template" do
          put 'update', :id => '123', :tutorial => @tutorial_params
          response.should render_template("tutorials/edit")
        end
      end
    end
    describe "when logged in as a non-admin who did not create the tutorial" do
      before(:each) do
        login_user
      end 
      it "should find the tutorial from params" do
        Tutorial.should_receive(:find).with('123').and_return(@tutorial)
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

  describe "POST 'preview'" do
    before(:each) do
      @tutorial_params = {
        :title => "Tutorial",
        :description => "Show u how to do this",
        :body_html => "lots of text with some html",
        :attachment_url => "http://s3.amazon.com/tutorial.zip",
        :youtube_id => "10110"
      }
      @tutorial = Tutorial.new
      Tutorial.stub(:find).and_return(@tutorial)
    end
    describe "when logged in as an admin" do
      before(:each) do 
        login_user(:admin => true)
      end
      it "should find the tutorial and prepare a preview" do
        Tutorial.should_receive(:find).with("123").and_return(@tutorial)
        @tutorial.should_receive(:prepare_preview).with(@tutorial_params.stringify_keys)
        post 'preview', :id => "123", :tutorial => @tutorial_params
      end
      it "should not save the tutorial" do
        @tutorial.should_not_receive(:save)
        post 'preview', :id => "123", :tutorial => @tutorial_params
      end
      it "should render the show template" do
        post 'preview', :id => "123", :tutorial => @tutorial_params
        response.should render_template("tutorials/show")
      end
    end
    describe "when logged in as a non-admin who created the tutorial" do
      before(:each) do
        login_user
        @tutorial.member = @current_member
      end
      it "should find the tutorial and prepare a preview" do
        Tutorial.should_receive(:find).with("123").and_return(@tutorial)
        @tutorial.should_receive(:prepare_preview).with(@tutorial_params.stringify_keys)
        post 'preview', :id => "123", :tutorial => @tutorial_params
      end
      it "should not save the tutorial" do
        @tutorial.should_not_receive(:save)
        post 'preview', :id => "123", :tutorial => @tutorial_params
      end
      it "should render the show template" do
        post 'preview', :id => "123", :tutorial => @tutorial_params
        response.should render_template("tutorials/show")
      end
    end
    describe "when logged in as a non-admin who did not create the tutorial" do
      before(:each) do
        login_user
      end 
      it "should find the tutorial from params" do
        Tutorial.should_receive(:find).with('123').and_return(@tutorial)
        post 'preview', :id => '123', :tutorial => @tutorial_params
      end
      it "should redirect to the root path" do
        post 'preview', :id => "123", :tutorial => @tutorial_params
        response.should redirect_to(root_path)
      end
    end
    describe "when not logged in" do
      it "should not find a tutorial" do
        Tutorial.should_not_receive(:find)
        post 'preview', :id => "123", :tutorial => @tutorial_params
      end
      it "should redirect to the root path" do
        post 'preview', :id => "123", :tutorial => @tutorial_params
        response.should redirect_to(root_path)
      end
    end
  end
end
