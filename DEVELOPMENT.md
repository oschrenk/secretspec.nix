# Development

## Requirements

- [nix](https://nixos.org/) provides the dev shell, the checks, and the formatter
- [direnv](https://direnv.net/) is optional, and loads the dev shell on `cd`

## Commands

- `task fmt` formats all nix files
- `task lint` lints with `statix` and `deadnix`
- `task test` runs the unit tests in `tests/secrets.nix`
