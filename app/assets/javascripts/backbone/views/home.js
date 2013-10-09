Sensori.Views.Home = Backbone.View.extend({

  initialize: function() {
    this.discussions = this.options.discussions;
    this.bootstrap();
  },

  bootstrap: function() {
    if(this.discussions) {
      // Setup views for the discussion previews (rendered server side on page load)
      this.discussions.each(function(discussion) {
        new Sensori.Views.DiscussionPreview({ model: discussion, el: this.$("[data-discussion-id='" + discussion.id + "']") });
      }, this);
    }
  }
});

