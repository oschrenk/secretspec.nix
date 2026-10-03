# `secretspec.nix`

Build 1Password `op://vault/item[/section]/field` reference strings from a [secretspec](https://secretspec.dev) manifest, at nix evaluation time.

[opnix](https://github.com/brizzbuzz/opnix) wants an `op://` reference for every secret it places.
`secretspec.toml` already names the provider, the item, and the field for each secret.

## Usage

Add the input:

```nix
inputs.secretspec.url = "github:oschrenk/secretspec.nix";
inputs.secretspec.inputs.nixpkgs.follows = "nixpkgs";
```

Read the manifest and ask for references:

```nix
let
  secrets = inputs.secretspec.lib.read ./secretspec.toml;
in
{
  services.onepassword-secrets.secrets.databasePassword = {
    reference = secrets.ref "DATABASE_PASSWORD";
    owner = "root";
    mode = "0600";
  };
}
```

## Not Supported

- the `refs` table
- provider-alias `ref` templates
- profile inheritance from `default`
- profile-level provider chains
- scopes

## Manifests That Predate `[defaults]`

A manifest without `[defaults]` needs a user-global `~/.config/secretspec/config.toml` on every machine:

```toml
[defaults]
provider = "null://"
```

`null://` reports every value as missing, so it satisfies the rule without ever answering.

Without any user config, a chain-less secret in a `[defaults]`-less project still errors, now with "no default provider exists".
