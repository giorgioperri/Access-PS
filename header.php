<?php
/**
 * Site header.
 *
 * @package AccessPSTheme
 */
?><!doctype html>
<html <?php language_attributes(); ?>>
<head>
	<meta charset="<?php bloginfo( 'charset' ); ?>">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>
<?php wp_body_open(); ?>
<div id="page" class="site">
	<a class="screen-reader-text" href="#primary"><?php esc_html_e( 'Skip to content', 'accesspstheme' ); ?></a>

	<header id="masthead" class="site-header">
		<div class="site-header__inner">
			<?php echo wp_kses_post( accesspstheme_brand_logo() ); ?>

			<button class="menu-toggle" type="button" aria-controls="site-navigation" aria-expanded="false">
				<span class="menu-toggle__bar"></span>
				<span class="menu-toggle__bar"></span>
				<span class="menu-toggle__bar"></span>
				<span class="screen-reader-text"><?php esc_html_e( 'Menu', 'accesspstheme' ); ?></span>
			</button>

			<nav id="site-navigation" class="main-navigation" aria-label="<?php esc_attr_e( 'Primary menu', 'accesspstheme' ); ?>" hidden>
				<button class="menu-close" type="button" aria-label="<?php esc_attr_e( 'Close menu', 'accesspstheme' ); ?>"></button>
				<?php
				wp_nav_menu(
					array(
						'theme_location' => 'primary',
						'menu_id'        => 'primary-menu',
						'container'      => false,
						'fallback_cb'    => false,
					)
				);
				?>
			</nav>
		</div>
	</header>
