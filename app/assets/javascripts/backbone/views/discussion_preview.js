Sensori.Views.DiscussionPreview = Backbone.View.extend({
  template: JST["backbone/templates/discussions/discussion_preview"],

  events: {
    "hover": 'onHover',
    "click": 'onClick'
  },

  initialize: function() {
    _.bindAll(this, "onHover", "onClick");
  },

  render: function() {
    this.setElement(this.template({ discussion: this.model }));
    return this;
  },

  onHover: function(e) {
    if(e.type == 'mouseenter') { this.$el.addClass("hover"); }
    if(e.type == 'mouseleave') { this.$el.removeClass("hover"); }
  },
  
  onClick: function(e) {
    var target = $(e.target);
    if(target.is("a")) { return; }
    e.preventDefault();
    Sensori.redirect(this.model.url());
  }
});

