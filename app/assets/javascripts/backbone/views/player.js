Sensori.Views.Player = Backbone.View.extend({
  initialize: function() {
    _.bindAll(this, 'onTrackStatusChanging', 'onTrackStatusChanged', 'onTrackFinished');
    this.pageTitle = document.title;
    this.collection = (this.collection || new Sensori.Collections.Tracks());
    this.listenTo(this.collection, 'status:changing', this.onTrackStatusChanging);
    this.listenTo(this.collection, 'status:changed', this.onTrackStatusChanged);
    this.listenTo(this.collection, 'finished', this.onTrackFinished);
    this.bootstrap();
  },

  bootstrap: function() {
    this.collection.each(function(track) {
      new Sensori.Views.Track({ model: track, el: this.$("[data-track-id='" + track.id + "']") });
    }, this);
  },

  onTrackStatusChanging: function(track, newStatus) {
    if(this.currentTrack && newStatus == 'playing') {
      this.currentTrack.stop();
    }
  },

  onTrackStatusChanged: function(track) {
    if(track.status == 'playing') {
      this.currentTrack = track;
      document.title = "► " + track.member.get('name') + " - " + track.get('title');
    } else {
      document.title = this.pageTitle;
    }
  },

  onTrackFinished: function(track) {
    track.stop();
    var nextTrack = this.collection.at(this.collection.indexOf(track) + 1);
    if(nextTrack) { nextTrack.play(); }
  }
});
