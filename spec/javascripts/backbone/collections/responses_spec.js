describe("Sensori.Collections.Responses", function() {
  var responses;

  it("should extend Backbone.Collection", function() {
    responses = new Sensori.Collections.Responses();
    expect(responses instanceof Backbone.Collection).toBe(true);
  });

  describe(".url", function() {
    it("should set url to /responses", function() {
      responses = new Sensori.Collections.Responses();
      expect(responses.url).toEqual("/responses");
    });
  });
});
