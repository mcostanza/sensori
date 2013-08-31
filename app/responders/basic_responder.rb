class BasicResponder < ActionController::Responder
  
  protected

  # Exact same behavior as the default responded except that it returns a 200 and renders the object on PUT requests
  def api_behavior(error)
    if resourceful? && put?
      display resource, :status => :ok
    else
      super
    end
  end
  
end
