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

  // Lazy-load images with data-src attribute when you scroll within 1000px of where they appear on the page
  $("img[data-src]").unveil(1000);

  // close popovers on external clicks
  $(':not(#anything)').on('click', function (e) {
    $('.popover-link').each(function () {
      //the 'is' for buttons that trigger popups
      //the 'has' for icons and other elements within a button that triggers a popup
      if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
        $(this).popover('hide');
        return;
      }
    });
  });
  
});
