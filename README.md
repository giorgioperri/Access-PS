# Access PS Theme

Custom WordPress theme for Access PS, an Italian information site that helps people understand the Pronto Soccorso access path.

The theme is built as a classic WordPress theme with normal page content so WPML can translate pages, menus, and strings. The homepage language selector uses a custom searchable UI backed by WPML's active language URLs.

## Site Structure

Run the site setup script from this theme directory after deploying the theme or from a WordPress-aware local shell:

```sh
./build-site-structure.sh
```

The script creates or updates the baseline pages, sets the homepage, creates the main/footer menus, and assigns menu locations. Override the WordPress root path when needed:

```sh
WP_PATH=/path/to/wordpress ./build-site-structure.sh
```

The script creates:

- Home
- Dove ti trovi?
- Arrivo
- Visita medica
- Uscita
- La storia del Policlinico Umberto I
- La storia dell'universita di Roma La Sapienza
- STP

It also sets Home as the static front page and creates/assigns the primary and footer menus.
