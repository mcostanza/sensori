describe("Sensori.Views.Submission", function() {
	var model,
	    view,
	    data;

	beforeEach(function() {
		model = new Sensori.Models.Submission({
			member_id: 1,
			session_id: 2
		});

		view = new Sensori.Views.Submission({
			model: model,
			sessionTitle: "Make A Beat"
		});
	});

	describe(".validate()", function() {
		beforeEach(function() {
			sinon.stub(view, "validateAttachmentUrl").returns(true);
			sinon.stub(view, "validateTitle").returns(true);
		});
		it("should validate the title and attachment url", function() {
			view.validate()
			expect(view.validateAttachmentUrl.callCount).toEqual(1);
			expect(view.validateTitle.callCount).toEqual(1);
		});
		it("should return true if there are no errors", function() {
		  expect(view.validate()).toBe(true);
		});
		it("should return false if the title validation fails", function() {
		  view.validateTitle.returns(false);
		  expect(view.validate()).toBe(false);
		});
		it("should return false if the attachment url validation fails", function() {
		  view.validateAttachmentUrl.returns(false);
		  expect(view.validate()).toBe(false);
		});
	});

	describe(".validateTitle(errors)", function() {
		beforeEach(function() {
			view.render();
			sinon.stub($.fn, "fadeOut");
			sinon.stub($.fn, "fadeIn");
		});
		afterEach(function() {
			$.fn.fadeOut.restore();
			$.fn.fadeIn.restore();
		});
		it("should add error status to the title input and return false if the model's title is empty", function() {
			model.set("title", "");

			expect(view.validateTitle()).toBe(false);
			var controlGroup = view.$("#submission_title").closest(".control-group");
			expect(controlGroup.hasClass("error")).toBe(true);
			expect($.fn.fadeIn.getCall(0).thisValue.selector).toEqual("#submission_title.closest(.control-group) .help-inline");
		});
		it("should remove error status from the title input and return true if the model has a title", function() {
			model.set("title", "beat");

			var controlGroup = view.$("#submission_title").closest(".control-group");
			controlGroup.addClass("error");

			expect(view.validateTitle()).toBe(true);

			expect(controlGroup.hasClass("error")).toBe(false);
			expect($.fn.fadeOut.getCall(0).thisValue.selector).toEqual("#submission_title.closest(.control-group) .help-inline");
		});
	});

	describe(".validateAttachmentUrl()", function() {
		beforeEach(function() {
			view.render();
			sinon.stub($.fn, "fadeOut");
			sinon.stub($.fn, "fadeIn");
		});
		afterEach(function() {
			$.fn.fadeOut.restore();
			$.fn.fadeIn.restore();
		});
		it("should add error status to the attachment_url element and return false if the model does not have an attachment_url", function() {
			expect(view.validateAttachmentUrl()).toBe(false);

			var controlGroup = view.$(".fileinput-button").closest(".control-group");
			expect(controlGroup.hasClass("error")).toBe(true);
			expect($.fn.fadeIn.getCall(0).thisValue.selector).toEqual(".fileinput-button.closest(.control-group) .help-inline");
		});		
		it("should remove error status from the attachment button and return true if the model has an attachment_url", function() {
			model.set("attachment_url", "http://s3.amazon.com/sensori/beat.mp3");
			var controlGroup = view.$(".fileinput-button").closest(".control-group");
			controlGroup.addClass("error");

			expect(view.validateAttachmentUrl()).toBe(true);

			expect(controlGroup.hasClass("error")).toBe(false);
			expect($.fn.fadeOut.getCall(0).thisValue.selector).toEqual(".fileinput-button.closest(.control-group) .help-inline");
		});
	});

	describe(".changeSubmissionTitle()", function() {
		beforeEach(function() {
			view.render();
			sinon.stub(view, "validateTitle");
		});
		it("should set the model's submission_title from the #submission_title input value", function() {
			view.$("#submission_title").val("my neat beat!");
			view.changeSubmissionTitle();
			expect(model.get("title")).toEqual("my neat beat!");
		});
		it("should validate the title", function() {
			view.changeSubmissionTitle()
			expect(view.validateTitle.callCount).toEqual(1);
		});
	});

	describe(".saveSubmission()", function() {
		beforeEach(function() {
			view.render();
			sinon.stub(model, "save");
			sinon.stub(view, "saveSuccess");
			sinon.stub(view, "saveError");
			sinon.stub(view, "validate").returns(true);
		});
		it("should return without saving or validating if the save button is disabled", function() {
			view.saveButton.addClass("disabled");
			view.saveSubmission();
			expect(view.validate.callCount).toEqual(0);
			expect(model.save.callCount).toEqual(0);
		});
		it("should validate the view", function() {
		  view.saveSubmission();
		  expect(view.validate.callCount).toEqual(1);
		});
		it("should save the model with success and error callbacks", function() {
		  view.saveSubmission()
		  expect(model.save.callCount).toEqual(1);

		  model.save.yieldTo("success");
		  expect(view.saveSuccess.callCount).toEqual(1);

		  model.save.yieldTo("error");
		  expect(view.saveError.callCount).toEqual(1);
		});
		it("should not save the model if the view is invalid", function() {
			view.validate.returns(false);
			view.saveSubmission();
			expect(model.save.callCount).toEqual(0);
		});
	});

	describe(".saveSuccess()", function() {
		beforeEach(function() {
		  view.render();
		  sinon.stub(view, "showAlert");
		});
		it("should enable the save button", function() {
			view.saveButton.addClass("disabled");
			view.saveSuccess();
			expect(view.saveButton.hasClass("disabled")).toBe(false);
		});
		it("should show an alert message", function() {
			view.saveSuccess();
			expect(view.showAlert.callCount).toEqual(1);
		});
	});

	describe(".saveError()", function() {
	  beforeEach(function() {
	    view.render();
	    view.saveButton.addClass("disabled");
	  });
	  it("should add an error alert message to the view", function() {
	  	view.saveError();
	  	expect(view.$(".alert.alert-error").length).toEqual(1);
	  });
	  it("should enable the save button", function() {
	  	view.saveError();
	  	expect(view.saveButton.hasClass("disabled")).toBe(false);
	  });
	});

	describe(".onAdd(event, data)", function() {
	  beforeEach(function() {
	    view.render();
	    sinon.stub($.fn, "fadeIn");
	  });
	  afterEach(function() {
	    $.fn.fadeIn.restore();
	  });
	  it("should remove the previous attachment link preview", function() {
	  	view.$(".fileinput-button").after("<div class='submission-link'>beat</div>");
	  	view.onAdd("event", { files: [{ name: "beat.jpg" }] });
	  	expect(view.$(".submission-link").length).toEqual(0);
	  });
	  describe("uploading an mp3 file", function() {
	  	beforeEach(function() {
	  	  data = {
	  	  	submit: sinon.spy(),
	  	  	files: [{ name: "beat.mp3" }]
	  	  };
	  	});
	    it("should disable the save button", function() {
	    	view.onAdd("event", data);
	    	expect(view.saveButton.hasClass("disabled")).toBe(true);
	    });
	    it("should remove error status from the attachment field", function() {
	      var controlGroup = view.$(".fileinput-button").closest(".control-group")
	      controlGroup.addClass("error");
	      view.onAdd("event", data);
	      expect(controlGroup.hasClass("error")).toBe(false);
	    });
	    it("should show the progress bar with 0% progress", function() {
	      view.onAdd("event", data);
	      expect($.fn.fadeIn.getCall(0).thisValue.selector).toEqual(".progress");
	      expect(view.$(".progress-bar").css("width")).toEqual("0%");
	    });
	    it("should submit the data", function() {
	      view.onAdd("event", data);
	      expect(data.submit.callCount).toEqual(1);
	    });
	  });
	  describe("uploading a wav file", function() {
	  	beforeEach(function() {
	  	  data = {
	  	  	submit: sinon.spy(),
	  	  	files: [{ name: "beat.wav" }]
	  	  };
	  	});
	    it("should disable the save button", function() {
	    	view.onAdd("event", data);
	    	expect(view.saveButton.hasClass("disabled")).toBe(true);
	    });
	    it("should remove error status from the attachment field", function() {
	      var controlGroup = view.$(".fileinput-button").closest(".control-group")
	      controlGroup.addClass("error");
	      view.onAdd("event", data);
	      expect(controlGroup.hasClass("error")).toBe(false);
	    });
	    it("should show the progress bar with 0% progress", function() {
	      view.onAdd("event", data);
	      expect($.fn.fadeIn.getCall(0).thisValue.selector).toEqual(".progress");
	      expect(view.$(".progress-bar").css("width")).toEqual("0%");
	    });
	    it("should submit the data", function() {
	      view.onAdd("event", data);
	      expect(data.submit.callCount).toEqual(1);
	    });
	  });
	  describe("any other file type", function() {
	  	beforeEach(function() {
	  	  data = {
	  	  	submit: sinon.spy(),
	  	  	files: [{ name: "beat.jpg" }]
	  	  };
	  	});
	    it("should enable the save button", function() {
	    	view.onAdd("event", data);
	    	expect(view.saveButton.hasClass("disabled")).toBe(false);
	    });
	    it("should add error status from the attachment field", function() {
	      var controlGroup = view.$(".fileinput-button").closest(".control-group")
	      view.onAdd("event", data);
	      expect(controlGroup.hasClass("error")).toBe(true);
	    });
	    it("should not submit the data", function() {
	      view.onAdd("event", data);
	      expect(data.submit.callCount).toEqual(0);
	    });
	  });
	});

	describe(".onProgress(event, data)", function() {
		beforeEach(function() {
		  view.render();
		});
	  it("should update the progress bar width", function() {
	  	view.onProgress("event", { loaded: 1, total: 10 });
	  	expect(view.$(".progress-bar").css("width")).toEqual("10%");
	  });
	});

	describe(".onDone(event, data)", function() {
		beforeEach(function() {
			view.render();
		  sinon.stub($.fn, "fadeOut");
		  data = { files: [{ name: "beat.mp3" }] }
		});
		afterEach(function() {
		  $.fn.fadeOut.restore();
		});
	  it("should fade out the progress bar", function() {
	    view.onDone("event", data);
	    expect($.fn.fadeOut.getCall(0).thisValue.selector).toEqual(".progress");
	  });
	  it("should remove disabled class from the save button", function() {
	    view.saveButton.addClass("disabled");
	    view.onDone("event", data);
	    expect(view.saveButton.hasClass("disabled")).toBe(false);
	  });
	  it("should set the model's attachment_url from the uploaded file", function() {
	    view.onDone("event", data);
	    expect(model.get("attachment_url")).toEqual("https://sensori-dev.s3.amazonaws.com/uploads/id/beat.mp3")
	  });
	  it("should add a preview link for the uploaded file", function() {
	    view.onDone("event", data);
	    expect(view.$(".submission-link").attr("href")).toEqual(model.get("attachment_url"));
	  });
	  describe("files with characters that need to be escaped", function() {
	  	beforeEach(function() {
	  		data.files[0].name = "Whip Em (Didn't We?).mp3";
	  	});
	  	it("sets the model's attachment_url to the correctly escaped url", function() {
	  		view.onDone("event", data);
	  		expect(model.get("attachment_url")).toEqual("https://sensori-dev.s3.amazonaws.com/uploads/id/Whip%20Em%20%28Didn%27t%20We%3F%29.mp3")
	  	});
	  });
	});

	describe(".showForm()", function() {
		beforeEach(function() {
		  view.render();
		  model.set({
		  	title: "beat",
		  	attachment_url: "http://s3.amazon.com/sensori/beat.mp3"
		  });
		  sinon.stub($.fn, "fadeIn");
		});
		afterEach(function() {
		  $.fn.fadeIn.restore();
		});
	  it("should unset title and attachment_url attachments on the model", function() {
	    view.showForm();
	    expect(model.has("title")).toBe(false);
	    expect(model.has("attachment_url")).toBe(false);
	  });
	  it("should remove the preview attachment link", function() {
	    view.$el.append("<div class='submision-link'>beat</div>");
	    view.showForm();
	    expect(view.$(".submission-link").length).toEqual(0);
	  });
	  it("should hide the change submission link", function() {
	    view.$(".change-submission").show();
	    view.showForm();
	    expect(view.$(".change-submission").is(":hidden")).toBe(true);
	  });
	  it("should show the new submission form", function() {
	  	view.showForm();
	  	expect($.fn.fadeIn.getCall(0).thisValue.selector).toEqual(".new-submission");
	  });
	});

	describe(".showAlert()", function() {
		beforeEach(function() {
		  view.render();
		  sinon.stub($.fn, "fadeIn");
		});
		afterEach(function() {
		  $.fn.fadeIn.restore();
		});
	  it("should hide the new submission form", function() {
	  	view.$(".new-submission").show();
	  	view.showAlert();
	  	expect(view.$(".new-submission").is(":hidden")).toBe(true);
	  });
	  it("should show the change submission element", function() {
	    view.showAlert();
	    expect($.fn.fadeIn.getCall(0).thisValue.selector).toEqual(".change-submission");
	  });
	  it("should add a success message to the view", function() {
			view.showAlert();
			expect(view.$(".alert.alert-success").length).toEqual(1);
	  });
	});

	describe(".render()", function() {
		beforeEach(function() {
		  sinon.stub($.fn, "fileupload");
		  sinon.stub(view, "onAdd");
		  sinon.stub(view, "onDone");
		  sinon.stub(view, "onFail");
		  sinon.stub(view, "onProgress");
		  sinon.stub(view, "showForm");
		  sinon.stub(view, "showAlert");
		});
		afterEach(function() {
		  $.fn.fileupload.restore()
		});
	  it("should set this.saveButton to the save button element", function() {
	  	view.render();
	  	expect(view.saveButton).toEqual(view.$("[data-trigger='save-submission']"));
	  });
	  it("should setup a file uploader", function() {
		  view.render();
		  expect($.fn.fileupload.callCount).toEqual(1);
		  
		  var fileuploadCall = $.fn.fileupload.getCall(0);
		  
		  fileuploadCall.yieldTo("add");
		  expect(view.onAdd.callCount).toEqual(1);

		  fileuploadCall.yieldTo("done");
		  expect(view.onDone.callCount).toEqual(1);

		  fileuploadCall.yieldTo("fail");
		  expect(view.onFail.callCount).toEqual(1);

		  fileuploadCall.yieldTo("progress");
		  expect(view.onProgress.callCount).toEqual(1);
	  });
	  it("should show the submission form if the submission is new", function() {
	    view.render();
	    expect(view.showForm.callCount).toEqual(1);
	    expect(view.showAlert.callCount).toEqual(0);
	  });
	  it("should show the submission alert if the submission is new", function() {
	    model.set("id", 123);
	    view.render();
	    expect(view.showForm.callCount).toEqual(0);
	    expect(view.showAlert.callCount).toEqual(1);
	  });
	  it("should return itself", function() {
	    expect(view.render()).toEqual(view);
	  });
	});
});
