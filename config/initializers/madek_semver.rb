# some constants externalized so they can be accessed from outside of rails

# Semver: get semantic version as a parsed Hash.
#

# TODO: this should be removed from here to the super project
# pending since I don't know potential problems

def git_build_version
  `cd .. && git log -n1 --format='%T'`.strip[0,5].presence rescue nil
end

def archive_build_version
  IO.read("../tree_id").strip[0,5].presence rescue nil
end

def build_version
  git_build_version || archive_build_version || "UNKNOWN"
end

MADEK_SEMVER = YAML.safe_load(File.read('.release.yml'))['semver']\
                .merge(build: [build_version])
