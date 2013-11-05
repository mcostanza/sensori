require 'spec_helper'

describe ResponsesController do
  describe "POST 'create'" do
    before do
      controller.stub(:ensure_signed_in)
      @member = double(Member, :id => 41)
      controller.instance_variable_set(:@current_member, @member)
      @params = { :response => { :discussion_id => '1', :body => "body" }, :format => :json }
      @discussion_response = Response.new
      @discussion_response.stub(:id).and_return(10)
      @discussion_response.stub(:save).and_return(true)
      Response.stub(:new).and_return(@discussion_response)
    end

    describe "before filters" do
      it "should have the ensure_signed_in before filter" do
        controller.should_receive(:ensure_signed_in)
        post 'create', @params
      end
    end

    it "should initialize a new response with the passed params and the member id and assign it to @discussion_response" do
      Response.should_receive(:new).with(@params[:response].merge(:member => @member).stringify_keys).and_return(@discussion_response)
      post 'create', @params
      assigns[:response].should == @discussion_response
    end
    it "should save the new response" do
      @discussion_response.should_receive(:save).and_return(true)
      post 'create', @params
    end
    it "should render a 201 created response" do
      post 'create', @params
      response.status.should == 201
    end
    it "should return a 422 when there are errors" do
      @discussion_response.stub(:errors).and_return({ :errors => true })
      post 'create', @params
      response.status.should == 422
    end
  end

end
