require "spec_helper"

describe MembersController do
  describe "routing" do

    it "routes to #update" do
      put("/members/1").should route_to("members#update", :id => "1")
    end
    
    it "routes to sign_in" do
      get("/members/sign_in").should route_to("members#sign_in")
    end

    it "routes to sign_out" do
      get("/members/sign_out").should route_to("members#sign_out")
    end
    
    it "routes to soundcloud_connect" do
      get("/members/soundcloud_connect").should route_to("members#soundcloud_connect")
    end
  end
end

