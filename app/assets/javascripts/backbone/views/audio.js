Sensori.Views.Audio = Backbone.View.extend({
  events: {
    "click": "onClick"
  },

  initialize: function() {
    _.bindAll(this, "onClick", "updateStatusClass"); 
    this.model = (this.model || new Sensori.Models.Audio({ url: this.$el.attr("href"), name: this.$el.text() }));
    this.listenTo(this.model, "status:changed", this.updateStatusClass);
    this.$el.data("audio-id", this.model.cid);
  },

  onClick: function(e) {
    e.preventDefault();
    if(this.model.status == "playing") {
      this.model.pause();
    } else { 
      this.model.play();
    }
  },

  updateStatusClass: function() {
    this.$el.removeClass("playing paused stopped").addClass(this.model.status);
  }
});
