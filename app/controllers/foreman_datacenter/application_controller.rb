module ForemanDatacenter
  class ApplicationController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, :with => :not_found

    def not_found(exception = nil)
      logger.debug "not found: #{exception}" if exception
      respond_to do |format|
        format.html { render "foreman_datacenter/common/404", :status => :not_found }
        format.any { head :not_found}
      end
      true
    end

    def find_resource
      instance_variable_set("@#{resource_name}",
                            resource_finder(resource_scope, params[:id]))
    end

    def resource_finder(scope, id)
      raise ActiveRecord::RecordNotFound if scope.empty?
      result = scope.from_param(id) if scope.respond_to?(:from_param)
      begin
        result ||= scope.friendly.find(id) if scope.respond_to?(:friendly)
      rescue ActiveRecord::RecordNotFound
      end
      result || scope.find(id)
    end

    def controller_permission
      controller_name
    end

    def resource_name(resource = controller_name)
      resource.singularize
    end

    def resource_class
      @resource_class ||= resource_class_for(resource_name)
      raise NameError, "Could not find resource class for resource #{resource_name}" if @resource_class.nil?
      @resource_class
    end

    def resource_scope(options = {})
      @resource_scope ||= scope_for(resource_class, options)
    end

    def scope_for(resource, options = {})
      controller = options.delete(:controller){ controller_permission }
      # don't call the #action_permission method here, we are not sure if the resource is authorized at this point
      # calling #action_permission here can cause an exception, in order to avoid this, ensure :authorized beforehand
      permission = options.delete(:permission)

      if resource.respond_to?(:authorized)
        permission ||= "#{action_permission}_#{controller}"
        resource = resource.authorized(permission, resource)
      end

      resource.where(options)
    end

    def resource_class_for(resource)
      klass = "ForemanDatacenter::#{resource.classify}".constantize
      klass
    rescue NameError
      nil
    end

    # def resource_base_search_and_page(tables = [])
    #   base = tables.empty? ? resource_base_with_search : resource_base_with_search.eager_load(*tables)
    #   base.paginate(:page => params[:page], :per_page => params[:per_page])
    # end

    def action_permission
      case params[:action]
        when 'new_connection'
          'new_connection'
        when 'connect'
          'connect'
        when 'planned'
          'planned'
        when 'connected'
          'connected'
        when 'disconnect'
          'disconnect'
        when 'populate_new'
          'populate_new'
        when 'depopulate'
          'depopulate'
        when 'populate'
          'populate'
        when 'move'
          'move'
        else
          super
      end
    end

  end
end
