$ ->
  initialise_pass_datepicker()
  $(document).on 'nested:fieldAdded', (event) ->
    initialise_pass_datepicker()

  $('.entry_pass_form').on 'submit', (e) ->
    e.preventDefault()
    $.validator.setDefaults({ ignore: ":hidden:not(select)" })
    if $('#entry_pass_form').valid()
    else
      e.stopPropagation()
      initialise_pass_datepicker()


@initialise_pass_datepicker =->
  $('.office-pass-datepicker').datepicker
      startDate: '0'
      endDate: '+7d'
      format: 'dd/mm/yyyy'
      autoclose: true
  $('.office-pass-datepicker').css 'height', '30px'
  $('.office-pass-datepicker').css 'text', '30px'


