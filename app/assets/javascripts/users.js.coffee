$(document).ready ->
  $('.resource').dataTable('ordering' : false)
  $('tr[hidden]').attr("hide", "true")
  $('#show').click ->
    if $(this).text() == 'Show All'
      params = $.param({ all:"all" })
      $.ajax 
        type: 'GET'
        dataType: 'script'
        url:'/users' + '?' + params
      $(this).text('Show Approved')
      $('tr[hide]').removeAttr('hidden')
      $('#show_text').text('Showing all- active & Inactive users.')
    else
      $.ajax
        type: 'GET'
        dataType: 'script'
        url:'/users'
      $(this).text('Show All')
      $('tr[hide]').attr('hidden', 'true')
      $('#show_text').text('Showing active users only.')

  $('#download_btn').click -> 
    if $('#show').text() == 'Show All'
      window.location.href = '/users.xlsx' 
    else
      window.location.href = '/users.xlsx'+'?'+ 'status=all'

