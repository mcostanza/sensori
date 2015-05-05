require "spec_helper"

describe TracksController do
  describe "routing" do
    it "routes GET /beats to tracks#index" do
      expect(get("/beats")).to route_to("tracks#index")
    end
  end
end

