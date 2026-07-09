(function () {
	var body = document.body;
	var menu = document.getElementById('site-navigation');
	var openButton = document.querySelector('.menu-toggle');
	var closeButton = document.querySelector('.menu-close');

	function setMenu(open) {
		if (!menu || !openButton) {
			return;
		}

		menu.hidden = !open;
		openButton.setAttribute('aria-expanded', open ? 'true' : 'false');
		body.classList.toggle('menu-is-open', open);
	}

	function closeLanguagePanels() {
		document.querySelectorAll('[data-language-selector]').forEach(function (selector) {
			var trigger = selector.querySelector('.accessps-language__trigger');
			var panel = selector.querySelector('.accessps-language__panel');

			if (trigger && panel) {
				trigger.setAttribute('aria-expanded', 'false');
				panel.hidden = true;
			}
		});
	}

	if (openButton) {
		openButton.addEventListener('click', function () {
			setMenu(true);
		});
	}

	if (closeButton) {
		closeButton.addEventListener('click', function () {
			setMenu(false);
		});
	}

	document.addEventListener('keydown', function (event) {
		if (event.key === 'Escape') {
			setMenu(false);
			closeLanguagePanels();
		}
	});

	if (window.matchMedia('(min-width: 801px)').matches && menu) {
		menu.hidden = false;
	}

	window.addEventListener('resize', function () {
		if (!menu) {
			return;
		}

		if (window.matchMedia('(min-width: 801px)').matches) {
			menu.hidden = false;
			body.classList.remove('menu-is-open');
		} else if (!body.classList.contains('menu-is-open')) {
			menu.hidden = true;
		}
	});

	document.querySelectorAll('[data-language-selector]').forEach(function (selector) {
		var trigger = selector.querySelector('.accessps-language__trigger');
		var panel = selector.querySelector('.accessps-language__panel');
		var current = selector.querySelector('[data-language-current]');
		var search = selector.querySelector('[data-language-search]');
		var choose = selector.querySelector('[data-language-choose]');
		var selectedUrl = '';

		if (!trigger || !panel || !choose) {
			return;
		}

		trigger.addEventListener('click', function () {
			var isOpen = trigger.getAttribute('aria-expanded') === 'true';
			closeLanguagePanels();
			trigger.setAttribute('aria-expanded', isOpen ? 'false' : 'true');
			panel.hidden = isOpen;

			if (!isOpen && search) {
				search.focus();
			}
		});

		selector.querySelectorAll('[data-language-option]').forEach(function (option) {
			option.addEventListener('click', function () {
				selectedUrl = option.dataset.url || '';

				selector.querySelectorAll('[data-language-option]').forEach(function (item) {
					item.classList.toggle('is-selected', item === option);
				});

				if (current) {
					current.textContent = option.dataset.label || option.textContent.trim();
				}

				choose.disabled = !selectedUrl;
			});
		});

		if (search) {
			search.addEventListener('input', function () {
				var query = search.value.trim().toLowerCase();

				selector.querySelectorAll('[data-language-option]').forEach(function (option) {
					option.hidden = option.dataset.label.toLowerCase().indexOf(query) === -1;
				});
			});
		}

		choose.addEventListener('click', function () {
			if (selectedUrl) {
				window.location.href = selectedUrl;
			}
		});
	});
}());
