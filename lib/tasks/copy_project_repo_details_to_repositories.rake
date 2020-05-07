namespace :create_project_repositories do
  desc "Copies CodeClimate details of all Projects to Repository model."
  task :copy_code_climate_details => [:environment] do
    projects = Project.all
    repositories = Repository.count
    projects.each do |project|
      if project.repositories.empty? &&
         ((project.code_climate_id && !project.code_climate_id.empty?) ||
          (project.code_climate_snippet && !project.code_climate_snippet.empty?) ||
          (project.code_climate_coverage_snippet && !project.code_climate_coverage_snippet.empty?))
        repository_attributes = {
          code_climate_id: project.code_climate_id,
          maintainability_badge: project.code_climate_snippet,
          test_coverage_badge: project.code_climate_coverage_snippet,
        }
        project.repositories.create!(repository_attributes)
      end
    end
    puts "Notice: #{Repository.count - repositories} Repositories Linked Successfully!"
  end
end
