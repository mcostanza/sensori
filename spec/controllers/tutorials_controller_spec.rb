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

    let!(:tutorial_1) { create(:tutorial, :created_at => 8.days.ago) }
    let!(:tutorial_2) { create(:tutorial, :created_at => 7.days.ago) }
    let!(:tutorial_3) { create(:tutorial, :created_at => 6.days.ago, :featured => true) }
    let!(:tutorial_4) { create(:tutorial, :created_at => 5.days.ago) }
    let!(:tutorial_5) { create(:tutorial, :created_at => 4.days.ago, :published => false) }
    let!(:tutorial_6) { create(:tutorial, :created_at => 3.days.ago) }
    let!(:tutorial_7) { create(:tutorial, :created_at => 2.days.ago) }
    let!(:tutorial_8) { create(:tutorial, :created_at => 1.day.ago) }

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
          expect(assigns[:tutorials]).to eq [tutorial_3, tutorial_8, tutorial_7, tutorial_6, tutorial_4, tutorial_2]
        end
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

          it "should redirect to the edit path if the member is the owner of the tutorial (non-admin)" do
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
      it "should render the new template" do
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
          expect(created_tutorial.published?).to be_false
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
    before(:each) do
      @tutorial = FactoryGirl.build(:tutorial)
      Tutorial.stub(:find).and_return(@tutorial)
    end
    describe "when logged in as an admin" do
      before(:each) do
        login_user(:admin => true)
      end
      it "should return http success" do
        get 'edit', id: '123'
        response.should be_success
      end
      it "should render the edit template" do
        get 'edit', id: '123'
        response.should render_template("tutorials/edit")
      end
      it "should find the tutorial from params[:id] and assign to @tutorial" do
        Tutorial.should_receive(:find).with('123').and_return(@tutorial)
        get 'edit', id: '123'
        assigns[:tutorial].should == @tutorial
      end
    end
    describe "when logged in as a non-admin who created the tutorial" do
      before(:each) do
        login_user
        @tutorial.member = @current_member
      end 
      it "should return http success" do
        get 'edit', id: '123'
        response.should be_success
      end
      it "should render the edit template" do
        get 'edit', id: '123'
        response.should render_template("tutorials/edit")
      end
      it "should find the tutorial from params[:id] and assign to @tutorial" do
        Tutorial.should_receive(:find).with('123').and_return(@tutorial)
        get 'edit', id: '123'
        assigns[:tutorial].should == @tutorial
      end
    end
    describe "when logged in as a non-admin who did not created the tutorial" do
      before(:each) do
        login_user
      end 
      it "should redirect to the root path" do
        get 'edit', id: '123'
        response.should redirect_to(root_path)
      end
    end
    describe "when not logged in" do
      it "should redirect to the root path" do
        get 'edit', id: '123'
        response.should redirect_to(root_path)
      end
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @tutorial_params = {
        :title => "Tutorial",
        :description => "Show u how to do this",
        :body_html => "lots of text with some html",
        :body_components => [{ "type" => "text", "content" => "lots of text with some html" }],
        :attachment_url => "http://s3.amazon.com/tutorial.zip",
        :video_url => "http://www.youtube.com/tutorial"
      }
      @tutorial = Tutorial.new
      @tutorial.stub(:id).and_return(123)
      @tutorial.stub(:update_attributes).and_return(true)
      Tutorial.stub(:find).and_return(@tutorial)
    end
    describe "when logged in as an admin" do
      before(:each) do 
        login_user(:admin => true)
      end
      it "should find the tutorial from params" do
        Tutorial.should_receive(:find).with('123').and_return(@tutorial)
        put 'update', :id => '123', :tutorial => @tutorial_params
      end
      it "should update tutorial attributes" do
        @tutorial.should_receive(:update_attributes).with(@tutorial_params.stringify_keys).and_return(true)
        put 'update', :id => '123', :tutorial => @tutorial_params
      end
      describe "valid params given" do
        it "should redirect to the tutorial" do
          put 'update', :id => '123', :tutorial => @tutorial_params
          response.should redirect_to(@tutorial)
        end
      end
      describe "invalid params given" do
        before(:each) do
          @tutorial.stub(:update_attributes).and_return(false)

          # Not called directly but needed for correct test behavior when using respond_with
          @tutorial.stub(:valid).and_return(false)
          @tutorial.stub(:errors).and_return('errors')
        end
        it "should render the edit template" do
          put 'update', :id => '123', :tutorial => @tutorial_params
          response.should render_template("tutorials/edit")
        end
      end
    end
    describe "when logged in as a non-admin who created the tutorial" do
      before(:each) do 
        login_user
        @tutorial.member = @current_member
      end
      it "should find the tutorial from params" do
        Tutorial.should_receive(:find).with('123').and_return(@tutorial)
        put 'update', :id => '123', :tutorial => @tutorial_params
      end
      it "should update tutorial attributes" do
        @tutorial.should_receive(:update_attributes).with(@tutorial_params.stringify_keys).and_return(true)
        put 'update', :id => '123', :tutorial => @tutorial_params
      end
      describe "valid params given" do
        it "should redirect to the tutorial" do
          put 'update', :id => '123', :tutorial => @tutorial_params
          response.should redirect_to(@tutorial)
        end
      end
      describe "invalid params given" do
        before(:each) do
          @tutorial.stub(:update_attributes).and_return(false)

          # Not called directly but needed for correct test behavior when using respond_with
          @tutorial.stub(:valid).and_return(false)
          @tutorial.stub(:errors).and_return('errors')
        end
        it "should render the edit template" do
          put 'update', :id => '123', :tutorial => @tutorial_params
          response.should render_template("tutorials/edit")
        end
      end
    end
    describe "when logged in as a non-admin who did not create the tutorial" do
      before(:each) do
        login_user
      end 
      it "should find the tutorial from params" do
        Tutorial.should_receive(:find).with('123').and_return(@tutorial)
        put 'update', :id => '123', :tutorial => @tutorial_params
      end
      it "should redirect to the root path" do
        put 'update', :id => '123', :tutorial => @tutorial_params
        response.should redirect_to(root_path)
      end
    end
    describe "when not logged in" do
      it "should not find a tutorial" do
        Tutorial.should_not_receive(:find)
        put 'update', :id => '123', :tutorial => @tutorial_params
      end
      it "should redirect to the root path" do
        put 'update', :id => '123', :tutorial => @tutorial_params
        response.should redirect_to(root_path)
      end
    end
  end

  describe "POST 'preview'" do
    before(:each) do
      @tutorial_params = {
        :title => "Tutorial",
        :description => "Show u how to do this",
        :body_html => "lots of text with some html",
        :attachment_url => "http://s3.amazon.com/tutorial.zip",
        :youtube_id => "10110"
      }
      @tutorial = Tutorial.new
      Tutorial.stub(:find).and_return(@tutorial)
    end
    describe "when logged in as an admin" do
      before(:each) do 
        login_user(:admin => true)
      end
      it "should find the tutorial and prepare a preview" do
        Tutorial.should_receive(:find).with("123").and_return(@tutorial)
        @tutorial.should_receive(:prepare_preview).with(@tutorial_params.stringify_keys)
        post 'preview', :id => "123", :tutorial => @tutorial_params
      end
      it "should not save the tutorial" do
        @tutorial.should_not_receive(:save)
        post 'preview', :id => "123", :tutorial => @tutorial_params
      end
      it "should render the show template" do
        post 'preview', :id => "123", :tutorial => @tutorial_params
        response.should render_template("tutorials/show")
      end
    end
    describe "when logged in as a non-admin who created the tutorial" do
      before(:each) do
        login_user
        @tutorial.member = @current_member
      end
      it "should find the tutorial and prepare a preview" do
        Tutorial.should_receive(:find).with("123").and_return(@tutorial)
        @tutorial.should_receive(:prepare_preview).with(@tutorial_params.stringify_keys)
        post 'preview', :id => "123", :tutorial => @tutorial_params
      end
      it "should not save the tutorial" do
        @tutorial.should_not_receive(:save)
        post 'preview', :id => "123", :tutorial => @tutorial_params
      end
      it "should render the show template" do
        post 'preview', :id => "123", :tutorial => @tutorial_params
        response.should render_template("tutorials/show")
      end
    end
    describe "when logged in as a non-admin who did not create the tutorial" do
      before(:each) do
        login_user
      end 
      it "should find the tutorial from params" do
        Tutorial.should_receive(:find).with('123').and_return(@tutorial)
        post 'preview', :id => '123', :tutorial => @tutorial_params
      end
      it "should redirect to the root path" do
        post 'preview', :id => "123", :tutorial => @tutorial_params
        response.should redirect_to(root_path)
      end
    end
    describe "when not logged in" do
      it "should not find a tutorial" do
        Tutorial.should_not_receive(:find)
        post 'preview', :id => "123", :tutorial => @tutorial_params
      end
      it "should redirect to the root path" do
        post 'preview', :id => "123", :tutorial => @tutorial_params
        response.should redirect_to(root_path)
      end
    end
  end
end
