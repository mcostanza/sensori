Sensori.Mixins.Validations = {
  matchers: {
    email: /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i
  },

  validatesPresenceOf: function(input) {
    this.addValidation(input, function() { return !_.isEmpty($.trim(input.val())); });
  },

  validatesFormatOf: function(input, type) {
    this.addValidation(input, _.bind(function() { return !_.isNull(input.val().match(this.matchers[type])); }, this));
  },

  validate: function() {
    this.invalidInputs = [];
    _.each(this.validations, function(validation) {
      if(!validation.isValid()) { this.invalidInputs.push(validation.input); }
    }, this);
    this.addErrors(this.invalidInputs);
    return _.isEmpty(this.invalidInputs);
  },

  addValidation: function(input, validation) {
    this.validations = this.validations || [];
    this.validations.push({ input: input, isValid: validation });
    input.on("focus", _.bind(function() {
      this.removeErrors(input);
    }, this));
  },

  addErrors: function(inputs) {
    if(!_.isArray(inputs)) { inputs = [inputs]; }
    _.each(inputs, function(input) {
      input.closest(".control-group").addClass("error");
    });
  },

  removeErrors: function(inputs) {
    if(!_.isArray(inputs)) { inputs = [inputs]; }
    _.each(inputs, function(input) {
      input.closest(".control-group").removeClass("error");
    });
  }
}
