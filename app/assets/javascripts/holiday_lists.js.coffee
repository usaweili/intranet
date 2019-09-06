# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('#date_year').on 'change', ->
    params = $.param({ year: $('#date_year').val() })
    $.ajax
      type: 'GET'
      dataType: 'script'
      url:'/holiday_lists'+ '?' + params


