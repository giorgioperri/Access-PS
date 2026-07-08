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

	if ( file_exists( $style_path ) ) {
		$theme_version = filemtime( $style_path );
	}

	wp_enqueue_style( 'accesspstheme-style', get_stylesheet_uri(), array(), $theme_version );
}
add_action( 'wp_enqueue_scripts', 'accesspstheme_enqueue_assets' );
