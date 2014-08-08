Sensori.Views.LatestPlaylist = Backbone.View.extend({
  template: JST["backbone/templates/shared/latest_playlist"],

  render: function() {
    SC.get("/users/sensori-collective/playlists", { limit: 1 }, $.proxy(function(response) {
      if(_.isEmpty(response.errors)) {
        this.model = new Sensori.Models.Playlist(_.first(response));
        this.$el.html(this.template({ playlist: this.model }));
      }
    }, this));
    return this;
  }
});
