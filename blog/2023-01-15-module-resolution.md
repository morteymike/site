---
slug: ts-monorepo-module-resolution
title: Aliases and Module Resultion for a Typescript Monorepo
authors:
  name: Mike Morton
  title: Co-founder, CEO at socra, Inc.
  url: https://github.com/mortymike
  image_url: https://github.com/mortymike.png
tags: [typescript, monorepo, turborepo, next, nextjs, next.js, modules, module-resolution]
---

# Setting up Import Aliases in a TypeScript Monorepo

When working with a monorepo that uses TypeScript, it's common to have a complex directory structure with many different packages and applications. In order to keep your code organized and easy to navigate, it can be helpful to set up import aliases for your internal packages.

In this guide, we'll walk through the steps for setting up import aliases in a monorepo that uses TypeScript, Turborepo, and Next.js.

## Step 1: Update the `baseUrl` in `tsconfig.json`

The first step is to update the `baseUrl` in the `tsconfig.json` file located in `apps/my-app` to reference the project root. This will ensure that the compiler knows where to look for your internal packages.

```json
{
    "compilerOptions": {
        "baseUrl": "../../",
        ...
    },
}
```

## Step 2: Add the `paths` option in `tsconfig.json`

Next, add the `paths` option in the `tsconfig.json` file located in `apps/my-app`. This option allows you to create aliases for directories in your project, so that you can reference them using a shorter path.

```json
{
    ...
    "compilerOptions": {
        "baseUrl": "../../",
        "paths": {
            "@/components/": ["apps/my-app/src/components/"],
            "@/src/": ["apps/my-app/src/"],
            "@ui/": ["packages/ui/src/"],
        }
    },
}
```

In this example, we've created three aliases:
- `@/components/*`: points to the `src/components` directory located in `apps/my-app`
- `@/src/*`: points to the `src` directory located in `apps/my-app`
- `@ui/*`: points to the `src` directory located in `packages/ui`

## Step 3: Use the aliases in your code

With the `paths` option set up, you can now use the aliases in your code to import files from your internal packages.

```tsx
import { MyComponent } from '@/components/MyComponent';
import { MyModule } from '@ui/MyModule';
```

## Conclusion

Setting up import aliases in a monorepo can help to keep your code organized and easy to navigate. By following the steps outlined in this guide, you can set up import aliases for your internal packages using TypeScript, Turborepo, and Next.js.

It's important to note that the paths configurations may vary depending on the monorepo structure, so it is recommended to check the directory structure and adjust accordingly.