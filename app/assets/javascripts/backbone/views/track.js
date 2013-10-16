Sensori.Views.Track = Backbone.View.extend({
  events: {
    "click .overlay": "onClick"
  },

  initialize: function() {
    _.bindAll(this, "onClick", "updateStatusClass"); 
    this.listenTo(this.model, "status:changed", this.updateStatusClass);
  },

  onClick: function(e) {
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
