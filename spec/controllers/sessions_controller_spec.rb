require 'spec_helper'

describe SessionsController do
  include LoginHelper

  describe "GET 'index'" do
    def make_request
      get 'index', params
    end

    let(:params) { {} }

    let(:sessions) { create_list(:session, 7) }

    it "should return http success" do
      get 'index'
      expect(response).to be_success
    end
    it "assigns @sessions" do
      make_request
      expect(assigns[:sessions]).to eq sessions.reverse.first(6)
    end

    context 'when pagination params are passed' do
      before do
        params[:page] = 2
      end

      it "loads paginated sessions" do
        make_request
        expect(assigns[:sessions]).to eq sessions.first(1)
      end

      context 'when a page lower than 1 is passed' do
        before do
          params[:page] = 0
        end
        
        it "loads the first page of sessions" do
          make_request
          expect(assigns[:sessions]).to eq sessions.reverse.first(6)
        end
      end
    end
  end

  describe "GET 'show'" do
    def make_request
      get 'show', :id => session_model.id
    end

    let(:session_model) { create(:session) }

    it "should return http success" do
      make_request
      expect(response).to be_success
    end
    it "loads and assigns the session" do
      make_request
      expect(assigns[:session]).to eq session_model
    end

    context 'when signed in' do
      let(:member) { create(:member) }

      before do
        sign_in_as(member)
      end

      context 'when the member already has a submission for this session' do
        let!(:submission) { create(:submission, session: session_model, member: member) }

        it "assigns the member's submission" do
          make_request
          expect(assigns[:submission]).to eq submission  
        end
      end

      context 'when the member does not already have a submission for this session' do
        it "assigns a new submission for the member and session" do
          make_request
          submission = assigns[:submission]
          expect(submission).to be_an_instance_of(Submission)
          expect(submission.member).to eq member
          expect(submission.session).to eq session_model
        end
      end
    end
  end

  describe "GET 'new'" do
    def make_request
      get 'new'
    end

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)
      end

      it "initializes a new session and assign it to @session" do
        make_request
        session_model = assigns[:session]
        expect(session_model).to be_an_instance_of(Session)
        expect(session_model.new_record?).to be_true
      end
    end
  end

  describe "POST 'create'" do
    def make_request
      post 'create', params
    end

    let(:params) do
      {
        session: {
          title: "title",
          description: "lets all make some beats",
          image: fixture_file_upload('/sensori-mpd.jpg', 'image/jpeg'),
          end_date: 2.weeks.from_now
        }
      }
    end

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      let(:created_session) { Session.last }

      before do
        sign_in_as(member)
      end

      it "creates a session" do
        expect { 
          make_request
        }.to change { Session.count }.by(1)

        expect(created_session.member).to eq member
        expect(created_session.title).to eq params[:session][:title]
        expect(created_session.description).to eq params[:session][:description]
      end

      it "assigns the session" do
        make_request
        expect(assigns[:session]).to eq created_session
      end

      it "redirects to the created session with a success notice" do
        make_request
        expect(response).to redirect_to(created_session)
        expect(flash[:notice]).to eq 'Session was successfully created.'
      end

      context 'when the session is invalid' do
        before do
          params[:session][:title] = nil
        end

        it "does not create a session" do
          expect {
            make_request
          }.not_to change { Session.count }
        end

        it "renders the new template" do
          make_request
          expect(response).to render_template('sessions/new')
        end
      end
    end
  end

  describe "PUT 'update'" do
    def make_request
      put 'update', params
    end

    let(:session_model) { create(:session, updated_at: 1.day.ago) }

    let(:params) do
      {
        id: session_model.id,
        session: {
          description: "new description!"
        }
      }
    end

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)
      end

      it "updates the session" do
        expect { 
          make_request
        }.to change { session_model.reload.updated_at }

        session_model.reload
        expect(session_model.description).to eq params[:session][:description]
      end

      it "assigns the session" do
        make_request
        expect(assigns[:session]).to eq session_model
      end

      it "redirects to the session with a success notice" do
        make_request
        expect(response).to redirect_to(session_model)
        expect(flash[:notice]).to eq 'Session was successfully updated.'
      end

      context 'when the session is invalid' do
        before do
          params[:session][:title] = nil
        end

        it "does not update the session" do
          expect {
            make_request
          }.not_to change { session_model.reload.updated_at }
        end

        it "renders the edit template" do
          make_request
          expect(response).to render_template('sessions/edit')
        end
      end
    end
  end

  describe "DELETE 'destroy'" do
    def make_request
      delete 'destroy', params
    end

    let!(:session_model) { create(:session) }

    let(:params) do
      {
        id: session_model.id
      }
    end

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)
      end

      it "destroys the session" do
        expect { 
          make_request
        }.to change { Session.count }.by(-1)

        expect(Session.exists?(session_model.id)).to be_false
      end

      it "redirects to the sessions index" do
        make_request
        expect(response).to redirect_to(sessions_url)
      end
    end
  end

  describe "GET 'submissions'" do
    def make_request
      get 'submissions', :id => session_model.id
    end

    let(:session_model) { create(:session) }

    before do
      create_list(:submission, 2, session: session_model)
    end

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)  
      end

      it "returns http success" do
        make_request
        expect(response).to be_success
      end
      it "loads and assigns @session and the associated @submissions" do
        make_request
        expect(assigns[:session]).to eq session_model
        expect(assigns[:submissions]).to eq session_model.submissions
      end
    end
  end
end
