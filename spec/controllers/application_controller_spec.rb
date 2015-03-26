require 'spec_helper'

describe ApplicationController do
  include LoginHelper

  let(:soundcloud_id) { 123 }

  describe "#signed_in?" do
    context 'when session[:soundcloud_id] is set' do
      before do
        sign_in(soundcloud_id)
      end

      it "returns true" do
        controller.signed_in?.should == true
      end
    end

    context 'when session[:soundcloud_id] is not set' do
      it "returns false" do
        controller.signed_in?.should be_false
      end
    end
  end

  describe "#signed_out?" do
    context 'when signed in' do
      before do
        sign_in(soundcloud_id)
      end

      it "returns false" do
        controller.signed_out?.should be_false
      end
    end
    
    context 'when not signed in' do
      it "returns true" do
        controller.signed_out?.should be_true
      end
    end
  end

  describe "#load_member_if_signed_in" do
    context 'when signed in' do
      let!(:member) { create(:member, :soundcloud_id => soundcloud_id) }

      before do
        sign_in(soundcloud_id)
      end

      it "assigns @current_member from session data" do
        controller.load_member_if_signed_in
        controller.instance_variable_get(:@current_member).should == member
      end
    end

    context 'when not signed in' do
      it "does not find a Member" do
        Member.should_not_receive(:find)
        controller.load_member_if_signed_in
      end

      it "does not assign @current_member" do
        controller.load_member_if_signed_in
        controller.instance_variable_get(:@current_member).should be_nil
      end
    end
  end

  describe "#ensure_signed_in" do
    context 'when signed in' do
      before do
        sign_in(soundcloud_id)
      end

      it "does not redirect" do
        controller.should_not_receive(:redirect_to)
        controller.ensure_signed_in
      end
    end

    context 'when not signed in' do
      it "redirects to the root path" do
        controller.should_receive(:redirect_to).with(root_path)
        controller.ensure_signed_in
      end      
    end
  end

  describe "#ensure_signed_out" do
    context 'when signed in' do
      before do
        sign_in(soundcloud_id)
      end

      it "redirects to the root path" do
        controller.should_receive(:redirect_to).with(root_path)
        controller.ensure_signed_out  
      end
    end

    context 'when not signed in' do
      it "does not redirect" do
        controller.should_not_receive(:redirect_to)
        controller.ensure_signed_out
      end  
    end
  end

  describe "#ensure_admin" do
    context 'when signed in' do
      before do
        sign_in_as(member)
      end

      context 'as an admin' do
        let(:member) { create(:member, :admin, :soundcloud_id => soundcloud_id) }  

        it "does not redirect" do
          controller.should_not_receive(:redirect_to)
          controller.ensure_admin
        end
      end

      context 'as a non-admin' do
        let(:member) { create(:member, :soundcloud_id => soundcloud_id) }  
      
        it "redirects to the root path" do
          controller.should_receive(:redirect_to).with(root_path)
          controller.ensure_admin
        end
      end
    end

    context 'when not signed in' do
      it "redirects to the root path" do
        controller.should_receive(:redirect_to).with(root_path)
        controller.ensure_admin
      end
    end
  end

  # This test is way too strict on implementation but I don't know how to test it otherwise outside of functional testing
  describe "#paginated_respond_with(resource)" do
    let(:resource) { double('resource', :total_pages => 10, :current_page => 1) }
    let(:format) { double('format') }
    
    it "includes pagination parameters in json responses" do
      controller.should_receive(:respond_with).with(resource).and_yield(format)
      format.should_receive(:json).and_yield
      controller.should_receive(:render).with(:json => { :models => resource, :total_pages => resource.total_pages, :page => resource.current_page })
      controller.paginated_respond_with(resource)
    end
  end

  describe ".responder" do
    it "returns BasicResponder" do
      ApplicationController.send(:responder).should == BasicResponder    
    end
  end
end
