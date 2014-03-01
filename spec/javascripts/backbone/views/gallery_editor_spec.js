describe("Sensori.Views.GalleryEditor", function() {
  var view, 
      data,
      mediaView,
      mediaModel;

  beforeEach(function() {
    view = new Sensori.Views.GalleryEditor({
      content: []
    });

    mediaModel = {
      type: "image",
      src: "https://sensori-dev.s3.amazonaws.com/uploads/id/picture.jpg",
      title: ""
    };
  });

  describe(".initialize(options)", function() {
    it("should set this.mediaViews to an empty array", function() {
      expect(view.mediaViews).toEqual([]);
    });
    it("should set this.content from options", function() {
      var content = [
        { type: "media", src: "http://s3.amazon.com/sensori/pics/1.jpg", title: "Rat near a trash can" }
      ];
      var view = new Sensori.Views.GalleryEditor({
        content: content
      })
      expect(view.content).toEqual(content);
    });
  });
  describe(".$el", function() {
    it("should be a div with class 'gallery-editor'", function() {
      expect(view.$el.prop("tagName")).toEqual("DIV");
      expect(view.$el.hasClass("gallery-editor")).toEqual(true);
    });
  });

  describe(".unveilImages()", function() {
    beforeEach(function() {
      sinon.stub($.fn, "unveil");
      view.$el.append("<img data-src='real-picture.jpg' src='/assets/loader.gif' />");
    });
    afterEach(function() {
      $.fn.unveil.restore();
    });
    it("should unveil all images with a data-src attribute within the element", function() {
      view.unveilImages();
      expect($.fn.unveil.callCount).toEqual(1);
      expect($.fn.unveil.getCall(0).thisValue.selector).toEqual("img[data-src]");
    });
  });

  describe(".updateGallery()", function() {
    beforeEach(function() {
      sinon.stub(view, "unveilImages");
    });
    it("should unveil the view's images", function() {
      view.updateGallery();
      expect(view.unveilImages.callCount).toEqual(1);
    });
  });

  describe(".isImage(file)", function() {
    it("should return true for valid image formats (png, jpg, gif)", function() {
      expect(view.isImage({ name: "test.jpg" })).toBe(true);
      expect(view.isImage({ name: "test.JPEG" })).toBe(true);
      expect(view.isImage({ name: "test.Gif" })).toBe(true);
      expect(view.isImage({ name: "test.png" })).toBe(true);
    });
    it("should return false if the file is any other format", function() {
      expect(view.isImage({ name: "test.pdf" })).toBe(false);
      expect(view.isImage({ name: "test.bmp" })).toBe(false);
    });
  });

  describe(".isAudio(file)", function() {
    it("should return true for valid audio formats (mp3, wav)", function() {
      expect(view.isAudio({ name: "test.mp3" })).toBe(true);
      expect(view.isAudio({ name: "test.MP3" })).toBe(true);
      expect(view.isAudio({ name: "test.wav" })).toBe(true);
    });
    it("should return false if the file is any other format", function() {
      expect(view.isAudio({ name: "test.pdf" })).toBe(false);
      expect(view.isAudio({ name: "test.jpg" })).toBe(false);
    });
  });

  describe("setupUploaderForm()", function() {
    beforeEach(function() {
      view.render();
      sinon.stub($.fn, "fileupload");
      sinon.stub(view, "uploaderOnAdd");
      sinon.stub(view, "uploaderOnProgress");
      sinon.stub(view, "uploaderOnDone");
      sinon.stub(view, "uploaderOnFail");
    });
    afterEach(function() {
      $.fn.fileupload.restore();
    });
    it("should initialize a fileupload object on the view's form with callbacks bound to this view", function() {
      view.setupUploaderForm();
      expect($.fn.fileupload.callCount).toEqual(1)
      expect($.fn.fileupload.getCall(0).thisValue.selector).toEqual("form");

      var fileupload = $.fn.fileupload.getCall(0);
      expect(_.keys(fileupload.args[0]).sort()).toEqual(["add", "done", "fail", "progress"]);

      fileupload.yieldTo("add");
      expect(view.uploaderOnAdd.calledOn(view)).toEqual(true);

      fileupload.yieldTo("done");
      expect(view.uploaderOnDone.calledOn(view)).toEqual(true);

      fileupload.yieldTo("fail");
      expect(view.uploaderOnFail.calledOn(view)).toEqual(true);

      fileupload.yieldTo("progress");
      expect(view.uploaderOnProgress.calledOn(view)).toEqual(true);
    });
  });

  describe(".uploaderOnAdd(e, data)", function() {
    beforeEach(function() {
      view.render();
      sinon.stub(jQuery.fn, "fadeIn");
      sinon.stub(jQuery.fn, "fadeOut");
    });
    afterEach(function() {
      jQuery.fn.fadeIn.restore();
      jQuery.fn.fadeOut.restore();
    });
    describe("when valid media is uploaded", function() {
      beforeEach(function() {
        sinon.stub(view, "isImage").returns(true);
        sinon.stub(view, "isAudio").returns(true);
        data = {
          submit: sinon.spy(),
          files: [
            { type: "media/png", name: "test.png" }
          ]
        }
      });
      it("should allow either image or audio", function() {
        view.isImage.returns(true);
        view.isAudio.returns(false);
        view.uploaderOnAdd('event', data);
        expect(data.submit.callCount).toEqual(1);

        view.isImage.returns(false);
        view.isAudio.returns(true);
        view.uploaderOnAdd('event', data);
        expect(data.submit.callCount).toEqual(2);

        view.isImage.returns(false);
        view.isAudio.returns(false);
        view.uploaderOnAdd('event', data);
        expect(data.submit.callCount).toEqual(2);
      });
      it("should submit the data", function() {
        view.uploaderOnAdd('event', data);
        expect(data.submit.callCount).toEqual(1);
      });
      it("should remove error status from the upload button", function() {
        view.$(".control-group").addClass("error")
        view.uploaderOnAdd("event", data);
        expect(view.$(".control-group").hasClass("error")).toBe(false);
        expect(jQuery.fn.fadeOut.getCall(0).thisValue.selector).toEqual(".control-group .help-inline");
      });
      it("should show the upload progress bar", function() {
        view.uploaderOnAdd("event", data);
        expect(jQuery.fn.fadeIn.getCall(0).thisValue.selector).toEqual(".progress");
      });
    });
    describe("when an invalid media is uploaded", function() {
      beforeEach(function() {
        sinon.stub(view, "isImage").returns(false);
        data = {
          submit: sinon.spy(),
          files: [
            { type: "application/pdf", name: "test.pdf" }
          ]
        };
      });
      it("should add error status to the upload button", function() {
        view.uploaderOnAdd("event", data);
        expect(view.$(".control-group").hasClass("error")).toBe(true);
        expect(jQuery.fn.fadeIn.getCall(0).thisValue.selector).toEqual(".control-group .help-inline");
      });
      it("should not submit the data", function() {
        view.uploaderOnAdd("event", data);
        expect(data.submit.callCount).toEqual(0);
      });
    });
  });

  describe(".uploaderOnProgress(e, data)", function() {
    beforeEach(function() {
      view.render()
      data = {
        loaded: 10,
        total: 100
      }
    });
    it("should update the progress bar", function() {
      var event = {};
      view.uploaderOnProgress(event, data);
      expect(view.$(".progress-bar").width() > 0).toBe(true);
    });
  });

  describe(".uploaderOnDone(e, data)", function() {
    beforeEach(function() {
      view.render();
      data = { 
        files: [
         { name: "picture.jpg" }
        ] 
      };
      sinon.stub(view, "addMedia");
      sinon.stub(view, "createEditorView").returns("media editor view");
      sinon.stub(jQuery.fn, "fadeOut");
    });
    afterEach(function() {
      view.addMedia.restore();
      view.createEditorView.restore();
      jQuery.fn.fadeOut.restore();
    });
    it("should create a media editor view with a model based on the uploaded file", function() {
      //image
      imageModel = {
        type: "image",
        src: "https://sensori-dev.s3.amazonaws.com/uploads/id/picture.jpg",
        title: ""
      };
      view.uploaderOnDone('event', data);
      expect(view.createEditorView.callCount).toEqual(1);
      expect(view.createEditorView.calledWith(mediaModel)).toEqual(true);
      //audio
      data.files[0].name = "test.wav";
      audioModel = {
        type: "audio",
        src: "https://sensori-dev.s3.amazonaws.com/uploads/id/test.wav",
        title: "test.wav"
      };
      view.uploaderOnDone('event', data);
      expect(view.createEditorView.callCount).toEqual(2);
      expect(view.createEditorView.calledWith(audioModel)).toEqual(true);
    });
    it("should add the media to the gallery", function() {
      view.uploaderOnDone("event", data);
      expect(view.addMedia.callCount).toEqual(1);
      expect(view.addMedia.calledWith("media editor view")).toEqual(true);
    });
    it("should hide the progress bar", function() {
      view.uploaderOnDone("event", data);
      expect(jQuery.fn.fadeOut.getCall(0).thisValue.selector).toEqual(".progress");
    });
  });

  describe(".uploaderOnFail(e, data)", function() {
  });

  describe(".addMedia(mediaView, options)", function() {
    beforeEach(function() {
      view.render();

      mediaView = new Sensori.Views.MediaEditor({
        model: { type: "image", src: "pic.jpg", title: "" }
      }).render();

      sinon.stub(view, "updateGallery");
    });
    it("should add the mediaView to this.mediaViews", function() {
      view.addMedia(mediaView);
      expect(view.mediaViews[0]).toEqual(mediaView);
    });
    it("should append the mediaView element to the gallery", function() {
      view.addMedia(mediaView);
      expect(view.$(mediaView.$el).length).toEqual(1);
    });
    it("should update the gallery", function() {
      view.addMedia(mediaView);
      expect(view.updateGallery.callCount).toEqual(1);
    });
    it("should not update the gallery if options.initialRender is true", function() {
      view.addMedia(mediaView, { initialRender: true });
      expect(view.updateGallery.callCount).toEqual(0);
    });
  });

  describe(".removeMedia(mediaView)", function() {
    beforeEach(function() {
      mediaView = new Sensori.Views.MediaEditor({
        model: { type: "image", src: "pic.jpg", title: "" }
      }).render();
      sinon.stub(mediaView, "remove");

      view.mediaViews = [1, 2, mediaView, 3];

      sinon.stub(view, "updateGallery");
    });
    it("should remove the mediaView from this.mediaViews", function() {
      view.removeMedia(mediaView);
      expect(view.mediaViews).toEqual([1, 2, 3]);
    });
    it("should remove the mediaView from the document", function() {
      view.removeMedia(mediaView);
      expect(mediaView.remove.callCount).toEqual(1);
    });
    it("should update the gallery", function() {
      view.removeMedia(mediaView);
      expect(view.updateGallery.callCount).toEqual(1);
    });
  });

  describe(".renderMedia()", function() {
    beforeEach(function() {
      sinon.stub(view, "createEditorView").returns("media editor view");
      sinon.stub(view, "addMedia");
      sinon.stub(view, "updateGallery");
      view.content = [mediaModel];
    });
    it("should create an media editor and add an media for each mediaModel in this.content", function() {
      view.renderMedia();
      expect(view.createEditorView.callCount).toEqual(1);
      expect(view.createEditorView.calledWith(view.content[0])).toEqual(true);
      expect(view.addMedia.callCount).toEqual(1);
      expect(view.addMedia.calledWith("media editor view", { initialRender: true })).toEqual(true);
    });
    it("should update the gallery after adding all medias", function() {
      view.renderMedia();
      expect(view.updateGallery.callCount).toEqual(1);
    });
  });

  describe(".createEditorView(mediaModel)", function() {
    beforeEach(function() {
      sinon.spy(Sensori.Views.MediaEditor.prototype, "render");
    });
    afterEach(function() {
      Sensori.Views.MediaEditor.prototype.render.restore();
    });
    it("should return a rendered media editor view initialized with mediaModel", function() {
      mediaView = view.createEditorView(mediaModel);
      expect(mediaView instanceof Sensori.Views.MediaEditor).toBe(true);
      expect(mediaView.render.callCount).toEqual(1);
      expect(mediaView.galleryView).toEqual(view);
      expect(mediaView.model).toEqual(mediaModel);
    });
  });

  describe(".getHTMLValue()", function() {
    beforeEach(function() {
      view.content = [mediaModel];
      view.render();
    });
    it("should return the tutorials/gallery template rendered with all the media elements", function() {
      var expected = JST["backbone/templates/tutorials/gallery"]({
        mediaItems: [view.mediaViews[0].getHTMLValue()]
      })
      expect(view.getHTMLValue()).toEqual(expected);
    });
  });

  describe(".getJSONValue()", function() {
    beforeEach(function() {
      view.content = [mediaModel];
      view.render();
    });
    it("should return an array with each mediaView's JSON value", function() {
      var expected = {
        type: "gallery",
        content: [mediaModel]
      };
      expect(view.getJSONValue()).toEqual(expected);
    });
  });

  describe(".render()", function() {
    beforeEach(function() {
      sinon.stub(view, "setupUploaderForm");
      sinon.stub(view, "renderMedia");
    });
    it("should set the view content to the gallery_editor template with nested s3_uploader_form template", function() {
      view.render();
      expect(view.$("form[action='https://sensori-dev.s3.amazonaws.com/']").length).toEqual(1);
      expect(view.$(".media-items").length).toEqual(1);
    });
    it("should initialize an media uploader form", function() {
      view.render();
      expect(view.setupUploaderForm.callCount).toEqual(1);
    });
    it("should render the gallery", function() {
      view.render();
      expect(view.renderMedia.callCount).toEqual(1);
    })
    it("should return itself", function() {
      expect(view.render()).toEqual(view);
    });
  })
});
