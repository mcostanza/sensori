require 'spec_helper'

describe DiscussionsHelper do

	describe "#discussion_owner(discussion_creator, response_creator, current_member)" do
		
	  let(:member_1) { build(:member, name: "DJ Costanza") }
		let(:member_2) { build(:member, name: "Envision") }
		let(:member_3) { build(:member, name: "Five05") }
	
    context 'when the discussion creator is the current member' do
      let(:discussion_creator) { member_1 }
      let(:response_creator) { member_2 }
      let(:current_member) { discussion_creator }

      it "returns 'your'" do
        expect(helper.discussion_owner(discussion_creator, response_creator, current_member)).to eq "your"
      end    
    end

    context 'when the discussion creator is also the response creator' do
      let(:discussion_creator) { member_1 }
      let(:response_creator) { discussion_creator }
      let(:current_member) { member_2 }

      it "returns 'their'" do
        expect(helper.discussion_owner(discussion_creator, response_creator, current_member)).to eq "their"
      end  
    end
	  
    context 'when neither the discussion creator nor the response creator are the current member' do
      let(:discussion_creator) { member_1 }
      let(:response_creator) { member_2 }
      let(:current_member) { member_3 }

      it "returns the possessive version of the discussion creator's name" do
        expect(helper.discussion_owner(discussion_creator, response_creator, current_member)).to eq "DJ Costanza's"
      end  
    end
	end

  describe "#discussion_categories" do
    it "returns Discussion::CATEGORIES prepended with nil (nil is used for all)" do
      expect(helper.discussion_categories).to eq([nil] + Discussion::CATEGORIES)
    end
  end

  describe "#discussion_categories_for_select" do
    it "returns Discussion::CATEGORIES mapped into an array of arrays" do
      expect(helper.discussion_categories_for_select).to eq Discussion::CATEGORIES.map { |c| [c.titleize, c] }
    end
  end

  describe "#category_name(category)" do
    it "titleizes the passed category" do
      expect(helper.category_name('music-recs')).to eq 'Music Recs'
    end
    it "returns 'All' when nil is passed" do
      expect(helper.category_name(nil)).to eq 'All'
    end
    it "returns 'All' when '' is passed" do
      expect(helper.category_name('')).to eq 'All'
    end
  end
end
