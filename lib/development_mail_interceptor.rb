class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    message.to = "swapnil@joshsoftware.com,paritoshbotre@joshsoftware.com"
  end
end
