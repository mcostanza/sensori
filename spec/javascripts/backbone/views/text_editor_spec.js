describe("Sensori.Views.TextEditor", function() {
  var view;

  beforeEach(function() {
    view = new Sensori.Views.TextEditor();
  });

  describe(".$el", function() {
    it("should be a textarea with class 'wysihtml5'", function() {
      expect(view.$el.prop("tagName")).toEqual("TEXTAREA");
      expect(view.$el.hasClass("wysihtml5")).toEqual(true);
    });
  });

  describe(".getHTMLValue()", function() {
    it("should return the element's value", function() {
      view.$el.val("This is how I think.");
      expect(view.getHTMLValue()).toEqual("This is how I think.");
    });
  });

  describe(".getJSONValue()", function() {
    it("should return an object with 'type' and 'content' attributes", function() {
      sinon.stub(view, "getHTMLValue").returns("This is how I think.");
      var expected = {
        type: "text",
        content: "This is how I think."
      };
      expect(view.getJSONValue()).toEqual(expected);
      expect(view.getHTMLValue.callCount).toEqual(1);
    });
  });

  describe(".createEditor()", function() {
    it("should initialize a wysihtml5 editor on the view's element", function() {
      sinon.stub($.fn, "wysihtml5");
      view.createEditor();
      expect($.fn.wysihtml5.callCount).toEqual(1);
      expect($.fn.wysihtml5.calledOn(view.$el)).toEqual(true);
      expect($.fn.wysihtml5.calledWith(view.wysihtml5Config)).toEqual(true);
    });
  });

  describe(".render()", function() {
    it("should set the element's content from this.options.content", function() {
      view.options.content = "<p>This is how I think.</p>"
      var expectedContent = "&lt;p&gt;This is how I think.&lt;/p&gt;"
      view.render();
      expect(view.$el.html()).toEqual(expectedContent);
    });
    it("should return itself", function() {
      expect(view.render()).toEqual(view);
    });
  });

});