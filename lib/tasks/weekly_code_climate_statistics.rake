desc "Fetches & loads weekly CodeClimate Statistics for each repo"
task :weekly_codeclimate_statistics => :environment do
  keys = CodeClimateStatistic.fields.keys
  from = Date.today.beginning_of_week.strftime('%Y-%m-%d')
  to = Date.today.strftime('%Y-%m-%d')
  query_string = "filter[from]=#{from}&filter[to]=#{to}"
  Repository.each do |repo|
    if repo.code_climate_id && !repo.code_climate_id.empty?
      url = "https://api.codeclimate.com/v1/repos/#{repo.code_climate_id}/metrics?#{query_string}"
      headers = { "Accept" => "application/vnd.api+json", "Authorization" => "Token token=#{ENV['CODE_CLIMATE_TOKEN']}" }
      begin
        response = HTTParty.get(url, headers: headers, timeout: 20)
      rescue Timeout::Error => e
        puts "Error: Request Timeout for #{repo.project.name}"
        next
      end
      response_body = JSON.parse(response.body)
      stats = { "repository_id": repo.id }
      stats["loc"] = {}
      stats["ratings"] = {}
      if response_body && response_body["data"] && response_body["data"].length > 0
        response_body["data"].each do |d|
          metric = d["attributes"]["name"]
          metric_split = d["attributes"]["name"].split(".")
          metric = metric_split.first
          if keys.include? metric
            point = d["attributes"]["points"].last
            if ["loc", "ratings"].include? metric
              stats[metric][metric_split.last] = point["value"] || 0
            else
              stats[metric] = point["value"] || 0
            end
            stats[:timestamp] = Time.at(point["timestamp"]) if !stats[:timestamp]
          end
        end
        code_climate_stat = CodeClimateStatistic.create(stats)
        if code_climate_stat.valid?
          puts "CodeClimate Statistics created successfully for #{repo.project.name}\'s #{repo.project.name} Repository."
        else
          puts "Error: #{code_climate_stat.errors.full_messages.join(",")} for #{repo.project.name}"
        end
      else
        puts "No Data Found for #{repo.project.name}\'s #{repo.name} Repository."
      end
    else
      puts "No CodeClimate Repo ID Found for #{repo.project.name}\'s #{repo.name} Repository."
    end
  end
end
