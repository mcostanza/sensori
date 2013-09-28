Sensori.Models.Member = Backbone.Model.extend({
  urlRoot: "/members",
  
  image: function(size) {
    switch(size) {
      case "small":
        return this.get("image_url").replace("t500x500", "t50x50");
      case "medium":
        return this.get("image_url").replace("t500x500", "large");
      default:
        return this.get("image_url");
    }
  },

  profileURL: function() {
    return "https://soundcloud.com/" + this.get("slug");
  }
});
