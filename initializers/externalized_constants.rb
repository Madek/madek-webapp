# some constants externalized so they can be accessed from outside of rails

# Semver: get semantic version as a parsed Hash.
MADEK_SEMVER = YAML.safe_load(File.read('.release.yml'))['semver']\
                .merge(build: ["g#{`git log -n1 --format='%h'`}".gsub(/\n/, '')])
