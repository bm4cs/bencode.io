---
layout: post
draft: false
title: "Vue and TypeScript"
slug: "vue"
date: "2023-05-24 20:45:36+11:00"
lastmod: "2023-05-24 20:45:36+11:00"
comments: false
categories:
  - webdev
tags:
  - vue
  - vuejs
  - typescript
  - web
  - frontend
  - javascript
---

## Learn you a TypeScript for better Vue

Instruct Vue on the component to use TypeScript and type up the `export default` by wrapping it in `defineComponent()`

```html
<script lang="ts">
    import { defineComponent } from 'vue'
    import type { PropType } from 'vue'

    type Restaurant = {
        id: string
        name: string
        address: string
        website: string
        status: string
    }

    export default defineComponent({
        props: {
            restaurant: {
                type: Object as PropType<Restaurant>
            }
        }
    })
  ...
```

What if other component need to share and use the types, such as the `Restaurant` type?

Put the into a dedicated types file e.g. `types.ts` that can be imported:

```typescript
export type Restaurant = {
  id: string;
  name: string;
  address: string;
  website: string;
  status: string;
};
```

Import it on the components needed:

```javascript
import type { Restaurant } from "@/types";
```
