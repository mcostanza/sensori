require "spec_helper"

describe HomeController do
  describe "routing" do
    it "routes GET / to home#index" do
      get("/").should route_to("home#index")
    end

    it "routes GET /about to home#about" do
      get("/about").should route_to("home#about")
    end

    it "routes GET /post/:anything to home#blog_post_redirect" do
      get("/post/64146452653/sensori-session-at-hostel-takeover-10-20-2013").should route_to("home#blog_post_redirect", :post_id => "64146452653/sensori-session-at-hostel-takeover-10-20-2013")
    end

    it "routes GET /kickstarter to home#kickstarter" do
      get('/kickstarter').should route_to('home#kickstarter')
    end

    it "routes GET /tagged/:anything to home#blog_tag_redirect" do
      get('/tagged/playlists').should route_to("home#blog_tag_redirect", :tag => "playlists")
    end
  end
end

