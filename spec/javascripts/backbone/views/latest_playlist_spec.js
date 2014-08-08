describe("Sensori.Views.LatestPlaylist", function() {
  var view;

  beforeEach(function() {
    view = new Sensori.Views.LatestPlaylist();
  });

  describe("template", function() {
    it("should be set to the latest playlist template", function() {
      expect(view.template).toEqual(JST["backbone/templates/shared/latest_playlist"]);
    });
  });

  describe(".render()", function() {
    beforeEach(function() {
      sinon.stub(SC, 'get');
      mockPlaylist = { get: sinon.stub() };
      sinon.stub(Sensori.Models, "Playlist").returns(mockPlaylist);
      sinon.stub(view.$el, 'html');
      sinon.stub(view, 'template').returns('template');
    });
    afterEach(function() {
      SC.get.restore();
      Sensori.Models.Playlist.restore();
    });
    it("should load the latest playlist from soundcloud", function() {
      view.render();
      expect(SC.get.callCount).toBe(1);
      expect(SC.get.calledWith("/users/sensori-collective/playlists", { limit: 1 })).toBe(true);
    });
    it("should set the model to a playlist model of the response from soundcloud", function() {
      var response = [{ id: 'response' }]
      view.render();
      SC.get.yield(response);
      expect(Sensori.Models.Playlist.callCount).toBe(1);
      expect(Sensori.Models.Playlist.calledWith({ id: 'response' })).toBe(true);
      expect(view.model).toEqual(mockPlaylist);
    });
    it("should render the template with the playlist model into the view element", function() {
      var response = [{ id: 'response' }]
      view.render();
      SC.get.yield(response);
      expect(view.template.callCount).toBe(1);
      expect(view.template.calledWith({ playlist: view.model })).toBe(true);
      expect(view.$el.html.callCount).toBe(1);
      expect(view.$el.html.calledWith('template')).toBe(true);
    });
    it("should not render anything if the soundcloud response fails", function() {
      var response = { errors: [{ error_message: '404 NOT FOUND' }] };
      view.render();
      SC.get.yield(response);
      expect(Sensori.Models.Playlist.callCount).toBe(0);
      expect(view.model).toBeUndefined();
      expect(view.template.callCount).toBe(0);
      expect(view.$el.html.callCount).toBe(0);
    });
    it("should return itself", function() {
      expect(view.render()).toBe(view);
    });
  });
});
