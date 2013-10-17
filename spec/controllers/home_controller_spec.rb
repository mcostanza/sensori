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
    it "should load the latest 4 tracks with member association and assign to @latest_tracks" do
      Track.should_receive(:includes).with(:member).and_return(@tracks_scope)
      @tracks_scope.should_receive(:latest).and_return(@tracks_scope)
      @tracks_scope.should_receive(:limit).with(4).and_return([@track])
      get 'index'
      assigns[:latest_tracks].should == [@track]
    end
    it "should load the latest 3 published tutorials with member association and assign to @tutorials" do
      Tutorial.should_receive(:includes).with(:member).and_return(@tutorials_scope)
      @tutorials_scope.should_receive(:where).with(published: true).and_return(@tutorials_scope)
      @tutorials_scope.should_receive(:limit).with(3).and_return([@tutorial])
      get 'index'
      assigns[:tutorials].should == [@tutorial]
    end
    it "should load the latest 3 discussions with member association and assign to @discussions" do
      Discussion.should_receive(:includes).with(:member).and_return(@discussions_scope)
      @discussions_scope.should_receive(:limit).with(3).and_return([@discussion])
      get 'index'
      assigns[:discussions].should == [@discussion]
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
end
