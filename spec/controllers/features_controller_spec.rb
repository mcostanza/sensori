require 'spec_helper'

describe FeaturesController do
  include LoginHelper

  before do
    controller.stub(:ensure_admin)
  end

  describe "GET 'index" do
    it "should have the ensure_admin before filter" do
      controller.should_receive(:ensure_admin)
      get 'index'
    end
    it "should load all of the features" do
      Feature.should_receive(:all).and_return('features')
      get 'index'
      assigns[:features].should == 'features'
    end
  end

  describe "GET 'show" do
    before do
      @feature = double(Feature, :id => 41)
      Feature.stub(:find).and_return(@feature)
    end
    it "should have the ensure_admin before filter" do
      controller.should_receive(:ensure_admin)
      get 'show', :id => 41
    end
    it "should find the feature by id and assign it to @feature" do
      Feature.should_receive(:find).with("41").and_return(@feature)
      get 'show', :id => 41
      assigns[:feature].should == @feature
    end
  end

  describe "GET 'new" do
    it "should have the ensure_admin before filter" do
      controller.should_receive(:ensure_admin)
      get 'new'
    end
    it "should initialize a new feature and assign it to @feature" do
      feature = Feature.new
      Feature.should_receive(:new).and_return(feature)
      get 'new'
      assigns[:feature].should == feature
    end
  end

  describe "POST 'create'" do
    before do
      login_user(:admin => true)
      @params = { :feature => { :title => "Title", :description => "Desc" } }
      @feature = Feature.new
      @feature.stub(:id).and_return(10)
      @feature.stub(:save).and_return(true)
      Feature.stub(:new).and_return(@feature)
    end
    it "should have the ensure_admin before filter" do
      controller.should_receive(:ensure_admin)
      post 'create', @params
    end
    it "should initialize a new feature with the passed params and the member id and assign it to the @feature" do
      Feature.should_receive(:new).with(@params[:feature].merge(:member_id => @current_member.id).stringify_keys).and_return(@feature)
      post 'create', @params
      assigns[:feature].should == @feature
    end
    it "should save the new feature" do
      @feature.should_receive(:save).and_return(true)
      post 'create', @params
    end
    it "should redirect to the created feature with a notice that the feature was created successfully" do
      post 'create', @params
      response.should redirect_to(@feature)
      flash[:notice].should == 'Feature was successfully created.'
    end
    it "should render the new action if the feature fails to save" do
      @feature.stub(:save).and_return(false)
      post 'create', @params
      response.should render_template(:new)
    end
  end

  describe "PUT 'update'" do
    before do
      login_user(:admin => true)
      @params = { :id => 10, :feature => { :title => "Title", :description => "Desc" } }
      @feature = Feature.new
      @feature.id = 10
      @feature.stub(:update_attributes).and_return(true)
      Feature.stub(:find).and_return(@feature)
    end
    it "should have the ensure_admin before filter" do
      controller.should_receive(:ensure_admin)
      put 'update', @params
    end
    it "should find the feature from params[:id]" do
      Feature.should_receive(:find).with("10").and_return(@feature)
      put 'update', @params
    end
    it "should update the feature with the passed params and assign to @feature" do
      @feature.should_receive(:update_attributes).with("title" => "Title", "description" => "Desc")
      put 'update', @params
      assigns[:feature].should == @feature
    end
    it "should redirect to the feature with a notice that the feature was updated successfully" do
      put 'update', @params
      response.should redirect_to(@feature)
      flash[:notice].should == 'Feature was successfully updated.'
    end
    it "should render the edit action if the feature fails to save" do
      @feature.stub(:update_attributes).and_return(false)
      put 'update', @params
      response.should render_template(:edit)
    end
  end

  describe "DELETE 'destroy'" do
    before do
      login_user(:admin => true)
      @params = { :id => 10 }
      @feature = Feature.new
      @feature.id = 10
      @feature.stub(:destroy)
      Feature.stub(:find).and_return(@feature)
    end
    it "should have the ensure_admin before filter" do
      controller.should_receive(:ensure_admin)
      delete 'destroy', @params
    end
    it "should find the feature from params[:id]" do
      Feature.should_receive(:find).with("10").and_return(@feature)
      delete 'destroy', @params
    end
    it "should destroy the feature" do
      @feature.should_receive(:destroy)
      delete 'destroy', @params
    end
    it "should redirect to the index with a success notice" do
      delete 'destroy', @params
      response.should redirect_to(:features)
      flash[:notice].should == 'Feature was successfully deleted.'
    end
  end
end
