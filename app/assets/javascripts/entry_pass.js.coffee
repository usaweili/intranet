$ ->

  $('.entry_pass_form').on 'submit', (e) ->
    e.preventDefault()
    $.validator.setDefaults({ ignore: ":hidden:not(select)" })
    if $('#entry_pass_form').valid()
    else
      e.stopPropagation()
      initialise_pass_datepicker()

disabledDates = ->
  blockedDates = []
  $.each $('.registered_entry_pass input'), (i, ele) ->
    blockedDates.push $(ele).val()
    return

  $.each entry_pass_stats, (date, availablity) ->
    if availablity == 0
      blockedDates.push date
    return
  blockedDates


@initialise_pass_datepicker =->
  $('.office-pass-datepicker').datepicker
      startDate: '0'
      endDate: '+7d'
      format: 'dd/mm/yyyy'
      autoclose: true
      datesDisabled: disabledDates()

  $('.office-pass-datepicker').css 'height', '30px'
  $('.office-pass-datepicker').css 'text', '30px'
  $('.office-pass-datepicker').on 'change', (e) ->
    show_availability_stats($(this))

@show_stats_on_render =->
  $('#entry_pass_form .office-pass-datepicker').each  ->
    show_availability_stats($(this))

@show_availability_stats = ($this) ->
  availablity = entry_pass_stats[$this.val()]
  if availablity == undefined
    availablity = total_availablity
  if availablity == 0
    $this.closest('.row').find('.available_text').text("Not Available")
  else
    $this.closest('.row').find('.available_text').text('('+ availablity + ') Available')
