# TODO

## pdp 0.8.0

- [X] Make `get_training_data()` more robust. See [this issue](https://github.com/bgreenwell/pdp/issues/90) for an example.

- [X] Implement fast (approximate) marginal effect plots. See [this issue](https://github.com/bgreenwell/pdp/issues/91) for a possible solution.

- ~~[ ] Add `in.memory` option for fast construction of PDPs/ICE curves. see [this issue](https://github.com/bgreenwell/pdp/issues/98) for details.~~
  * Does not seem to provide any meaningful reduction in computation time; in fact, in some cases, this approach is actually slower.
  * Focus more on parallel execution!
  
- Better support for **h2o** models.

- [X] Switch to **tinytest** framework.

- [ ] Increase test coverage to >90%.

- [X] Add **parsnip** support.
