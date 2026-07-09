eslint-docker
=============

[ESLint](https://github.com/eslint/eslint) Docker Image with [@eslint/js](https://github.com/eslint/eslint/tree/main/packages/js)

How to Use
----------

```console
docker container run --rm -v "$PWD":/work:ro ghcr.io/shakiyam/eslint .
```

`@eslint/js` is installed in the image and resolvable from your `eslint.config.js`:

```js
const js = require('@eslint/js');

module.exports = [
  js.configs.recommended
];
```

Author
------

[Shinichi Akiyama](https://github.com/shakiyam)

License
-------

[MIT License](https://opensource.org/licenses/MIT)
