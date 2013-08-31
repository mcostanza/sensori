require "spec_helper"

describe ResponsesController do
  describe "routing" do

    it "routes to #create" do
      post("/responses").should route_to("responses#create")
    end

  end
end

