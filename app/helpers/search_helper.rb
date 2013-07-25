module SearchHelper
end

module SearchResult
  # Types of search results
  module Type
    POST = 1
    USER = 2
    ORGANIZATION = 3

    # Gets the pluralized string name of the search result type
    def self.ToName(type)
      if type == POST
        "Posts"
      elsif type == USER
        "Users"
      else
        "Organizations"
      end
    end
  end

  # Number of entries per page of results
  PAGE_SIZE = 5

  def self.CreatePostResult(post)
    result = {
      :type => Type::POST,
      :post => post,
    }

    result
  end

  def self.CreateUserResult(user)
    result = {
      :type => Type::USER,
      :user => user,
    }

    result
  end

  def self.CreateOrganizationResult(organization)
    result = {
      :type => Type::ORGANIZATION,
      :organization => organization,
    }

    result
  end

  # Outputs a link tag which is active if the current_type is the active_type
  def self.GetTypeLink(view, active_type, current_type, query)
    active_class = ''
    if active_type.to_i == current_type.to_i
      active_class = 'ui-btn-active'
    end

    type_link = view.search_path(:type => current_type.to_s, :q => query.to_s, :force => 1)
    view.link_to Type::ToName(current_type), type_link, :class => active_class
  end

  def self.HasNext(results)
    results.length > PAGE_SIZE.to_i
  end
end
