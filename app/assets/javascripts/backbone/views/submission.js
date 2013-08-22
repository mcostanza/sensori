Sensori.Views.Submission = Backbone.View.extend({
	events: {
		"click [data-trigger='save-submission']": "saveSubmission",
    "click [data-trigger='change-submission']": "showForm",
    "keyup #submission_title": "changeSubmissionTitle"
	},

  validate: function() {
    var errors = {};
    if (_.isEmpty(this.model.get("title"))) { errors.title = true; }
    if (_.isEmpty(this.model.get("attachment_url"))) { errors.attachment_url = true; }
    this.renderErrors(errors);
    return _.isEmpty(errors);
  },

  renderErrors: function(errors) {
    var titleControlGroup = this.$("#submission_title").closest(".control-group");  
    if (errors.title) {
      titleControlGroup.addClass("error");
      titleControlGroup.find(".help-inline").fadeIn();
    } else {
      titleControlGroup.removeClass("error");
      titleControlGroup.find(".help-inline").fadeOut();
    }

    var attachmentUrlControlGroup = this.$(".fileinput-button").closest(".control-group");  
    if (errors.attachment_url) {
      attachmentUrlControlGroup.addClass("error");
      attachmentUrlControlGroup.find(".help-inline").fadeIn();
    } else {
      attachmentUrlControlGroup.removeClass("error");
      attachmentUrlControlGroup.find(".help-inline").fadeOut();
    }
  },

  changeSubmissionTitle: function() {
    this.model.set("title", this.$("#submission_title").val());
    this.validate();
  },

	saveSubmission: function() {
    if (this.saveButton.hasClass("disabled")) { return; }

    if (!this.validate()) { return; }

    this.model.save(null, {
      success: _.bind(this.saveSuccess, this),
      error: _.bind(this.saveError, this)
    });
	},

  saveSuccess: function() {
    this.saveButton.removeClass("disabled");
    this.showAlert();
  },

  saveError: function() {
    this.saveButton.removeClass("disabled");
    this.$(".alert").fadeOut().delay().remove();

    var notice = $("<div>")
      .hide()
      .addClass("alert alert-error")
      .html("Sorry, submitting your beat failed...");

    this.$el.prepend(notice);
    notice.fadeIn();
  },

	onAdd: function(event, data) {
    var acceptedFileTypes = /\.(?:mp3|wav)$/i,
        fileName = data.files[0].name,
        attachmentUrlControlGroup = this.$(".fileinput-button").closest(".control-group");

    attachmentUrlControlGroup.find(".submission-link").remove();
    this.saveButton.addClass("disabled");

    if (acceptedFileTypes.test(fileName)) {
      attachmentUrlControlGroup.removeClass("error");
      attachmentUrlControlGroup.find(".help-inline").fadeOut();

      this.$(".progress").fadeIn();
      this.$(".progress-bar").css({ width: "0%" });
      data.submit();
    } else {
      this.saveButton.removeClass("disabled");
      attachmentUrlControlGroup.addClass("error");
      attachmentUrlControlGroup.find(".help-inline").fadeIn();
    }
	},

	onProgress: function(event, data) {
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

  showForm: function() {
    this.model.unset("title");
    this.model.unset("attachment_url");

    this.$(".submission-link").remove();

    this.$(".change-submission").hide();
    this.$(".new-submission").fadeIn();
  },

  showAlert: function() {
    this.$(".alert").fadeOut().delay().remove();

    this.$(".new-submission").hide();
    this.$(".change-submission").fadeIn();

    var notice = $("<div>")
      .hide()
      .addClass("alert alert-success")
      .html("Your submitted beat for " + this.options.sessionTitle + " is ")
      .append(this.submissionLink());

    this.$el.prepend(notice);
    notice.fadeIn();
  },

	render: function() {
    this.$el.html(JST["backbone/templates/sessions/submission"]({
      uploadForm: JST["backbone/templates/shared/s3_uploader_form"]()
    }));

    this.saveButton = this.$("[data-trigger='save-submission']");
    this.$("form").fileupload({
      add:      _.bind(this.onAdd, this),
      progress: _.bind(this.onProgress, this),
      done:     _.bind(this.onDone, this),
      fail:     _.bind(this.onFail, this)
    });

    if (this.model.isNew()) {
      this.showForm();
    } else {
      this.showAlert();
    }

		return this;
	}
});