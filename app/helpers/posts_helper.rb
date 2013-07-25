module PostsHelper
  module FilterType
    ALL = "all"
    FOLLOWING = "following"
  end

  # Outputs selected if the item is selected, else not selected
  def self.IsSelected(type, selected)
    if selected == type or (selected.nil? and type == FilterType::ALL)
      "selected=\"selected\""
    else
      ""
    end
  end
end
