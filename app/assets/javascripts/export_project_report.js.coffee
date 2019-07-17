$(document).ready ->
  $('#summary').click ->
    if $('#summary').prop("checked") == true
      $('.projects_dropdown').hide()
    else
      $('.projects_dropdown').show()
