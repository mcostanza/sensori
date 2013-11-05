require 'spec_helper'

describe ApplicationController do
  
  describe "#signed_in?" do
    it "should return true if session[:soundcloud_id] is set" do
      session[:soundcloud_id] = 123
      controller.signed_in?.should be_true
    end
    it "should return false if session[:soundcloud_id] is not set" do
      session[:soundcloud_id] = nil
      controller.signed_in?.should be_false
    end
  end

  describe "#signed_out?" do
    it "should return true if signed_in? returns false" do
      controller.stub(:signed_in?).and_return(false)
      controller.signed_out?.should be_true
    end
    it "should return false if signed_in? returns tru" do
      controller.stub(:signed_in?).and_return(true)
      controller.signed_out?.should be_false
    end
  end

  describe "#load_member_if_signed_in" do
    it "should assign @current_member to a Member loaded from session[:soundcloud_id] if signed in" do
      controller.stub(:signed_in?).and_return(true)
      session[:soundcloud_id] = 123
      member = double(Member)
      Member.should_receive(:find_by_soundcloud_id).with(123).and_return(member)
      controller.load_member_if_signed_in
      controller.instance_variable_get(:@current_member).should == member
    end
    it "should not assign @current_member or load a Member if signed_in? returns false" do
      controller.stub(:signed_in?).and_return(false)
      Member.should_not_receive(:find_by_soundcloud_id)
      controller.load_member_if_signed_in
      controller.instance_variable_get(:@current_member).should be_nil
    end
  end

  describe "#ensure_signed_in" do
    it "should redirect to the root path if not signed in" do
      controller.stub(:signed_in?).and_return(false)
      controller.should_receive(:redirect_to).with(root_path)
      controller.ensure_signed_in
    end
    it "should not redirect if signed in" do
      controller.stub(:signed_in?).and_return(true)
      controller.should_not_receive(:redirect_to)
      controller.ensure_signed_in
    end
  end

  describe "#ensure_signed_out" do
    it "should redirect to the root path if signed out" do
      controller.stub(:signed_out?).and_return(false)
      controller.should_receive(:redirect_to).with(root_path)
      controller.ensure_signed_out
    end
    it "should not redirect if signed out" do
      controller.stub(:signed_out?).and_return(true)
      controller.should_not_receive(:redirect_to)
      controller.ensure_signed_out
    end
  end

  describe "#ensure_admin" do
    it "should redirect to the root path if @current_member is nil" do
      controller.should_receive(:redirect_to).with(root_path)
      controller.ensure_admin
    end
    it "should redirect to the root path if @current_member is set but not an admin" do
      controller.instance_variable_set(:@current_member, double(Member, :admin? => false))
      controller.should_receive(:redirect_to).with(root_path)
      controller.ensure_admin
    end
    it "should not redirect if @current_member is set to an admin" do
      controller.instance_variable_set(:@current_member, double(Member, :admin? => true))
      controller.should_not_receive(:redirect_to)
      controller.ensure_admin
    end
  end

  # This test is way too strict on implementation but I don't know how to test it otherwise outside of functional testing
  describe "#paginated_respond_with(resource)" do
    before do
      @resource = double('resource', :total_pages => 10, :current_page => 1)
      @format = double('format')
    end
    it "should include pagination parameters in json responses" do
      controller.should_receive(:respond_with).with(@resource).and_yield(@format)
      @format.should_receive(:json).and_yield
      controller.should_receive(:render).with(:json => { :models => @resource, :total_pages => @resource.total_pages, :page => @resource.current_page })
      controller.paginated_respond_with(@resource)
    end
  end

  describe ".responder" do
    it "should return BasicResponder" do
      ApplicationController.send(:responder).should == BasicResponder    
    end
  end
end
