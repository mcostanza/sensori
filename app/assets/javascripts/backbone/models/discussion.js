Sensori.Models.Discussion = Backbone.Model.extend({
  urlRoot: "/discussions",
  idAttribute: "slug",

  initialize: function(options) {
    if(this.has('member')) {
      // Setup the member association if it is included in the attributes
      this.member = new Sensori.Models.Member(this.get('member'));
      // Unset the member attribute so it is not synced on save
      this.unset("member", { silent: true });
    }
  }
});
