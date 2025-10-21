# React Modernization Plan

## Overview
- Total files: 219 React component files  
- createReactClass usage: 300 occurrences
- lodash usage: 192 occurrences
- React version: 16.14 (supports hooks)

## Strategy

### 1. createReactClass → Modern React
Convert in order of complexity:
1. **Functional components** - Pure render components without state
2. **Functional components with hooks** - Components with state but simple lifecycle  
3. **Class components** - Components with complex lifecycle methods

### 2. Lodash → Native JavaScript

Common replacements:
- `f.map(arr, fn)` → `arr.map(fn)`
- `f.get(obj, path, default)` → `obj?.path ?? default` or helper function
- `f.present(val)` → custom helper or inline check
- `f.isEmpty(val)` → `!val || Object.keys(val).length === 0` or Array.isArray check
- `f.includes(arr, val)` → `arr.includes(val)`
- `f.compact(arr)` → `arr.filter(Boolean)`
- `f.filter(arr, fn)` → `arr.filter(fn)`
- `f.merge(obj1, obj2)` → `{...obj1, ...obj2}` or Object.assign
- `f.omit(obj, keys)` → Object destructuring or custom helper
- `f.cloneDeep(obj)` → `structuredClone(obj)` or JSON.parse/stringify
- `f.flatten(arr)` → `arr.flat()`
- `f.kebabCase(str)` → custom helper or regex
- `l.isEqual(a, b)` → shallow compare or JSON.stringify for deep

### 3. Active-lodash specifics
- `f.present(val)` - checks if value is defined and not empty
- `f.presence(val)` - returns val if present, undefined otherwise

## Execution Order
1. UI components (buttons, icons, etc.) - simplest
2. Decorators without state
3. Decorators with state
4. Views and containers
5. Complex components with lifecycle

## Notes
- Keep changes minimal
- Test after each batch
- Create utility helpers for commonly repeated patterns
