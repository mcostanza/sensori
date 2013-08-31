Sensori.Views.AttachmentUploader = Backbone.View.extend({

	events: {
		"click .disabled": "preventDefault"
	},

	preventDefault: function(event) {
		event.preventDefault();
	},

	onAdd: function(event, data) {
		this.trigger("upload:add");
		this.$(".download-button").addClass("disabled");
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
  	this.trigger("upload:done");
  	this.$(".progress").fadeOut();

    var file   = data.files[0],
        domain = this.$("form").attr('action'),
        path   = this.$('input[name=key]').val().replace('${filename}', file.name);
        
    this.model.set("attachment_url", domain + path);
    this.$(".download-button")
    	.removeClass("disabled")
    	.attr("href", this.model.get("attachment_url"));
  },

  onFail: function(e, data) {
  	this.trigger("upload:fail");
  },
	
	render: function() {
		this.$el.html(JST["backbone/templates/shared/attachment_uploader"]({
			attachmentUrl: this.model.get("attachment_url"),
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