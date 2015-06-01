require 'spec_helper'

describe HomeController do

  describe "GET 'index'" do
    def make_request
      get 'index'
    end

    it "returns http success" do
      make_request
      expect(response).to be_success
    end

    it "renders the index template" do
      make_request
      expect(response).to render_template('home/index')
    end
    
    context 'assigned data' do
      let!(:tutorial_1) { create(:tutorial, :created_at => 5.days.ago) }
      let!(:tutorial_2) { create(:tutorial, :created_at => 4.days.ago, :featured => true) }
      let!(:tutorial_3) { create(:tutorial, :created_at => 3.days.ago) }
      let!(:tutorial_4) { create(:tutorial, :created_at => 2.days.ago, :published => false) }
      let!(:tutorial_5) { create(:tutorial, :created_at => 1.day.ago) }

      let!(:feature_1) { create(:feature) }

      let!(:playlist_1) { create(:playlist, :soundcloud) }
      let!(:playlist_2) { create(:playlist, :bandcamp) }

      it "finds and assigns featured and latest published tutorials" do
        make_request
        expect(assigns[:tutorials]).to eq([tutorial_2, tutorial_5, tutorial_3])
      end

      it "assigns all features to @features" do
        make_request
        expect(assigns[:features]).to eq([feature_1])
      end

      it "assigns a CarouselItemsPresenter for the features and tutorials" do
        make_request
        carousel_items_presenter = assigns[:carousel_items_presenter]
        expect(carousel_items_presenter.models).to eq([feature_1, tutorial_2, tutorial_5, tutorial_3])
      end

      it "assigns a PlaylistPresenter for the latest playlist" do
        make_request
        playlist_presenter = assigns[:playlist_presenter]
        expect(playlist_presenter.playlist).to eq playlist_2
      end
    end
  end

  describe "GET 'about'" do
    it "returns http success" do
      get "about"
      expect(response).to be_success
    end

    it "renders the about template" do
      get "about"
      expect(response).to render_template('home/about')
    end
  end

  describe "GET 'blog_post_redirect'" do
    let(:post_id) { "53782176895/new-tracks-week-of-june-17th" }
    
    it "redirects to the equivalent post path on blog.sensoricollective.com" do
      get 'blog_post_redirect', :post_id => post_id
      expect(response).to redirect_to(File.join("http://blog.sensoricollective.com/post", post_id))
    end
  end

  describe "GET 'blog_tag_redirect'" do
    let(:tag) { 'playlist' }

    it "redirects to the equivalent tagged posts path on blog.sensoricollective.com" do
      get 'blog_tag_redirect', :tag => tag
      expect(response).to redirect_to(File.join("http://blog.sensoricollective.com/tagged", tag))
    end
  end

  describe "GET 'kickstarter'" do
    it "redirects to kickstarter with 302 status" do
      get "kickstarter"
      expect(response).to redirect_to("http://www.kickstarter.com/projects/philsergi/sensori-collective-community-music-center")
      expect(response.status).to eq 302
    end
  end
end
