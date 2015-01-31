**Views**, 
aka "Frontend"
aka "the Website"
aka "the Application", since this is how Madek is exposed to the end user.

The following is 1 Chapter per view, with 1 sub-section per action (`index`, `show`, etc for resources and custom ones )

(when in doubt where an URL goes, see [`routes.rb`](http://github.com/zhdk/madek/blob/master/config/routes.rb))


# `/` (application#root)

The "home page" (no sub-sections, obviously).

Non-resourceful.

**Content:**
- Login Form

# `my`

The user's "My Archive" section.

Non-resourceful.

**Content:**
- Latest (sorted by updated_at)
    - MediaEntries
    - Collections
    - FilterSets
- LatestImported (sorted by created_at)
    - MediaEntries
- Favorite
    - MediaEntries
    - Collections
    - FilterSets
