Sensori.Views.DiscussionResponse = Backbone.View.extend({

  initialize: function() {
    this.collection.on("add", this.addResponse, this);
    this.postButton = this.$("[data-trigger='post']");
    this.responseInput = this.$("#response_body");
  },

  events: {
    "click [data-trigger='post']": "processResponse"
  },

  processResponse: function(event) {
    var view = this;
    this.postButton.prop('disabled', true);

    if(this.notificationsEnabled() && !Sensori.Member.has('email')) {
      this.promptForEmail();
    } else {
      this.saveResponse()
    }
  },

  saveResponse: function() {
    var view = this;
    var response = new Sensori.Models.Response({
      body: this.responseInput.val(),
      discussion_id: this.model.get("id"),
      notifications: this.notificationsEnabled()
    });
    response.save(null, {
      success: function() {
        view.collection.add(response);
        view.responseInput.val("");
        view.postButton.prop('disabled', false);
      },
      error: function(e) { console.log(e); }
    });
  },

  addResponse: function(response) {
    this.$('.responses').append(JST["backbone/templates/discussions/response"]({
      member: Sensori.Member,
      response: response
    }));
  },
  
  notificationsEnabled: function() {
    return this.$("#discussion_notifications").prop('checked');
  },

  promptForEmail: function() {
    this.emailPrompt = this.emailPrompt || new Sensori.Views.EmailPrompt({ el: this.el, model: Sensori.Member, message: "Email address to send response notifications:" });
    this.emailPrompt.on("email:saved", this.processResponse, this);
    this.emailPrompt.on("hide", function() { 
      this.postButton.prop('disabled', false);
    }, this);
    this.emailPrompt.render();
  }
});
