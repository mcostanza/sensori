require 'spec_helper'

describe HomeController do

  describe "GET 'prelaunch'" do
    it "should return http success" do
      get 'prelaunch'
      response.should be_success
    end
    it "should render the prelaunch template" do
      get 'prelaunch'
      response.should render_template("home/prelaunch")
    end
    it "should assign @prelaunch_signup to a new PrelaunchSignup model" do
      get 'prelaunch'
      prelaunch_signup = assigns[:prelaunch_signup]
      prelaunch_signup.should be_an_instance_of(PrelaunchSignup)
      prelaunch_signup.new_record?.should be_true
    end
  end

  describe "GET 'contact_us'" do
    it "should return http success" do
      get "contact_us"
      response.should be_success
    end
    it "should render the contact_us template" do
      get "contact_us"
      response.should render_template("home/contact_us")
    end
  end

  describe "POST 'send_feedback'" do
    before(:each) do
      @email = mock('email', :deliver => true)
      SensoriMailer.stub!(:contact_us).and_return(@email)
    end
    describe "with valid params" do
      before(:each) do
        @params = { 
          :name => "J. Berg",
          :email => "jberg@hotmail.com",
          :message => "Keep it up!"
        }
      end
      it "should deliver a contact_us email" do
        SensoriMailer.should_receive(:contact_us).with({
          :name => @params[:name], 
          :email => @params[:email], 
          :message => @params[:message]
        }).and_return(@email)
        @email.should_receive(:deliver)
        post "send_feedback", @params
      end
      it "should set a flash notice" do
        post "send_feedback", @params
        flash[:notice].should_not be_nil
      end
      it "should redirect to prelaunch" do
        post "send_feedback", @params
        response.should redirect_to("/")
      end
    end
    describe "with invalid params" do
      before(:each) do
        @params = {
          :name => "",
          :email => "jberg@hotmail.com",
          :message => ":("
        }
      end
      it "should not deliver a contact_us email" do
        SensoriMailer.should_not_receive(:contact_us)
        post "send_feedback", @params
      end
      it "should set a flash error" do
        post "send_feedback", @params
        flash[:error].should_not be_nil
      end
      it "should render the contact_us action" do
        post "send_feedback", @params
        response.should render_template("home/contact_us")
      end
    end
  end

  describe "GET /" do
    it "should redirect to kickstarter with 302 status" do
      get "kickstarter"
      response.should redirect_to("http://www.kickstarter.com/projects/1123891588/566962090")
      response.status.should == 302
    end
    it "should be connected as the root url" do
      assert_generates '/', :controller => 'home', :action => 'kickstarter'
    end
  end

end
