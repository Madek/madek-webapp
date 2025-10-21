import React from 'react'

const MediaEntryPrivacyStatusIcon = ({ get }) => {
  const status = get.privacy_status
  const icon_map = {
    public: 'open',
    shared: 'group',
    private: 'private'
  }
  return <i className={`icon-privacy-${icon_map[status]}`} />
}

export default MediaEntryPrivacyStatusIcon
module.exports = MediaEntryPrivacyStatusIcon
