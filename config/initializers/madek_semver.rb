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
  @releases_info ||= begin YAML.safe_load(
      File.read('../config/releases.yml'))['releases'].map do |rel|
        rel.merge(semver: semver(rel))
      end
    rescue Errno::ENOENT => e # ignore file errors
    end
end

def git_hash
  @git_hash ||= \
    if deploy_info then deploy_info['commit_id']
    else
      `git log -n1 --format='%h'`.chomp
    end
end

def semver(release_info)
  version = ['major', 'minor', 'patch']
    .map { |key| release_info.fetch("version_#{key}") }
    .join('.')
  pre = release_info['version_pre'].presence
  pre.nil? ? version : "v#{version}-#{pre}"
end

def version_from_archive
  return unless deploy_info.present?
  {
    type: 'archive',
    deploy_info: deploy_info,
    semver: releases_info.try(:first).try(:[], :semver)
  }
end

def version_from_git
  return unless git_hash
  {
    type: 'git',
    git_hash: git_hash,
    git_url: "https://ci.zhdk.ch/cider-ci/ui/workspace?git_ref=#{git_hash}"
  }
end

MADEK_VERSION = (version_from_archive || version_from_git)
  .merge(releases: releases_info.presence)
  .deep_symbolize_keys
  .freeze
