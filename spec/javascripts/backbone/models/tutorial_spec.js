describe("Sensori.Models.Tutorial", function() {
  var tutorial,
      options;
  it("should extend Backbone.Model", function() {
    tutorial = new Sensori.Models.Tutorial();
    expect(tutorial instanceof Backbone.Model).toBe(true);
  });

  describe(".url()", function() {
    it("should return /tutorials for new records", function() {
      tutorial = new Sensori.Models.Tutorial();
      expect(tutorial.url()).toEqual("/tutorials");
    });
    it("should return /tutorials/id for existing records", function() {
      tutorial = new Sensori.Models.Tutorial({ id: 123 });
      expect(tutorial.url()).toEqual("/tutorials/123");
    });
  });

  describe(".publish(options)", function() {
    beforeEach(function() {
      options = { 
        success: sinon.spy(),
        error: sinon.spy()
      };
      sinon.stub($, "ajax");
    });
    afterEach(function() {
      $.ajax.restore();
    });
    it("should set the model with published: true", function() {
      tutorial.publish(options);
      expect(tutorial.get("published")).toBe(true);
    });
    it("should send an ajax request to publish the tutorial with success/error callbacks from options", function() {
      tutorial.publish(options);
      expect($.ajax.callCount).toEqual(1);
      var ajaxCall = $.ajax.getCall(0),
          ajaxArgs = ajaxCall.args[0];

      expect(ajaxArgs.type).toEqual("PUT");
      expect(ajaxArgs.dataType).toEqual("json");
      expect(ajaxArgs.data).toEqual({ tutorial: { published: true } });
      
      ajaxCall.yieldTo("success");
      expect(options.success.callCount).toEqual(1);

      ajaxCall.yieldTo("error");
      expect(options.error.callCount).toEqual(1);      
    });
  })

});
