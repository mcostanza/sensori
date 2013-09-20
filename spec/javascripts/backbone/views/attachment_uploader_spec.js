describe("Sensori.Views.AttachmentUploader", function() {
  var view,
      model,
      event,
      data;

  beforeEach(function() {
  	model = new Sensori.Models.Tutorial();
  	
  	view = new Sensori.Views.AttachmentUploader({
  	  model: model
  	}).render();

  	event = "event!";
  	data = {
      files: [{ name: "audio.wav" }]
    };
  	sinon.spy(view, "trigger");
  });

  describe(".initialize()", function() {
    it("should set this.template to backbone/templates/shared/attachment_uploader by default", function() {
      expect(view.template).toEqual("backbone/templates/shared/attachment_uploader");
    });
    it("should set this.template to options.template", function() {
      view = new Sensori.Views.AttachmentUploader({ template: "another/template" });
      expect(view.template).toEqual("another/template");
    });
    it("should set this.acceptedFileTypesRegex from options when given as an array", function() {
      view = new Sensori.Views.AttachmentUploader({ acceptedFileTypes: ["wav", "mp3"] });
      expect(view.acceptedFileTypesRegex).toEqual(/\.(?:wav|mp3)$/i);
    });
    it("should not set this.acceptedFileTypesRegex if not given", function() {
      expect(view.acceptedFileTypesRegex).toBe(undefined);
    });
  });

  describe(".isValidAttachment(file)", function() {
    it("should return true if this.acceptedFileTypesRegex is not set", function() {
      expect(view.isValidAttachment(data.files[0])).toBe(true);
    });
    it("should return true if this.acceptedFileTypesRegex is set and the file matches an accepted type", function() {
      view.acceptedFileTypesRegex = /\.(?:wav)$/
      expect(view.isValidAttachment(data.files[0])).toBe(true);
    });
    it("should return false if this.acceptedFileTypesRegex is set and the file does not match an accepted type", function() {
      view.acceptedFileTypesRegex = /\.(?:gif|jpg)$/
      expect(view.isValidAttachment(data.files[0])).toBe(false);
    });
  });

  describe(".onAdd(event, data)", function() {
  	beforeEach(function() {
  		data.submit = sinon.spy()
      sinon.stub(view, "isValidAttachment");
      sinon.stub(jQuery.fn, "fadeOut");
      sinon.stub(jQuery.fn, "fadeIn");
      view.$el.append("<div class='control-group'><span class='help-inline' style='display:none;'>must be a valid file</span></div>");
  	});
    afterEach(function() {
      jQuery.fn.fadeOut.restore();
      jQuery.fn.fadeIn.restore();
    });
    it("should verify the attached file is valid", function() {
      view.onAdd(event, data);
      expect(view.isValidAttachment.calledWith(data.files[0])).toBe(true);
    });
    describe("with a valid attachment", function() {
      beforeEach(function() {
        view.isValidAttachment.returns(true);
      });
      it("should trigger an 'upload:add' event", function() {
    		view.onAdd(event, data);
    		expect(view.trigger.callCount).toEqual(1);
    		expect(view.trigger.calledWith("upload:add")).toBe(true);
    	});
    	 it("should show the progress bar with 0% progress", function() {
    		view.onAdd(event, data);
        expect(jQuery.fn.fadeIn.getCall(0).thisValue.selector).toEqual(".progress");
    		expect(view.$(".progress-bar").width()).toEqual(0);
    	});
    	it("should submit the attachment data", function() {
    		view.onAdd(event, data);
    		expect(data.submit.callCount).toEqual(1);
    	});
      it("should disable the download button", function() {
        view.onAdd(event, data);
        expect(view.$(".download-button").hasClass("disabled")).toBe(true);
      });
      it("should remove error status from the .control-group element", function() {
        view.$(".control-group").addClass("error");
        view.onAdd(event, data);
        expect(view.$(".control-group.error").length).toEqual(0);
      });
      it("should hide the .help-inline message", function() {
        view.onAdd(event, data);
        expect(jQuery.fn.fadeOut.getCall(0).thisValue.selector).toEqual(".control-group .help-inline");
      });
    });
    describe("with an invalid attachment", function() {
      beforeEach(function() {
        view.isValidAttachment.returns(false);
      });
      it("should add error status to the .control-group element", function() {
        view.onAdd(event, data);
        expect(view.$(".control-group.error").length).toEqual(1);
        expect(jQuery.fn.fadeIn.getCall(0).thisValue.selector).toEqual(".control-group .help-inline");
      });
    });
  });

  describe(".onProgress(event, data", function() {
  	beforeEach(function() {
  		data.loaded = 10;
  		data.total = 100;
  	});
  	it("should trigger an 'upload:progress' event", function() {
  		view.onProgress(event, data);
  		expect(view.trigger.callCount).toEqual(1);
  		expect(view.trigger.calledWith("upload:progress")).toBe(true);
  	});
  	it("should update the progress bar", function() {
  		view.onProgress(event, data);
  		expect(view.$(".progress-bar").width() > 0).toBe(true);
  	});
  });

  describe(".onDone(event, data)", function() {
  	beforeEach(function() {
  		data.files = [{ name: "samples.zip" }]
  	});
  	it("should trigger an 'upload:done' event", function() {
  		view.onDone(event, data);
  		expect(view.trigger.callCount).toEqual(1);
  		expect(view.trigger.calledWith("upload:done")).toBe(true);
  	});
  	it("should set the model's attachment_url and attachment_name", function() {
  		var expected = "https://sensori-dev.s3.amazonaws.com/uploads/id/samples.zip";
  		view.onDone(event, data);
  		expect(model.get("attachment_url")).toEqual(expected);
      expect(model.get("attachment_name")).toEqual("samples.zip");
  	})
    it("should enable the download button and set the href to the attachment url", function() {
      var expected = "https://sensori-dev.s3.amazonaws.com/uploads/id/samples.zip";
      view.$(".download-button").addClass("disabled");
      view.onDone(event, data);
      expect(view.$(".download-button").hasClass("disabled")).toBe(false);
      expect(view.$(".download-button").attr("href")).toEqual(expected);
    });
  });

  describe(".onFail(event, data)", function() {
  });

  describe(".render()", function() {
    beforeEach(function() {
      sinon.stub($.fn, "fileupload");
      view = new Sensori.Views.AttachmentUploader({
        model: model
      });
      sinon.stub(view, "onAdd");
      sinon.stub(view, "onDone");
      sinon.stub(view, "onFail");
      sinon.stub(view, "onProgress");
    });
    afterEach(function() {
      $.fn.fileupload.restore();
    });
    it("should set the element content to an s3 uploader form and progress bar", function() {
      view.render();
      expect(view.$("form").attr("action")).toEqual("https://sensori-dev.s3.amazonaws.com/");
      expect(view.$(".progress").length).toEqual(1);
    });
    it("should setup a file uploader on the s3 form", function() {
      view.render();
      
      expect($.fn.fileupload.callCount).toEqual(1);
      
      var fileupload = $.fn.fileupload.getCall(0);
      expect(_.keys(fileupload.args[0]).sort()).toEqual(["add", "done", "fail", "progress"]);

      fileupload.yieldTo("add");
      expect(view.onAdd.callCount).toEqual(1);

      fileupload.yieldTo("done");
      expect(view.onDone.callCount).toEqual(1);

      fileupload.yieldTo("fail");
      expect(view.onFail.callCount).toEqual(1);

      fileupload.yieldTo("progress");
      expect(view.onProgress.callCount).toEqual(1);
    });
    it("should return itself", function() {
      expect(view.render()).toEqual(view);
    });
  });
});