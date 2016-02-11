require 'spec_helper'

describe SessionsController do
  include LoginHelper

  describe "GET 'index'" do
    def make_request
      get 'index', params
    end

    let(:params) { {} }

    let(:sessions) { create_list(:session, 7) }

    it "returns http success" do
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

    it "returns http success" do
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
        expect(session_model.new_record?).to be true
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
        },
        sample_packs: [
          { url: 'http://s3.amazon.com/sensori/sample-packs/1.zip', name: 'samples-1.zip' }
        ]
      }
    end

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      let(:created_session) { Session.last }
      let(:created_sample_pack) { created_session.sample_packs.last }

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

      it "creates associated sample packs" do
        expect { make_request }.to change { SamplePack.count }.by(1)

        expect(created_sample_pack.url).to eq params[:sample_packs][0][:url]
        expect(created_sample_pack.name).to eq params[:sample_packs][0][:name]
        expect(created_sample_pack.deleted).to be_falsey
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

        it "does not create any sample packs" do
          expect { make_request }.to_not change { SamplePack.count }
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

    let!(:session_model) { create(:session, updated_at: 1.day.ago) }
    let!(:sample_pack_1) { create(:sample_pack, session: session_model) }
    let!(:sample_pack_2) { create(:sample_pack, session: session_model) }

    let(:sample_pack_1_params) do
      {
        url: sample_pack_1.url,
        name: 'New Name For Sample Pack 1'
      }
    end

    let(:new_sample_pack_params) do
      { 
        url: 'http://s3.amazon.com/sensori/sample-packs/new.zip', 
        name: 'Brand New Hot Fiya Samplez'
      }
    end

    let(:params) do
      {
        id: session_model.id,
        session: {
          description: "new description!"
        },
        sample_packs: [
          sample_pack_1_params,
          new_sample_pack_params
        ]
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

      it "updates the associated sample packs" do
        make_request

        sample_pack_1.reload
        expect(sample_pack_1.name).to eq sample_pack_1_params[:name]
        expect(sample_pack_1.deleted).to be_falsey

        sample_pack_2.reload
        expect(sample_pack_2.deleted).to be_truthy

        sample_pack_3 = session_model.sample_packs.last
        expect(sample_pack_3.url).to eq new_sample_pack_params[:url]
        expect(sample_pack_3.name).to eq new_sample_pack_params[:name]
        expect(sample_pack_3.deleted).to be_falsey
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

        it "does not change any sample packs" do
          make_request

          SamplePack.where(deleted: false, session_id: session_model.id).should =~ [sample_pack_1, sample_pack_2]
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

        expect(Session.exists?(session_model.id)).to be false
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
