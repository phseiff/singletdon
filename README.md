![Signletdon](header.png)

Singletdon is a fork of Mastodon (specifically of [this](https://github.com/Grawl/mastodon) fork) optimized for use in single-user instances for power users, who don't hesitate to dabble into code to fix something if something breaks.

It also comes with a docker-compose template (as well as instructions) for including pgadmin4 into your installation to edit your posts in the database after you made them.

## Is this maintained?

This is the fork that I use for my own single-user instance, [toot.phseiff.com](https://toot.phseiff.com/), so updates and changes will come as I need them.
I don't intend to implement features or broaden the scope of features based on requests, but I will still respond to issues with advice on how to fix them, and I am open for pull requests.

Note that this fork aims to remove restrictions that Mastodon usually imposes, including those to protect them from messing up their own instance (e.g. by making unreasonable long toots, using too much cluttering formatting, etc.), since it assumes that every user of the instance has the competence expected from an admin.

You will also have to fork this repository and replace all instances of `phseiff` in its codebase with your own username, since it currently hard codes the username.

## Why would I even make a single user instance?

* Pros of single user instances, compared to making an account on another instance:
  * Ability to style ones account with CSS ([example](https://toot.phseif.com/@phseiff))
  * ones data in ones own hands
  * full control over the instance blocklist
  * ones own custom emojis
  * Ability to [edit toots in the data base](#how-to-edit-the-database) (I made good experiences with pgadmin4 for that; instructions later on)
  * No character limit (when using singletdon)
  * More cusomizations when using singletdon (see below)
  
* Cons of single user instances:
  * You probably won't federate as far
  * Even if you do, noone will see your posts if they only use the local timeline (this problem is also present in small non-single-user instances).

## Features / Changes:

This is a list of things that differ between this fork and normal mastodon.

Not all of these are implemented yet, and I will implement new ones whenever I need them (and some probably never), but please feel free to create a pul request for any of them (and raise an issue beforehand so I know someone is already working on them)!

I marked implemented features with ✅, and not-yet-implemented ones with 🚩, for your convenience.

* ✅ **Configurable character limit**:

  You can increase your toot character limit to any number in `.env.production` (feature by @Graz, from whose fork this is forked).
  
* ✅ **Markdown formatting in Toots**:

  You can use markdown formatting (bulletpoint lists, inline code, underline, bold, cursive, links)

  ToDo:
  * only markdown links (the ones with a custom description text) should federate to other instances, since the other formatting instructions (bold, cursive, bulletpoint lists) aren't interpreted correctly and should better be left un-rendered for the view on other instances.

* ✅ **Use multiple paragraphs in your instance description (the one displayed on your public profile beneath your account description)**:

  ToDo: Support full formatting like in toots, when it's displayed on the website frontend.

* ✅ **Up to 10 profile metadata fields (rather than the usual 5)**:

  You could potentially increase this by going through my commits and looking for the one where I changed something from 5 to 10; shouldn't be hard to locate and change this.

* ✅ **Clicking on a hashtag on your instances account's frontend** leads to `yourinstanceaddress/@yourusername/tagged/hashtag` rather than `yourinstanceaddress/tags/hashtag`, which filters YOUR posts by the hashtag rather than showing all posts of any federated instances with this hashtag.

  ❗ This currently only works if your username is `phseiff` (which it naturally isn't, lol), so you will need to search the code for a mention of `phseiff` with something along the lines of `tag` near it, and change that.

* 🚩 **There are some more things noted in issues in this repository** (but I also use these issues for things related to my own mastodon instance specifically), and I will transcript these into the README once I find time and motivation to do so.

Feel free to make pull requests for things I noted I plan in the future, or ask if it's okay to make one for a different feature!

## How to edit the Database

Here are some tips on how to edit your toots in your instance's database if you use a single-user instance, using self-hosted pgadmin4.

I run mastodon with `docker-compose` and traefik, and I added a `PgAdmin4` container to it that connects to my database.<br/>
I just have to access it, connect to the data base (the host name is `db`, the port is `5432`, and the username is `postgres`), log in with the login data specified in the docker compose file, and I can then modify my posts using the following query and modifying the fields in the table it gives me:

```mysql
SELECT * FROM public.statuses
WHERE (url like '/users/[myusername]/%'
AND text like '&[search term%]') -- <- in case you are looking for a specific toot
ORDER BY id ASC LIMIT 100;  -- <- not really needed unless you have many toots
```

I also recommend making a quick backup beforehand, just to be sure;
if you use the same `docker-compose` file as I, you can do this via

```bash
docker exec -t mastodon_db_1 pg_dump -Fc -U postgres -f '/export.dump'
docker cp mastodon_db_1:/export.dump /home/[yourusername]/export.dump
```

The docker-compsoe file I use for this has the following content:

```dockerfile
version: '3'
services:

  db:
    restart: always
    image: postgres:9.6-alpine
    networks:
      - internal_network
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
    volumes:
      - ./postgres:/var/lib/postgresql/data
    environment:
      POSTGRES_HOST_AUTH_METHOD: trust

  pgadmin:
    restart: always
    image: dpage/pgadmin4
    ports:
      - "5050:80"
    depends_on:
      - db
    networks:
      - web
      - internal_network
    volumes:
      - ./pgadmin/pgadmin4.db:/pgadmin/config/pgadmin4.db
      - ./pgadmin/storage:/pgadmin/storage/
      - ./pgadmin/pgadmin:/var/lib/pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: "[youremailaddress]]"
      PGADMIN_DEFAULT_PASSWORD: [yoursafepassword]
    labels:
      # if you leave this out and run mastodon on your PC, you can access the interface with localhost:5050.
      - "traefik.enable=true"
      - "traefik.backend=mastodon-pgadmin"
      - "traefik.frontend.rule=Host:[your postgres frontend url]"
      - "traefik.port=80"
      - "traefik.docker.network=web"
      - "traefik.frontend.headers.SSLRedirect=true"
      - "traefik.frontend.headers.STSSeconds=315360000"
      - "traefik.frontend.headers.browserXSSFilter=true"
      - "traefik.frontend.headers.contentTypeNosniff=true"
      - "traefik.frontend.headers.forceSTSHeader=true"
      - "traefik.frontend.headers.SSLHost=[your postgres frontend url]"
      - "traefik.frontend.headers.STSIncludeSubdomains=true"
      - "traefik.frontend.headers.STSPreload=true"
      - "traefik.frontend.headers.frameDeny=true"

  redis:
    restart: always
    image: redis:5.0-alpine
    networks:
      - internal_network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
    volumes:
      - ./redis:/data

  web:
    build: .
    image: tootsuite/mastodon
    restart: always
    env_file: .env.production
    command: bash -c "rm -f /mastodon/tmp/pids/server.pid; bundle exec rails s -p 3000"
    networks:
      - web
      - internal_network
    healthcheck:
      test: ["CMD-SHELL", "wget -q --spider --proxy=off localhost:3000/health || exit 1"]
    depends_on:
      - db
      - redis
#      - es
    volumes:
      - ./public/system:/mastodon/public/system
    labels:
      - "traefik.enable=true"
      - "traefik.backend=mastodon-web"
      - "traefik.frontend.rule=Host:[yourinstanceurl]"
      - "traefik.port=3000"
      - "traefik.docker.network=web"
      - "traefik.frontend.headers.SSLRedirect=true"
      - "traefik.frontend.headers.STSSeconds=315360000"
      - "traefik.frontend.headers.browserXSSFilter=true"
      - "traefik.frontend.headers.contentTypeNosniff=true"
      - "traefik.frontend.headers.forceSTSHeader=true"
      - "traefik.frontend.headers.SSLHost=[yourinstanceurl]"
      - "traefik.frontend.headers.STSIncludeSubdomains=true"
      - "traefik.frontend.headers.STSPreload=true"
      - "traefik.frontend.headers.frameDeny=true"

  streaming:
    build: .
    image: tootsuite/mastodon
    restart: always
    env_file: .env.production
    command: node ./streaming
    networks:
      - web
      - internal_network
    healthcheck:
      test: ["CMD-SHELL", "wget -q --spider --proxy=off localhost:4000/api/v1/streaming/health || exit 1"]
    depends_on:
      - db
      - redis
    labels:
      - "traefik.enable=true"
      - "traefik.backend=mastodon-streaming"
      - "traefik.frontend.rule=(Host(`[yourinstanceurl]`) && PathPrefix(`/api/v1/streaming`))"
      - "traefik.port=4000"
      - "traefik.docker.network=web"

  sidekiq:
    build: .
    image: tootsuite/mastodon
    restart: always
    env_file: .env.production
    command: bundle exec sidekiq
    depends_on:
      - db
      - redis
    networks:
      - web
      - internal_network
    volumes:
      - ./public/system:/mastodon/public/system
## Uncomment to enable federation with tor instances along with adding the following ENV variables
## http_proxy=http://privoxy:8118
## ALLOW_ACCESS_TO_HIDDEN_SERVICE=true
#  tor:
#    image: sirboops/tor
#    networks:
#      - external_network
#      - internal_network
#
#  privoxy:
#    image: sirboops/privoxy
#    volumes:
#      - ./priv-config:/opt/config
#    networks:
#      - external_network
#      - internal_network

networks:
  web:
    external: true
  internal_network:
    external: false

```

❗ I can not guarantee that this will not do irreparable damage to your mastodon instance and database; use at your own discretion.

ALso note that changes you apply to your posts won't federate to other instances;
so you can only use this to edit what's shown in your public profile when someone views it on your instance rather than their own.
