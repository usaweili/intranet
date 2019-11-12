
$(document).ready ->
  $('#private_profile_date_of_joining').on 'change', ->
    date = $('#private_profile_date_of_joining').val()
    date = date.split('-').reverse().join('-')
    date = new Date(date)
    date = date.addDays(90)
    $('#private_profile_end_of_probation').val(convert(date))


Date::addDays = (days) ->
  date = new Date(@valueOf())
  date.setDate date.getDate() + days
  date

convert = (fromDate) ->
  date  = new Date(fromDate)
  month = date.getMonth()
  month = month + 1
  month = ('0' + month).slice(-2)
  day   = ('0' + date.getDate()).slice(-2)
  [
    day
    month
    date.getFullYear()
  ].join '-'
