require 'spec_helper'

describe DiscussionsController do

  include LoginHelper

  describe "GET 'index'" do
    def make_request
      get 'index', params
    end

    let!(:discussions) do 
      1.upto(11).map { |num| create(:discussion, :any_category, last_post_at: num.hours.ago) }
    end

    let(:params) { {} }

    it "should return http success" do
      make_request
      expect(response).to be_success
    end

    context 'when filtering by a category' do
      let(:params) { { category: 'general' } }
      
      let!(:discussions) do 
        1.upto(11).map { |num| create(:discussion, category: 'general', last_post_at: num.hours.ago) }
      end

      let!(:other_discussion) { create(:discussion, category: 'production') }

      it "loads and assigns 10 discussions from the category" do
        make_request
        expect(assigns[:discussions]).to eq discussions.first(10)
      end
    end

    context 'when not filtering by category' do
      it "loads and assigns 10 discussions from all categories" do
        make_request
        expect(assigns[:discussions]).to eq discussions.first(10)
      end
    end

    context 'with pagination' do
      let(:params) { { page: 2 } }

      it "loads and assigns paginated discussions" do
        make_request
        expect(assigns[:discussions]).to eq [discussions.last]
      end
    end

    context 'with a page lower than 1' do
      let(:params) { { page: 0 } }

      it "loads and assigns the first page of discussions" do
        make_request
        expect(assigns[:discussions]).to eq discussions.first(10)
      end
    end

    it "uses the paginated_respond_with method to respond" do
      expect(controller).to receive(:paginated_respond_with).with(discussions.first(10))
      make_request
    end
  end

  describe "GET 'show'" do
    def make_request
      get 'show', params
    end

    let(:params) { { id: discussion.id } }

    let(:discussion) { create(:discussion, :response_count => 3) }

    it "should return http success" do
      make_request
      expect(response).to be_success
    end
    it "finds and assigns the discussion" do
      make_request
      expect(assigns[:discussion]).to eq discussion
    end
    it "assigns the discussion's responses" do
      make_request
      expect(assigns[:responses]).to eq discussion.responses
    end
  end

  describe "GET 'new'" do
    def make_request
      get 'new'
    end

    it_should_behave_like "an action that requires a signed in member"

    context 'when signed in' do
      let(:member) { create(:member) }

      before do
        sign_in_as(member)
      end

      it "renders the new discussion template" do
        make_request
        expect(response).to render_template("discussions/new")
      end

      it "assigns a new discussion associated with the current member" do
        make_request
        discussion = assigns[:discussion]
        expect(discussion.new_record?).to be_true
        expect(discussion.member).to eq member
      end
    end
  end

  describe "POST 'create'" do
    def make_request
      post 'create', params
    end

    let(:params) do
      {
        discussion: {
          subject: 'check my new beat',
          body: 'its cool right?',
          category: 'production',
          members_only: false
        }
      }
    end    

    it_should_behave_like "an action that requires a signed in member"

    context 'when signed in' do
      let(:member) { create(:member) }

      let(:created_discussion) { Discussion.last }

      before do
        sign_in_as(member)    
      end  

      context 'with valid parameters' do
        it "creates a discussion" do
          expect { 
            make_request 
          }.to change { Discussion.count }.by(1)

          expect(created_discussion.member).to eq member
          expect(created_discussion.subject).to eq params[:discussion][:subject]
          expect(created_discussion.body).to eq params[:discussion][:body]
          expect(created_discussion.members_only).to eq params[:discussion][:members_only]
        end

        it "assigns the created discussion" do
          make_request
          expect(assigns[:discussion]).to eq created_discussion
        end

        it "redirects to the created discussion" do
          make_request
          expect(response).to redirect_to(created_discussion)
        end
      end

      context 'with invalid parameters' do
        before do
          params[:discussion][:subject] = nil
        end

        it "does not create a discussion" do
          expect { 
            make_request
          }.not_to change { Discussion.count }
        end

        it "renders the new template" do
          make_request
          expect(response).to render_template('discussions/new')
        end
      end
    end
  end

  describe "DELETE 'destroy'" do
    def make_request
      delete 'destroy', params
    end

    let(:member) { create(:member) }
    let(:discussion) { create(:discussion, member: member) }

    let(:params) do
      {
        id: discussion.id
      }
    end

    before do
      allow(Discussion).to receive(:find).with(discussion.id).and_return(discussion)
    end

    it_should_behave_like "an action that requires a signed in member"

    context 'when signed in' do
      before do
        sign_in_as(member)
      end

      context 'when the discussion is editable by the current member' do
        before do
          allow(discussion).to receive(:editable?).with(member).and_return(true)
        end

        it "destroys the discussion" do
          expect {
            make_request
          }.to change { Discussion.count }.by(-1)

          expect(Discussion.exists?(discussion.id)).to be_false
        end

        it "redirects to the discussions index with a success notice" do
          make_request
          expect(response).to redirect_to(discussions_url)
          expect(flash[:notice]).to eq 'Discussion was successfully deleted.'
        end
      end      

      context 'when the discussion is not editable by the current member' do
        before do
          allow(discussion).to receive(:editable?).with(member).and_return(false)
        end

        it "does not destroy the discussion" do
          expect {
            make_request
          }.not_to change { Discussion.count }

          expect(Discussion.exists?(discussion.id)).to be_true
        end

        it "redirects to the discussion with a flash alert" do
          make_request
          expect(response).to redirect_to(discussion)
          expect(flash[:alert]).to eq 'Discussion is no longer editable.'
        end
      end
    end
  end

  describe "GET 'edit'" do
    def make_request
      get 'edit', params
    end

    let(:member) { create(:member) }
    let(:discussion) { build(:discussion, member: member, :id => 10101) }

    let(:params) do
      {
        :id => discussion.id
      }
    end

    before do
      allow(Discussion).to receive(:find).with(discussion.id).and_return(discussion)
    end

    it_should_behave_like "an action that requires a signed in member"

    context 'when signed in' do
      before do
        sign_in_as(member)
      end

      context 'when the discussion is editable by the current member' do
        before do
          allow(discussion).to receive(:editable?).with(member).and_return(true)
        end

        it "assigns the discussion" do
          make_request
          expect(assigns[:discussion]).to eq discussion
        end

        it "renders the edit template" do
          make_request
          expect(response).to render_template('discussions/edit')
        end
      end      

      context 'when the discussion is not editable by the current member' do
        before do
          allow(discussion).to receive(:editable?).with(member).and_return(false)
        end

        it "redirects to the discussion with a flash alert" do
          make_request
          expect(response).to redirect_to(discussion)
          expect(flash[:alert]).to eq 'Discussion is no longer editable.'
        end
      end
    end
  end

  describe "PUT 'update'" do
    def make_request
      put 'update', params
    end

    let(:member) { create(:member) }
    let(:discussion) { create(:discussion, member: member, updated_at: 1.day.ago) }

    let(:params) do
      {
        id: discussion.id, 
        discussion: {
          body: 'new body!'
        }
      }
    end

    it_should_behave_like "an action that requires a signed in member"

    before do
      allow(Discussion).to receive(:find).and_return(discussion)
    end

    it_should_behave_like "an action that requires a signed in member"

    context 'when signed in' do
      before do
        sign_in_as(member)
      end

      context 'when the discussion is editable by the current member' do
        before do
          allow(discussion).to receive(:editable?).with(member).and_return(true)
        end

        it "updates the discussion" do
          expect {
            make_request
          }.to change { discussion.reload.updated_at }

          expect(discussion.reload.body).to eq params[:discussion][:body]
        end

        it "redirects to the discussion" do
          make_request
          expect(response).to redirect_to(discussion)
        end
      end      

      context 'when the discussion is not editable by the current member' do
        before do
          allow(discussion).to receive(:editable?).with(member).and_return(false)
        end

        it "does not update the discussion" do
          expect {
            make_request
          }.not_to change { discussion.reload.updated_at }
        end

        it "redirects to the discussion with a flash alert" do
          make_request
          expect(response).to redirect_to(discussion)
          expect(flash[:alert]).to eq 'Discussion is no longer editable.'
        end
      end
    end
  end
end
