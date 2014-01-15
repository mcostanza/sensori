Sensori.Models.Audio = Backbone.Model.extend({

  initialize: function() {
    this.status = 'stopped';
    this.prepareSoundObject();
  },

  title: function() {
    return this.get("name");
  },

  play: function() {
    this.trigger('status:changing', this, 'playing');
    this.soundObject.play({
      onfinish: $.proxy(function() { 
        this.trigger('finished', this);
        this.updateStatus('stopped');
      }, this)
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
    this.soundObject = soundManager.createSound({
      url: this.get("url")
    });
  }
});
