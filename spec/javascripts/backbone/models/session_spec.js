describe("Sensori.Models.Session", function() {
  var session;

  it("should extend Backbone.Model", function() {
    session = new Sensori.Models.Session();
    expect(session instanceof Backbone.Model).toBe(true);
  });

  describe(".url()", function() {
    it("should return /sessions for new records", function() {
      session = new Sensori.Models.Session();
      expect(session.url()).toEqual("/sessions");
    });
    it("should return /sessions/:id for existing records", function() {
      session = new Sensori.Models.Session({ id: 123 });
      expect(session.url()).toEqual("/sessions/123");
    });
  });
});
