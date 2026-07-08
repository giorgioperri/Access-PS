<?php
/**
 * Site footer.
 *
 * @package AccessPSTheme
 */
?>

	<footer id="colophon" class="site-footer">
		<div class="site-footer__inner">
			<p>
				&copy; <?php echo esc_html( gmdate( 'Y' ) ); ?>
				<a href="<?php echo esc_url( home_url( '/' ) ); ?>"><?php bloginfo( 'name' ); ?></a>
			</p>

			<nav class="footer-navigation" aria-label="<?php esc_attr_e( 'Footer menu', 'accesspstheme' ); ?>">
				<?php
				wp_nav_menu(
					array(
						'theme_location' => 'footer',
						'container'      => false,
						'fallback_cb'    => false,
					)
				);
				?>
			</nav>
		</div>
	</footer>
</div>

<?php wp_footer(); ?>
</body>
</html>
