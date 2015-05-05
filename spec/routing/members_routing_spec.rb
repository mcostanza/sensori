require "spec_helper"

describe MembersController do
  describe "routing" do

    it "routes to #update" do
      expect(put("/members/1")).to route_to("members#update", :id => "1")
    end

    it "routes to #show" do
      expect(get("/members/1")).to route_to("members#show", :id => "1")
    end

    it "routes to #show (flat route)" do
      expect(get("/five05")).to route_to("members#show", :id => "five05")
    end
    
    it "routes to sign_in" do
      expect(get("/members/sign_in")).to route_to("members#sign_in")
    end

    it "routes to sign_out" do
      expect(get("/members/sign_out")).to route_to("members#sign_out")
    end
    
    it "routes to soundcloud_connect" do
      expect(get("/members/soundcloud_connect")).to route_to("members#soundcloud_connect")
    end
  end
end

