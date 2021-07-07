![Signletdon](header.png)

Singletdon is a fork of Mastodon (specifically of [this](https://github.com/Grawl/mastodon) fork) optimized for use in single-user instances for power users, who don't hesitate to dabble into code to fix something if something breaks.

## Is this maintained?

This is the fork that I use for my own single-user instance, [toot.phseiff.com](https://toot.phseiff.com/), so updates and changes will come as I need them.
I don't intend to implement features or broaden the scope of features based on requests, but I will still respond to issues with advice on how to fix them, and I am open for pull requests.

Note that this fork aims to remove restrictions that Mastodon usually imposes, including those to protect them from messing up their own instance (e.g. by making unreasonable long toots, using too much cluttering formatting, etc.), since it assumes that every user of the instance has the competence expected from ana dmin.

## Why would I even make a single user instance?

* Pros of single user instances, compared to making an account on another instance:
  * Ability to style ones account with CSS ([example](https://toot.phseif.com/@phseiff))
  * ones data in ones own hands
  * full control over the instance blocklist
  * ones own custom emojis
  * Ability to edit toots in the data base
  * No character limit (when using singletdon)
  * More cusomizations when using singletdon (see below)
  
* Cons of single user instances:
  * You probably won't federate as far
  * Even if you do, noone will see your posts if they only use the local timeline (this problem is also present in small non-single-user instances).

### Features / Changes:

This is a list of things that differ between this fork and normal mastodon.

Not all of these are implemented yet, and I will implement new ones whenever I need them (and some probably never), but please feel free to create a pul request for any of them (and raise an issue beforehand so I know someone is already working on them)!

I marked implemented features with ✅, and not-yet-implemented ones with 🚩, for your convenience.
