class SearchController < ApplicationController
  before_filter :authenticate_user!

  # TODO(vmarmol): The fact that I have to put to_i everywhere lets me know I don't know Ruby's "magic"

  # Search the specified type with the specified query, limit, and offset.
  def search_by_type query, type, limit, offset
    results = []

    # Search posts
    if type.to_i == SearchResult::Type::POST.to_i
      post_query = "%#{query}%"
      results = Post.includes([:user, :organization]).find(:all, :limit => limit, :conditions => ["text LIKE ?", post_query], :order => "created_at DESC", :offset => offset)
      results.map!{|p| SearchResult::CreatePostResult(p)}
    end

    # Search users
    if type.to_i == SearchResult::Type::USER.to_i
      user_query = "%#{query}%"
      results = User.find(:all, :limit => limit, :conditions => ["name LIKE ?", user_query], :offset => offset)
      results.map!{|u| SearchResult::CreateUserResult(u)}
    end

    # Search organizations
    if type.to_i == SearchResult::Type::ORGANIZATION.to_i
      org_query = "%#{query}%"
      results = Organization.find(:all, :limit => limit, :conditions => ["name LIKE ?", org_query], :offset => offset)
      results.map!{|o| SearchResult::CreateOrganizationResult(o)}
    end

    return results
  end

  # Return the "next type" by cycling through existing types in the following
  # order: posts, users, and organizations.
  def next_type current_type
    if current_type.to_i == SearchResult::Type::POST.to_i
      return SearchResult::Type::USER
    end

    if current_type.to_i == SearchResult::Type::USER.to_i
      return SearchResult::Type::ORGANIZATION
    end

    if current_type.to_i == SearchResult::Type::ORGANIZATION.to_i
      return SearchResult::Type::POST
    end
  end

  # Try the query of the specified type and at the specified page. If there are
  # no results of the specified type other types should be checked as well. If
  # force is specified, only this type is searched.
  def perform_search query, type, page_num, force
    results = []
    offset = page_num.to_i * SearchResult::PAGE_SIZE.to_i
    # Fetch one more (which we won't displays so that we know if we can page)
    limit = SearchResult::PAGE_SIZE.to_i + 1

    if offset > 0 or not force.nil?
      # We are requesting another page so there must be results for this type,
      # only search this type.
      results = search_by_type query, type, limit, offset
    else
      # There may not be search results of this type, so we cycle between the
      # types until we do find results (or no results at all).
      for i in 0..2
        results = search_by_type query, type, limit, offset

        # If you did find results, we are done.
        if not results.empty?
          break
        end

        # Try the next type for results
        type = next_type type
      end
    end

    return results, type
  end

  def search
    @query = params[:q]
    @type = params[:type]
    @page_num = params[:page]
    @results = nil
    @force = params[:force]

    # Default to posts
    if @type.nil? or @type.empty?
      @type = SearchResult::Type::POST
    end

    # Default to 0th page
    if @page_num.nil? or @page_num.empty?
      @page_num = 0
    end

    # Search if a query was specified
    if not @query.nil? and not @query.strip().empty?
      @results, @type = perform_search @query, @type, @page_num, @force
    end
  end
end
