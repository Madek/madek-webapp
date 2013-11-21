/* To avoid CSS expressions while still supporting IE 7 and IE 6, use this script */
/* The script tag referring to this file must be placed before the ending body tag. */

/* Use conditional comments in order to target IE 7 and older:
	<!--[if lt IE 8]><!-->
	<script src="ie7/ie7.js"></script>
	<!--<![endif]-->
*/

(function() {
	function addIcon(el, entity) {
		var html = el.innerHTML;
		el.innerHTML = '<span style="font-family: \'madek-icon-font\'">' + entity + '</span>' + html;
	}
	var icons = {
		'icon-question-mark': '&#xe600;',
		'icon-question': '&#xe601;',
		'icon-nav-help': '&#xe601;',
		'icon-magnifier': '&#xe606;',
		'icon-lens': '&#xe607;',
		'icon-nav-search': '&#xe607;',
		'icon-lock': '&#xe60a;',
		'icon-cog': '&#xe60b;',
		'icon-eye': '&#xe60c;',
		'icon-upload': '&#xe60e;',
		'icon-dload': '&#xe60f;',
		'icon-power-off': '&#xe610;',
		'icon-clipboard': '&#xe612;',
		'icon-star': '&#xe614;',
		'icon-vis-graph': '&#xe618;',
		'icon-privacy-open': '&#xe619;',
		'icon-arrow-left': '&#xe602;',
		'icon-arrow-down': '&#xe603;',
		'icon-arrow-up': '&#xe604;',
		'icon-arrow-right': '&#xe605;',
		'icon-media-entry': '&#xe61e;',
		'icon-close': '&#xe625;',
		'icon-checkmark': '&#xe626;',
		'icon-pen': '&#xe628;',
		'icon-move': '&#xe621;',
		'icon-privacy-group-alt': '&#xe629;',
		'icon-privacy-private-alt': '&#xe62a;',
		'icon-privacy-group': '&#xe62c;',
		'icon-add-group': '&#xe623;',
		'icon-highlight': '&#xe608;',
		'icon-home': '&#xe624;',
		'icon-plus': '&#xe60d;',
		'icon-madek': '&#xe617;',
		'icon-checkbox': '&#xe62d;',
		'icon-checkbox-active': '&#xe62e;',
		'icon-bang': '&#xe616;',
		'icon-tag': '&#xe627;',
		'icon-vis-list': '&#xe61f;',
		'icon-vis-miniature': '&#xe620;',
		'icon-vis-grid': '&#xe622;',
		'icon-set': '&#xe615;',
		'icon-trash': '&#xe611;',
		'icon-admin': '&#xe613;',
		'icon-star-empty': '&#xe61a;',
		'icon-placeholder': '&#xe61b;',
		'icon-filter': '&#xe609;',
		'icon-cover': '&#xe61c;',
		'icon-plus-small': '&#xe62b;',
		'icon-privacy-private': '&#xe61d;',
		'icon-user': '&#xe61d;',
		'icon-man_silhouette': '&#xe61d;',
		'icon-add-user': '&#xe630;',
		'icon-question': '&#xe62f;',
		'icon-copy': '&#xe631;',
		'icon-applytoall': '&#xe631;',
		'0': 0
		},
		els = document.getElementsByTagName('*'),
		i, c, el;
	for (i = 0; ; i += 1) {
		el = els[i];
		if(!el) {
			break;
		}
		c = el.className;
		c = c.match(/icon-[^\s'"]+/);
		if (c && icons[c[0]]) {
			addIcon(el, icons[c[0]]);
		}
	}
}());
