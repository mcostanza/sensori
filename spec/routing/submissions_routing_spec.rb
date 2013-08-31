require "spec_helper"

describe SubmissionsController do
  describe "routing" do

    it "routes to #create" do
      post("/sessions/1/submissions").should route_to("submissions#create", :session_id => "1")
    end

    it "routes to #update" do
      put("/sessions/1/submissions/2").should route_to("submissions#update", :id => "2", :session_id => "1")
    end

    it "routes to #destroy" do
      delete("/sessions/1/submissions/2").should route_to("submissions#destroy", :id => "2", :session_id => "1")
    end

  end
end
