# Update tags script

The script simplifies updating tags in the repository. Searches for the latest version (git tag) and adds a new tag with the next version number. It lets the user choose the type of version number change (major, minor, patch).

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

## License

[MIT](https://choosealicense.com/licenses/mit/)
