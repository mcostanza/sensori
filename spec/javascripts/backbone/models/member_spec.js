describe("Sensori.Models.Member", function() {
  var member, image_url;

  it("should extend Backbone.Model", function() {
    member = new Sensori.Models.Member();
    expect(member instanceof Backbone.Model).toBe(true);
  });

  describe(".url()", function() {
    it("should return /members for new records", function() {
      member = new Sensori.Models.Member();
      expect(member.url()).toEqual("/members");
    });
    it("should return /members/id for existing records", function() {
      member = new Sensori.Models.Member({ id: 123 });
      expect(member.url()).toEqual("/members/123");
    });
  });

  describe(".image(size)", function() {
    beforeEach(function() {
      image_url = "http://image.com/phil-t500x500.jpg";
      member = new Sensori.Models.Member({ id: 123, image_url: image_url });
    });
    it("should return the small image when 'small' is passed", function() {
      expect(member.image('small'), image_url.replace("t500x500", "t50x50"));
    });
    it("should return the medium image when 'medium' is passed", function() {
      expect(member.image('small'), image_url.replace("t500x500", "large"));
    });
    it("should return the original image when nothing is passed", function() {
      expect(member.image(), image_url);
    });
    it("should return the original image if the arg passed is not understood", function() {
      expect(member.image('oopsies'), image_url);
    });
  });

  describe("profilePath()", function() {
    it("should return /:slug", function() {
      member = new Sensori.Models.Member({ slug: 'five05' });
      expect(member.profilePath(), "/five05");
    });
  });
});
