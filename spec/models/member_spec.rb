require 'spec_helper'

describe Member do
  before(:each) do
    @member = FactoryGirl.build(:member)
  end
  
  describe "validations" do
    it "should be valid given valid attributes" do
      @member.valid?.should be_true
    end
    it "should be invalid without a soundcloud_id" do
      @member.soundcloud_id = nil
      @member.valid?.should be_false
    end
    it "should be invalid with a non-unique soundcloud_id" do
      @member.save
      other = FactoryGirl.build(:member)
      other.soundcloud_id = @member.soundcloud_id
      other.valid?.should be_false
    end
    it "should be invalid without name" do
      @member.name = nil
      @member.valid?.should be_false
    end
    it "should be invalid without slug" do
      @member.slug = nil
      @member.valid?.should be_false
    end
    it "should be invalid without image_url" do
      @member.image_url = nil
      @member.valid?.should be_false
    end
    it "should be invalid without soundcloud_access_token" do
      @member.soundcloud_access_token = nil
      @member.valid?.should be_false
    end
  end

  describe "associations" do
    it "should have a tracks association" do
      @member.should respond_to(:tracks)
    end
  end

end
