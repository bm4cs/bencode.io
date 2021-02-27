Hugo based blog.

# Theme

Uses the [terminal](https://github.com/panr/hugo-theme-terminal#how-to-edit) theme.

Customisation:

1. Edit `layouts/_default/index.html` sort by lastmod desc with `$paginator := .Paginate (where $PageContext.RegularPages.ByLastmod.Reverse "Type" $contentTypeName)`
2. Also rip out all content in the layout bar the title.
3. In `assets/css/main.css` patch `..headings--one-size` setting the `margin-top` to `0`.
