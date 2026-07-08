<?php
/**
 * 404 template.
 *
 * @package AccessPSTheme
 */

get_header();
?>

<main id="primary" class="site-main">
	<section class="error-404 not-found">
		<header class="page-header">
			<h1 class="page-title"><?php esc_html_e( 'Page not found', 'accesspstheme' ); ?></h1>
		</header>

		<div class="page-content">
			<p><?php esc_html_e( 'The page you requested could not be found.', 'accesspstheme' ); ?></p>
			<?php get_search_form(); ?>
		</div>
	</section>
</main>

<?php
get_footer();
