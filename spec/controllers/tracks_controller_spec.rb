require 'spec_helper'

describe TracksController do
  describe "GET 'index'" do
    def make_request
      get 'index', params
    end

    let(:params) do
      {}
    end

    let!(:tracks) do 
      1.upto(13).map { |num| create(:track, posted_at: num.minutes.ago) }
    end

    it "should return http success" do
      get 'index'
      expect(response).to be_success
    end

    it "loads the latest 12 Tracks and assigns to @tracks" do
      make_request
      expect(assigns[:tracks]).to eq tracks.first(12)
    end

    context 'with pagination params' do
      let(:params) { { page: 2 } }

      it "loads paginated tracks" do
        make_request
        expect(assigns[:tracks]).to eq tracks.last(1)
      end

      context 'when page is less than 1' do
        let(:params) { { page: 0 } }
        it "loads the first page of tracks" do
          make_request
          expect(assigns[:tracks]).to eq tracks.first(12)
        end
      end
    end
  end
end
