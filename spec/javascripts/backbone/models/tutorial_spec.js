describe("Sensori.Models.Tutorial", function() {
  it("should extend Backbone.Model", function() {
    var tutorial = new Sensori.Models.Tutorial();
    expect(tutorial instanceof Backbone.Model).toBe(true);
  });
});