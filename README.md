# Yet Another Hugo Site (YAHS)

My [hugo](https://gohugo.io/) static site, for software development related thoughts and content, available at <https://www.bencode.net>

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
