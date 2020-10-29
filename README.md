# ijl20.github.io

This is a trial using the GitHub Pages built-in support for Jekyll templating, which means we can
embed the group content into a formatted 'standard' Cambridge web page.

E.g. The Systems Group homepage is in `/index.html`, which is embedded into the `{{ content }}` piece of
the `_layouts/default.html` template.

We are also able to use the simple interative embedding capability of the Jekyll templating to allow
a file-per-person for the `people` page content, i.e. the markup for Ian Lewis is contained entirely in
the `_people\ijl20.md` file.

## Updating

You need a `github.com` account and be added to this repo. Then you edit the content the same as you
would any repo, either directly on GitHub or via `git clone https://github.com/ijl20.github.io`.

If you [install Jekyll](https://jekyllrb.com/docs/installation/), then you can view the site
locally before you push it back up to GitHub.

This approach is intentionally *permissive*. Git is a versioning control system and all updates are
tagged with the updater, so we can roll back if necessary and humiliate delinquent updaters.

Our template design ensures the majority of updates are to individual files unique to the person
or project involved.

It make take ~5 minutes for a change to appear on the interwebs, but usually much less.

## Adding a Person

Place a suitable portrait in the `/images/` directory and reference it as in the example below.

Create a `_people/<name>.md` file (any name will do, but crsid would help), containing e.g.:

```
---
name: Professor Mort
office: FN17
phone: (3)34419
image: /images/mort.jpg
---

Richard Mortier returned to the Computer Laboratory in 2015, having spent time at Sprint ATL,
Microsoft Research, Vipadia Limited and Horizon Digital Economy Research at the University
of Nottingham. He is now Reader in Computing & Human-Data Interaction, interested in the
intersection of systems and HCI.
```

## Directory structure

### `_layouts/`

Contains Jekyll templates, e.g. see `_layouts/default.html` for the Cambridge 'Project Light' page template

### `style/`

Contains css files, plus the `ucampas` Project Light style collection.
