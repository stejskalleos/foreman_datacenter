module Api
  module V2
    module ForemanDatacenter
      class PowerPortTemplatesController < ForemanDatacenter::BaseController
	include ::ForemanDatacenter::Controller::Parameters::PowerPortTemplate

        before_action :find_optional_nested_object
        before_action :find_resource, :only => %w{destroy show}
        add_scoped_search_description_for(::ForemanDatacenter::PowerPortTemplate)
        param_group :search_and_pagination, ::Api::V2::BaseController

        api :GET, "/foreman_datacenter/power_port_templates/", N_("List all PowerPortTemplates")
        
        def index
          @power_port_templates = resource_scope_for_index
        end

        api :GET, "/foreman_datacenter/power_port_templates/:id/", N_("Show a PowerPortTemplates")
        param :id, :identifier, :required => true

        def show
        end

	def_param_group :power_port_template do
	  param :power_port_template, Hash, :required => true, :action_aware => true do
	    param :name, String, :required => true
	    param :device_type_id, :number, :desc => N_("DeviceType ID")
	  end
	end

	api :POST, "/foreman_datacenter/power_port_templates", N_("Create a PowerPortTemplate")
	param_group :power_port_template, :as => :create

	def create
	  @power_port_template = ::ForemanDatacenter::PowerPortTemplate.new(power_port_template_params)
	  process_response @power_port_template.save
	end

	api :DELETE, "/foreman_datacenter/power_port_templates/:id/", N_("Delete a PowerPortTemplate")
	param :id, :identifier, :required => true

	def destroy
	  process_response @power_port_template.destroy
	end

      end
    end
  end
end
