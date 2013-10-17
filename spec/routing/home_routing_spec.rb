require "spec_helper"

describe HomeController do
  describe "routing" do

    it "routes to #index" do
      get("/").should route_to("home#index")
    end

    it "routes to #about" do
      get("/about").should route_to("home#about")
    end

    it "routes to #blog_post_redirect" do
      get("/post/64146452653/sensori-session-at-hostel-takeover-10-20-2013").should route_to("home#blog_post_redirect", :post_id => "64146452653/sensori-session-at-hostel-takeover-10-20-2013")
    end
  end
end

