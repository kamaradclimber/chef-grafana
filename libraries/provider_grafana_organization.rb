require 'chef/provider/lwrp_base'
require_relative 'organization_api'

class Chef
  class Provider
    class GrafanaOrganization < Chef::Provider::LWRPBase
      provides :grafana_organization
      include GrafanaCookbook::OrganizationApi

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create_if_missing do
        grafana_options = {
          host: new_resource.host,
          port: new_resource.port,
          user: new_resource.user,
          password: new_resource.password
        }
        orgs = get_orgs_list(grafana_options)

        exists = false
        orgs.each do |org|
          if org['name'] == new_resource.name
            exists = true
          end
        end
        unless exists
          converge_by("Creating organization #{new_resource.name}") do
            add_org(new_resource.name, grafana_options)
          end
        end
      end
    end
  end
end