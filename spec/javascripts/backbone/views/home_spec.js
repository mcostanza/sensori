describe("Sensori.Views.Home", function() {
  var view,
      el,
      discussions;

  beforeEach(function() {
    discussions = new Sensori.Collections.Discussions([{ id: 13, slug: 'test-1' }, { id: 14, slug: 'test-2' }]);
    el = $("<div>").append([
      "<div class='media discussion-preview' data-discussion-id='test-1'>",
      "<div class='media discussion-preview' data-discussion-id='test-2'>"
      ].join(""));
    view = new Sensori.Views.Home({
      discussions: discussions,
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
    it("should setup .discussions with the discussions passed", function() {
      expect(view.discussions).toBe(discussions);
    });
    it("should setup discussion previews if the view is initialized with discussions", function() {
      view = new Sensori.Views.Home({
        discussions: discussions,
        el: el
      });
      expect(Sensori.Views.DiscussionPreview.callCount).toBe(2);
      expect(Sensori.Views.DiscussionPreview.calledWith({
        model: discussions.models[0],
        el: el.find("[data-discussion-id='" + discussions.models[0].id + "']")
      })).toBe(true);
      expect(Sensori.Views.DiscussionPreview.calledWith({
        model: discussions.models[1],
        el: el.find("[data-discussion-id='" + discussions.models[1].id + "']")
      })).toBe(true);
    });
    it("should not setup discussion previews if the view was not initialized with discussions", function() {
      view = new Sensori.Views.Home();
      expect(Sensori.Views.DiscussionPreview.callCount).toBe(0);
    });
  });

  describe(".bootstrap()", function() {
    beforeEach(function() {
      sinon.stub(Sensori.Views, 'DiscussionPreview');
    });
    afterEach(function() {
      Sensori.Views.DiscussionPreview.restore();
    });
    it("should setup discussion preview views for each of the models in the discussions collection", function() {
      view.bootstrap();
      expect(Sensori.Views.DiscussionPreview.callCount).toBe(2);
      expect(Sensori.Views.DiscussionPreview.calledWith({
        model: discussions.models[0],
        el: el.find("[data-discussion-id='" + discussions.models[0].id + "']")
      })).toBe(true);
      expect(Sensori.Views.DiscussionPreview.calledWith({
        model: discussions.models[1],
        el: el.find("[data-discussion-id='" + discussions.models[1].id + "']")
      })).toBe(true);
    });
    it("should not do anything if discussions is not set", function() {
      view.discussions = undefined;
      view.bootstrap();
      expect(Sensori.Views.DiscussionPreview.callCount).toBe(0);
    });
  });
});
