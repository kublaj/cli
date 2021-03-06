class Sem::API::Team < SimpleDelegator
  extend Sem::API::Base

  def self.all
    Sem::API::Org.all.pmap(&:teams).flatten
  end

  def self.find!(team_srn)
    org_name, team_name = Sem::SRN.parse_team(team_srn)

    team = client.teams.list_for_org!(org_name).find { |t| t.name == team_name }

    if team.nil?
      raise Sem::Errors::ResourceNotFound.new("Team", [org_name, team_name])
    end

    new(org_name, team)
  rescue SemaphoreClient::Exceptions::NotFound
    raise Sem::Errors::ResourceNotFound.new("Team", [org_name, team_name])
  end

  def self.create!(team_srn, args)
    org_name, team_name = Sem::SRN.parse_team(team_srn)

    team = client.teams.create_for_org!(org_name, args.merge(:name => team_name))

    new(org_name, team)
  rescue SemaphoreClient::Exceptions::NotFound
    raise Sem::Errors::ResourceNotFound.new("Organization", [org_name])
  end

  attr_reader :org_name

  def initialize(org_name, team)
    @org_name = org_name

    super(team)
  end

  def full_name
    "#{org_name}/#{name}"
  end

  def update!(args)
    new_team = Sem::API::Base.client.teams.update!(id, args)

    self.class.new(@org_name, new_team)
  end

  def add_user(username)
    Sem::API::Base.client.users.attach_to_team!(username, id)
  rescue SemaphoreClient::Exceptions::NotFound
    raise Sem::Errors::ResourceNotFound.new("User", [username])
  end

  def remove_user(username)
    Sem::API::Base.client.users.detach_from_team!(username, id)
  rescue SemaphoreClient::Exceptions::NotFound
    raise Sem::Errors::ResourceNotFound.new("User", [username])
  end

  def add_project(project)
    Sem::API::Base.client.projects.attach_to_team!(project.id, id)
  rescue SemaphoreClient::Exceptions::NotFound
    raise Sem::Errors::ResourceNotFound.new("Project", [project.full_name])
  end

  def remove_project(project)
    Sem::API::Base.client.projects.detach_from_team!(project.id, id)
  rescue SemaphoreClient::Exceptions::NotFound
    raise Sem::Errors::ResourceNotFound.new("Project", [project.full_name])
  end

  def add_secret(secret)
    Sem::API::Base.client.secrets.attach_to_team!(secret.id, id)
  rescue SemaphoreClient::Exceptions::NotFound
    raise Sem::Errors::ResourceNotFound.new("Secret", [secret.full_name])
  end

  def remove_secret(secret)
    Sem::API::Base.client.secrets.detach_from_team!(secret.id, id)
  rescue SemaphoreClient::Exceptions::NotFound
    raise Sem::Errors::ResourceNotFound.new("Secret", [secret.full_name])
  end

  def delete!
    Sem::API::Base.client.teams.delete!(id)
  end

  def users
    Sem::API::Base.client.users.list_for_team!(id).map { |user| Sem::API::User.new(user) }
  end

  def projects
    Sem::API::Base.client.projects.list_for_team!(id).map { |project| Sem::API::Project.new(org_name, project) }
  end

  def secrets
    Sem::API::Base.client.secrets.list_for_team!(id).map { |secret| Sem::API::Secret.new(org_name, secret) }
  end

end
