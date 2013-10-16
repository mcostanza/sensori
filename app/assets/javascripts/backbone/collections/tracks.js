Sensori.Collections.Tracks = Backbone.Collection.extend({
  model: Sensori.Models.Track,
  url: "/tracks",

  parse: function(response) {
    return response.models;
  }
});
