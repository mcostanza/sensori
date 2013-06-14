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
      controller.stub!(:signed_in?).and_return(false)
      controller.signed_out?.should be_true
    end
    it "should return false if signed_in? returns tru" do
      controller.stub!(:signed_in?).and_return(true)
      controller.signed_out?.should be_false
    end
  end

  describe "#load_member_if_signed_in" do
    it "should assign @member to a Member loaded from session[:soundcloud_id] if signed in" do
      controller.stub!(:signed_in?).and_return(true)
      session[:soundcloud_id] = 123
      member = mock(Member)
      Member.should_receive(:find_by_soundcloud_id).with(123).and_return(member)
      controller.load_member_if_signed_in
      controller.instance_variable_get(:@member).should == member
    end
    it "should not assign @member or load a Member if signed_in? returns false" do
      controller.stub!(:signed_in?).and_return(false)
      Member.should_not_receive(:find_by_soundcloud_id)
      controller.load_member_if_signed_in
      controller.instance_variable_get(:@member).should be_nil
    end
  end

  describe "#ensure_signed_in" do
    it "should redirect to the root path if not signed in" do
      controller.stub!(:signed_in?).and_return(false)
      controller.should_receive(:redirect_to).with(root_path)
      controller.ensure_signed_in
    end
    it "should not redirect if signed in" do
      controller.stub!(:signed_in?).and_return(true)
      controller.should_not_receive(:redirect_to)
      controller.ensure_signed_in
    end
  end

  describe "#ensure_signed_out" do
    it "should redirect to the root path if signed out" do
      controller.stub!(:signed_out?).and_return(false)
      controller.should_receive(:redirect_to).with(root_path)
      controller.ensure_signed_out
    end
    it "should not redirect if signed out" do
      controller.stub!(:signed_out?).and_return(true)
      controller.should_not_receive(:redirect_to)
      controller.ensure_signed_out
    end
  end
end