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

end