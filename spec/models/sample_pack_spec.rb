require 'spec_helper'

describe SamplePack do
  describe "validations" do
  	let(:sample_pack) { build(:sample_pack) }

  	specify { sample_pack.should be_valid }

  	%w[ url name session ].each do |attribute|
  		context "without #{attribute}" do
	  		before do 
	  			sample_pack.send("#{attribute}=", nil)
	  		end

	  		specify { sample_pack.should_not be_valid }
	  	end
  	end
  end

  describe "associations" do
    it "belongs to a session" do
      expect(described_class.reflect_on_association(:session).macro).to eq :belongs_to
    end
  end
end
