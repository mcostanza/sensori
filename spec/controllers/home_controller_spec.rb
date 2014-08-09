require 'spec_helper'

describe HomeController do

  describe "GET 'index'" do
    before(:each) do
      @track = double(Track)
      @tracks_scope = double('tracks with members', :limit => [@track])
      @tracks_scope.stub(:latest).and_return(@tracks_scope)
      Track.stub(:includes).and_return(@tracks_scope)

      @tutorial = double(Tutorial)
      @tutorials_scope = double('tutorials with members', :limit => [@track])
      @tutorials_scope.stub(:where).and_return(@tutorials_scope)
      Tutorial.stub(:includes).and_return(@tutorials_scope)

      @discussion = double(Discussion)
      @discussions_scope = double('discussions with members', :limit => [@discussion])
      Discussion.stub(:includes).and_return(@discussions_scope)
    end
    it "should return http success" do
      get 'index'
      response.should be_success
    end
    it "should render the index template" do
      get 'index'
      response.should render_template('home/index')
    end
    it "should load the latest 3 published tutorials with member association and assign to @tutorials" do
      Tutorial.should_receive(:includes).with(:member).and_return(@tutorials_scope)
      @tutorials_scope.should_receive(:where).with(published: true).and_return(@tutorials_scope)
      @tutorials_scope.should_receive(:limit).with(3).and_return([@tutorial])
      get 'index'
      assigns[:tutorials].should == [@tutorial]
    end
    it "should load all features and assign them to @features" do
      Feature.should_receive(:all).and_return('features')
      get 'index'
      assigns[:features].should == 'features'
    end
  end

  describe "GET 'about'" do
    it "should return http success" do
      get "about"
      response.should be_success
    end
    it "should render the about template" do
      get "about"
      response.should render_template("home/about")
    end
  end

  describe "GET 'blog_post_redirect'" do
    before(:each) do
      @post_id = "53782176895/new-tracks-week-of-june-17th"
    end
    it "should be connected as '/post/*'" do
      assert_generates "post/#{@post_id}", :controller => 'home', :action => 'blog_post_redirect', :post_id => @post_id
    end
    it "should redirect to the equivalent post path on blog.sensoricollective.com" do
      get 'blog_post_redirect', :post_id => @post_id
      response.should redirect_to(File.join("http://blog.sensoricollective.com/post", @post_id))
    end
  end

  describe "GET 'blog_tag_redirect'" do
    before(:each) do
      @tag = "playlist"
    end
    it "should be connected as '/tagged/*'" do
      assert_generates "tagged/#{@tag}", :controller => 'home', :action => 'blog_tag_redirect', :tag => @tag
    end
    it "should redirect to the equivalent tagged posts path on blog.sensoricollective.com" do
      get 'blog_tag_redirect', :tag => @tag
      response.should redirect_to(File.join("http://blog.sensoricollective.com/tagged", @tag))
    end
  end

  describe "GET 'kickstarter'" do
    it "should be connected as '/kickstarter'" do
      assert_generates "/kickstarter", :controller => 'home', :action => 'kickstarter'
    end
    it "should redirect to kickstarter with 302 status" do
      get "kickstarter"
      response.should redirect_to("http://www.kickstarter.com/projects/philsergi/sensori-collective-community-music-center")
      response.status.should == 302
    end
  end
end
