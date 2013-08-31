Sensori.Models.Submission = Backbone.Model.extend({

	url: function() {
   var root = "/sessions/" + this.get("session_id") + "/submissions";
   return this.isNew() ? root : root + "/" + this.id;
  }

});