require 'spec_helper'

describe TutorialsController do
  include LoginHelper

  before do
    allow(controller).to receive(:respond_with).and_call_original
  end

  describe "GET 'index'" do
    def make_request
      get 'index', params
    end

    let(:params) { {} }

    let!(:tutorial_1) { create(:tutorial, created_at: 8.days.ago) }
    let!(:tutorial_2) { create(:tutorial, created_at: 7.days.ago) }
    let!(:tutorial_3) { create(:tutorial, created_at: 6.days.ago, featured: true) }
    let!(:tutorial_4) { create(:tutorial, created_at: 5.days.ago) }
    let!(:tutorial_5) { create(:tutorial, created_at: 4.days.ago, published: false) }
    let!(:tutorial_6) { create(:tutorial, created_at: 3.days.ago) }
    let!(:tutorial_7) { create(:tutorial, created_at: 2.days.ago) }
    let!(:tutorial_8) { create(:tutorial, created_at: 1.day.ago) }

    it "return http success" do
      make_request
      expect(response).to be_success
    end

    it "renders the index template" do
      make_request
      expect(response).to render_template("tutorials/index")
    end

    it "loads and assigns 6 published/featured tutorials" do
      make_request
      expect(assigns[:tutorials]).to eq [tutorial_3, tutorial_8, tutorial_7, tutorial_6, tutorial_4, tutorial_2]
    end

    context 'with pagination' do
      let(:params) { { page: 2 } }

      it "loads paginated tutorials" do
        make_request
        expect(assigns[:tutorials]).to eq [tutorial_1]
      end

      context 'when page is less than 1' do
        let(:params) { { page: 0 } }
        it "loads and assigns the first page of tutorials" do
          make_request
          expect(assigns[:tutorials].map(&:title)).to eq [tutorial_3, tutorial_8, tutorial_7, tutorial_6, tutorial_4, tutorial_2].map(&:title)
        end
      end
    end

    context 'when signed in' do
      let(:member) { tutorial_5.member }

      before do
        sign_in_as(member)
      end

      it "includes unpublished tutorials created by the current member" do
        make_request
        expect(assigns[:tutorials]).to eq [tutorial_3, tutorial_8, tutorial_7, tutorial_6, tutorial_5, tutorial_4]
      end
    end
  end

  describe "GET 'show'" do
    def make_request
      get 'show', id: tutorial.id
    end
    
    let(:tutorial) { create(:tutorial) }
    
    context "when the tutorial is published" do
      it "returns http success" do
        make_request
        expect(response).to be_success
      end
      it "renders the show template" do
        make_request
        expect(response).to render_template("tutorials/show")
      end
      it "finds and assigns the tutorial" do
        make_request
        expect(assigns[:tutorial]).to eq tutorial
      end
    end

    context "when the tutorial is not published" do
      let(:tutorial) { create(:tutorial, published: false) }

      context 'when signed in' do
        before do
          sign_in_as(member)
        end

        context 'as an admin' do
          let(:member) { create(:member, :admin) }

          before do
            sign_in_as(member)
          end

          it "redirects to the edit path" do
            make_request
            expect(response).to redirect_to("http://test.host/tutorials/#{tutorial.slug}/edit")
          end
        end

        context 'as the member who created the tutorial' do
          let(:member) { tutorial.member }

          before do
            sign_in_as(member)
          end

          it "redirects to the edit path if the member is the owner of the tutorial (non-admin)" do
            make_request
            expect(response).to redirect_to("http://test.host/tutorials/#{tutorial.slug}/edit")
          end
        end

        context 'as any other member' do
          let(:member) { create(:member) }

          it "redirects to the tutorials index" do
            make_request
            expect(response).to redirect_to(tutorials_url)
          end
        end
      end

      context 'when not signed in' do
        it "redirects to the tutorials index" do
          make_request
          expect(response).to redirect_to(tutorials_url)
        end
      end
    end
  end

  describe "GET 'new'" do
    def make_request
      get 'new'
    end

    it_should_behave_like 'an action that requires a signed in member'

    describe "when logged in" do
      let(:member) { create(:member) }
      
      before do
        sign_in_as(member)
      end

      it "returns http success" do
        make_request
        expect(response).to be_success
      end
      it "renders the new template" do
        make_request
        expect(response).to render_template("tutorials/new")
      end
      it "assigns a new tutorial" do
        make_request
        tutorial = assigns[:tutorial]
        expect(tutorial).to be_an_instance_of(Tutorial)
        expect(tutorial.member).to eq member
      end
    end
  end

  describe "POST 'create'" do
    def make_request
      post 'create', params
    end

    let(:params) do
      {
        tutorial: tutorial_params,
        format: 'json'
      }
    end

    let(:tutorial_params) do
      {
        :title => "Tutorial",
        :description => "Show u how to do this",
        :body_html => "lots of text with some html",
        :body_components => [{ "type" => "text", "content" => "lots of text with some html" }],
        :attachment_url => "http://s3.amazon.com/tutorial.zip",
        :youtube_id => "10110"
      }
    end

    it_should_behave_like 'an action that requires a signed in member'

    context "when signed in" do
      let(:member) { create(:member) }

      before do
        sign_in_as(member)
      end

      context 'when valid parameters are given' do
        let(:created_tutorial) { Tutorial.last }

        it "creates an unpublished tutorial" do
          expect {
            make_request
          }.to change { Tutorial.count }.by(1)

          expect(created_tutorial.title).to eq tutorial_params[:title]
          expect(created_tutorial.description).to eq tutorial_params[:description]
          expect(created_tutorial.body_html).to eq tutorial_params[:body_html]
          expect(created_tutorial.body_components).to eq tutorial_params[:body_components]
          expect(created_tutorial.title).to eq tutorial_params[:title]
          expect(created_tutorial.member).to eq member
          expect(created_tutorial.published?).to be false
        end

        it "responds with 201 status" do
          make_request
          expect(response.status).to eq 201
        end

        it "responds with the tutorial" do
          make_request
          expect(controller).to have_received(:respond_with).with(created_tutorial)
        end
      end

      context 'when invalid parameters are given' do
        before do
          params[:tutorial][:title] = ''
        end

        it "does not create a tutorial" do
          expect {
            make_request
          }.not_to change { Tutorial.count }
        end

        it "responds with 422" do
          make_request
          expect(response.status).to eq 422
        end

        it "responds with the tutorial" do
          make_request
          expect(controller).to have_received(:respond_with).with(an_instance_of(Tutorial))
        end
      end
    end
  end

  describe "GET 'edit'" do
    def make_request
      get 'edit', id: tutorial.id
    end

    before do
      allow(Tutorial).to receive(:find).and_return(tutorial)
    end

    let(:tutorial) { create(:tutorial) }

    it_should_behave_like 'an action that requires a signed in member'

    describe "when signed in" do
      let(:member) { create(:member) }
      
      before do
        sign_in_as(member)
      end

      context 'as a member who can edit this tutorial' do
        before do
          allow(tutorial).to receive(:editable?).with(member).and_return(true)
        end

        it "returns http success" do
          make_request
          expect(response).to be_success
        end
        it "renders the edit template" do
          make_request
          expect(response).to render_template("tutorials/edit")
        end
        it "loads and assigns the tutorial" do
          make_request
          expect(assigns[:tutorial]).to eq tutorial
        end
      end

      context 'as a member who cannot edit this tutorial' do
        before do
          allow(tutorial).to receive(:editable?).with(member).and_return(false)
        end

        it "redirects to the root path" do
          make_request
          expect(response).to redirect_to root_path
        end
      end
    end

    context 'when not signed in' do
      it "redirects to the root path" do
        make_request
        expect(response).to redirect_to root_path
      end      
    end
  end

  describe "PUT 'update'" do
    def make_request
      put 'update', params
    end

    before do
      allow(Tutorial).to receive(:find).and_return(tutorial)
    end

    let(:member) { create(:member) }
    let(:tutorial) { create(:tutorial, member: member, updated_at: 1.day.ago, include_table_of_contents: false) }

    let(:params) do
      {
        id: tutorial.id,
        tutorial: tutorial_params,
        format: 'json'
      }
    end

    let(:tutorial_params) do
      {
        title: "Tutorial",
        description: "Show u how to do this",
        body_html: "lots of text with some html",
        body_components: [{ "type" => "text", "content" => "lots of text with some html" }],
        attachment_url: "http://s3.amazon.com/tutorial.zip",
        youtube_id: "10110",
        published: true
      }
    end

    it_should_behave_like 'an action that requires a signed in member'

    context "when signed in" do
      let(:member) { create(:member) }

      before do
        sign_in_as(member)
      end

      context 'as a member who can edit this tutorial' do
        before do
          allow(tutorial).to receive(:editable?).with(member).and_return(true)
        end

        context 'when valid parameters are given' do
          it "updates the tutorial" do
            expect {
              make_request
            }.to change { tutorial.reload.updated_at }

            tutorial.reload

            expect(tutorial.title).to eq tutorial_params[:title]
            expect(tutorial.description).to eq tutorial_params[:description]
            expect(tutorial.body_html).to eq tutorial_params[:body_html]
            expect(tutorial.body_components).to eq tutorial_params[:body_components]
            expect(tutorial.title).to eq tutorial_params[:title]
            expect(tutorial.member).to eq member
            expect(tutorial.published?).to be true
          end

          it "responds with 200 status" do
            make_request
            expect(response.status).to eq 200
          end

          it "responds with the tutorial" do
            make_request
            expect(controller).to have_received(:respond_with).with(tutorial.reload)
          end
        end

        context 'when invalid parameters are given' do
          before do
            params[:tutorial][:title] = ''
          end

          it "does not update the tutorial" do
            expect {
              make_request
            }.not_to change { tutorial.reload.updated_at }
          end

          it "responds with 422" do
            make_request
            expect(response.status).to eq 422
          end

          it "responds with the tutorial" do
            make_request
            expect(controller).to have_received(:respond_with).with(tutorial)
          end
        end
      end

      context 'as a member who cannot edit this tutorial' do
        before do
          allow(tutorial).to receive(:editable?).with(member).and_return(false)
        end

        it "redirects to the root path" do
          make_request
          expect(response).to redirect_to root_path
        end

        it "does not update the tutorial" do
          expect {
            make_request
          }.not_to change { tutorial.reload.updated_at }
        end
      end
    end
  end

  describe "POST 'preview'" do
    def make_request
      post 'preview', params
    end

    before do
      allow(Tutorial).to receive(:find).and_return(tutorial)
    end

    let(:member) { create(:member) }
    let(:tutorial) { create(:tutorial, member: member, updated_at: 1.day.ago, include_table_of_contents: false) }

    let(:params) do
      {
        id: tutorial.id,
        tutorial: tutorial_params
      }
    end

    let(:tutorial_params) do
      {
        title: "Tutorial",
        description: "Show u how to do this",
        body_html: "lots of text with some html",
        body_components: [{ "type" => "text", "content" => "lots of text with some html" }],
        attachment_url: "http://s3.amazon.com/tutorial.zip",
        youtube_id: "10110"
      }
    end

    it_should_behave_like 'an action that requires a signed in member'

    context "when signed in" do
      let(:member) { create(:member) }

      before do
        sign_in_as(member)
      end

      context 'as a member who can edit this tutorial' do
        before do
          allow(tutorial).to receive(:editable?).with(member).and_return(true)
        end

        it "prepares a preview of the tutorial" do
          expect(tutorial).to receive(:prepare_preview)
          make_request
        end
        
        it "assigns the tutorial" do
          make_request
          expect(assigns[:tutorial]).to eq tutorial
        end

        it "responds with 200 status" do
          make_request
          expect(response.status).to eq 200
        end

        it "renders the show template" do
          make_request
          expect(response).to render_template("tutorials/show")
        end

        it "does not update the tutorial" do
          expect {
            make_request
          }.not_to change { tutorial.reload.updated_at }
        end
      end
    

      context 'as a member who cannot edit this tutorial' do
        before do
          allow(tutorial).to receive(:editable?).with(member).and_return(false)
        end

        it "redirects to the root path" do
          make_request
          expect(response).to redirect_to root_path
        end

        it "does not update the tutorial" do
          expect {
            make_request
          }.not_to change { tutorial.reload.updated_at }
        end        
      end
    end
  end
end
