require 'spec_helper'

describe MembersHelper do
  describe "#member_location(member)" do
    let(:member) { build(:member, :city => "Boston", :country => "United States") }
    
    it "returns a formatted string of the members location" do
      expect(helper.member_location(member)).to eq "Boston, United States"
    end

    context "when the member's country is blank" do
      let(:member) { build(:member, :city => "Boston") }
        
      it "returns only the city when country is unavailable" do
        expect(helper.member_location(member)).to eq "Boston"
      end    
    end
    
    context "when the member's city is blank" do
      let(:member) { build(:member, :country => "United States") }

      it "returns only the country" do
        expect(helper.member_location(member)).to eq "United States"
      end  
    end
    
    context 'when the member does not have any location data' do
      let(:member) { build(:member) }
      
      it "returns an empty string" do
        expect(helper.member_location(member)).to eq ''
      end  
    end
  end

  describe "#member_profile_full_name(member)" do
    context 'when the member has a full_name' do
      let(:member) { build(:member, :full_name => 'Steve Dods') }

      it "returns a muted span with the member's full name" do
        assert_dom_equal(helper.member_profile_full_name(member), '<span class="full-name muted">(Steve Dods)</span>')
      end  
    end
    
    context 'when the member does not have a full_name' do
      let(:member) { build(:member) }

      it "returns nil when the member's full name is not set" do
        expect(helper.member_profile_full_name(member)).to be_nil
      end      
    end
  end

  describe "#member_profile_location(member)" do
    context "when the member's location is set" do
      let(:member) { build(:member, :city => "Boston", :country => "United States") }

      it "returns the member's location along with a map marker icon" do
        assert_dom_equal(helper.member_profile_location(member), '<p><i class="icon-map-marker"></i> Boston, United States</p>')
      end
    end
  

    context "when the member's location data is not set" do
      let(:member) { build(:member) }
      
      it "returns nil" do
        expect(helper.member_profile_location(member)).to be_nil
      end
    end
    
  end
end
