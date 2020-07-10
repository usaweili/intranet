desc 'Fetches & loads weekly Rollbar Items for each repo'
task fetch_rollbar_statistics: :environment do
  Repository.each do |repo|
    load_issues(page = 1, repo) if repo.rollbar_access_token.present?
  end
end

def load_issues(page = 1, repo)
  url = ROLLBAR_ISSUES_URL + "?page=#{page}&environment=production"
  headers = { 'X-Rollbar-Access-Token' => repo.rollbar_access_token }
  response = HttpartyService.new(url: url, headers: headers, timeout: 20).get

  if response && !response[:error] && response.body
    response_body = JSON.parse(response.body)

    if response_body['result'] && response_body['result']['items']
      active_issue_count = resolved_issue_count = new_issue_count = 0
      total_issues = response_body['result']['total_count'] - (100 * page - 1)
      items = response_body['result']['items']

      active_issue_count = items.select {|i| i['status'] == 'active'}.count
      resolved_issue_count = items.select {|i| i['status'] == 'resolved'}.count
      new_issue_count = items.select {|i| i['first_occurrence_timestamp'] >= (Time.now.beginning_of_day - 7.days).to_i}.count

      rollbar_statistic = RollbarStatistic.where(date: Date.today, repository: repo).last
      if rollbar_statistic.present?
        active_issue_count += rollbar_statistic.active_issue_count
        resolved_issue_count += rollbar_statistic.resolved_issue_count
        new_issue_count += rollbar_statistic.new_issue_count
        rollbar_statistic.update(active_issue_count: active_issue_count, resolved_issue_count: resolved_issue_count,
                                 new_issue_count: new_issue_count)
      else
        rollbar_statistic ||= RollbarStatistic.create(total_issues: total_issues, active_issue_count: active_issue_count,
                                                      resolved_issue_count: resolved_issue_count, repository: repo,
                                                      new_issue_count: new_issue_count, date: Date.today)
      end
      if rollbar_statistic.valid?
        puts "Rollbar Statistics Created / Updated successfully for #{repo.name} repository."
      else
        puts "Error: #{rollbar_statistic.errors.full_messages.join(',')} for #{repo.name} repository."
      end
      load_issues(page + 1, repo) if total_issues > 100
    end
  end
end
