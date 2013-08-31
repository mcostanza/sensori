// This is not setup as a normal JST in the templates directory because
// the signature for AWS needs to be regenerated every page load.
JST["backbone/templates/shared/s3_uploader_form"] = function() {
  return [
    '<form action="https://sensori-dev.s3.amazonaws.com/">',
      '<input id="key" name="key" type="hidden" value="uploads/id/${filename}" />',
    '</form>'
  ].join("");
};