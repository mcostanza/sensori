require 'spec_helper'

describe User do
  before(:each) do
    @user = FactoryGirl.build(:user)
  end

  describe "validations" do
    it "should be valid given valid attributes" do
      @user.valid?.should be_true
    end
    it "should be invalid with a non-unique email" do
      @user.save
      other_user = FactoryGirl.build(:user)
      other_user.email = @user.email
      other_user.valid?.should be_false
    end
    it "should be invalid with a non-unique username" do
      @user.save
      other_user = FactoryGirl.build(:user)
      other_user.username = @user.username
      other_user.valid?.should be_false
    end
  end
end
