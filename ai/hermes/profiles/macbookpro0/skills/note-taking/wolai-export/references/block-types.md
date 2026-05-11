# Wolai Block Types Quick Reference

## Block types seen in `get_page_blocks` output

```
type        | markdown             | notes
------------|----------------------|---------------------------------------------
heading     | #/##/### title       | level=1/2/3; children.ids = sub-blocks
text        | inline content       | most common; rich text in content[]
code        | ```lang\ncode\n```   | language field present
bookmark    | > [title](url)       | bookmark_source + bookmark_info.title/desc
callout     | > icon content       | icon field (font_awesome)
bull_list   | - content            | bulleted list item
enum_list   | 1. content           | numbered list item
todo_list   | - [x] content        | checked boolean
image       | ![image](url)        | media.download_url (expires!)
divider     | ---                  | horizontal rule
quote       | > content            | blockquote
toggle_list | <details>...</details> | collapsible section
block_equation | $$ LaTeX $$       | display math
simple_table | table markdown      | table_content: [[col1, col2], ...]
page        | (separate file)      | marks a sub-page boundary
```

## Rich text content[] item fields

```
title: str        -- text content
type: "text"|"bi_link"|"equation"
bold: bool
italic: bool
underline: bool
strikethrough: bool
inline_code: bool
link: str         -- external URL (for type="text")
ref_id: str       -- target workspace (for type="bi_link")
block_id: str     -- target page/block ID (for type="bi_link")
```

## Export structure convention

Based on `raw/tools-export/`:

```
RootName.md                          ← # title, ## 目录, child links
SubName/SubName.md                   ← folder = slug, file = same name
SubName/GrandChild/GrandChild.md     ← deeper nesting, same pattern
SubName/image/image_xxx.png          ← images in parent folder
```

Key patterns:
- Child links: `[Title](Child/Child.md "Title")`
- External links: `[text](url "text")` (title repeated as tooltip)
- Spaces in folder names: `<Folder Name/Folder Name.md>`
- H1 for page title AND section headings (both use `#`)
- Each heading section has a TOC entry at top

## Common pitfalls

1. **Flat block list**: blocks are depth-first order, use children.ids for nesting
2. **Image URLs expire**: download immediately (expires_in: 1800s typical)
3. **Sub-pages need separate fetch**: get_page_blocks is 1-level deep
4. **bi_link references**: may point to other workspaces
5. **Empty blocks**: can appear (id-only, content=[])
