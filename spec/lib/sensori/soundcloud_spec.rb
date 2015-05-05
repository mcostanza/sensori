require 'spec_helper'

describe Sensori::Soundcloud do
  
  it "has a module accessor for client_id" do
    expect(Sensori::Soundcloud).to respond_to(:client_id)
    expect(Sensori::Soundcloud).to respond_to(:client_id=)
  end

  it "has a module accessor for secret" do
    expect(Sensori::Soundcloud).to respond_to(:secret)
    expect(Sensori::Soundcloud).to respond_to(:secret=)
  end

  it "has a module accessor for app_client" do
    expect(Sensori::Soundcloud).to respond_to(:app_client)
    expect(Sensori::Soundcloud).to respond_to(:app_client=)
  end

  describe ".app_client" do
    before(:each) do
      allow(Sensori::Soundcloud).to receive(:client_id).and_return(123)
      allow(Sensori::Soundcloud).to receive(:secret).and_return('secret')
      Sensori::Soundcloud.app_client = nil
    end

    it "returns a ::Soundcloud instance initialized with client id and secret" do
      app_client = Sensori::Soundcloud.app_client
      expect(app_client).to be_an_instance_of(::Soundcloud::Client)
      expect(app_client.client_id).to eq 123
      expect(app_client.client_secret).to eq 'secret'
    end
  end
end
