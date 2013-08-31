require 'spec_helper'

describe BasicResponder do
  it "should be a subclass of ActionController::Responder" do
    BasicResponder.superclass.should == ActionController::Responder
  end

  describe "#api_behavior(error) -- protected method" do
    before do
      @responder = BasicResponder.new(ActionController::Base.new, 'resources')
      @responder.stub(:resourceful?).and_return(true)
      @responder.stub(:resource).and_return('resource')
    end
    it "should return status 200 with the rendered resource for PUT requests" do
      @responder.stub(:put?).and_return(true)
      @responder.should_receive(:display).with('resource', :status => :ok)
      @responder.send(:api_behavior, nil)
    end
    it "should not affect GET requests" do
      @responder.stub(:put?).and_return(false)
      @responder.stub(:get?).and_return(true)
      @responder.should_receive(:display).with('resource')
      @responder.send(:api_behavior, nil)
    end
    it "should not affect POST requests" do
      @responder.stub(:put?).and_return(false)
      @responder.stub(:get?).and_return(false)
      @responder.stub(:post?).and_return(true)
      @responder.stub(:api_location).and_return('api location')
      @responder.should_receive(:display).with('resource', :status => :created, :location => 'api location')
      @responder.send(:api_behavior, nil)
    end
    it "should not affect DELETE requests" do
      @responder.stub(:put?).and_return(false)
      @responder.stub(:get?).and_return(false)
      @responder.stub(:post?).and_return(false)
      @responder.should_receive(:head).with(:no_content)
      @responder.send(:api_behavior, nil)
    end
    it "should raise an exception when the request is not resourceful" do
      @responder.stub(:resourceful?).and_return(false)
      lambda { @responder.send(:api_behavior, Exception.new) }.should raise_error
    end
  end
end
