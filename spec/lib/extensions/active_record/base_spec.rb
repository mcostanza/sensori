require 'spec_helper'

describe ActiveRecord::Base do
  describe "#just_created?" do

    it "should return true when a record is just created" do
      expect(create(:member).just_created?).to be_true
    end
    it "should return false when a record already existed" do
      member_id = create(:member).id
      expect(Member.find(member_id).just_created?).to be_false
    end
  end
end
