require 'spec_helper'

describe ActiveRecord::Base do
  describe "#just_created?" do
  	let(:model) { create(:member) }

  	context 'when the record was just created' do  	
  		it "returns true" do
      	expect(model.just_created?).to be true
    	end	
  	end
    
  	context 'when the record already existed in the database' do
  		it "returns false" do
      	expect(Member.find(model.id).just_created?).to be false
    	end
  	end
  end
end
