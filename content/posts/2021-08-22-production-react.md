---
layout: post
title: "React environment variables in an nginx container"
draft: false
slug: "react-build"
date: "2021-08-21 22:05:15"
lastmod: "2021-10-05 14:48:10"
comments: false
categories:
    - react
tags:
    - webdev
    - react
    - containers
    - k8s
---

Your React app is ready to ship. Congratulations!

Packaging for production is (and should) be different from your development configuration.

In the case of [Create React App](https://create-react-app.dev/) the toolchain is rich, includes development productivity conveniences such as hot reloading, source maps and [custom environment variables](https://create-react-app.dev/docs/adding-custom-environment-variables/).

This toolchain is mind blowingly productive as you develop the app, `npm start` and watch the magic unfold.

At this point, its possible to put the React app one big (~1.7GB) happy container:

```dockerfile
FROM node:latest
WORKDIR /
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
EXPOSE 3000
CMD [ "npm", "start" ]
```

Why ship the complete development toolchain (such as webpack, eslint, babeljs) and all the source code out to customers in a production build?

Its time to put the runtime container on a diet.

_Create React App_ provides an `npm task` for this very purpose called `build`. It instructs `node` and `webpack` to prepare a production bundle.

The output of `build` is a big ball of minified, tree shaken, optimised, transpiled JS, CSS and HTML. Not intended for human consumption, but perfect for serving up as static assets. Pick your favourite `httpd` such as `nginx:alpine`:

```dockerfile
FROM node:latest as build
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /usr/src/app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

It turns out the `nginx:alpine` container image is WAY WAY faster, and WAY WAY WAY (98.5%) smaller at 27MB.

However, one _disappointing_ trade-off is that support for managing custom [environment variables](https://create-react-app.dev/docs/adding-custom-environment-variables/) drops off, with the loss of the development toolchain.

The documentation highlights this:

> The environment variables are embedded during the build time. Since Create React App produces a static HTML/CSS/JS bundle, it can’t possibly read them at runtime. To read them at runtime, you would need to load HTML into memory on the server and replace placeholders in runtime, as [described here](https://create-react-app.dev/docs/title-and-meta-tags/#injecting-data-from-the-server-into-the-page). Alternatively you can rebuild the app on the server anytime you change them.

In a nutshell this suggests using global `window` variables in the base page, and replacing placeholders at runtime. For example:

```html
<!DOCTYPE html>
<html lang="en">
    <head>
        <script>
            window.API_URI = "$API_URI";
            window.CONFLUENCE_URI = "$CONFLUENCE_URI";
            window.INTRANET_URI = "$INTRANET_URI";

            // for local development only - this wont affect production builds
            if (window.API_URI.includes("API_URI")) {
                window.API_URI = "http://localhost:5000/api";
            }
        </script>
    </head>
</html>
```

Given this is running from a spartan `alpine` base image, I opted to _live off the land_ and use `sed` to do this *find and replace* work. Using the `-e` switch `sed` can read env vars:

```bash
#!/bin/sh

# Substitute container environment into production packaged react app
# CRA does have some support for managing .env files, but not as an `npm build` output

# To test:
# docker run --rm -e API_URI=http://localhost:5000/api -e CONFLUENCE_URI=https://confluence.evilcorp.org -e INTRANET_URI=https://intranet.evilcorp.org -it -p 3000:80/tcp dam-frontend:latest

cp -f /usr/share/nginx/html/index.html /tmp

if [ -n "$API_URI" ]; then
sed -i -e "s|REPLACE_API_URI|$API_URI|g" /tmp/index.html
fi

if [ -n "$CONFLUENCE_URI" ]; then
sed -i -e "s|REPLACE_CONFLUENCE_URI|$CONFLUENCE_URI|g" /tmp/index.html
fi

if [ -n "$INTRANET_URI" ]; then
sed -i -e "s|REPLACE_INTRANET_URI|$INTRANET_URI|g" /tmp/index.html
fi

cat /tmp/index.html > /usr/share/nginx/html/index.html
```

Finally its simply a matter of invoking this shell script `set-env.sh` as part of the `CMD` directive in the `Dockerfile`, like so:

```dockerfile
FROM node:latest as build
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN npm run build

FROM nginxinc:nginx-unprivileged:alpine
COPY --from=build /usr/src/app/build /usr/share/nginx/html
EXPOSE 8080
CMD ["sh", "-c", "cd /usr/share/nginx/html/ && ./set-env.sh && nginx -g 'daemon off;'"]
```

To get `set-env.sh` in the container, I lazily put the `set-env.sh` script into the `public` folder within the React source tree. `npm run build` automatically puts all assets in `public` into the output build directory. You could of course run a second `COPY` directive in the `Dockerfile`. Your choice.
