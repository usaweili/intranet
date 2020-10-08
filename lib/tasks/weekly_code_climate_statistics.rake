desc 'Fetches & loads weekly CodeClimate Statistics for each repo'
task :weekly_codeclimate_statistics => :environment do
  Repository.each do |repo|
    if repo.code_climate_id.present?
      headers = {
        'Accept' => 'application/vnd.api+json',
        'Authorization' => "Token token=#{ENV['CODE_CLIMATE_TOKEN']}"
      }
      repo_url = "https://api.codeclimate.com/v1/repos/#{repo.code_climate_id}"
      begin
        repo_response = HTTParty.get(repo_url, headers: headers, timeout: 20)
      rescue Timeout::Error => e
        puts "Error: Request Timeout for #{repo.project.name}"
        next
      end

      if repo_response.success?
        stat = repo.code_climate_statistics.new
        date_interval = (Date.current - 2.week).beginning_of_week..Date.current
        repo_details = JSON.parse(repo_response.body)
        latest_snap_id =
          repo_details['data']['relationships']['latest_default_branch_snapshot']['data']['id']
        latest_test_report =
          repo_details['data']['relationships']['latest_default_branch_test_report']['data']
        latest_test_coverage_id = latest_test_report && latest_test_report['id']
        if latest_snap_id.present?
          snapshot_url = "#{repo_url}/snapshots/#{latest_snap_id}"
          begin
            snap_response = HTTParty.get(snapshot_url, headers: headers, timeout: 20)
          rescue Timeout::Error => e
            puts "Error: Request Timeout for #{repo.project.name}"
            next
          end

          if snap_response.success?
            snap_details = JSON.parse(snap_response.body)
            snap_timestamp = snap_details['data']['attributes']['created_at']
            snap_date = Date.parse(snap_timestamp)
            if snap_date.in? date_interval
              stat.lines_of_code = snap_details['data']['attributes']['lines_of_code']
              stat.total_issues = snap_details['data']['meta']['issues_count']
              stat.technical_debt_ratio =
                snap_details['data']['meta']['measures']['technical_debt_ratio']['value']
              issues_url = "#{snapshot_url}/issues"
              complexity_issues_url = "#{issues_url}?filter[categories]=Complexity"
              duplication_issues_url = "#{issues_url}?filter[categories]=Duplication"
              begin
                c_issues_response =
                  HTTParty.get(complexity_issues_url, headers: headers, timeout: 20)
                d_issues_response =
                  HTTParty.get(duplication_issues_url, headers: headers, timeout: 20)
              rescue Timeout::Error => e
                puts "Error: Request Timeout for #{repo.project.name}"
                next
              end

              c_issues_details = JSON.parse(c_issues_response.body)
              d_issues_details = JSON.parse(d_issues_response.body)
              stat.complexity_issues = c_issues_details['meta']['total_count']
              stat.duplication_issues = d_issues_details['meta']['total_count']
              ratings = snap_details['data']['attributes']['ratings']
              ratings.each do |rating|
                if rating['pillar'] == 'Maintainability'
                  stat.maintainability = rating['measure']['value']
                  stat.remediation_time =
                    rating['measure']['meta']['remediation_time']['value']
                  stat.implementation_time =
                    rating['measure']['meta']['implementation_time']['value']
                end
              end
              stat.save!
              puts "Successfully captured statistics for #{repo.project.name}"
            else
              puts "No snapshot captured on default branch of #{repo.project.name}\'s #{repo.name} in this week."
            end
          else
            puts "Failed to retreive latest snapshot details for #{repo.project.name}\'s #{repo.name}."
          end
        else
          puts "Failed to retreive latest snapshot Id for #{repo.project.name}\'s #{repo.name}."
        end

        if latest_test_coverage_id.present?
          test_report_url = "#{repo_url}/test_reports/#{latest_test_coverage_id}"
          begin
            test_coverage_response =
              HTTParty.get(test_report_url, headers: headers, timeout: 20)
          rescue Timeout::Error => e
            puts "Error: Request Timeout for #{repo.project.name}"
            next
          end

          test_coverage_details = JSON.parse(test_coverage_response.body)
          report_timestamp = test_coverage_details['data']['attributes']['received_at']
          date_of_report = Date.parse(report_timestamp)
          if date_of_report.in? date_interval
            stat.test_coverage =
              test_coverage_details['data']['attributes']['rating']['measure']['value']
            stat.save!
            puts "Successfully captured test coverage for #{repo.project.name}"
          else
            puts "No test report captured on default branch of #{repo.project.name}\'s #{repo.name} in this week."
          end
        else
          puts "Failed to retreive latest test coverage Id for #{repo.project.name}\'s #{repo.name}."
        end
      else
        puts "Failed to retreive repository details for #{repo.project.name}\'s #{repo.name}."
      end
    else
      puts "No CodeClimate Repo ID Found for #{repo.project.name}\'s #{repo.name} Repository."
    end
  end
end
