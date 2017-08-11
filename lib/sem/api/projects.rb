module Sem
  module API
    class Projects < Base
      include Traits::AssociatedWithOrg
      include Traits::AssociatedWithTeam

      def self.list
        org_names = Orgs.list.map { |org| org[:username] }

        org_names.map { |name| list_for_org(name) }.flatten
      end

      def self.info(path)
        org_name, project_name = path.split("/")

        list_for_org(org_name).find { |project| project[:name] == project_name }
      end

      def self.api
        client.projects
      end

      def self.to_hash(project)
        {
          :id => project.id,
          :name => project.name
        }
      end
    end
  end
end