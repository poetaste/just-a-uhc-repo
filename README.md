![The Unofficial Homestuck Collection](./collection_logo.png)

# Unofficial Homestuck Collection (Gentoo Overlay)

A Gentoo overlay providing ebuilds for the [Unofficial Homestuck Collection](https://github.com/GiovanH/unofficial-homestuck-collection) — an offline, feature-complete reader for *Homestuck* and related works.

---

## Installation

### 1. Add the overlay

```sh
eselect repository add just-a-uhc-repo git https://github.com/poetaste/just-a-uhc-repo.git
emaint sync -r just-a-uhc-repo
```

### 2. Install the package

Choose one variant:

#### Binary package
```sh
emerge -av app-misc/unofficial-homestuck-collection-bin
```

#### Source package

```sh
emerge -av app-misc/unofficial-homestuck-collection
```

---


### Asset Pack

To run The Unofficial Homestuck Collection, you need to pair this application with an **Asset Pack V2**, which contains the media and data required.  
A significant effort has been made to keep this repository free of copyrighted material; for that reason, it does not and will not host or directly link to those assets.

---

## Package Summary

| Package                                        | Version     | Build Type       | License |
| ---------------------------------------------- | ----------- | ---------------- | ------- |
| `app-misc/unofficial-homestuck-collection-bin` | 2.7.2       | Pre-built binary | GPL-3   |
| `app-misc/unofficial-homestuck-collection`     | 2.7.2  | Source build     | GPL-3   |

**Upstream:** [GiovanH/unofficial-homestuck-collection](https://github.com/GiovanH/unofficial-homestuck-collection)

---


## Contributing

Contributions and feedback are welcome.

1. Report overlay issues or improvements on the [overlay repository](https://github.com/poetaste/just-a-uhc-repo)
2. Upstream issues should be directed to the [official project](https://github.com/GiovanH/unofficial-homestuck-collection)
3. Pull requests are appreciated for fixes, enhancements, and new ebuild versions

---

## License

This overlay is distributed under the **MIT License** — see [LICENSE](LICENSE).
The Unofficial Homestuck Collection itself is licensed under **GPL-3**.
Refer to the [upstream repository](https://github.com/GiovanH/unofficial-homestuck-collection) for full terms.

---

## Acknowledgments

- Thanks to [GiovanH](https://github.com/GiovanH) and contributors for creating and maintaining the Unofficial Homestuck Collection
- Built for the Gentoo Linux community
