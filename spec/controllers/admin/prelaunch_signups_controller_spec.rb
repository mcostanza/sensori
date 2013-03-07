require 'spec_helper'

describe Admin::PrelaunchSignupsController do
  
  include Devise::TestHelpers
  
  describe "GET 'index'" do
    before(:each) do
      @prelaunch_signups = mock('prelaunch signups', :to_csv => "csv data")
      PrelaunchSignup.stub!(:order).and_return(@prelaunch_signups)
    end
    describe "signed in as an admin" do
      before(:each) do
        sign_in FactoryGirl.create(:user, :admin => true)
      end
      it "should find all PrelaunchSignups ordered by id" do
        PrelaunchSignup.should_receive(:order).with(:id)
        get 'index', :format => 'csv'
      end
      it "should send PrelaunchSignups data in csv format" do
        @prelaunch_signups.should_receive(:to_csv).and_return("csv data")
        controller.should_receive(:send_data).with("csv data")
        get 'index', :format => 'csv'
      end
    end
    it "should respond with 401 status if logged in" do
      get 'index', :format => 'csv'
      response.status.should == 401
    end
    it "should redirect if signed in as a non-admin" do
      sign_in FactoryGirl.create(:user, :admin => false)
      get 'index', :format => 'csv'
      response.should be_redirect
    end
  end

end
