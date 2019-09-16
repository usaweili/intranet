namespace :probation_notification do
  desc 'Notify to management about employee probation end'
    task :probation_end => [:environment] do
      PrivateProfile.notify_probation_end
    end
end
