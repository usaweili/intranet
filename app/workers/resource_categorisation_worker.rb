class ResourceCategorisationWorker
  include Sidekiq::Worker

  def perform(email)
    ResourceCategorisationService.new(email).call
  end
end
