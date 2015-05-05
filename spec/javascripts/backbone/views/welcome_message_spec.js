describe("Sensori.Views.WelcomeMessage", function() {
  var view,
      el;

  beforeEach(function() {
    el = $("<body><div class='nav'><div class='container'></div></div></body>");
    view = new Sensori.Views.WelcomeMessage({ el: el });
  });

  describe("events", function() {
    it("should hide the welcome message", function() {
      expect(view.events["click"]).toEqual("hide");
    });
  });

  describe("initialize", function() {
    it("should set popoverTarget to the navbar container", function() {
      expect(view.popoverTarget).toEqual(view.$(".navbar .container"));
    });
  });

  describe("show", function() {
    beforeEach(function() {
      sinon.stub(view.popoverTarget, 'popover');
    });
    it("should setup and show the popover on the popoverTarget", function() {
      view.show();
      expect(view.popoverTarget.popover.callCount).toBe(2);
      expect(view.popoverTarget.popover.calledWith({
        title: 'Welcome!',
        placement: 'bottom',
        content: 'Your Soundcloud tracks will now show up in the "Beats" section. <a href="/about">Learn more</a>',
        html: true
      })).toBe(true);
      expect(view.popoverTarget.popover.calledWith('show')).toBe(true);
    });
  });

  describe("hide", function() {
    beforeEach(function() {
      sinon.stub(view.popoverTarget, 'popover');
      sinon.stub(view, 'stopListening');
    });
    it("should destroy the popover", function() {
      view.hide();
      expect(view.popoverTarget.popover.callCount).toBe(1);
      expect(view.popoverTarget.popover.calledWith('destroy')).toBe(true);
    });
    it("should have the view stop listening for events", function() {
      view.hide();
      expect(view.stopListening.callCount).toBe(1);
    });
  });
});
