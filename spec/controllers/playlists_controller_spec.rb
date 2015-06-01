require 'spec_helper'

describe PlaylistsController do
  include LoginHelper

  describe "GET 'index" do
    def make_request
      get 'index'
    end

    let!(:playlist_1) { create(:playlist) }

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)
      end

      it "assigns all playlists" do
        make_request
        expect(assigns[:playlists]).to eq([playlist_1])
      end
    end
  end

  describe "GET 'show" do
    def make_request
      get 'show', :id => playlist_1.id
    end

    let(:playlist_1) { create(:playlist) }

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)
      end

      it "assigns @playlist" do
        make_request
        expect(assigns[:playlist]).to eq(playlist_1)
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
      
      it "assigns a new playlist" do
        make_request
        playlist_model = assigns[:playlist]
        expect(playlist_model).to be_instance_of(Playlist)
        expect(playlist_model).to be_new_record
      end
    end
  end

  describe "POST 'create'" do
    def make_request
      post 'create', params
    end

    let(:params) do 
      { 
        :playlist => { 
          :title => "Cool New Album We Like", 
          :link => "http://somebody.bandcamp.com/albums/cool-album"
        }
      }
    end

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)
      end
      
      it "creates a playlist based on params" do
        expect { 
          make_request 
        }.to change { Playlist.count }.by(1)

        playlist_model = Playlist.last
        expect(playlist_model.title).to eq params[:playlist][:title]
        expect(playlist_model.link).to eq params[:playlist][:link]
      end

      it "redirects to the created playlist with a notice that the playlist was created successfully" do
        make_request
        expect(response).to redirect_to(Playlist.last)
        expect(flash[:notice]).to eq 'Playlist was successfully created.'
      end

      context 'with invalid params' do
        before do
          params[:playlist][:title] = nil
        end
        
        it "does not create a playlist" do
          expect { make_request }.not_to change { Playlist.count }
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

    let(:playlist_1) { create(:playlist, updated_at: 1.week.ago) }

    let(:params) do 
      { 
        :id => playlist_1.id,
        :playlist => { 
          :title => "New Title"
        } 
      }
    end

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)
      end

      it "updates the playlist with the passed params" do
        make_request
        playlist_1.reload
        expect(playlist_1.title).to eq params[:playlist][:title]
      end

      it "assigns the playlist" do
        make_request
        expect(assigns[:playlist]).to eq(playlist_1)
      end

      it "redirects to the playlist with a notice that the playlist was updated successfully" do
        make_request
        expect(response).to redirect_to(playlist_1)
        expect(flash[:notice]).to eq 'Playlist was successfully updated.'
      end

      context 'with invalid params' do
        before do
          params[:playlist][:title] = ' '
        end

        it "renders the edit action" do
          make_request
          expect(response).to render_template(:edit)
        end

        it "does not update the playlist" do
          expect { 
            make_request 
          }.not_to change { playlist_1.reload.updated_at }
        end
      end
    end
  end

  describe "DELETE 'destroy'" do
    def make_request
      delete 'destroy', params
    end

    let!(:playlist_1) { create(:playlist) }

    let(:params) { { :id => playlist_1.id } }

    it_should_behave_like 'an action that requires a signed in admin member'

    context 'when signed in as an admin member' do
      let(:member) { create(:member, :admin) }

      before do
        sign_in_as(member)
      end    
    
      it "destroys the playlist" do
        expect { 
          make_request 
        }.to change { Playlist.count }.by(-1)

        expect { 
          playlist_1.reload
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "redirects to the index with a success notice" do
        make_request
        expect(response).to redirect_to(:playlists)
        expect(flash[:notice]).to eq 'Playlist was successfully deleted.'
      end
    end
  end
end