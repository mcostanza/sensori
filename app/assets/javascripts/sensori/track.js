var Sensori = Sensori || {};

Sensori.Track = function(element, position, player) {
  var track = this;
  this.element = element;
  this.position = position;
  SC.stream(element.data('track'), $.proxy(function(sound) {
    this.sound = sound;
  }, this));
  this.artist = element.data('artist');
  this.title = element.data('title');
  this.player = player;
  this.status = 'stopped';
  
  this.element.on('click', '.overlay', $.proxy(this.click, this));
}

$.extend(Sensori.Track.prototype, {
  play : function() {
    this.sound.play({ 
      onfinish: $.proxy(this.player.playNext, this.player)
    });
    this.updateStatus('playing');
  },
  pause : function() {
    this.sound.pause();
    this.updateStatus('paused');
  },
  stop : function() {
    this.sound.stop();
    this.updateStatus('stopped');
  },
  click : function(event) {
    if(this.status == 'playing') { this.player.pause(); }
    else { this.player.play(this); }
  },
  updateStatus : function(status) {
    this.status = status;
    this.element.removeClass("playing paused stopped").addClass(status);
  }
});
