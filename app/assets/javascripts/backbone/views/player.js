Sensori.Views.Player = Backbone.View.extend({
  events: {
    "click [data-type=audio]": "setupAndPlayAudio"
  },

  initialize: function() {
    _.bindAll(this, 'onTrackStatusChanging', 'onTrackStatusChanged', 'onTrackFinished', 'setupAndPlayAudio');
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
    if(this.currentTrack && (this.currentTrack != track) && newStatus == 'playing') {
      this.currentTrack.stop();
    }
  },

  onTrackStatusChanged: function(track) {
    if(track.status == 'playing') {
      this.currentTrack = track;
      document.title = "► " + track.title();
    } else {
      document.title = this.pageTitle;
    }
  },

  onTrackFinished: function(track) {
    var nextTrack = this.collection.at(this.collection.indexOf(track) + 1);
    if(nextTrack) { nextTrack.play(); }
  },

  // This function is used to setup and play non-continuous audio embeds
  setupAndPlayAudio: function(e) {
    // Return if the view for this element has already been setup
    if($(e.target).data('audio-id')) { return; }

    e.preventDefault();
    var audioView = new Sensori.Views.Audio({ el: e.target });
    // Setup audio status change events (finished is not needed -- audio embeds are not continuous)
    this.listenTo(audioView.model, 'status:changing', this.onTrackStatusChanging);
    this.listenTo(audioView.model, 'status:changed', this.onTrackStatusChanged);
    audioView.model.play();
  }
});
