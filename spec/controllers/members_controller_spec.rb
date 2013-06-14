require 'spec_helper'

describe MembersController do

  describe "GET '/members/sign_in'" do
    before(:each) do
      @soundcloud = mock(::Soundcloud, :authorize_url => "soundcloud authorize url")
      controller.stub!(:soundcloud_app_client).and_return(@soundcloud)
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
      @soundcloud_app_client = mock(::Soundcloud)
      controller.stub!(:soundcloud_app_client).and_return(@soundcloud_app_client)
    end
    describe "soundcloud code is present" do
      before(:each) do
        @code = 'soundcayode'
      end
      describe "token exchange succeeds" do
        before(:each) do
          @exchange_response = ::Soundcloud::HashResponseWrapper.new({ :access_token => 'soundtokez' })
          @soundcloud_app_client.stub!(:exchange_token).and_return(@exchange_response)

          @member_profile = ::Soundcloud::HashResponseWrapper.new({
            "id" => 3897419, 
            "permalink" => "dj-costanza", 
            "username" => "DJ Costanza", 
            "uri" => "https://api.soundcloud.com/users/3897419", 
            "permalink_url" => "http://soundcloud.com/dj-costanza", 
            "avatar_url" => "https://i1.sndcdn.com/avatars-000039096498-86ivun-large.jpg?0c5f27c"
          })
          @member_client = mock(::Soundcloud, :get => @member_profile)
          ::Soundcloud.stub!(:new).and_return(@member_client)

          @member = mock(Member, :save => true, :valid? => true, :soundcloud_id => @member_profile.soundcloud_id)
          Member.stub!(:find_or_initialize_by_soundcloud_id).and_return(@member)
        end
        it "should load the soundcloud user's profile" do
          @soundcloud_app_client.should_receive(:exchange_token).with(:code => @code).and_return(@exchange_response)
          ::Soundcloud.should_receive(:new).with(:access_token => @exchange_response.access_token).and_return(@member_client)
          @member_client.should_receive(:get).with('/me').and_return(@member_profile)
          get 'soundcloud_connect', :code => @code
        end
        it "should find or initialize a Member from soundcloud profile data" do
          expected_attributes = {
            :soundcloud_id => @member_profile.id,
            :name => @member_profile.username,
            :slug => @member_profile.permalink,
            :image_url => @member_profile.avatar_url,
            :soundcloud_access_token => @exchange_response.access_token
          }
          Member.should_receive(:find_or_initialize_by_soundcloud_id).with(expected_attributes).and_return(@member)
          get 'soundcloud_connect', :code => @code
        end
        it "should attempt to save the Member" do
          @member.should_receive(:save)
          get 'soundcloud_connect', :code => @code
        end
        describe "valid Member successfully found/initialized" do
          it "should set session[:soundcloud_id]" do
            get 'soundcloud_connect', :code => @code
            session[:soundcloud_id].should == @member_profile.soundcloud_id
          end
          it "should redirect to the root url with a flash notice" do
            get 'soundcloud_connect', :code => @code
            response.should redirect_to(root_url)
            flash[:notice].should_not be_nil
          end
        end
        describe "valid Member not successfully found/initialized" do
          before(:each) do
            @member.stub!(:valid?).and_return(false)
          end
          it "should not set session data" do
            get 'soundcloud_connect', :code => @code
            session[:soundcloud_id].should be_nil
          end
          it "should redirect to the root url with an error message" do
            get 'soundcloud_connect', :code => @code
            response.should redirect_to root_url
            flash[:error].should_not be_nil
          end
        end
      end
      describe "token exchange fails" do
        before(:each) do
          @exchange_response = ::Soundcloud::HashResponseWrapper.new({})
          @soundcloud_app_client.stub!(:exchange_token).and_return(@exchange_response)
        end
        it "should not attempt to find/initialize a Member" do
          Member.should_not_receive(:find_or_initialize_by_soundcloud_id)
          get 'soundcloud_connect', :code => @code
        end
        it "should redirect to the root url with an error message" do
          get 'soundcloud_connect', :code => @code
          response.should redirect_to root_url
          flash[:error].should_not be_nil
        end
        it "should not set session data" do
          get 'soundcloud_connect', :code => @code
          session[:soundcloud_id].should be_nil
        end
      end
    end
    describe "soundcloud code is not present" do
      it "should not attempt to find/initialize a Member" do
        Member.should_not_receive(:find_or_initialize_by_soundcloud_id)
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
      Sensori::Soundcloud.stub!(:client_id).and_return('123')
      Sensori::Soundcloud.stub!(:secret).and_return('secret')
    end
    it "should return a ::Soundcloud instance initialized with the Sensori client_id, secret, and redirect url" do
      soundcloud_app_client = controller.soundcloud_app_client
      soundcloud_app_client.should be_an_instance_of(::Soundcloud)
      soundcloud_app_client.client_id.should == '123'
      soundcloud_app_client.client_secret.should == 'secret'
      soundcloud_app_client.redirect_uri.should == members_soundcloud_connect_url
    end
  end

end
