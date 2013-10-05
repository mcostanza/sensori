describe("Underscore Mixins", function() {
  var text;

  describe("_.truncate(text, length)", function() {
    beforeEach(function() {
      text = "This is the Text";
    });
    it("should truncate the string passed the correct length", function() {
      expect(_.truncate(text, 10)).toEqual("This is...");
    });
    it("should be non destrunctive", function() {
      _.truncate(text, 10);
      expect(text).toEqual("This is the Text");
    });
    it("should not modify strings where the length is exactly the length allowed", function() {
      expect(_.truncate(text, 16)).toEqual("This is the Text");
    });
    it("should not modify strings where the length is less than the length allowed", function() {
      expect(_.truncate(text, 100)).toEqual("This is the Text");
    });
  });
});

