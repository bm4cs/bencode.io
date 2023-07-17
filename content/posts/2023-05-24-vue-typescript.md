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

### Props

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


### Data

Now we have a type definition, can strongly type the data definition e.g. a `DataShape` type:

```html
<script lang="ts">
import type { Restaurant } from "@/types";

type DataShape = {
  filterText: string
  restaurantList: Restaurant[]
  showNewForm: boolean
}

export default defineComponent({
  data: (): DataShape => ({
    filterText: '',
    restaurantList: [
      {
        id: 'd22d1ddf-992e-4111-b489-31a08ecb74c4',
        name: 'Bread n Butter',
        address: '46 Thistle Place'
      }
    ]
  })
})
</script>
```

### Computed properties and methods

Computed properties are normally return heavy, type them up:

```javascript
computed: {
  filteredRestaurantList(): Restaurant[] {
    return this.restaurantList.filter((r) => {
      if (r.name) {
        return r.name.toLowerCase().includes(this.filterText.toLowerCase())
      }
      else {
        return this.restaurantList
      }
    })
  },
  numberOfRestaurants(): number {
    return this.restaurantList.length
  }
}
```

Methods generally take in data e.g. an event handler that takes in a classic `payload` argument. Type up all teh things:

```javascript
methods: {
  addRestaurant(payload: Restaurant) {
    this.restaurantList.push(payload)
    this.hideForm()
  }
}
```