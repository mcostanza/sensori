Sensori.Views.Submission = Backbone.View.extend({
	events: {
		"click [data-trigger='save-submission']": "saveSubmission"
	},

	saveSubmission: function() {
    if (this.saveButton.hasClass("disabled")) { return; }

		this.model.set("title", this.$("#submission_title").val());

    this.model.save(null, {
      success: _.bind(this.saveSuccess, this),
      error: _.bind(this.saveError, this)
    });
	},

  saveSuccess: function() {
    this.saveButton.removeClass("disabled");
    this.renderSubmissionNotice();
  },

  saveError: function() {
    this.saveButton.removeClass("disabled");
    this.$(".alert")
      .fadeOut()
      .delay()
      .remove();

    var notice = $("<div>")
      .hide()
      .addClass("alert alert-error")
      .html("Sorry, submitting your beat failed...");

    this.$el.prepend(notice);
    notice.fadeIn();
  },

	onAdd: function(event, data) {
    var acceptedFileTypes = /\.(?:mp3|wav)$/i,
        fileName = data.files[0].name;

    this.$(".text-error").remove();
		this.saveButton.addClass("disabled");

    if (acceptedFileTypes.test(fileName)) {
      this.$(".progress").fadeIn();
      this.$(".progress-bar").css({ width: "0%" });
      data.submit();
    } else {
      this.$(".fileinput-button").after("<span class='text-error'>Please submit an mp3 or wav file</span>");
      this.saveButton.addClass("disabled");
    }
	},

	onProgress: function(event, data) {
		this.trigger("upload:progress");
		// Calculate the completion percentage of the upload
    var progress = parseInt(data.loaded / data.total * 100, 10);
    this.$(".progress-bar").css({ width: progress + "%" });
	},

  onDone: function(e, data) {
  	this.$(".progress").fadeOut();
  	this.saveButton.removeClass("disabled");

    var file   = data.files[0],
        domain = this.$("form").attr('action'),
        path   = this.$('input[name=key]').val().replace('${filename}', file.name);
        
    this.model.set("attachment_url", domain + path);
    
    var submissionLink = this.submissionLink().addClass("submission-link").text(file.name);
    this.$(".fileinput-button").after(submissionLink);
  },

  onFail: function(e, data) {
  },

  submissionLink: function () {
    var submissionLink = $("<a>")
      .attr("href", this.model.get("attachment_url"))
      .attr("target", "_blank")
      .text(_.isEmpty(this.model.get("title")) ? "Untitled" : this.model.get("title"));

    return submissionLink;
  },

  renderSubmissionNotice: function() {
  	this.$(".alert")
  		.fadeOut()
  		.delay()
  		.remove();

  	var notice = $("<div>")
  		.hide()
  		.addClass("alert alert-success")
  		.html("Your submitted beat for " + this.options.sessionTitle + " is ")
  		.append(this.submissionLink());

  	this.$el.prepend(notice);
  	notice.fadeIn();
  },
	
	render: function() {
    this.saveButton = this.$("[data-trigger='save-submission']");

		this.$("form").fileupload({
      add:      _.bind(this.onAdd, this),
      progress: _.bind(this.onProgress, this),
      done:     _.bind(this.onDone, this),
      fail:     _.bind(this.onFail, this)
    });

		if (this.model.get("attachment_url")) {
			this.renderSubmissionNotice();
		} else {
    	this.saveButton.addClass("disabled");
    }

		return this;
	}
});