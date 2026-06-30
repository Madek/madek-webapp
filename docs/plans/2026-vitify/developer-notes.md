# Vitify - report by developer

Initial prompt:

```md
# Create new build of server side bundle with Vite

There is an existing build with `watchify`: `npm run build:server`

Now a new (parallel) build should be created, based on Vite. The Vite build should create the same bundle, but with a different file name.
```

The agent implemented this straightforward, with one or two runtime errors he had to fix.

Without me explicitly specifying he chose an approach with zero code changes (though it implicitly follows from the requirement that the old build should continue to work).

After this I interactively prompted him to replace one script after another. There was only one failing spec in the process, which was costly to fix however.
