require 'spec_helper'

describe FeaturesController do
  include LoginHelper

  describe "GET 'index" do
    def make_request
      get 'index'
    end

    let!(:feature_1) { create(:feature) }

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)
      end

      it "assigns all features" do
        make_request
        expect(assigns[:features]).to eq([feature_1])
      end
    end
  end

  describe "GET 'show" do
    def make_request
      get 'show', :id => feature_1.id
    end

    let(:feature_1) { create(:feature) }

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)
      end

      it "assigns @feature" do
        make_request
        expect(assigns[:feature]).to eq(feature_1)
      end
    end
  end

  describe "GET 'new" do
    def make_request
      get 'new'
    end

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)
      end
      
      it "assigns a new feature" do
        make_request
        feature_model = assigns[:feature]
        expect(feature_model).to be_instance_of(Feature)
        expect(feature_model).to be_new_record
      end
    end
  end

  describe "POST 'create'" do
    def make_request
      post 'create', params
    end

    let(:params) do 
      { 
        :feature => { 
          :title => "Titleddd", 
          :description => "Descriptiodddn",
          :link => "http://links.com",
          :image => fixture_file_upload('/sensori-mpd.jpg')
        } 
      }
    end

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)
      end
      
      it "creates a feature based on params and the current member" do
        expect { 
          make_request 
        }.to change { Feature.count }.by(1)

        feature_model = Feature.last
        expect(feature_model.title).to eq params[:feature][:title]
        expect(feature_model.description).to eq params[:feature][:description]
        expect(feature_model.link).to eq params[:feature][:link]
        expect(feature_model.image).to be_present
        expect(feature_model.member).to eq member
      end

      it "redirects to the created feature with a notice that the feature was created successfully" do
        make_request
        expect(response).to redirect_to(Feature.last)
        expect(flash[:notice]).to eq 'Feature was successfully created.'
      end

      context 'with invalid params' do
        before do
          params[:feature][:title] = nil
        end
        
        it "does not create a feature" do
          expect { make_request }.not_to change { Feature.count }
        end

        it "renders the new action" do
          make_request
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe "PUT 'update'" do
    def make_request
      put 'update', params
    end

    let(:feature_1) { create(:feature, updated_at: 1.week.ago) }

    let(:params) do 
      { 
        :id => feature_1.id,
        :feature => { 
          :title => "New Title", 
          :description => "New Description" 
        } 
      }
    end

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)
      end

      it "updates the feature with the passed params" do
        make_request
        feature_1.reload
        expect(feature_1.title).to eq params[:feature][:title]
        expect(feature_1.description).to eq params[:feature][:description]
      end

      it "assigns the feature" do
        make_request
        expect(assigns[:feature]).to eq(feature_1)
      end

      it "redirects to the feature with a notice that the feature was updated successfully" do
        make_request
        expect(response).to redirect_to(feature_1)
        expect(flash[:notice]).to eq 'Feature was successfully updated.'
      end

      context 'with invalid params' do
        before do
          params[:feature][:title] = ' '
        end

        it "renders the edit action" do
          make_request
          expect(response).to render_template(:edit)
        end

        it "does not update the feature" do
          expect { 
            make_request 
          }.not_to change { feature_1.reload.updated_at }
        end
      end
    end
  end

  describe "DELETE 'destroy'" do
    def make_request
      delete 'destroy', params
    end

    let!(:feature_1) { create(:feature) }

    let(:params) { { :id => feature_1.id } }

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)
      end    
    
      it "destroys the feature" do
        expect { 
          make_request 
        }.to change { Feature.count }.by(-1)

        expect { 
          feature_1.reload
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "redirects to the index with a success notice" do
        make_request
        expect(response).to redirect_to(:features)
        expect(flash[:notice]).to eq 'Feature was successfully deleted.'
      end
    end
  end
end