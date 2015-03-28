require 'spec_helper'

describe HomeController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      expect(response).to be_success
    end
    it "renders the index template" do
      get 'index'
      expect(response).to render_template('home/index')
    end

    context 'assigned data' do
      let!(:track_1) { create(:track, :posted_at => 5.minutes.ago) }
      let!(:track_2) { create(:track, :posted_at => 4.minutes.ago) }
      let!(:track_3) { create(:track, :posted_at => 3.minutes.ago) }
      let!(:track_4) { create(:track, :posted_at => 2.minutes.ago) }
      let!(:track_5) { create(:track, :posted_at => 1.minute.ago)  }

      let!(:tutorial_1) { create(:tutorial, :created_at => 5.days.ago) }
      let!(:tutorial_2) { create(:tutorial, :created_at => 4.days.ago, :featured => true) }
      let!(:tutorial_3) { create(:tutorial, :created_at => 3.days.ago) }
      let!(:tutorial_4) { create(:tutorial, :created_at => 2.days.ago, :published => false) }
      let!(:tutorial_5) { create(:tutorial, :created_at => 1.day.ago) }

      let!(:discussion_1) { create(:discussion, :last_post_at => 4.minutes.ago) }
      let!(:discussion_2) { create(:discussion, :last_post_at => 3.minutes.ago) }
      let!(:discussion_3) { create(:discussion, :last_post_at => 2.minutes.ago) }
      let!(:discussion_4) { create(:discussion, :last_post_at => 1.minute.ago)  }

      it "finds and assigns the latest tracks" do
        get 'index'
        expect(assigns[:latest_tracks]).to eq([track_5, track_4, track_3, track_2])
      end

      it "finds and assigns featured and latest published tutorials" do
        get 'index'
        expect(assigns[:tutorials]).to eq([tutorial_2, tutorial_5, tutorial_3])
      end

      it "finds and assigns the latest discussions" do
        get 'index'
        expect(assigns[:discussions]).to eq([discussion_4, discussion_3, discussion_2])
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
