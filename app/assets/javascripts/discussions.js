// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  $("form").submit(function(e){
    var notifications = $('#discussion-notifications').prop('checked');
    var email = $('#email').val();
    if(notifications && !email) {
      e.preventDefault();
      $('#discussion-notification-modal').modal();
    }
  });
  $("#modal-post").on('click', function(e) {
    $("#email").val($("#modal-email").val());
    $("form").submit();
  });
});
