#!/usr/bin/env bash

set -euo pipefail

# Builds the WordPress page/menu structure for Access PS.
#
# Usage:
#   ./build-site-structure.sh
#   WP_PATH=/path/to/wordpress ./build-site-structure.sh
#   WP=wp-cli.phar ./build-site-structure.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WP_ROOT_DEFAULT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
THEME_SLUG="$(basename "$SCRIPT_DIR")"

WP="${WP:-wp}"
WP_PATH="${WP_PATH:-$WP_ROOT_DEFAULT}"

wp_cli() {
	"$WP" --path="$WP_PATH" --skip-plugins "$@"
}

require_wp() {
	if ! command -v "$WP" >/dev/null 2>&1; then
		echo "Error: wp command not found. Set WP=/path/to/wp or run from a shell with WP-CLI available." >&2
		exit 1
	fi

	if ! wp_cli core is-installed >/dev/null 2>&1; then
		echo "Error: WordPress is not installed or not reachable at WP_PATH=$WP_PATH" >&2
		exit 1
	fi
}

page_id_by_slug() {
	local slug="$1"

	wp_cli post list \
		--post_type=page \
		--post_status=any \
		--pagename="$slug" \
		--field=ID \
		--format=ids
}

upsert_page() {
	local title="$1"
	local slug="$2"
	local content="$3"
	local menu_order="${4:-0}"
	local page_id

	page_id="$(page_id_by_slug "$slug")"

	if [[ -n "$page_id" ]]; then
		wp_cli post update "$page_id" \
			--post_title="$title" \
			--post_name="$slug" \
			--post_content="$content" \
			--post_status=publish \
			--menu_order="$menu_order" \
			>/dev/null
		echo "$page_id"
	else
		wp_cli post create \
			--post_type=page \
			--post_title="$title" \
			--post_name="$slug" \
			--post_content="$content" \
			--post_status=publish \
			--menu_order="$menu_order" \
			>/dev/null
		page_id_by_slug "$slug"
	fi
}

menu_id_by_slug() {
	local slug="$1"

	wp_cli term list nav_menu \
		--slug="$slug" \
		--field=term_id \
		--format=ids
}

ensure_menu() {
	local name="$1"
	local slug="$2"
	local menu_id

	menu_id="$(menu_id_by_slug "$slug")"

	if [[ -z "$menu_id" ]]; then
		wp_cli menu create "$name" >/dev/null
		menu_id_by_slug "$slug"
	else
		echo "$menu_id"
	fi
}

ensure_menu_item() {
	local menu_slug="$1"
	local page_id="$2"
	local title="$3"
	local position="$4"
	local existing_item_id

	existing_item_id="$(wp_cli menu item list "$menu_slug" \
		--format=json |
		php -r '
			$items = json_decode(stream_get_contents(STDIN), true) ?: [];
			$pageId = (string) $argv[1];
			$title = (string) $argv[2];
			foreach ($items as $item) {
				$isPostType = ($item["type"] ?? "") === "post_type";
				$matchesObject = (string) ($item["object_id"] ?? "") === $pageId;
				$matchesTitle = (string) ($item["title"] ?? "") === $title;
				if ($isPostType && ($matchesObject || $matchesTitle)) {
					echo $item["db_id"];
					exit;
				}
			}
		' "$page_id" "$title")"

	if [[ -n "$existing_item_id" ]]; then
		wp_cli menu item update "$existing_item_id" \
			--title="$title" \
			--position="$position" \
			>/dev/null
	else
		wp_cli menu item add-post "$menu_slug" "$page_id" \
			--title="$title" \
			--position="$position" \
			>/dev/null
	fi
}

IFS= read -r -d '' HOME_CONTENT <<'HTML' || true
<div class="accessps-page accessps-home">
	<section class="accessps-hero-image">
		<img src="https://picsum.photos/1100/620?random=11" alt="">
	</section>

	<section class="accessps-home__intro accessps-narrow">
		<h1 class="accessps-title accessps-home__title">ACCESS PS</h1>
		<div class="accessps-lead accessps-home__copy">
			<p>Benvenuti in <strong>ACCESS PS</strong>,<br>il progetto di Terza Missione dell’<a href="/la-storia-delluniversita-di-roma-la-sapienza/"><strong>Università di Roma La Sapienza</strong></a> dedicato al Pronto Soccorso del <a href="/la-storia-del-policlinico-umberto-i/"><strong>Policlinico Umberto I</strong></a>.</p>
			<p>Il sito offre informazioni utili per orientarsi nei servizi e nei percorsi di accesso al Pronto Soccorso.</p>
			<p>Un’iniziativa pensata per accogliere, informare e accompagnare cittadini e pazienti, valorizzando il legame tra cura, ricerca e formazione.</p>
		</div>

		[accessps_language_selector]

		<p><a class="accessps-enter-button" href="/dove-ti-trovi/">ENTRA</a></p>

		<div class="accessps-stamp">
			<img src="/wp-content/themes/accesspstheme/assets/images/access-ps-logo.svg" alt="Access PS">
		</div>
	</section>
</div>
HTML

IFS= read -r -d '' LANDING_CONTENT <<'HTML' || true
<div class="accessps-page accessps-choice">
	<section class="accessps-narrow">
		<h1 class="accessps-title">DOVE TI TROVI?</h1>
		<p class="accessps-choice__subtitle">Seleziona l’area in cui ti trovi<br>per ricevere le informazioni su come procedere<br>e sui percorsi più indicati</p>
	</section>

	<section class="accessps-choice__stage">
		<img src="https://picsum.photos/1100/1100?random=21" alt="">
		<div class="accessps-choice__cards">
			<a class="accessps-choice-card" href="/arrivo/">
				<span class="accessps-choice-card__icon">[accessps_icon name="pin"]</span>
				<div><h2>ARRIVO</h2><p>Sei all’ingresso<br>del Pronto Soccorso</p></div>
				<span class="accessps-choice-card__arrow">[accessps_icon name="arrow"]</span>
			</a>
			<a class="accessps-choice-card" href="/visita-medica/">
				<span class="accessps-choice-card__icon">[accessps_icon name="stethoscope"]</span>
				<div><h2>VISITA MEDICA</h2><p>Sei in attesa o in<br>area visite</p></div>
				<span class="accessps-choice-card__arrow">[accessps_icon name="arrow"]</span>
			</a>
			<a class="accessps-choice-card" href="/uscita/">
				<span class="accessps-choice-card__icon">[accessps_icon name="exit"]</span>
				<div><h2>USCITA</h2><p>Stai per lasciare<br>il pronto soccorso</p></div>
				<span class="accessps-choice-card__arrow">[accessps_icon name="arrow"]</span>
			</a>
		</div>
	</section>
</div>
HTML

IFS= read -r -d '' ARRIVO_CONTENT <<'HTML' || true
<div class="accessps-page accessps-content accessps-narrow">
	<section class="accessps-section">
		<h1 class="accessps-title">ARRIVO</h1>
		<p><strong>Quando arrivi in PRONTO SOCCORSO un infermiere effettuerà il TRIAGE ovvero valuterà il motivo per cui sei arrivato e le tue condizioni.<br>Ti verrà assegnato un codice colore che determinerà la priorità di ingresso in visita.</strong></p>
		<div class="accessps-photo accessps-photo--fade"><img src="https://picsum.photos/760/360?random=31" alt=""></div>
	</section>

	<section class="accessps-section">
		<h2>Documenti e informazioni da preparare</h2>
		<p><strong>Quando entri al triage, è importante avere con te, se ne sei in possesso:</strong></p>
		<ul>
			<li>Tessera sanitaria (se disponibile)</li>
			<li>Tessera TEAM o STP (<a href="/stp/"><strong>clicca per informazioni</strong></a>)</li>
		</ul>
		<p><strong>Inoltre, devi essere pronto a comunicare:</strong></p>
		<ul>
			<li>Quali farmaci assumi abitualmente (se possibile con una lista o con una foto delle confezioni)</li>
			<li>Se soffri di malattie già note (per esempio diabete, pressione alta, problemi cardiaci o altre patologie)</li>
			<li>Se hai allergie a farmaci</li>
		</ul>
	</section>

	<section class="accessps-section">
		<h2>Cosa succede durante il TRIAGE</h2>
		<p>Quando entri nel <strong>BOX TRIAGE</strong>, l’infermiere svolge una valutazione iniziale del tuo stato.<br>Questa valutazione si svolge in più passaggi:</p>
		<div class="accessps-two-col">
			<div>
				<p><strong>Ti verranno fatte alcune domande:</strong></p>
				<p>Devi spiegare:</p>
				<ul>
					<li>Qual è il problema per cui sei venuto</li>
					<li>Quando è iniziato</li>
					<li>Se è migliorato, peggiorato o è rimasto uguale</li>
				</ul>
			</div>
			<span class="accessps-inline-icon">[accessps_icon name="questions"]</span>
		</div>
		<div class="accessps-two-col">
			<div>
				<p><strong>Vengono raccolte informazioni sanitarie:</strong></p>
				<p>L’infermiere ti chiederà:</p>
				<ul>
					<li>Quali farmaci assumi</li>
					<li>Se hai malattie già note</li>
					<li>Se hai allergie</li>
				</ul>
			</div>
			<span class="accessps-inline-icon">[accessps_icon name="document"]</span>
		</div>
		<p><strong>Se necessario verranno controllati i parametri vitali:</strong></p>
		<ul>
			<li>Pressione arteriosa</li>
			<li>Frequenza cardiaca.</li>
			<li>Temperatura.</li>
			<li>Ossigenazione.</li>
		</ul>
		<p><strong>Possono essere richiesti esami iniziali</strong></p>
		<p>In alcuni casi vengono eseguiti subito esami del sangue per iniziare la valutazione</p>
		<p><strong>Ti potrebbe essere posizionata una ago cannula per l’esecuzione di prelievi ulteriori o la successiva somministrazione di farmaci.</strong></p>
	</section>

	<section class="accessps-section">
		<h2>Cosa ti verrà dato dall’infermiere:</h2>
		<span class="accessps-inline-icon">[accessps_icon name="document"]</span>
		<p><strong>Un foglio con un numero<br>di TRE CIFRE.</strong><br>È il numero con cui verrai<br>chiamato per la visita.</p>
		<p><strong>Un braccialetto<br>identificativo.</strong><br>Deve rimanere sempre<br>al polso.</p>
		<div class="accessps-photo"><img src="https://picsum.photos/760/170?random=32" alt=""></div>
		<p class="accessps-caption">Esempio illustrativo di braccialetto identificativo.</p>
	</section>

	<section class="accessps-section">
		<h2>Codici colore</h2>
		<p>Dopo il triage ti viene assegnato un <strong>codice colore</strong><br>Successivamente verrai indirizzato in sala d’attesa:</p>
		<ul>
			<li>rimani in questa area fino alla chiamata per la visita medica.</li>
			<li>Sarai chiamato con il <strong>numero di 3 cifre assegnato</strong> presente sul foglio che ti è stato consegnato.</li>
		</ul>
		<p>Il codice colore <strong>serve a stabilire il tempo di attesa</strong><br>prima della visita.</p>
		<div class="accessps-code-list">
			<span><i class="accessps-dot accessps-dot--red"></i><strong>Rosso</strong> → Immediato</span>
			<span><i class="accessps-dot accessps-dot--yellow"></i><strong>Giallo</strong> → Breve</span>
			<span><i class="accessps-dot accessps-dot--blue"></i><strong>Azzurro</strong> → Variabile</span>
			<span><i class="accessps-dot accessps-dot--green"></i><strong>Verde</strong> → Variabile</span>
			<span><i class="accessps-dot accessps-dot--white"></i><strong>Bianco</strong> → Variabile</span>
		</div>
		<p>Contatta gli operatori se il tuo problema peggiora<br>Non allontanarti e non aspettare in altre aree diverse da quelle indicate dal personale.</p>
		<div class="accessps-photo accessps-photo--fade"><img src="https://picsum.photos/760/360?random=33" alt=""></div>
		<p class="accessps-caption">Sala d’attesa pazienti</p>
	</section>

	<section class="accessps-section">
		<h2>Dove vanno i familiari</h2>
		<p>I familiari <strong>non possono entrare nelle aree di visita,</strong> non devono entrare nei reparti o cercare direttamente il paziente.<br>Devono recarsi nella sala d’attesa parenti, che vi verrà indicata dal personale.</p>
		<div class="accessps-photo accessps-photo--fade"><img src="https://picsum.photos/760/360?random=34" alt=""></div>
		<p>I familiari potranno chiedere informazioni al:<br><strong>BOX ACCOGLIENZA PARENTI</strong></p>
		<div class="accessps-photo accessps-photo--fade"><img src="https://picsum.photos/760/360?random=35" alt=""></div>
	</section>

	<section class="accessps-section">
		<span class="accessps-inline-icon">[accessps_icon name="clipboard"]</span>
		<h2>Aiutaci a migliorare:</h2>
		<p>La tua opinione è importante.</p>
		<p><a class="accessps-button" href="https://forms.google.com/">Compila il questionario</a></p>
	</section>
</div>
HTML

IFS= read -r -d '' VISITA_CONTENT <<'HTML' || true
<div class="accessps-page accessps-content accessps-narrow">
	<section class="accessps-section">
		<h1 class="accessps-title">VISITA MEDICA</h1>
		<p class="accessps-lead"><strong>Dopo essere stato chiamato con il numero di riferimento, vieni visitato dal medico che valuta la tua situazione attuale e la tua storia clinica.</strong></p>
	</section>

	<section class="accessps-section">
		<div class="accessps-two-col">
			<div>
				<h2>In questo momento possono essere richiesti:</h2>
				<ul>
					<li>Esami radiologici</li>
					<li>Esami ematochimici</li>
					<li>Valutazioni specialistiche</li>
				</ul>
				<p>Il medico può prescriverti dei farmaci somministrati in forma di compresse o per via endovenosa.</p>
			</div>
			<span class="accessps-inline-icon">[accessps_icon name="document"]</span>
		</div>
	</section>

	<section class="accessps-section">
		<h2>Cosa succede dopo la visita</h2>
		<h3>Piastra 1:</h3>
		<p>Sei in un'area dedicata alla valutazione e al trattamento iniziale. Verrai informato sull'andamento degli esami e sulle tue condizioni.</p>
		<div class="accessps-photo"><img src="https://picsum.photos/760/220?random=41" alt=""></div>
		<h3>Piastra 2:</h3>
		<p>Sei in attesa di un posto letto in questo ospedale o in un altro ospedale convenzionato, che ti verrà fornito appena disponibile.</p>
		<div class="accessps-photo"><img src="https://picsum.photos/760/220?random=42" alt=""></div>
		<h3>Piastra 3 – Urgenze Minori:</h3>
		<p>Sei in un'area dedicata alla valutazione e al trattamento.</p>
		<div class="accessps-photo"><img src="https://picsum.photos/760/220?random=43" alt=""></div>
		<p>La scelta della poltrona o della barella è dettata dal personale in base alle singole necessità dei pazienti.</p>
	</section>

	<section class="accessps-section">
		<span class="accessps-inline-icon">[accessps_icon name="bed"]</span>
		<h2>Cosa devi fare durante l'attesa</h2>
		<p>Evita di allontanarti senza avvisare il personale per non rallentare il tuo percorso.</p>
		<p>Se i tuoi sintomi cambiano o peggiorano, avvisa subito il personale in servizio.</p>
	</section>

	<section class="accessps-section">
		<h2>Cibo, bevande e fumo</h2>
		<p>Non mangiare né bere senza aver chiesto al medico o all’infermiere. Ricorda che alcuni esami richiedono il digiuno.</p>
	</section>

	<section class="accessps-section">
		<h2>I tuoi accompagnatori</h2>
		<p>Le persone che ti hanno accompagnato si trovano in sala d’attesa parenti.</p>
		<p>Per chiedere informazioni devono rivolgersi al:<br><strong>BOX ACCOGLIENZA PARENTI</strong></p>
		<p><strong>IMPORTANTE:</strong> gli orari di visita sono esposti all'entrata di ogni area del pronto soccorso e possono essere richiesti al <strong>BOX ACCOGLIENZA PARENTI.</strong></p>
		<div class="accessps-photo accessps-photo--fade"><img src="https://picsum.photos/760/360?random=44" alt=""></div>
	</section>

	<section class="accessps-section">
		<span class="accessps-inline-icon">[accessps_icon name="wifi"]</span>
		<h2>Connessione Wi-Fi</h2>
		<p>All'interno del pronto soccorso è presente una rete Wi-Fi a cui puoi collegarti durante l'attesa.</p>
	</section>

	<section class="accessps-section">
		<span class="accessps-inline-icon">[accessps_icon name="clipboard"]</span>
		<h2>Aiutaci a migliorare:</h2>
		<p>La tua opinione è importante.</p>
		<p><a class="accessps-button" href="https://forms.google.com/">Compila il questionario</a></p>
	</section>
</div>
HTML

IFS= read -r -d '' USCITA_CONTENT <<'HTML' || true
<div class="accessps-page accessps-content accessps-narrow">
	<section class="accessps-section">
		<h1 class="accessps-title">USCITA</h1>
		<p>Leggi sempre con attenzione la <strong>CARTELLA CLINICA</strong> che ti viene consegnata e se hai dubbi chiedi al personale. <strong>Dovrai controfirmare la cartella alla dimissione.</strong></p>
		<p>Qui di seguito trovi indicati i possibili esiti del tuo percorso.</p>
	</section>

	<section class="accessps-section">
		<h2>DIMISSIONE A DOMICILIO</h2>
		<p><strong>Se vieni dimesso a domicilio, puoi tornare a casa.</strong></p>
		<p>Le indicazioni da seguire sono nella sezione<br><strong>"NOTE E PRESCRIZIONI"</strong> della tua documentazione.<br>Qui trovi:</p>
		<div class="accessps-two-col">
			<ul>
				<li>i farmaci da assumere</li>
				<li>eventuali controlli da eseguire</li>
				<li>le indicazioni del medico</li>
			</ul>
			<span class="accessps-inline-icon">[accessps_icon name="document"]</span>
		</div>
		<p>Potrebbero essere presenti delle impegnative per farmaci o visite. Se presenti, recati in farmacia per i farmaci e in ambulatorio per la visita prescritta.</p>
		<p>Conserva sempre la documentazione rilasciata.</p>
		<p><strong>IMPORTANTE:</strong> se hai un medico di famiglia in Italia, consegnagli una copia della documentazione.</p>
	</section>

	<section class="accessps-section">
		<h2>DIMISSIONE A STRUTTURA AMBULATORIALE</h2>
		<p>Il giorno e l'orario della Visita Ambulatoriale sono nella sezione<br><strong>"NOTE E PRESCRIZIONI".</strong></p>
		<div class="accessps-two-col">
			<div>
				<p><strong>Devi presentarti portando:</strong></p>
				<ul>
					<li>tutta la tua documentazione clinica</li>
					<li>la cartella del pronto soccorso</li>
					<li>l'impegnativa per la visita consegnata al pronto soccorso</li>
				</ul>
			</div>
			<span class="accessps-inline-icon">[accessps_icon name="document"]</span>
		</div>
		<p>Per alcune prestazioni potrebbe essere richiesto il pagamento del ticket, alla cassa indicata dal personale.</p>
	</section>

	<section class="accessps-section">
		<h2>TRASFERIMENTO AD ALTRA AREA<br>DEL PRONTO SOCCORSO</h2>
		<p>In alcuni casi il tuo percorso continua all'interno del pronto soccorso.</p>
		<p><strong>OBI – Osservazione Breve Intensiva</strong></p>
		<p>Rimani in un'area dedicata dove potrai eseguire ulteriori indagini e/o terapie, per poi essere dimesso o, se necessario, ricoverato.</p>
		<div class="accessps-photo"><img src="https://picsum.photos/760/240?random=51" alt=""></div>
	</section>

	<section class="accessps-section">
		<span class="accessps-inline-icon">[accessps_icon name="bed"]</span>
		<h2>RICOVERO IN REPARTO OSPEDALIERO</h2>
		<p><strong>Se vieni ricoverato:</strong></p>
		<ul>
			<li>verrai trasferito in un reparto dell'ospedale</li>
			<li>da questo momento il tuo percorso prosegue fuori dal pronto soccorso</li>
			<li>gli orari di visita ti saranno forniti all'accesso in reparto</li>
		</ul>
		<h2>Certificato di malattia</h2>
		<p>Se hai bisogno di un certificato di malattia, comunicalo al medico prima della dimissione o del ricovero.</p>
	</section>

	<section class="accessps-section">
		<h2>PAGAMENTO TICKET PRONTO SOCCORSO</h2>
		<p>Il ticket è previsto per accessi non urgenti non seguiti da ricovero. Se non esente, l'utente paga la quota fissa e gli eventuali ticket per esami/prestazioni eseguiti.</p>
		<p>Rif. normativo: art. 1, comma 796, lett. p), L. 296/2006; DCA Regione Lazio n. 42/2008.</p>
		<span class="accessps-inline-icon">[accessps_icon name="ticket"]</span>
		<h2>PAGAMENTO TICKET FARMACI E VISITE</h2>
		<p>Se non hai un codice fiscale, la tessera TEAM o il tesserino STP, i farmaci e/o le visite specialistiche verranno prescritti su carta intestata e dovrai pagare la tariffa per intero, anche se avresti diritto all'esenzione.</p>
	</section>

	<section class="accessps-section">
		<span class="accessps-inline-icon">[accessps_icon name="clipboard"]</span>
		<h2>Aiutaci a migliorare:</h2>
		<p>La tua opinione è importante.</p>
		<p><a class="accessps-button" href="https://forms.google.com/">Compila il questionario</a></p>
	</section>
</div>
HTML

IFS= read -r -d '' POLICLINICO_CONTENT <<'HTML' || true
<div class="accessps-page">
	<section class="accessps-history-hero" style="background-image: url('https://picsum.photos/1000/620?random=61');">
		<h1>La storia del Policlinico Umberto I</h1>
	</section>

	<section class="accessps-history accessps-narrow">
		<div class="accessps-history-block">
			<div class="accessps-history-block__icon">[accessps_icon name="building"]</div>
			<div class="accessps-history-block__copy"><p><strong>Il Policlinico Umberto I</strong> è stato fondato a Roma nella seconda metà dell'Ottocento, in risposta all'esigenza di dotare la capitale del nuovo Regno d'Italia di un ospedale universitario capace di unire formazione medica, ricerca scientifica e cura dei pazienti in un'unica struttura organica. Il principale promotore del progetto fu <strong>Guido Baccelli</strong>, clinico della Sapienza e Ministro della Pubblica Istruzione, che dedicò decenni alla sua realizzazione, istituendo una commissione di illustri clinici e ottenendo i primi finanziamenti statali nel <strong>1881.</strong></p></div>
		</div>
		<div class="accessps-history-block">
			<div class="accessps-history-block__icon">[accessps_icon name="door"]</div>
			<div class="accessps-history-block__copy"><p>La prima pietra fu posata il <strong>19 gennaio 1888</strong> dal Re Umberto I e dalla Regina Margherita di Savoia, da cui l’ospedale prese il nome che porta ancora oggi. I lavori veri e propri, su progetto degli architetti Giulio Podesti e Filippo Laccetti, si protrassero per oltre un decennio. La solenne cerimonia di inaugurazione si tenne in <strong>Campidoglio il 18 gennaio 1903</strong>, alla presenza del Re Vittorio Emanuele III; l’inaugurazione ufficiale dell’intero complesso, in occasione del giubileo accademico di Baccelli, avvenne nell’<strong>aprile 1906.</strong></p></div>
		</div>
		<div class="accessps-history-block">
			<div class="accessps-history-block__icon">[accessps_icon name="hands"]</div>
			<div class="accessps-history-block__copy"><p>Fin dalla sua nascita il Policlinico si distinse come <strong>prototipo insuperato di ospedale a padiglioni</strong>, protagonista della svolta dell’architettura sanitaria che attraverso tutta l’Europa nella seconda metà dell’Ottocento. La struttura, con i suoi edifici distribuiti attorno a un nucleo centrale, conserva ancora oggi quella leggibilità storica e quella coerenza progettuale che ne hanno fatto un modello di riferimento.</p></div>
		</div>
		<div class="accessps-history-block">
			<div class="accessps-history-block__icon">[accessps_icon name="hospital"]</div>
			<div class="accessps-history-block__copy"><p>Nel corso dei decenni il Policlinico si è consolidato come <strong>struttura di riferimento</strong> per l’intero <strong>Centro Italia</strong>, strettamente integrato con la <strong>Facoltà di Medicina e Chirurgia della Sapienza</strong>. Oggi dispone di 1.235 posti letto organizzati in <strong>11 Dipartimenti Assistenziali Integrati</strong>, con specialità che coprono la quasi totalità delle discipline mediche e chirurgiche. Sul fronte dell’emergenza sono attivi <strong>5 Pronto Soccorso</strong>, di cui 3 interni e 2 esterni, tutti operativi 24 ore su 24, a testimonianza di una vocazione all’assistenza continua che attraversa tutta la storia dell’istituzione.</p></div>
		</div>

		<h2>LO SAPEVI CHE</h2>
		<ul>
			<li>Il complesso ospedaliero è composto da <strong>54 edifici</strong> distribuiti su circa 300.000 m²: 46 all'interno del cosiddetto “quadrilatero” — delimitato da viale Regina Elena, viale dell'Università, viale del Policlinico e via Lancisi — e 8 esterni. Una vera cittadella della medicina nel <strong>cuore di Roma.</strong></li>
			<li>Prima della costruzione del Policlinico, le cliniche della <strong>Facoltà di Medicina</strong> erano distribuite in cinque ospedali diversi della città, rendendo frammentata la formazione medica degli studenti. Il Policlinico nacque proprio per porre fine a questa dispersione.</li>
			<li>Alla posa della prima pietra, il <strong>19 gennaio 1888</strong>, Guido Baccelli pronunciò le parole che ancora oggi sintetizzano la vocazione del Policlinico e che sono ricordate da una targa all’interno della struttura: <strong>«Qui verranno i derelitti della fortuna a sentire i benefici effetti di quell’amplesso immortale che si daranno Carità e Scienza».</strong> Un impegno verso gli ultimi che attraversa, da allora, tutta la storia dell’istituzione.</li>
			<li>Il Policlinico Umberto I è oggi un’<strong>Azienda Ospedaliero-Universitaria</strong> strettamente integrata con la Sapienza, fondata nel 1303 da Papa Bonifacio VIII: due delle istituzioni più antiche e radicate di Roma collaborano così in un progetto comune di cura, ricerca e formazione.</li>
		</ul>

		<p class="accessps-back"><a class="accessps-button" href="/">Indietro</a></p>
	</section>
</div>
HTML

IFS= read -r -d '' SAPIENZA_CONTENT <<'HTML' || true
<div class="accessps-page">
	<section class="accessps-history-hero" style="background-image: url('https://picsum.photos/1000/620?random=62');">
		<h1>La storia dell’università di Roma La Sapienza</h1>
	</section>

	<section class="accessps-history accessps-narrow">
		<div class="accessps-history-block">
			<div class="accessps-history-block__icon">[accessps_icon name="building"]</div>
			<div class="accessps-history-block__copy"><p><strong>La Sapienza Università di Roma</strong> è una delle università più antiche d’Europa. Fondata nel 1303 da Papa Bonifacio VIII, nasce come luogo di studio, ricerca e formazione al servizio della città e della comunità.</p></div>
		</div>
		<div class="accessps-history-block">
			<div class="accessps-history-block__icon">[accessps_icon name="hospital"]</div>
			<div class="accessps-history-block__copy"><p>Nel corso dei secoli la Sapienza è cresciuta insieme a Roma, diventando un punto di riferimento nazionale e internazionale per la conoscenza scientifica, umanistica e medica.</p></div>
		</div>
		<div class="accessps-history-block">
			<div class="accessps-history-block__icon">[accessps_icon name="hands"]</div>
			<div class="accessps-history-block__copy"><p>Il legame tra università, cura e territorio è al centro della sua missione. Attraverso la didattica, la ricerca e la Terza Missione, la Sapienza promuove progetti capaci di creare valore pubblico e di rendere la conoscenza accessibile.</p></div>
		</div>
		<div class="accessps-history-block">
			<div class="accessps-history-block__icon">[accessps_icon name="document"]</div>
			<div class="accessps-history-block__copy"><p><strong>ACCESS PS</strong> nasce in questo contesto: un progetto pensato per accompagnare cittadini e pazienti nell’accesso al Pronto Soccorso, valorizzando il rapporto tra formazione, ricerca e assistenza.</p></div>
		</div>

		<h2>LO SAPEVI CHE</h2>
		<ul>
			<li>La Sapienza è stata fondata nel <strong>1303</strong> ed è oggi una delle più grandi università d’Europa.</li>
			<li>La sua storia è profondamente intrecciata con quella della città di Roma e delle sue istituzioni sanitarie.</li>
			<li>La Terza Missione sostiene il dialogo tra università e società, trasformando ricerca e competenze in strumenti utili per le persone.</li>
		</ul>

		<p class="accessps-back"><a class="accessps-button" href="/">Indietro</a></p>
	</section>
</div>
HTML

IFS= read -r -d '' STP_CONTENT <<'HTML' || true
<div class="accessps-page accessps-simple-page accessps-narrow">
	<section>
		<h1>STP</h1>
		<p>Pagina informativa STP in preparazione.</p>
		<p><a class="accessps-button" href="/dove-ti-trovi/">Indietro</a></p>
	</section>
</div>
HTML

main() {
	require_wp

	echo "Using WordPress path: $WP_PATH"

	local home_id landing_id arrivo_id visita_id uscita_id policlinico_id sapienza_id stp_id main_menu_id footer_menu_id

	wp_cli option update blogname "Access PS" >/dev/null
	wp_cli option update blogdescription "Progetto di Terza missione di Sapienza Università di Roma" >/dev/null

	if wp_cli theme is-installed "$THEME_SLUG" >/dev/null 2>&1; then
		wp_cli theme activate "$THEME_SLUG" >/dev/null
	fi

	home_id="$(upsert_page "Home" "home" "$HOME_CONTENT" 0)"
	landing_id="$(upsert_page "Dove ti trovi?" "dove-ti-trovi" "$LANDING_CONTENT" 10)"
	arrivo_id="$(upsert_page "Arrivo" "arrivo" "$ARRIVO_CONTENT" 20)"
	visita_id="$(upsert_page "Visita medica" "visita-medica" "$VISITA_CONTENT" 30)"
	uscita_id="$(upsert_page "Uscita" "uscita" "$USCITA_CONTENT" 40)"
	policlinico_id="$(upsert_page "La storia del Policlinico Umberto I" "la-storia-del-policlinico-umberto-i" "$POLICLINICO_CONTENT" 50)"
	sapienza_id="$(upsert_page "La storia dell’università di Roma La Sapienza" "la-storia-delluniversita-di-roma-la-sapienza" "$SAPIENZA_CONTENT" 60)"
	stp_id="$(upsert_page "STP" "stp" "$STP_CONTENT" 70)"

	wp_cli option update show_on_front page >/dev/null
	wp_cli option update page_on_front "$home_id" >/dev/null

	main_menu_id="$(ensure_menu "Main menu" "main-menu")"
	footer_menu_id="$(ensure_menu "Footer menu" "footer-menu")"

	ensure_menu_item "main-menu" "$policlinico_id" "La storia del Policlinico" 1
	ensure_menu_item "main-menu" "$sapienza_id" "La storia della Sapienza" 2
	ensure_menu_item "main-menu" "$stp_id" "STP" 3

	ensure_menu_item "footer-menu" "$policlinico_id" "La storia del Policlinico" 1
	ensure_menu_item "footer-menu" "$sapienza_id" "La storia della Sapienza" 2
	ensure_menu_item "footer-menu" "$stp_id" "STP" 3

	wp_cli menu location assign "$main_menu_id" primary >/dev/null
	wp_cli menu location assign "$footer_menu_id" footer >/dev/null

	echo "Site structure complete."
	echo "Home page ID: $home_id"
	echo "Landing page ID: $landing_id"
	echo "Arrivo page ID: $arrivo_id"
	echo "Visita medica page ID: $visita_id"
	echo "Uscita page ID: $uscita_id"
	echo "Policlinico history page ID: $policlinico_id"
	echo "Sapienza history page ID: $sapienza_id"
	echo "STP page ID: $stp_id"
	echo "Main menu ID: $main_menu_id"
	echo "Footer menu ID: $footer_menu_id"
}

main "$@"
