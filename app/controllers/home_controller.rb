class HomeController < ApplicationController
  def prelaunch
    @prelaunch_signup = PrelaunchSignup.new
  end
end
