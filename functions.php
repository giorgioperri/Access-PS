<?php
/**
 * Theme functions and definitions.
 *
 * @package AccessPSTheme
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

if ( ! function_exists( 'accesspstheme_setup' ) ) {
	/**
	 * Sets up theme defaults and registers WordPress features.
	 */
	function accesspstheme_setup() {
		load_theme_textdomain( 'accesspstheme', get_template_directory() . '/languages' );

		add_theme_support( 'automatic-feed-links' );
		add_theme_support( 'title-tag' );
		add_theme_support( 'post-thumbnails' );
		add_theme_support( 'responsive-embeds' );
		add_theme_support( 'wp-block-styles' );
		add_theme_support( 'align-wide' );
		add_theme_support(
			'html5',
			array(
				'comment-form',
				'comment-list',
				'gallery',
				'caption',
				'search-form',
				'script',
				'style',
			)
		);

		register_nav_menus(
			array(
				'primary' => __( 'Primary Menu', 'accesspstheme' ),
				'footer'  => __( 'Footer Menu', 'accesspstheme' ),
			)
		);
	}
}
add_action( 'after_setup_theme', 'accesspstheme_setup' );

/**
 * Enqueues theme assets.
 */
function accesspstheme_enqueue_assets() {
	$theme_version = wp_get_theme()->get( 'Version' );
	$style_path    = get_stylesheet_directory() . '/style.css';
	$script_path   = get_stylesheet_directory() . '/assets/js/site.js';

	if ( file_exists( $style_path ) ) {
		$theme_version = filemtime( $style_path );
	}

	wp_enqueue_style( 'accesspstheme-style', get_stylesheet_uri(), array(), $theme_version );

	if ( file_exists( $script_path ) ) {
		wp_enqueue_script(
			'accesspstheme-site',
			get_stylesheet_directory_uri() . '/assets/js/site.js',
			array(),
			filemtime( $script_path ),
			true
		);
	}
}
add_action( 'wp_enqueue_scripts', 'accesspstheme_enqueue_assets' );

/**
 * Returns an asset URL from the theme images directory.
 *
 * @param string $filename Asset filename.
 * @return string
 */
function accesspstheme_image_url( $filename ) {
	return get_stylesheet_directory_uri() . '/assets/images/' . ltrim( $filename, '/' );
}

/**
 * Returns the replaceable Sapienza logo image.
 *
 * @param string $class_name Optional class name.
 * @return string
 */
function accesspstheme_brand_logo( $class_name = '' ) {
	$class_name = trim( 'accessps-brand ' . $class_name );

	return '<a class="' . esc_attr( $class_name ) . '" href="' . esc_url( home_url( '/' ) ) . '" rel="home">
		<img src="' . esc_url( accesspstheme_image_url( 'accessps/home/logo-sapienza-terza-missione.png' ) ) . '" alt="' . esc_attr__( 'Sapienza Università di Roma', 'accesspstheme' ) . '">
	</a>';
}

/**
 * Outputs simple line icons used by shortcode content.
 *
 * @param string $name Icon name.
 * @return string
 */
function accesspstheme_icon_svg( $name ) {
	$icons = array(
		'pin'        => '<svg viewBox="0 0 64 64" aria-hidden="true"><path d="M32 58s20-19.1 20-36A20 20 0 0 0 12 22c0 16.9 20 36 20 36Z"/><circle cx="32" cy="22" r="7"/></svg>',
		'stethoscope'=> '<svg viewBox="0 0 64 64" aria-hidden="true"><path d="M20 8v15a12 12 0 0 0 24 0V8"/><path d="M32 35v8a11 11 0 0 0 22 0v-6"/><circle cx="54" cy="34" r="4"/><path d="M16 8h8M40 8h8"/></svg>',
		'exit'       => '<svg viewBox="0 0 64 64" aria-hidden="true"><path d="M14 10h22v44H14z"/><path d="M36 32h18M46 22l10 10-10 10"/></svg>',
		'arrow'      => '<svg viewBox="0 0 64 64" aria-hidden="true"><path d="M10 32h40M38 18l14 14-14 14"/></svg>',
		'document'   => '<svg viewBox="0 0 64 64" aria-hidden="true"><path d="M18 6h23l9 9v43H18z"/><path d="M40 6v12h10M25 28h18M25 38h18M25 48h10"/><circle cx="46" cy="48" r="8"/><path d="M46 44v5"/></svg>',
		'questions'  => '<svg viewBox="0 0 64 64" aria-hidden="true"><path d="M16 10h28l8 8v36H16z"/><path d="M43 10v11h9M24 28h14M24 38h10M24 48h9"/><circle cx="47" cy="45" r="9"/><path d="M47 48v.5M44 42a3 3 0 1 1 5 2c-1 1-2 1.6-2 3"/></svg>',
		'building'   => '<svg viewBox="0 0 64 64" aria-hidden="true"><path d="M12 54h40M16 50V24h32v26M12 24l20-12 20 12M24 50v-8h16v8M24 30h4M36 30h4M24 38h4M36 38h4"/><path d="M32 18v-6"/></svg>',
		'door'       => '<svg viewBox="0 0 64 64" aria-hidden="true"><path d="M18 54V10h28v44M26 54V18l20-8M32 34h2"/></svg>',
		'hands'      => '<svg viewBox="0 0 64 64" aria-hidden="true"><path d="M22 44 13 35a7 7 0 0 1 0-10l7 7V14a5 5 0 0 1 10 0v18"/><path d="M42 44l9-9a7 7 0 0 0 0-10l-7 7V14a5 5 0 0 0-10 0v18"/><path d="M24 52h16M32 16v18"/></svg>',
		'hospital'   => '<svg viewBox="0 0 64 64" aria-hidden="true"><path d="M12 56V20h40v36M20 56V10h24v46"/><path d="M28 20h8M32 16v8M20 30h6M38 30h6M20 40h6M38 40h6M28 56V44h8v12"/></svg>',
		'bed'        => '<svg viewBox="0 0 64 64" aria-hidden="true"><path d="M10 48V18M54 48V30a8 8 0 0 0-8-8H30v26M10 34h44M10 48h44M16 28h10"/><circle cx="32" cy="12" r="5"/><path d="M32 17v9M27 22h10"/></svg>',
		'ticket'     => '<svg viewBox="0 0 64 64" aria-hidden="true"><path d="M14 24a7 7 0 0 0 0 14l6 14 30-12-6-14a7 7 0 0 0 0-14L38 0 8 12z" transform="translate(3 6) rotate(-20 32 32)"/><path d="M29 22h12M25 32h12"/></svg>',
		'wifi'       => '<svg viewBox="0 0 64 64" aria-hidden="true"><path d="M12 24a32 32 0 0 1 40 0M20 34a20 20 0 0 1 24 0M28 44a8 8 0 0 1 8 0"/><circle cx="32" cy="52" r="2"/></svg>',
		'clipboard'  => '<svg viewBox="0 0 64 64" aria-hidden="true"><path d="M20 12h24v44H20z"/><path d="M26 12a6 6 0 0 1 12 0M26 24h12M26 34h12M26 44h8"/><circle cx="46" cy="44" r="9"/><path d="M46 47v.5M43 41a3 3 0 1 1 5 2c-1 1-2 1.6-2 3"/></svg>',
	);

	if ( empty( $icons[ $name ] ) ) {
		return '';
	}

	return '<span class="accessps-icon accessps-icon--' . esc_attr( $name ) . '">' . $icons[ $name ] . '</span>';
}

/**
 * Icon shortcode.
 *
 * @param array $atts Shortcode attributes.
 * @return string
 */
function accesspstheme_icon_shortcode( $atts ) {
	$atts = shortcode_atts(
		array(
			'name' => 'document',
		),
		$atts,
		'accessps_icon'
	);

	return accesspstheme_icon_svg( sanitize_key( $atts['name'] ) );
}
add_shortcode( 'accessps_icon', 'accesspstheme_icon_shortcode' );

/**
 * WPML language selector shortcode.
 *
 * @return string
 */
function accesspstheme_language_selector_shortcode() {
	$languages = accesspstheme_get_wpml_languages();

	ob_start();

	if ( ! empty( $languages ) ) {
		?>
		<div class="accessps-language" data-language-selector>
			<button class="accessps-language__trigger" type="button" aria-expanded="false" aria-controls="accessps-language-panel">
				<span data-language-current><?php esc_html_e( 'Seleziona la tua lingua', 'accesspstheme' ); ?></span>
				<span class="accessps-language__globe" aria-hidden="true">◎</span>
			</button>
			<div class="accessps-language__panel" id="accessps-language-panel" hidden>
				<label class="screen-reader-text" for="accessps-language-search"><?php esc_html_e( 'Cerca lingua', 'accesspstheme' ); ?></label>
				<input class="accessps-language__search" id="accessps-language-search" type="search" placeholder="<?php esc_attr_e( 'Cerca lingua', 'accesspstheme' ); ?>" data-language-search>
				<div class="accessps-language__list">
					<?php foreach ( $languages as $language ) : ?>
						<button class="accessps-language__option" type="button" data-language-option data-url="<?php echo esc_url( $language['url'] ); ?>" data-label="<?php echo esc_attr( $language['label'] ); ?>">
							<?php if ( ! empty( $language['flag_url'] ) ) : ?>
								<img class="accessps-language__flag" src="<?php echo esc_url( $language['flag_url'] ); ?>" alt="">
							<?php else : ?>
								<span class="accessps-language__flag" aria-hidden="true"></span>
							<?php endif; ?>
							<span><?php echo esc_html( $language['label'] ); ?></span>
							<span class="accessps-language__radio" aria-hidden="true"></span>
						</button>
					<?php endforeach; ?>
				</div>
				<p class="accessps-language__empty" hidden data-language-no-results><?php esc_html_e( 'Nessuna lingua trovata.', 'accesspstheme' ); ?></p>
				<button class="accessps-language__choose" type="button" disabled data-language-choose><?php esc_html_e( 'Scegli', 'accesspstheme' ); ?></button>
			</div>
		</div>
		<?php
	} elseif ( current_user_can( 'manage_options' ) ) {
		echo '<p class="accessps-language__notice">' . esc_html__( 'Configura WPML per mostrare il selettore lingua.', 'accesspstheme' ) . '</p>';
	}

	return ob_get_clean();
}
add_shortcode( 'accessps_language_selector', 'accesspstheme_language_selector_shortcode' );

/**
 * Gets active WPML languages for the custom selector.
 *
 * @return array<int, array<string, string>>
 */
function accesspstheme_get_wpml_languages() {
	$wpml_languages = apply_filters(
		'wpml_active_languages',
		null,
		array(
			'skip_missing' => 1,
			'orderby'      => 'native_name',
		)
	);

	if ( empty( $wpml_languages ) || ! is_array( $wpml_languages ) ) {
		return array();
	}

	$languages = array();

	foreach ( $wpml_languages as $language ) {
		if ( empty( $language['url'] ) ) {
			continue;
		}

		$native_name     = ! empty( $language['native_name'] ) ? $language['native_name'] : '';
		$translated_name = ! empty( $language['translated_name'] ) ? $language['translated_name'] : '';
		$label           = $native_name ? $native_name : $translated_name;

		if ( $native_name && $translated_name && $native_name !== $translated_name ) {
			$label = sprintf( '%1$s (%2$s)', $native_name, $translated_name );
		}

		$url = set_url_scheme( $language['url'], wp_parse_url( home_url( '/' ), PHP_URL_SCHEME ) ?: 'https' );

		$languages[] = array(
			'label'    => $label,
			'url'      => $url,
			'flag_url' => ! empty( $language['country_flag_url'] ) ? $language['country_flag_url'] : '',
		);
	}

	return $languages;
}
