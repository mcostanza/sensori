describe("Sensori.Models.Discussion", function() {
  var discussion;

  it("should extend Backbone.Model", function() {
    discussion = new Sensori.Models.Discussion();
    expect(discussion instanceof Backbone.Model).toBe(true);
  });

  describe(".initialize(options)", function() {
    beforeEach(function() {
      mockMember = { name: 'John' };
      sinon.stub(Sensori.Models, "Member").returns(mockMember);
    });
    afterEach(function() {
      Sensori.Models.Member.restore();
    });
    it("should set member to a new Sensori.Models.Member if set in attributes", function() {
      var discussionAttrs = { subject: 'test', member: { name: 'John' } };
      discussion = new Sensori.Models.Discussion(discussionAttrs);
      expect(Sensori.Models.Member.callCount).toBe(1);
      expect(Sensori.Models.Member.calledWith(discussionAttrs.member)).toBe(true);
    });
    it("should unset the member attribute if passed", function() {
      var discussionAttrs = { subject: 'test', member: { name: 'John' } };
      discussion = new Sensori.Models.Discussion(discussionAttrs);
      expect(discussion.attributes['member']).not.toBeDefined();
    });
    it("should not set member if the member attribute is not passed", function() {
      discussion = new Sensori.Models.Discussion();
      expect(discussion.member).not.toBeDefined();
    });
  });

  describe(".url()", function() {
    it("should return /discussions for new records", function() {
      discussion = new Sensori.Models.Discussion();
      expect(discussion.url()).toEqual("/discussions");
    });
    it("should return /discussions/slug for existing records", function() {
      discussion = new Sensori.Models.Discussion({ slug: 'hey-brother' });
      expect(discussion.url()).toEqual("/discussions/hey-brother");
    });
  });
});
