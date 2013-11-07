require 'spec_helper'

describe MembersController do

  describe "GET '/members/sign_in'" do
    before(:each) do
      @soundcloud = double(::Soundcloud, :authorize_url => "soundcloud authorize url")
      controller.stub(:soundcloud_app_client).and_return(@soundcloud)
    end
    it "should redirect to the Soundcloud authorizorization url" do
      get 'sign_in'
      response.should redirect_to(@soundcloud.authorize_url)
    end
  end

  describe "GET 'sign_out'" do
    before(:each) do
      request.env['HTTP_REFERER'] = '/previous/url'
    end
    it "should reset the session" do
      session[:soundcloud_id] = '123'
      get 'sign_out'
      session[:soundcloud_id].should be_nil
    end
    it "should redirect to the previous url with a flash notice" do
      get 'sign_out'
      response.should redirect_to('/previous/url')
      flash[:notice].should_not be_nil
    end
  end

  describe "GET 'soundcloud_connect'" do
    before(:each) do
      @soundcloud_app_client = double(::Soundcloud)
      controller.stub(:soundcloud_app_client).and_return(@soundcloud_app_client)
      @member = double(Member, :valid? => true, :soundcloud_id => '123', :just_created? => false)
      Member.stub(:sync_from_soundcloud).and_return(@member)
    end
    describe "soundcloud code is present" do
      before(:each) do
        @code = 'soundcayode'
        @exchange_response = ::Soundcloud::HashResponseWrapper.new({ :access_token => 'soundtokez' })
        @soundcloud_app_client.stub(:exchange_token).and_return(@exchange_response)
      end
      it "should sync Member data from soundcloud" do
        @soundcloud_app_client.should_receive(:exchange_token).with(:code => @code).and_return(@exchange_response)
        Member.should_receive(:sync_from_soundcloud).with('soundtokez').and_return(@member)
        get 'soundcloud_connect', :code => @code
      end
      describe "valid Member successfully found/created" do
        it "should set session[:soundcloud_id]" do
          get 'soundcloud_connect', :code => @code
          session[:soundcloud_id].should == @member.soundcloud_id
        end
        it "should redirect to the root url with a flash notice (existing member)" do
          get 'soundcloud_connect', :code => @code
          response.should redirect_to(root_url)
          flash[:notice].should_not be_nil
          flash[:signed_up].should be_false
        end
        it "should redirect to the root url with a flash notice (new member)" do
          @member.stub(:just_created?).and_return(true)
          get 'soundcloud_connect', :code => @code
          response.should redirect_to(root_url)
          flash[:notice].should_not be_nil
          flash[:signed_up].should be_true
        end
      end
      describe "valid Member not successfully found/created" do
        before(:each) do
          @member.stub(:valid?).and_return(false)
        end
        it "should not set session data" do
          get 'soundcloud_connect', :code => @code
          session[:soundcloud_id].should be_nil
        end
        it "should redirect to the root url with an error message" do
          get 'soundcloud_connect', :code => @code
          response.should redirect_to root_url
          flash[:error].should_not be_nil
          flash[:signed_up].should be_false
        end
      end
    end
    describe "soundcloud code is not present" do
      it "should not attempt to sync Member data from soundcloud" do
        Member.should_not_receive(:sync_from_soundcloud)
        get 'soundcloud_connect'
      end
      it "should redirect to the root url with an error message" do
        get 'soundcloud_connect'
        response.should redirect_to root_url
        flash[:error].should_not be_nil
      end
      it "should not set session data" do
        get 'soundcloud_connect'
        session[:soundcloud_id].should be_nil
      end
    end
  end

  describe "#soundcloud_app_client" do
    before(:each) do
      Sensori::Soundcloud.stub(:client_id).and_return('123')
      Sensori::Soundcloud.stub(:secret).and_return('secret')
    end
    it "should return a ::Soundcloud instance initialized with the Sensori client_id, secret, and redirect url" do
      soundcloud_app_client = controller.soundcloud_app_client
      soundcloud_app_client.should be_an_instance_of(::Soundcloud::Client)
      soundcloud_app_client.client_id.should == '123'
      soundcloud_app_client.client_secret.should == 'secret'
      soundcloud_app_client.redirect_uri.should == members_soundcloud_connect_url
    end
  end

  describe "PUT 'update'" do
    before do
      @params = {
        :id => 41,
        :member => { 'email' => 'test@gmail.com' },
        :format => 'json'
      }
      @member = Member.new
      controller.instance_variable_set(:@current_member, @member)
      Member.stub(:find).and_return(@member)
      @member.stub(:update_attributes).and_return(true)
    end
    it "should update attributes" do
      @member.should_receive(:update_attributes).with(@params[:member]).and_return(true)
      put 'update', @params
      response.should be_success
    end
    it "should not update the member if it differs from the logged in member" do
      controller.instance_variable_set(:@current_member, double(Member))
      @member.should_not_receive(:update_attributes)
      put 'update', @params
    end
    it "should not update the member if there is no logged in member" do
      controller.instance_variable_set(:@current_member, nil)
      @member.should_not_receive(:update_attributes)
      put 'update', @params
    end
    it "should return 400 when there are errors" do
      @member.stub(:errors).and_return({ :error => true })
      put 'update', @params
      response.status.should == 422
    end
  end

  describe "GET 'show'" do
    before do
      @tracks = [double(Track)]
      @tracks_scope = double('tracks scope', :latest => @tracks)
      @member = double(Member, :tracks => @tracks_scope)
      Member.stub(:find).and_return(@member)
    end
    it "should return http success" do
      get 'show', :id => 1
      response.should be_success
    end
    it "should find the member by id and assign it to @member" do
      Member.should_receive(:find).with("1").and_return(@member)
      get 'show', :id => 1
      assigns[:member].should == @member
    end
    it "should load the members tracks and assign them to @tracks" do
      @member.should_receive(:tracks).and_return(@tracks_scope)
      @tracks_scope.should_receive(:latest).and_return(@tracks)
      get 'show', :id => 1
      assigns[:tracks].should == @tracks
    end
  end
end
