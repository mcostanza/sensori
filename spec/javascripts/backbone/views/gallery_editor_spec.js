describe("Sensori.Views.GalleryEditor", function() {
  var view, 
      data,
      imageView,
      imageModel;

  beforeEach(function() {
    view = new Sensori.Views.GalleryEditor({
      content: []
    });

    imageModel = {
      type: "image",
      src: "https://sensori-dev.s3.amazonaws.com/uploads/id/picture.jpg",
      title: ""
    };
  });

  describe(".initialize(options)", function() {
    it("should set this.imageViews to an empty array", function() {
      expect(view.imageViews).toEqual([]);
    });
    it("should set this.content from options", function() {
      var content = [
        { type: "image", src: "http://s3.amazon.com/sensori/pics/1.jpg", title: "Rat near a trash can" }
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

  describe(".resizeThumbnails()", function() {
    beforeEach(function() {
      sinon.stub(view, "getSpanClass").returns("span8");
      view.imageViews = [
        { el: $("<div class='span11'></div>")[0] },
        { el: $("<div class='span5'></div>")[0] },
        { el: $("<div class='span3'></div>")[0] },
        { el: $("<div class='span2'></div>")[0] }
      ];
    });
    it("should remove all existing span[num] classes from the gallery's image editor elements and add the calculated span class", function() {
      view.resizeThumbnails();
      expect(view.getSpanClass.callCount).toEqual(1);
      _.each(_.pluck(view.imageViews, 'el'), function(el) {
        expect($(el).hasClass("span11 span5 span3 span2")).toEqual(false);
        expect($(el).hasClass("span8")).toEqual(true);
      });
    });
  });

  describe(".getSpanClass()", function() {
    it("should return 'span11' when there is 1 imageView", function() {
      view.imageViews = [1];
      expect(view.getSpanClass()).toEqual("span11");
    });
    it("should return 'span11' when there is 1 imageView", function() {
      view.imageViews = [1];
      expect(view.getSpanClass()).toEqual("span11");
    })
    it("should return 'span5' when there are 2 imageViews", function() {
      view.imageViews = [1, 2];
      expect(view.getSpanClass()).toEqual("span5");
    })
    it("should return 'span3' when there are 3 imageViews", function() {
      view.imageViews = [1, 2, 3];
      expect(view.getSpanClass()).toEqual("span3");
    })
    it("should return 'span2' when there are 4 imageViews", function() {
      view.imageViews = [1, 2, 3, 4];
      expect(view.getSpanClass()).toEqual("span2");
    })
    it("should return 'span2' when there are > 4 imageViews", function() {
      view.imageViews = [1, 2, 3, 4, 5, 6];
      expect(view.getSpanClass()).toEqual("span2");
    })
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
      sinon.stub(view, "resizeThumbnails");
      sinon.stub(view, "unveilImages");
    });
    it("should resize the view's thumbnails", function() {
      view.updateGallery();
      expect(view.resizeThumbnails.callCount).toEqual(1);
    });
    it("should unveil the view's images", function() {
      view.updateGallery();
      expect(view.unveilImages.callCount).toEqual(1);
    });
  });

  describe(".isImage(file)", function() {
    it("should return true if the file is a jpg/jpeg image", function() {
      expect(view.isImage({ type: "image/jpg" })).toBe(true);
      expect(view.isImage({ type: "image/jpeg" })).toBe(true);
      expect(view.isImage({ type: "IMAGE/JPG" })).toBe(true);
    });
    it("should return true if the file is a gif image", function() {
      expect(view.isImage({ type: "image/gif" })).toBe(true);
      expect(view.isImage({ type: "IMAGE/GIF" })).toBe(true);
    });
    it("should return true if the file is a png image", function() {
      expect(view.isImage({ type: "image/png" })).toBe(true);
      expect(view.isImage({ type: "IMAGE/PNG" })).toBe(true);
    });
    it("should return false if the file is any other type", function() {
      expect(view.isImage({ type: "application/pdf" })).toBe(false);
      expect(view.isImage({ type: "application/wav" })).toBe(false);
    });
  });

  describe("setupImageUploaderForm()", function() {
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
      view.setupImageUploaderForm();
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
    describe("when an image is uploaded", function() {
      beforeEach(function() {
        sinon.stub(view, "isImage").returns(true);
        data = {
          submit: sinon.spy(),
          files: [
            { type: "image/png", name: "test.png" }
          ]
        }
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
    describe("when a non-image is uploaded", function() {
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
      sinon.stub(view, "addImage");
      sinon.stub(view, "createImageEditorView").returns("image editor view");
      sinon.stub(jQuery.fn, "fadeOut");
    });
    afterEach(function() {
      view.addImage.restore();
      view.createImageEditorView.restore();
      jQuery.fn.fadeOut.restore();
    });
    it("should create an image editor view with an imageModel based on the uploaded file", function() {
      view.uploaderOnDone('event', data);
      expect(view.createImageEditorView.callCount).toEqual(1);
      expect(view.createImageEditorView.calledWith(imageModel)).toEqual(true);
    });
    it("should add the image to the gallery", function() {
      view.uploaderOnDone("event", data);
      expect(view.addImage.callCount).toEqual(1);
      expect(view.addImage.calledWith("image editor view")).toEqual(true);
    });
    it("should hide the progress bar", function() {
      view.uploaderOnDone("event", data);
      expect(jQuery.fn.fadeOut.getCall(0).thisValue.selector).toEqual(".progress");
    });
  });

  describe(".uploaderOnFail(e, data)", function() {
  });

  describe(".addImage(imageView, options)", function() {
    beforeEach(function() {
      view.render();

      imageView = new Sensori.Views.ImageEditor({
        model: { type: "image", src: "pic.jpg", title: "" }
      }).render();

      sinon.stub(view, "updateGallery");
    });
    it("should add the imageView to this.imageViews", function() {
      view.addImage(imageView);
      expect(view.imageViews[0]).toEqual(imageView);
    });
    it("should append the imageView element to the gallery", function() {
      view.addImage(imageView);
      expect(view.$(imageView.$el).length).toEqual(1);
    });
    it("should update the gallery", function() {
      view.addImage(imageView);
      expect(view.updateGallery.callCount).toEqual(1);
    });
    it("should not update the gallery if options.initialRender is true", function() {
      view.addImage(imageView, { initialRender: true });
      expect(view.updateGallery.callCount).toEqual(0);
    });
  });

  describe(".removeImage(imageView)", function() {
    beforeEach(function() {
      imageView = new Sensori.Views.ImageEditor({
        model: { type: "image", src: "pic.jpg", title: "" }
      }).render();
      sinon.stub(imageView, "remove");

      view.imageViews = [1, 2, imageView, 3];

      sinon.stub(view, "updateGallery");
    });
    it("should remove the imageView from this.imageViews", function() {
      view.removeImage(imageView);
      expect(view.imageViews).toEqual([1, 2, 3]);
    });
    it("should remove the imageView from the document", function() {
      view.removeImage(imageView);
      expect(imageView.remove.callCount).toEqual(1);
    });
    it("should update the gallery", function() {
      view.removeImage(imageView);
      expect(view.updateGallery.callCount).toEqual(1);
    });
  });

  describe(".renderImages()", function() {
    beforeEach(function() {
      sinon.stub(view, "createImageEditorView").returns("image editor view");
      sinon.stub(view, "addImage");
      sinon.stub(view, "updateGallery");
      view.content = [imageModel];
    });
    it("should create an image editor and add an image for each imageModel in this.content", function() {
      view.renderImages();
      expect(view.createImageEditorView.callCount).toEqual(1);
      expect(view.createImageEditorView.calledWith(view.content[0])).toEqual(true);
      expect(view.addImage.callCount).toEqual(1);
      expect(view.addImage.calledWith("image editor view", { initialRender: true })).toEqual(true);
    });
    it("should update the gallery after adding all images", function() {
      view.renderImages();
      expect(view.updateGallery.callCount).toEqual(1);
    });
  });

  describe(".createImageEditorView(imageModel)", function() {
    beforeEach(function() {
      sinon.spy(Sensori.Views.ImageEditor.prototype, "render");
    });
    afterEach(function() {
      Sensori.Views.ImageEditor.prototype.render.restore();
    });
    it("should return a rendered image editor view initialized with imageModel", function() {
      imageView = view.createImageEditorView(imageModel);
      expect(imageView instanceof Sensori.Views.ImageEditor).toBe(true);
      expect(imageView.render.callCount).toEqual(1);
      expect(imageView.galleryView).toEqual(view);
      expect(imageView.model).toEqual(imageModel);
    });
  });

  describe(".getHTMLValue()", function() {
    beforeEach(function() {
      view.content = [imageModel];
      view.render();
    });
    it("should return the tutorials/gallery_show template rendered with current span class and all imageView thumbnails", function() {
      var expected = JST["backbone/templates/tutorials/gallery_show"]({
        spanClass: "span11",
        thumbnails: [view.imageViews[0].getHTMLValue()]
      })
      expect(view.getHTMLValue()).toEqual(expected);
    });
  });

  describe(".getJSONValue()", function() {
    beforeEach(function() {
      view.content = [imageModel];
      view.render();
    });
    it("should return an array with each imageView's JSON value", function() {
      var expected = {
        type: "gallery",
        content: [imageModel]
      };
      expect(view.getJSONValue()).toEqual(expected);
    });
  });

  describe(".render()", function() {
    beforeEach(function() {
      sinon.stub(view, "setupImageUploaderForm");
      sinon.stub(view, "renderImages");
    });
    it("should set the view content to the gallery_editor template with nested s3_uploader_form template", function() {
      view.render();
      expect(view.$("form[action='https://sensori-dev.s3.amazonaws.com/']").length).toEqual(1);
      expect(view.$("ul.thumbnails").length).toEqual(1);
    });
    it("should initialize an image uploader form", function() {
      view.render();
      
      expect(view.setupImageUploaderForm.callCount).toEqual(1);
    });
    it("should render the gallery", function() {
      view.render();
      expect(view.renderImages.callCount).toEqual(1);
    })
    it("should return itself", function() {
      expect(view.render()).toEqual(view);
    });
  })
});