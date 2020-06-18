module EntryPassesHelper

  def any_employee_registered?(date)
    return false unless @office_passes.has_key?(date)
    @office_passes[date].count > 0
  end

  def registered_employee_count_for(date)
    @office_passes[date].count rescue 0
  end

  def sorted_list(names_with_id)
    names_with_id.sort_by{|i| i.first.strip.downcase}
  end

  def entry_pass_availablity_stats
    passes_data = {}
    @office_passes.map{|i, data| passes_data.merge!("#{i.to_s}" => DAILY_OFFICE_ENTRY_LIMIT - data.count)}
    passes_data.to_json
  end

  def get_pass_user_name(user_id)
    User.where({id: user_id}).first.try(:name)
  end
end
