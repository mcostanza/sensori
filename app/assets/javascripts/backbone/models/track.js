Sensori.Models.Track = Sensori.Models.Audio.extend({
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

  title: function() {
    return this.member.get("name") + " - " + this.get("title");
  },

  prepareSoundObject: function() {
    if(this.has('stream_url')) {
      SC.stream(this.get('stream_url'), $.proxy(function(soundObject) {
        this.soundObject = soundObject;
      }, this));
    }
  }
});
