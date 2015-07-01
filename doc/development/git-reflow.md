# Git Workflow

Work in Progress.  

NOTE: A very similar process is
[Gitlab Flow](http://doc.gitlab.com/ee/workflow/gitlab_flow.html).

This guide focuses on the concrete steps/commands a developer has to do,
and breaking it down into small concrete steps.

<mark>TODO: init, release flow</mark>


## Config

First of all: Avoid non-fast-forward (aka ugly) merges:

```bash
cd /path/to/repo
git config --local merge.ff only
# or set it for all repos on this system:
git config --global merge.ff only
```

This Guide uses Shell Variables to make the examples more readable and runnable (if you define them correctly).

```bash
nn='nn'         # your initials
origin='origin' # name of git remote
next='next'     # name of targeted "next" branch
```

## Branches

### Integration Branches

- `master`
- `next`
- `madek-v3` (considered `next` for Version 3.0, which has no `master` yet)

They must only be merged fast-forward and should never be force-pushed.

### Personal Branches

```bash
personal_branch="${nn}_${next}_ticket-name_42"
```

Any branch that starts with the initials of a developer.
Must not be merged by other developers without coordinating with the owner.

They target a specific `next` branch, which comes after the initials.
They must be rebased regularly against their target:

```bash
git fetch
# step can be used to clean up the branch
git rebase --interactive --autosquash $origin/$next
# update origin - by force because rebasing
git push --force $origin $personal_branch
```

***Pro-Tips***:

- Use [`fixup!` etc in commit messages](http://git-scm.com/docs/git-rebase).
- Only re-order history if you are sure there are no conflicts
  (i.e. if a file was only changed in one commit, it can be moved freely in the "timeline").

*Examples:*

- Simplest form is a "private next",
as a staging area for merges, linting, CI, ….  
  `private_next=nn_next`

- It might also relate to a feature or directly to a ticket  
  `nn_next_fix-the-buggy-bug`

- Special case: **hotfixes**.  
They differ in their target (`master` instead of `next`)
and are a short-lived exception and all the rules don't really apply
since the goal is to deploy the fix as fast as possible.  
  `master_hotfix_restore-authentication`

### Feature Branches

```bash
feature_branch="${next}_feature-name"
```

A Branch must be a Feature Branch if it has one of the following properties:
- several people are working on it
- work done in it will be merged into `next` as more than one commit
- work on it will take more than one iteration

It has a (preferably short) name, which starts with the `$next`.
*Example:* `next_shave-yak`

Commits are "collected" in it while working on
one or more features and/or tickets.
Before merging it into `$next`, it is cleaned up either by
interactive rebasing (selective squash, reword, fixup) or by one or more
squash-merges intro `$private_next`.

## Example Workflows

### Collaborating

When collaborating, rebasing/updating origin must only be done
if all people working on it are in direct contact
and are prepared to throw away their current version of the branch.

```bash
# 1. This is done by everyone:
git stash -m "saving work before resetting ${feature_branch}"
# 2. One developer does a rebase just like with a personal branch.
# 3. Then, everyone else:
git fetch
git reset --hard $origin $feature_branch
git stash pop
```

When the work is done, one developer is designated and integrates it
like a personal branch.

### Integrating "extra" commits from feature branches

Sometimes unrelated work or urgent fixes ends up in Personal or Feature branches.
This is how to integrate them into `$next` without headaches:

```bash
git checkout $private_next
git cherry-pick $commit
git push $origin $private_next
# Run tests. Amend fixes if necessary. If all is green continue.
git checkout $next
git merge $private_next
git push $origin $next
# Now rebase your own feature branch.
# If YOU DID NOT AMEND any fixes, the commit will just move to the bottom.
# OTHERWISE: manually remove the commit in interactive mode (vim: `dd`)
git rebase --interactive $origin/$next
```
