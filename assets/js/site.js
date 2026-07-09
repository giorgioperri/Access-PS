(function () {
	var html = document.documentElement;
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

	var translations = {
		it: {
			current: 'Italiano',
			enter: 'ENTRA',
			title: 'ACCESS PS',
			intro: 'Benvenuti in ACCESS PS, il progetto di Terza Missione dell’Università di Roma La Sapienza dedicato al Pronto Soccorso del Policlinico Umberto I.',
			info: 'Il sito offre informazioni utili per orientarsi nei servizi e nei percorsi di accesso al Pronto Soccorso.',
			mission: 'Un’iniziativa pensata per accogliere, informare e accompagnare cittadini e pazienti, valorizzando il legame tra cura, ricerca e formazione.'
		},
		en: {
			current: 'English',
			enter: 'ENTER',
			title: 'ACCESS PS',
			intro: 'Welcome to ACCESS PS, the Third Mission project by Sapienza University of Rome dedicated to the Emergency Department of Policlinico Umberto I.',
			info: 'The site offers useful information to help you find your way through Emergency Department services and access paths.',
			mission: 'An initiative designed to welcome, inform and guide citizens and patients, strengthening the connection between care, research and education.'
		},
		fr: {
			current: 'Français',
			enter: 'ENTRER',
			title: 'ACCESS PS',
			intro: 'Bienvenue sur ACCESS PS, le projet de Troisième Mission de l’Université de Rome La Sapienza dédié aux urgences du Policlinico Umberto I.',
			info: 'Le site fournit des informations utiles pour s’orienter dans les services et les parcours d’accès aux urgences.',
			mission: 'Une initiative pensée pour accueillir, informer et accompagner les citoyens et les patients, en valorisant le lien entre soins, recherche et formation.'
		},
		de: {
			current: 'Deutsch',
			enter: 'EINTRETEN',
			title: 'ACCESS PS',
			intro: 'Willkommen bei ACCESS PS, dem Third-Mission-Projekt der Universität Rom La Sapienza für die Notaufnahme des Policlinico Umberto I.',
			info: 'Die Website bietet hilfreiche Informationen zur Orientierung in den Diensten und Zugangswegen der Notaufnahme.',
			mission: 'Eine Initiative, die Bürgerinnen, Bürger und Patientinnen und Patienten willkommen heißt, informiert und begleitet und die Verbindung zwischen Versorgung, Forschung und Ausbildung stärkt.'
		},
		es: {
			current: 'Español',
			enter: 'ENTRAR',
			title: 'ACCESS PS',
			intro: 'Bienvenidos a ACCESS PS, el proyecto de Tercera Misión de la Universidad de Roma La Sapienza dedicado a Urgencias del Policlinico Umberto I.',
			info: 'El sitio ofrece información útil para orientarse en los servicios y recorridos de acceso a Urgencias.',
			mission: 'Una iniciativa pensada para acoger, informar y acompañar a ciudadanos y pacientes, valorizando el vínculo entre atención, investigación y formación.'
		}
	};

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

	function applyFallbackTranslation(code) {
		var data = translations[code];

		if (!data) {
			return;
		}

		var title = document.querySelector('[data-home-title]');
		var intro = document.querySelector('[data-home-intro]');
		var info = document.querySelector('[data-home-info]');
		var mission = document.querySelector('[data-home-mission]');
		var enter = document.querySelector('.js-enter-button');

		if (title) {
			title.textContent = data.title;
		}

		if (intro) {
			intro.textContent = data.intro;
		}

		if (info) {
			info.textContent = data.info;
		}

		if (mission) {
			mission.textContent = data.mission;
		}

		if (enter) {
			enter.textContent = data.enter;
			enter.dataset.selectedLanguage = code;
		}

		html.lang = code;
	}

	document.querySelectorAll('[data-language-selector]').forEach(function (selector) {
		var trigger = selector.querySelector('.accessps-language__trigger');
		var panel = selector.querySelector('.accessps-language__panel');
		var current = selector.querySelector('[data-language-current]');
		var search = selector.querySelector('[data-language-search]');

		if (!trigger || !panel) {
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
				var code = option.dataset.code;
				var label = option.dataset.label;
				var wpmlLanguages = window.accesspsTheme && window.accesspsTheme.wpmlLanguages ? window.accesspsTheme.wpmlLanguages : {};

				selector.querySelectorAll('[data-language-option]').forEach(function (item) {
					item.classList.toggle('is-selected', item === option);
				});

				if (current) {
					current.textContent = label;
				}

				applyFallbackTranslation(code);
				closeLanguagePanels();

				if (wpmlLanguages[code] && window.location.href !== wpmlLanguages[code]) {
					window.location.href = wpmlLanguages[code];
				}
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

		selector.querySelectorAll('[data-language-close]').forEach(function (button) {
			button.addEventListener('click', closeLanguagePanels);
		});
	});
}());
