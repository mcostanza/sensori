require 'spec_helper'

describe PrelaunchSignupsController do

  describe "POST 'create'" do
    before(:each) do
      @prelaunch_signup_params = { 'email' => 'test@email.com' }
      PrelaunchSignup.stub!(:create)
    end
    it "should create a PrelaunchSignup from params" do
      PrelaunchSignup.should_receive(:create).with(@prelaunch_signup_params)
      post 'create', 'prelaunch_signup' => @prelaunch_signup_params
    end
    it "should set a flash message and redirect to home#prelaunch" do
      post 'create', 'prelaunch_signup' => @prelaunch_signup_params
      response.should redirect_to('/')
      flash[:notice].should_not be_nil
    end
  end
  
end
