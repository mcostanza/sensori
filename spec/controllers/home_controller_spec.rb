require 'spec_helper'

describe HomeController do

  describe "GET 'prelaunch'" do
    it "returns http success" do
      get 'prelaunch'
      response.should be_success
    end
    it "should assign @prelaunch_signup to a new PrelaunchSignup model" do
      get 'prelaunch'
      prelaunch_signup = assigns[:prelaunch_signup]
      prelaunch_signup.should be_an_instance_of(PrelaunchSignup)
      prelaunch_signup.new_record?.should be_true
    end
  end

end
