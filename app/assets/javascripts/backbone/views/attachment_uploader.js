Sensori.Views.AttachmentUploader = Backbone.View.extend({

	initialize: function() {
		this.template = this.options.template || "backbone/templates/shared/attachment_uploader";
		
		var acceptedFileTypes = this.options.acceptedFileTypes;
		if (_.isArray(acceptedFileTypes) && acceptedFileTypes.length > 0) {
			this.acceptedFileTypesRegex = new RegExp("\\.(?:" + acceptedFileTypes.join("|") + ")$", "i");
		}
	},

	events: {
		"click .disabled": "preventDefault",
    "click [data-trigger='remove-attachment']": "triggerRemove"
	},

	preventDefault: function(event) {
		event.preventDefault();
	},

	isValidAttachment: function(file) {
		if (!this.acceptedFileTypesRegex) { return true; }

		return this.acceptedFileTypesRegex.test(file.name);
	},

	onAdd: function(event, data) {
    var file = data.files[0];

    if (this.isValidAttachment(file)) {
			this.trigger("upload:add");
			this.$(".download-button").addClass("disabled");

      this.$(".control-group").removeClass("error");
      this.$(".control-group").find(".help-inline").fadeOut();

      this.$(".progress").fadeIn();
      this.$(".progress-bar").css({ width: "0%" });

      this.$(".attachment-name").text(file.name);

      data.submit();
    } else {
      this.$(".control-group").addClass("error");
      this.$(".control-group").find(".help-inline").fadeIn();
    }
	},

	onProgress: function(event, data) {
		this.trigger("upload:progress");
		// Calculate the completion percentage of the upload
    var progress = parseInt(data.loaded / data.total * 100, 10);
    this.$(".progress-bar").css({ width: progress + "%" });
	},

  onDone: function(e, data) {
  	this.$(".progress").fadeOut({
  		complete: _.bind(function() {
  			this.$(".progress-bar").css({ width: "0%" });
  		}, this)
  	});

    var file   = data.files[0],
        domain = this.$("form").attr('action'),
        path   = this.$('input[name=key]').val().replace('${filename}', file.name);
        
    this.model.set({
    	"attachment_url": domain + path,
    	"attachment_name": file.name
    });

    this.$(".download-button")
    	.removeClass("disabled")
    	.attr("href", this.model.get("attachment_url"));

    this.$(".remove-button").removeClass("disabled");

    this.trigger("upload:done");
  },

  onFail: function(e, data) {
  	this.trigger("upload:fail");
  },

  // parent views can hook into this behavior
  triggerRemove: function(event) {
    var button = $(event.target).closest('[data-trigger]');
    if (button.hasClass('disabled')) { return; }

    if (window.confirm('Are you sure?')) {
      this.trigger("remove-attachment", this.model);
    }
  },
	
	render: function() {
		this.$el.html(JST[this.template]({
			attachmentUrl: this.model.get("attachment_url"),
			attachmentName: this.model.get("attachment_name"),
      removeButton: this.options.removeButton,
			uploadForm: JST["backbone/templates/shared/s3_uploader_form"]()
		}));

		this.$("form").fileupload({
      add:      _.bind(this.onAdd, this),
      progress: _.bind(this.onProgress, this),
      done:     _.bind(this.onDone, this),
      fail:     _.bind(this.onFail, this)
    });

		return this;
	}
	
});