require 'spec_helper'

describe TracksController do

  describe "GET 'index'" do
    before(:each) do
      @track = double(Track)
      @scope = double('tracks scope', :per => [@track])
      @scope.stub(:page).and_return(@scope)
      @scope.stub(:latest).and_return(@scope)
      Track.stub(:includes).and_return(@scope)
    end
    it "should return http success" do
      get 'index'
      response.should be_success
    end
    it "should load the latest 12 Tracks and assign to @tracks" do
      Track.should_receive(:includes).with(:member).and_return(@scope)
      @scope.should_receive(:latest).and_return(@scope)
      @scope.should_receive(:page).with(1).and_return(@scope)
      @scope.should_receive(:per).with(12).and_return([@track])
      get 'index'
      assigns[:tracks].should == [@track]
    end
    it "should load the latest 12 Tracks with pagination" do
      Track.should_receive(:includes).with(:member).and_return(@scope)
      @scope.should_receive(:latest).and_return(@scope)
      @scope.should_receive(:page).with(2).and_return(@scope)
      @scope.should_receive(:per).with(12).and_return([@track])
      get 'index', :page => 2
      assigns[:tracks].should == [@track]
    end
    it "should not allow a page less than 1" do
      Track.should_receive(:includes).with(:member).and_return(@scope)
      @scope.should_receive(:latest).and_return(@scope)
      @scope.should_receive(:page).with(1).and_return(@scope)
      @scope.should_receive(:per).with(12).and_return([@track])
      get 'index', :page => 0
      assigns[:tracks].should == [@track]
    end
    it "should be connected as '/beats'" do
      assert_generates '/beats', :controller => 'tracks', :action => 'index'
    end
  end

end
