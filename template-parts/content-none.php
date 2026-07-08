<?php
/**
 * Empty-state content template part.
 *
 * @package AccessPSTheme
 */
?>

<section class="no-results not-found">
	<header class="page-header">
		<h1 class="page-title"><?php esc_html_e( 'Nothing found', 'accesspstheme' ); ?></h1>
	</header>

	<div class="page-content">
		<?php if ( is_home() && current_user_can( 'publish_posts' ) ) : ?>
			<p>
				<?php
				printf(
					wp_kses(
						/* translators: 1: Link to new post screen. */
						__( 'Ready to publish your first post? <a href="%1$s">Get started here</a>.', 'accesspstheme' ),
						array(
							'a' => array(
								'href' => array(),
							),
						)
					),
					esc_url( admin_url( 'post-new.php' ) )
				);
				?>
			</p>
		<?php elseif ( is_search() ) : ?>
			<p><?php esc_html_e( 'No results matched your search. Try a different query.', 'accesspstheme' ); ?></p>
			<?php get_search_form(); ?>
		<?php else : ?>
			<p><?php esc_html_e( 'No content is available yet.', 'accesspstheme' ); ?></p>
		<?php endif; ?>
	</div>
</section>
