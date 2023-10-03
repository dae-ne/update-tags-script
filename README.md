# Update tags script

> :warning: **this script will remove all your local tags** and replace them with tags from a remote repository.

The script simplifies updating tags in a repository. Searches for the latest version (git tag) and adds a new tag with the next version number. It lets the user choose the type of version number change (major, minor, patch).

Version number is based on [Semantic Versioning](https://semver.org/). For now works only for format `vX.Y.Z` where `X`, `Y`, and `Z` are major, minor, and patch version numbers respectively.

## Example

```
$ ./update_tags.sh

Fetching tags...
Current version: v1.0.1

1) v1.0.2
2) v1.1.0
3) v2.0.0
4) quit
Select the new version: 1
```

In this example, the script found the latest version `v1.0.1` and proposed three options for the new version number. Users can choose one of them, or quit the script. If the user chooses the first option, the script will add a new tag `v1.0.2` to the repository. It will also update `v1.0` and `v1` to point to the new tag.

A version can also be specified using the `-v` option. For example: `./update_tags.sh -v v1.0.2`. It will break if the specified version already exists, can be used to create an initial tag, e.g. `v1.0.0` (`v0.0.0` is default).

## Flags

- `-v` - specify the version number to add (e.g. `v1.0.2`)
- `-t` - specify the type of version number change (major, minor, patch)
- `-p` - push to remote repository
- `-f` - force push to remote repository

Examples:

```bash
./update_tags.sh -v v1.0.2
./update_tags.sh -t patch
./update_tags.sh -p
./update_tags.sh -f
./update_tags.sh -t patch -p
```

## GitHub Actions example

```yaml
name: Update tags

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'specific version'
        required: false
        type: string
      update-type:
        description: 'version update type'
        required: false
        default: 'patch'
        type: choice
        options:
          - patch
          - minor
          - major

jobs:
  update-tags:
    permissions:
      contents: write
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: true
      - name: Set up Git
        run: |
          git config user.email '${GITHUB_ACTOR_ID}+${GITHUB_ACTOR}@users.noreply.github.com'
          git config user.name '${GITHUB_ACTOR}'
      - name: Add permissions
        run: |
          chmod +x update-tags-script/update_tags.sh
      - name: Run script
        run: |
          if [ -z "${{ github.event.inputs.version }}" ]; then
            update-tags-script/update_tags.sh -f -t ${{ github.event.inputs.update-type }}
          else
            update-tags-script/update_tags.sh -f -v ${{ github.event.inputs.version }} -t ${{ github.event.inputs.update-type }}
          fi
        shell: bash
```

## License

[MIT](https://choosealicense.com/licenses/mit/)
