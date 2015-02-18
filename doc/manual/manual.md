The [Manual](#) aims to be a complete description of the (non-standard, non-obvious)
business logic of the application.

See menu for sub-sections.

Below is the designated area for some yet-unsorted stuff,
should be cleaned up before a release.

---

## Featurescape

[in PDF Form here](manual/Featurescape_2.pdf)

(Maintained by S. Schumacher)

---

## Branches

- `master`: on production
- `staging`: on staging
- `next`: collect for staging
- *(currently):* `madek-v3`: "next" and "staging" for v3

---

# External Contributors

(for non-technical staff the same process applies)

- Contributions from external people can be send via pull requests
- Because of our workflow regarding git and continuous testing,
  we can't use the big green merge button


## How to merge

```bash
# edit this to match the situation:
TARGET='madek-v3'
USER_SHORT='cw'
USER_GITHUB='niknoilich'

cd madek
git checkout -b ${USER_SHORT}_${TARGET} ${TARGET}
git pull https://github.com/${USER_GITHUB}/madek.git ${TARGET}
# should had no conflicts
git push --set-upstream origin ${USER_SHORT}_${TARGET}
# test in CI, if success:
git checkout ${TARGET}
git merge ${USER_SHORT}_${TARGET}
git push origin ${TARGET}
```

---

# "Entrusted Resources"

A Resource is "entrusted" to a User if they have "view" Permissions on the
Resource, either directly or via their membership in a Group.
Therefore, a Resource with "view" Permissions for "Public" can
never be "entrusted" because it is already public.

# "Privacy Status"

- `public`: "Public" has "view" Permission
- `private`: No Person or Group has "view" Permission
- `shared`:
    - if User is the owner and any Person or Group has "view" Permission
    - if User is not the owner and has "view" Permission
      (directly or via Group membership)
