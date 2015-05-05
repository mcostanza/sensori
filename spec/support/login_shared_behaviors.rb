shared_examples_for 'an action that requires a signed in member' do
	context 'when not signed in' do
		it "redirects to the root path" do
			make_request
			expect(response).to redirect_to(root_path)
		end
	end
end

shared_examples_for 'an action that requires a signed in admin member' do
	context 'when not signed in' do
		it "redirects to the root path" do
			make_request
			expect(response).to redirect_to(root_path)
		end
	end

	context 'when signed in as a non-admin' do
		let(:member) { create(:member) }

		before do
		  sign_in_as(member)
		end

		it "redirects to the root path" do
			make_request
			expect(response).to redirect_to(root_path)
		end
	end
end