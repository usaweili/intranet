query_string = window.location.search
severity = {'critical': 'red', 'major': 'orange', 'minor': 'gold'}

$(document).ready ->
  page = 1
  template = Mustache.compile($.trim($('#issues_template').html()))
  view = (record, index) ->
    record.color = severity[record.attributes.severity]
    template
      record: record
      index: index

  callback = {
    after_add: (data)->
      page = page + 1
      this.opts.params["page"] = page
  }

  options =
    view: view
    data_url: '/repositories/get_repo_issues'+ query_string
    stream_after: 1
    fetch_data_limit: 100
    params: { page: page }
    callbacks: callback

  if($('#issues_table').length)
    $('#issues_table').stream_table options, data if typeof data isnt "undefined"
