require "spec_helper"

describe ResponsesController do
  describe "routing" do

    it "routes to #create" do
      expect(post("/responses")).to route_to("responses#create")
    end

  end
end

