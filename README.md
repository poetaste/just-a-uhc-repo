# Unofficial Homestuck Collection (Gentoo Overlay)

A Gentoo overlay providing an ebuild for the binary release of the Unofficial Homestuck Collection client.

---

## Installation (Gentoo)

Enable the overlay:

```sh
sudo eselect repository add just-a-uhc-repo git https://github.com/poetaste/just-a-uhc-repo.git
sudo emaint sync -r just-a-uhc-repo
```

Install the package:

```sh
sudo emerge -av app-misc/unofficial-homestuck-collection-bin
```

---

## Notes

* Currently, this overlay ships only the binary package. A source ebuild is still a work in progress, and I'm working on it lol.

---

## License

This overlay is licensed under MIT. See the LICENSE file for details.

---
