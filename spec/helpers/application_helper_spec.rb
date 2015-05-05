require 'spec_helper'

describe ApplicationHelper do

  it "should have a MOBILE_USER_AGENTS constant" do
    expect(ApplicationHelper::MOBILE_USER_AGENTS).not_to be_nil
  end
  it "should have a MOBILE_USER_AGENT_REGEX constant" do
    expect(ApplicationHelper::MOBILE_USER_AGENT_REGEX).not_to be_nil
  end
  
  describe "#is_mobile_device?" do
    let(:mock_request) { double('request', user_agent: user_agent) }

    before do
      allow(helper).to receive(:request).and_return(mock_request)
    end

    context 'when the user agent is for a mobile device' do
      let(:user_agent) { 'iphone' }

      it "returns true" do
        expect(helper.is_mobile_device?).to be_true
      end  
    end

    context 'when the user agent is for a mobile device (case insensitive)' do
      let(:user_agent) { 'Android' }

      it "returns true" do
        expect(helper.is_mobile_device?).to be_true
      end  
    end
    
    context 'when the user agent is not for a mobile device' do
      let(:user_agent) { 'Firefox' }
      
      it "returns false" do
        expect(helper.is_mobile_device?).to be_false
      end
    end

    context 'when no user agent is available' do
      let(:user_agent) { nil }

      it "returns nil without shitting" do
        expect { helper.is_mobile_device? }.not_to raise_error
        expect(helper.is_mobile_device?).to be_false        
      end
    end
  end

  describe "#active_if(condition)" do
    it "should return 'active' if the condition is true" do
      expect(helper.active_if(true)).to eq 'active'
    end
    it "should return nil otherwise" do
      expect(helper.active_if(false)).to be_nil
      expect(helper.active_if(nil)).to be_nil
    end
  end

  describe "#member_profile_page?(member)" do
    let(:member) { build(:member) }
    
    before do
      allow(helper).to receive(:member_profile_path).and_return('/user')
    end

    context 'when member is present' do
      context "when viewing the member's profile page" do
        it "returns true" do
          expect(helper).to receive(:current_page?).and_return(true)
          helper.member_profile_page?(member).should be_true
        end
      end

      context "when not viewing the member's profile page" do
        it "returns false" do
          expect(helper).to receive(:current_page?).with('/user').and_return(false)
          helper.member_profile_page?(member).should be_false
        end
      end
    end

    context 'when member is blank' do
      let(:member) { nil }

      it "returns false" do
        expect(helper.member_profile_page?(member)).to be_false
      end
    end
  end
end
