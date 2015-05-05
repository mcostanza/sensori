require "spec_helper"

describe TutorialsController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/tutorials")).to route_to("tutorials#index")
    end

    it "routes to #new" do
      expect(get("/tutorials/new")).to route_to("tutorials#new")
    end

    it "routes to #show" do
      expect(get("/tutorials/1")).to route_to("tutorials#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/tutorials/1/edit")).to route_to("tutorials#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/tutorials")).to route_to("tutorials#create")
    end

    it "routes to #update" do
      expect(put("/tutorials/1")).to route_to("tutorials#update", :id => "1")
    end

    it "routes to #preview" do
      expect(post("/tutorials/1/preview")).to route_to("tutorials#preview", :id => "1")
    end

  end
end
