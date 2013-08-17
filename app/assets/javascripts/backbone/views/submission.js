Sensori.Views.Submission = Backbone.View.extend({
	events: {
		"click .disabled": "preventDefault",
		"click [data-trigger='save-submission']": "saveSubmission"
	},

	saveSubmission: function() {
		this.model.set({
			title: ""
		})
	},

	preventDefault: function(event) {
		event.preventDefault();
	},

	onAdd: function(event, data) {
		this.$("[data-trigger='save-submission']").addClass("disabled");

		var audio = this.$("audio");
		audio.fadeOut("fast", function() { audio.remove() });

		this.$(".progress").fadeIn();
		this.$(".progress-bar").css({ width: "0%" });
		data.submit();
	},

	onProgress: function(event, data) {
		this.trigger("upload:progress");
		// Calculate the completion percentage of the upload
    var progress = parseInt(data.loaded / data.total * 100, 10);
    this.$(".progress-bar").css({ width: progress + "%" });
	},

  onDone: function(e, data) {
  	this.$(".progress").fadeOut();
  	this.$("[data-trigger='save-submission']").removeClass("disabled");

    var file   = data.files[0],
        domain = this.$("form").attr('action'),
        path   = this.$('input[name=key]').val().replace('${filename}', file.name);
        
    this.model.set("attachment_url", domain + path);
    
    var audio = $("<audio controls>")
    	.attr("src", this.model.get("attachment_url"))
    	.hide();

    this.$el.append(audio);

    audio.fadeIn();
  },

  onFail: function(e, data) {
  },
	
	render: function() {
		this.$("form").fileupload({
      add:      _.bind(this.onAdd, this),
      progress: _.bind(this.onProgress, this),
      done:     _.bind(this.onDone, this),
      fail:     _.bind(this.onFail, this)
    });

    if (!this.model.get("attachment_url")) {
    	this.$("[data-trigger='save-submission']").addClass("disabled");
    }

		return this;
	}
});