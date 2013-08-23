describe("Sensori.Models.Submission", function() {
  var submission;

  it("should extend Backbone.Model", function() {
    submission = new Sensori.Models.Submission();
    expect(submission instanceof Backbone.Model).toBe(true);
  });

  describe(".url()", function() {
    it("should return /sessions/:session_id/submissions for new records", function() {
      submission = new Sensori.Models.Submission({ session_id: 1 });
      expect(submission.url()).toEqual("/sessions/1/submissions");
    });
    it("should return /sessions/:session_id/submissions/:id for existing records", function() {
      submission = new Sensori.Models.Submission({ session_id: 1, id: 2 });
      expect(submission.url()).toEqual("/sessions/1/submissions/2");
    });
  });

});