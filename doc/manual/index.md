The [Manual](#) aims to be a complete description of the (non-standard, non-obvious)
business logic of the application.

See menu for large sub-sections, below is some yet-unsorted stuff.

## Branches

- `master`: on production
- `staging`: on staging
- `next`: collect for staging
- *(currently):* `madek-v3`: "next" and "staging" for v3

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
