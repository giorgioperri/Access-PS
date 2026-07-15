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
		var search = selector.querySelector('[data-language-search]');
		var options = selector.querySelectorAll('[data-language-option]');
		var noResults = selector.querySelector('[data-language-no-results]');

		if (!trigger || !panel) {
			return;
		}

		function normalize(value) {
			return (value || '')
				.toString()
				.normalize('NFD')
				.replace(/[\u0300-\u036f]/g, '')
				.toLowerCase()
				.trim();
		}

		function filterLanguages() {
			var query = normalize(search ? search.value : '');
			var visibleCount = 0;

			options.forEach(function (option) {
				var searchableText = normalize(option.dataset.label + ' ' + option.textContent);
				var isMatch = !query || searchableText.indexOf(query) !== -1;

				option.hidden = !isMatch;

				if (isMatch) {
					visibleCount += 1;
				}
			});

			if (noResults) {
				noResults.hidden = visibleCount > 0;
			}
		}

		trigger.addEventListener('click', function () {
			var isOpen = trigger.getAttribute('aria-expanded') === 'true';
			closeLanguagePanels();
			trigger.setAttribute('aria-expanded', isOpen ? 'false' : 'true');
			panel.hidden = isOpen;

			if (!isOpen && search) {
				filterLanguages();
				search.focus();
			}
		});

		options.forEach(function (option) {
			option.addEventListener('click', function () {
				var languageUrl = option.dataset.url || '';

				if (languageUrl) {
					window.location.href = languageUrl;
				}
			});
		});

		if (search) {
			search.addEventListener('input', filterLanguages);
			search.addEventListener('search', filterLanguages);
			filterLanguages();
		}

	});
}());
