describe("Sensori.Collections.Discussions", function() {
  var discussions;

  it("should extend Backbone.Collection", function() {
    discussions = new Sensori.Collections.Discussions();
    expect(discussions instanceof Backbone.Collection).toBe(true);
  });

  describe(".url", function() {
    it("should set url to /discussions", function() {
      discussions = new Sensori.Collections.Discussions();
      expect(discussions.url).toEqual("/discussions");
    });
  });

  describe(".parse(response)", function() {
    it("should return response.models", function() {
      var models = [1,2,3];
      var response = { models: models };
      discussions = new Sensori.Collections.Discussions();
      expect(discussions.parse(response)).toEqual(models);
    });
  });
});

