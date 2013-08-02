describe("Sensori.Models.Tutorial", function() {
  var tutorial;
  it("should extend Backbone.Model", function() {
    tutorial = new Sensori.Models.Tutorial();
    expect(tutorial instanceof Backbone.Model).toBe(true);
  });

  describe(".url()", function() {
    it("should return /tutorials for new records", function() {
      tutorial = new Sensori.Models.Tutorial();
      expect(tutorial.url()).toEqual("/tutorials");
    });
    it("should return /tutorials/id for existing records", function() {
      tutorial = new Sensori.Models.Tutorial({ id: 123 });
      expect(tutorial.url()).toEqual("/tutorials/123");
    });
  });

});