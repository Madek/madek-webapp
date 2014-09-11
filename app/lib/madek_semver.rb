module MadekSemver 
  def self.semver
    "#{Settings.release.version_major}.#{Settings.release.version_minor}.#{Settings.release.version_patch}" \
    + Settings.release.version_pre.to_s + Settings.release.version_build.to_s
  end
end
