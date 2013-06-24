// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {

  var lightboxContainer = $("#tutorial-lightbox"),
      lightboxImg       = lightboxContainer.find("img"),
      lightboxCaption   = lightboxContainer.find(".lightbox-caption");

  $(".tutorial [data-lightbox=true]").on("click", function(event) {
    var img = $(event.target).closest("[data-lightbox]").find("img");

    lightboxImg.attr("src", img.attr("src"));
    lightboxImg.attr("title", img.attr("title"));
    lightboxImg.attr("alt", img.attr("alt"));
    lightboxCaption.html(img.attr("title"));

    $("#tutorial-lightbox").lightbox();

  });

});