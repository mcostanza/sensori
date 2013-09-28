describe("Sensori.Models.Discussion", function() {
  var discussion;

  it("should extend Backbone.Model", function() {
    discussion = new Sensori.Models.Discussion();
    expect(discussion instanceof Backbone.Model).toBe(true);
  });

  describe(".url()", function() {
    it("should return /discussions for new records", function() {
      discussion = new Sensori.Models.Discussion();
      expect(discussion.url()).toEqual("/discussions");
    });
    it("should return /discussions/slug for existing records", function() {
      discussion = new Sensori.Models.Discussion({ slug: 'hey-brother' });
      expect(discussion.url()).toEqual("/discussions/hey-brother");
    });
  });
});
