module EntryPassesHelper

  def any_employee_registered?(date)
    @office_passes.select{|pass| pass.date == date}.count > 0
  end

  def registered_employee_count_for(date)
    @office_passes.select{|pass| pass.date == date}.count
  end

  def sorted_list(names_with_id)
    names_with_id.sort_by{|i| i.first.strip.downcase}
  end
end
