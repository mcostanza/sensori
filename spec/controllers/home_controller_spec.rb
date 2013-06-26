require 'spec_helper'

describe HomeController do

  describe "GET 'index'" do
    before(:each) do
      @track = mock(Track)
      @tracks_scope = mock('tracks with members', :latest => [@track])
      Track.stub!(:includes).and_return(@tracks_scope)

      @tutorial = mock(Tutorial)
      @tutorials_scope = mock('tutorials with members', :limit => [@track])
      Tutorial.stub!(:includes).and_return(@tutorials_scope)
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
      @tracks_scope.should_receive(:latest).with(4).and_return([@track])
      get 'index'
      assigns[:latest_tracks].should == [@track]
    end
    it "should load the latest 3 tutorials with member association and assign to @tutorials" do
      Tutorial.should_receive(:includes).with(:member).and_return(@tutorials_scope)
      @tutorials_scope.should_receive(:limit).with(3).and_return([@tutorial])
      get 'index'
      assigns[:latest_tracks].should == [@track]
    end
  end

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

  describe "GET 'kickstarter'" do
    it "should redirect to kickstarter with 302 status" do
      get "kickstarter"
      response.should redirect_to("http://www.kickstarter.com/projects/philsergi/sensori-collective-community-music-center")
      response.status.should == 302
    end
  end

end
