<?php
/**
 * Site footer.
 *
 * @package AccessPSTheme
 */
?>

	<footer id="colophon" class="site-footer">
		<div class="site-footer__inner">
			<?php echo wp_kses_post( accesspstheme_brand_logo( 'accessps-brand--footer' ) ); ?>
		</div>
	</footer>
	<div class="site-footer-band" aria-hidden="true"></div>
</div>

<?php wp_footer(); ?>
</body>
</html>
