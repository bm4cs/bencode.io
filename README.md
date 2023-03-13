# Yet Another Hugo Site (YAHS)

My [hugo](https://gohugo.io/) static site, for software development related thoughts and content available at <https://www.bencode.net>

## favicon

Can never remember this.

1. First read [this](https://stackoverflow.com/questions/48956465/favicon-standard-2022-svg-ico-png-and-dimensions#48969053)
2. Upload high resolution PNG you want to use into <https://realfavicongenerator.net/>
3. Generate emoji based favicon using [favicon.io](https://favicon.io/emoji-favicons/carpentry-saw)
4. Combine the outputs, first with the higher resolution versions for large formats, replacing low resolution formats (32x32 and lower) with the emoji based versions
5. Inject the below `head` section into the hugo theme partial (i.e. `~/bencode.net/themes/terminal/layouts/partials/head.html`)
6. Rebuild the theme with npm/yarn (also described below)

```html
<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
<link rel="manifest" href="/site.webmanifest">
<link rel="mask-icon" href="/safari-pinned-tab.svg" color="#5bbad5">
<meta name="msapplication-TileColor" content="#da532c">
<meta name="theme-color" content="#ffffff">
```

## Theme customisation

Uses the mint [terminal](https://hugo-terminal.vercel.app/) theme by [Radek Kozieł](https://github.com/panr).

### Post sort order

Edit `layouts/_default/index.html` sort posts by lastmod descending with `$paginator := .Paginate (where $PageContext.RegularPages.ByLastmod.Reverse "Type" $contentTypeName)`

### Simplify post summaries in the main list view

Rip out all content in `layouts/_default/index.html` except the title, and the last modified date of the post in `January 2021` format.

Should end up with something similar to:

```
{{ define "main" }}
  {{ if .Content }}
    <div class="index-content {{ if .Params.framed -}}framed{{- end -}}">
      {{ .Content }}
    </div>
  {{ end }}
  <div class="posts">
    {{ $isntDefault := not (or (eq (trim $.Site.Params.contentTypeName " ") "posts") (eq (trim $.Site.Params.contentTypeName " ") "")) }}
    {{ $contentTypeName := cond $isntDefault (string $.Site.Params.contentTypeName) "posts" }}

    {{ $PageContext := . }}
    {{ if .IsHome }}
      {{ $PageContext = .Site }}
    {{ end }}
    {{ $paginator := .Paginate (where $PageContext.RegularPages.ByLastmod.Reverse "Type" $contentTypeName) }}

    {{ range $paginator.Pages }}
      <div class="post on-list">
        <h1 class="post-title">
          <a href="{{ .Permalink }}">{{ .Title | markdownify }}</a>
        </h1>
        <div class="post-meta">
          <span class="post-date">
            {{ .Lastmod.Format "January 2006" }}
          </span>
        </div>
      </div>
    {{ end }}
    {{ partial "pagination.html" . }}
  </div>
{{ end }}
```

### Padding tweaks now leaner post summaries

In `assets/css/main.css` patch `..headings--one-size` setting the `margin-top` to `0`.

### Rebuild the theme

A node toolchain is needed to proceed. Install dependencies and build:

```
cd themes/terminal
npm install
npm install yarn
yarn build
```
