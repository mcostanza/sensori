describe("Sensori.Collections.Tracks", function() {
  var tracks;

  it("should extend Backbone.Collection", function() {
    tracks = new Sensori.Collections.Tracks();
    expect(tracks instanceof Backbone.Collection).toBe(true);
  });

  describe(".model", function() {
    it("should set model to Sensori.Models.Track", function() {
      expect(tracks.model).toEqual(Sensori.Models.Track);
    });
  });

  describe(".url", function() {
    it("should set url to /tracks", function() {
      tracks = new Sensori.Collections.Tracks();
      expect(tracks.url).toEqual("/tracks");
    });
  });

  describe(".parse(response)", function() {
    it("should return response.models", function() {
      var models = [1,2,3];
      var response = { models: models };
      tracks = new Sensori.Collections.Tracks();
      expect(tracks.parse(response)).toEqual(models);
    });
  });
});

