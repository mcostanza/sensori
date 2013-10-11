Sensori.Views.WelcomeMessage = Backbone.View.extend({
  initialize: function() {
    this.popoverTarget = this.$("#nav-beats");
  },

  events: {
    "click" : "hide"
  },

  show: function() {
    this.popoverTarget.popover({
      title: 'Welcome!',
      placement: 'bottom',
      content: 'Your Soundcloud tracks will now show up in the "Beats" section. <a href="/about">Learn more</a>',
      html: true
    });
    this.popoverTarget.popover('show');
  },

  hide: function() {
    this.popoverTarget.popover('destroy');
    this.stopListening();
  }
});
