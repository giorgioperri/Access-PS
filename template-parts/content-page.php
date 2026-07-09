<?php
/**
 * Page content template part.
 *
 * @package AccessPSTheme
 */
?>

<article id="post-<?php the_ID(); ?>" <?php post_class( 'entry' ); ?>>
	<div class="entry-content">
		<?php
		echo do_shortcode( get_the_content() ); // phpcs:ignore WordPress.Security.EscapeOutput.OutputNotEscaped

		wp_link_pages(
			array(
				'before' => '<div class="page-links">' . esc_html__( 'Pages:', 'accesspstheme' ),
				'after'  => '</div>',
			)
		);
		?>
	</div>

	<footer class="entry-footer">
		<?php edit_post_link( esc_html__( 'Edit', 'accesspstheme' ) ); ?>
	</footer>
</article>
