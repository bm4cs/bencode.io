---
layout: post
title: "Production React in an NGINX container"
draft: false
slug: "react-build"
date: "2021-08-21 22:05:15"
lastmod: "2021-08-28 16:40:39"
comments: false
categories:
    - react
tags:
    - webdev
    - react
    - containers
---

Your React app is ready to ship. Congratulations!

Packaging for production is (and should) be different from your development configuration.

In the case of [Create React App](https://create-react-app.dev/) the toolchain is rich, includes development productivity conveniences such as hot reloading, source maps and [custom environment variables](https://create-react-app.dev/docs/adding-custom-environment-variables/).

This is truly wonderful as you develop the app, `npm start` and watch the magic unfold.

At this point, its possible to put all this in one big happy container:

```dockerfile
FROM node:latest
WORKDIR /
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
EXPOSE 3000
CMD [ "npm", "start" ]
```

But damn, that is going to be a heavy container. Expect a weigh in of about 1.7GB. The real question...Why ship the complete development toolchain (such as webpack, eslint, babeljs) and all the source code out to customers in a production build.

Its time to lean the build down.

CRA provides an `npm task` for this very purpose called `build`. It instructs node and webpack to prepare a production bundle.

The output of `build` is a mess of minimified, tree shaken, optimised, transpiled ball of JS/CSS/HTML. Not intended for human consumption. But the cool thing at this point is these can now be served as static assets. Pick your favourite web server running on an alpine image, such as `nginx:alpine`:

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

In testing, my docker image weighed in at a lean 27MB (in contrast to the ~1700MB of the node based container).

One _disappointing_ side effect, is support for managing custom [environment variables](https://create-react-app.dev/docs/adding-custom-environment-variables/) goes away, with the loss of the development toolchain.

> The environment variables are embedded during the build time. Since Create React App produces a static HTML/CSS/JS bundle, it can’t possibly read them at runtime. To read them at runtime, you would need to load HTML into memory on the server and replace placeholders in runtime, as [described here](https://create-react-app.dev/docs/title-and-meta-tags/#injecting-data-from-the-server-into-the-page). Alternatively you can rebuild the app on the server anytime you change them.

This suggests injecting global variables in the page as follows, and using a process on the server to substitute them with corresponding environment:

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

Given this is running in a spartan `alpine` base image, I opted to go with a tiny shell script using classical UNIX tools such as `sed`:

```bash
#!/bin/sh

# Substitute container environment into production packaged react app
# CRA does have some support for managing .env files, but not when built

originalfile="index.html"
tmpfile=$(mktemp)
cp $originalfile $tmpfile
cat $originalfile | envsubst | tee $tmpfile &&  mv $tmpfile $originalfile
```

Here I stumbled upon the nifty `envsubst`. This little program will read a file and replace `$VARIABLE_NAME` formatted text, with actual environment variable value, if such a variable exists. It wont overwrite an existing file, hence the `tee` business.

I will probably change this over to a neater `sed` implementation, which supports in place edits and environment variables, something along the lines of this:

```bash
#!/bin/sh

if [[ -v API_URI]]; then
sed -i -e "s|REPLACE_API_URI|$API_URI|g" index.html
fi

if [[ -v CONFLUENCE_URI]]; then
sed -i -e "s|REPLACE_CONFLUENCE_URI|$CONFLUENCE_URI|g" index.html
fi

if [[ -v INTRANET_URI]]; then
sed -i -e "s|REPLACE_INTRANET_URI|$INTRANET_URI|g" index.html
fi
```

Finally, its just a matter of invoking this little script which I called `set-env.sh`, just prior to launching the `nginx` daemon process.

I decided to do this in the `CMD` directive in the `Dockerfile`, like so:

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

To get it in the container, I lazily put the `set-env.sh` script into the `public` folder within the react source tree. `npm run build` automatically puts all assets in `public` into the output build directory. You could of course run a second `COPY` directive in the `Dockerfile`. Your choice.