Foreman::Application.routes.draw do
  scope 'datacenter', module: :foreman_datacenter do
    resources :sites
    resources :racks do
      get :rack_groups, on: :collection
    end
    resources :rack_groups
    resources :platforms
    resources :device_roles
    resources :manufacturers
    resources :device_types do
      resources :interface_templates, only: [:new, :create, :destroy],
                path: 'interfaces' do
        get :new_management, on: :collection
      end
      resources :console_port_templates, only: [:new, :create, :destroy],
                path: 'console_ports'
      resources :power_port_templates, only: [:new, :create, :destroy],
                path: 'power_ports'
      resources :console_server_port_templates, only: [:new, :create, :destroy],
                path: 'console_server_ports'
      resources :power_outlet_templates, only: [:new, :create, :destroy],
                path: 'power_outlets'
      resources :device_bay_templates, only: [:new, :create, :destroy],
                path: 'device_bays'
    end
    resources :devices do
      collection do
        get :device_types, :racks
      end
      member do
        get :inventory, :lldp_neighbors
      end
      resources :device_bays, except: [:show, :index], shallow: true do
        member do
          get :populate_new
          patch :populate
          delete :depopulate
        end
      end
      resources :device_interfaces, except: [:show, :index], shallow: true do
        resources :device_interface_connections, except: [:show, :edit, :update, :index],
                  shallow: true do
          member do
            patch :planned, :connected
          end
        end
      end
    end
    resources :device_interface_connections, only: [:index], path: 'connections' do
      collection do
        get :devices, :interfaces
      end
    end
  end
end
