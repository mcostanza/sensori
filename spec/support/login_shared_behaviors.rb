shared_examples_for 'an action that requires a signed in user' do
	context 'when not signed in' do
		it "redirects to the root path" do
			make_request
			expect(response).to redirect_to(root_path)
		end
	end
end