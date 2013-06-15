require 'spec_helper'

describe Sensori::Soundcloud do
  
  it "should have a module accessor for client_id" do
    Sensori::Soundcloud.should respond_to(:client_id)
    Sensori::Soundcloud.should respond_to(:client_id=)
  end

  it "should have a module accessor for secret" do
    Sensori::Soundcloud.should respond_to(:secret)
    Sensori::Soundcloud.should respond_to(:secret=)
  end

  it "should have a module accessor for app_client" do
    Sensori::Soundcloud.should respond_to(:app_client)
    Sensori::Soundcloud.should respond_to(:app_client=)
  end

  describe ".app_client" do
    before(:each) do
      Sensori::Soundcloud.stub!(:client_id).and_return(123)
      Sensori::Soundcloud.stub!(:secret).and_return('secret')
      Sensori::Soundcloud.app_client = nil
    end
    it "should return a ::Soundcloud instance initialized with client id and secret" do
      app_client = Sensori::Soundcloud.app_client
      app_client.should be_an_instance_of(::Soundcloud)
      app_client.client_id.should == 123
      app_client.client_secret.should == 'secret'
    end
  end

end