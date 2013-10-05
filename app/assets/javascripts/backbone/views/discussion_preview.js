Sensori.Views.DiscussionPreview = Backbone.View.extend({
  template: JST["backbone/templates/discussions/discussion_preview"],

  render: function() {
    this.setElement(this.template({ discussion: this.model }));
    return this;
  }
});

