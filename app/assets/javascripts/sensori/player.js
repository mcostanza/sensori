var Sensori = Sensori || {};

Sensori.Player = function() {
  this.tracks = [];
  this.current_track = null;
  this.pageTitle = document.title;
  this.on('statusChanged', $.proxy(this.updatePageTitle, this));
  this.load();
}

$.extend(Sensori.Player.prototype, {
  load : function() {
    var player = this;
    $('[data-track]').each(function(index, element) {
      player.tracks.push(new Sensori.Track($(element), index, player));
    });
    this.current_track = this.tracks[0];
  },
  play : function(track) {
    if(track == this.current_track) {
      track.play();
    } else {
      this.current_track.stop();
      track.play();
      this.current_track = track;
    }
    this.statusChanged();
  },
  playNext : function() {
    var track = this.tracks[this.current_track.position + 1];
    if(track != undefined) { this.play(track); }
    else { this.stop(); }
  },
  pause : function() {
    this.current_track.pause();
    this.statusChanged();
  },
  stop : function() {
    this.current_track.stop();
    this.statusChanged();
  },
  status : function() {
    this.current_track.status();
  },
  statusChanged : function() {
    $(this).trigger('statusChanged', this.current_track.status);
  },
  updatePageTitle : function(event, status) {
    if(status == 'playing') {
      document.title = "► " + this.current_track.artist + " - " + this.current_track.title;
    } else {
      document.title = this.pageTitle;
    }
  },
  on : function(event, callback) { $(this).on(event, callback); }
});
