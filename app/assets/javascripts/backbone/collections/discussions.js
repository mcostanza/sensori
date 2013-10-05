Sensori.Collections.Discussions = Backbone.Collection.extend({
  model: Sensori.Models.Discussion,
  url: "/discussions",

  parse: function(response) {
    return response.models;
  }
});

