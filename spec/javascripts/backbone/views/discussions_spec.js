describe("Sensori.Views.Discussions", function() {
  var view,
      el,
      collection;

  beforeEach(function() {
    collection = new Sensori.Collections.Discussions([{ id: 13, slug: 'test-1' }, { id: 14, slug: 'test-2' }]);
    el = $("<div>").append([
      "<div class='media discussion-preview' data-discussion-id='test-1'>",
      "<div class='media discussion-preview' data-discussion-id='test-2'>"
      ].join(""));
    view = new Sensori.Views.Discussions({
      collection: collection,
      el: el
    });
  });

  describe(".initialize()", function() {
    beforeEach(function() {
      sinon.stub(Sensori.Views, 'DiscussionPreview');
    });
    afterEach(function() {
      Sensori.Views.DiscussionPreview.restore();
    });
    it("should setup discussion previews if the view is initialized with a collection", function() {
      view = new Sensori.Views.Discussions({
        collection: collection,
        el: el
      });
      expect(Sensori.Views.DiscussionPreview.callCount).toBe(2);
      expect(Sensori.Views.DiscussionPreview.calledWith({
        model: collection.models[0],
        el: el.find("[data-discussion-id='" + collection.models[0].id + "']")
      })).toBe(true);
      expect(Sensori.Views.DiscussionPreview.calledWith({
        model: collection.models[1],
        el: el.find("[data-discussion-id='" + collection.models[1].id + "']")
      })).toBe(true);
    });
    it("should not setup discussion previews if the view was not initialized with a collection", function() {
      view = new Sensori.Views.Discussions();
      expect(Sensori.Views.DiscussionPreview.callCount).toBe(0);
    });
    it("should setup an empty collection if one is not passed", function() {
      view = new Sensori.Views.Discussions();
      expect(view.collection).toBeDefined();
    });
  });

  describe(".bootstrap()", function() {
    beforeEach(function() {
      sinon.stub(Sensori.Views, 'DiscussionPreview');
    });
    afterEach(function() {
      Sensori.Views.DiscussionPreview.restore();
    });
    it("should setup discussion preview views for each of the models in the collection", function() {
      view.bootstrap();
      expect(Sensori.Views.DiscussionPreview.callCount).toBe(2);
      expect(Sensori.Views.DiscussionPreview.calledWith({
        model: collection.models[0],
        el: el.find("[data-discussion-id='" + collection.models[0].id + "']")
      })).toBe(true);
      expect(Sensori.Views.DiscussionPreview.calledWith({
        model: collection.models[1],
        el: el.find("[data-discussion-id='" + collection.models[1].id + "']")
      })).toBe(true);
    });
  });
});

