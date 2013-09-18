describe("Sensori.Models.Response", function() {
  var response;

  it("should extend Backbone.Model", function() {
    response = new Sensori.Models.Response();
    expect(response instanceof Backbone.Model).toBe(true);
  });

  describe(".url()", function() {
    it("should return /responses for new records", function() {
      response = new Sensori.Models.Response();
      expect(response.url()).toEqual("/responses");
    });
    it("should return /responses/:id for existing records", function() {
      response = new Sensori.Models.Response({ id: 123 });
      expect(response.url()).toEqual("/responses/123");
    });
  });
});
