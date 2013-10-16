Sensori.Models.Track = Backbone.Model.extend({
  urlRoot: "/tracks",

  initialize: function() {
    if(this.has('member')) {
      // Setup the member association if it is included in the attributes
      this.member = new Sensori.Models.Member(this.get('member'));
      // Unset the member attribute so it is not synced on save
      this.unset("member", { silent: true });
    }
    this.status = 'stopped';
    this.prepareSoundObject();
  },

  play: function() {
    this.trigger('status:changing', this, 'playing');
    this.soundObject.play({
      onfinish: $.proxy(function() { this.trigger('finished', this); }, this)
    });
    this.updateStatus('playing');
  },

  pause: function() {
    this.trigger('status:changing', this, 'paused');
    this.soundObject.pause();
    this.updateStatus('paused');
  },

  stop: function() {
    this.trigger('status:changing', this, 'stopped');
    this.soundObject.stop();
    this.updateStatus('stopped');
  },

  updateStatus: function(status) {
    this.status = status;
    this.trigger('status:changed', this);
  },

  prepareSoundObject: function() {
    if(this.has('stream_url')) {
      SC.stream(this.get('stream_url'), $.proxy(function(soundObject) {
        this.soundObject = soundObject;
      }, this));
    }
  },

});

