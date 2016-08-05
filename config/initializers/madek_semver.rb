# some constants externalized so they can be accessed from outside of rails

# Semver: get semantic version as a parsed Hash.
#
# Supports one of two cases:
# - deployed on a server, info comes from superproject
# - if not found, its assumed to be a dev instance and shows git info



def deploy_info
  @deploy_info ||= begin
    YAML.safe_load(File.read('../config/deploy-info.yml'))
  rescue
  end
end

def releases_info
  @releases_info ||= YAML.safe_load(
    File.read('../config/releases.yml'))['releases']
end

def git_hash
  @git_hash ||= \
    if deploy_info then deploy_info['commit_id']
    else
      `git log -n1 --format='%h'`.chomp
    end
end

def version_from_archive
  return unless deploy_info.present?
  release = releases_info.first
  version = ['major', 'minor', 'patch']
    .map { |key| release.fetch("version_#{key}") }
    .join('.')
  pre = release['version_pre'].presence
  semver = (pre.nil? ? version : "v#{version}-#{pre}")
  return release
          .merge(deploy_info)
          .merge(version: semver, git_hash: git_hash)
          .symbolize_keys
end

def version_from_git
  return unless git_hash
  {
    version: "git",
    name: git_hash,
    info_url: "https://github.com/Madek/madek-webapp/commit/#{git_hash}"
  }
end

MADEK_VERSION = (version_from_archive || version_from_git).freeze
