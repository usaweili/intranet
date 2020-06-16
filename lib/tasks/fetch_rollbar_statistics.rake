desc 'Fetches & loads weekly Rollbar Items for each repo'
task fetch_rollbar_statistics: :environment do
  Repository.each do |repo|
    load_issues(page = 1, repo) if repo.rollbar_access_token.present?
  end
end

def load_issues(page = 1, repo)
  url = "https://api.rollbar.com/api/1/items?page=#{page}&environment=production"
  headers = { 'X-Rollbar-Access-Token' => repo.rollbar_access_token }
  begin
    response = HTTParty.get(url, headers: headers, timeout: 20)
  rescue Timeout::Error => e
    puts "Error: Request Timeout for #{repo.project.name}"
    return
  end
  response_body = JSON.parse(response.body)
  if response_body && response_body['result'] && response_body['result']['items']
    active_issue_count = 0
    resolved_issue_count = 0
    new_issue_count = 0
    total_issues = response_body['result']['total_count'] - (100 * page - 1)
    items = response_body['result']['items']
    items.each do |item|
      active_issue_count += 1 if item['status'] == 'active'
      resolved_issue_count += 1 if item['status'] == 'resolved'
      new_issue_count += 1 if item['first_occurrence_timestamp'] >= (Time.now.beginning_of_day - 7.days).to_i
    end
    rollbar_statistic = RollbarStatistic.where(date: Date.today, repository: repo).last
    if rollbar_statistic.present?
      active_issue_count += rollbar_statistic.active_issue_count
      resolved_issue_count += rollbar_statistic.resolved_issue_count
      new_issue_count += rollbar_statistic.new_issue_count
      rollbar_statistic.update(active_issue_count: active_issue_count, resolved_issue_count: resolved_issue_count,
                               new_issue_count: new_issue_count)
    else
      rollbar_statistic ||= RollbarStatistic.create(total_issues: total_issues, active_issue_count: active_issue_count, resolved_issue_count: resolved_issue_count,
                                                    new_issue_count: new_issue_count, repository: repo, date: Date.today)
    end
    if rollbar_statistic.valid?
      puts "Rollbar Statistics Created / Updated successfully for #{repo.name} repository."
    else
      puts "Error: #{rollbar_statistic.errors.full_messages.join(',')} for #{repo.name} repository."
    end
    load_issues(page + 1, repo) if total_issues > 100
  end
end
