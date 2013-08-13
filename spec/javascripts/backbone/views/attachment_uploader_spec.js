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
  	data = {};
  	sinon.spy(view, "trigger");
  });

  describe(".onAdd(event, data)", function() {
  	beforeEach(function() {
  		data.submit = sinon.spy()
  	});
  	it("should trigger an 'upload:add' event", function() {
  		view.onAdd(event, data);
  		expect(view.trigger.callCount).toEqual(1);
  		expect(view.trigger.calledWith("upload:add")).toBe(true);
  	});
  	 it("should show the progress bar with 0% progress", function() {
  		$("body").append(view.$el);

  		view.onAdd(event, data);
  		expect(view.$(".progress").is(":visible")).toBe(true);
  		expect(view.$(".progress-bar").width()).toEqual(0);

  		view.$el.remove();
  	});
  	it("should submit the attachment data", function() {
  		view.onAdd(event, data);
  		expect(data.submit.callCount).toEqual(1);
  	});
    it("should disable the download button", function() {
      view.onAdd(event, data);
      expect(view.$(".download-button").hasClass("disabled")).toBe(true);
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
  	it("should set the model's attachment_url", function() {
  		var expected = "https://sensori-dev.s3.amazonaws.com/uploads/id/samples.zip";
  		view.onDone(event, data);
  		expect(model.get("attachment_url")).toEqual(expected);
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